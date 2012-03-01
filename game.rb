require 'rubygems'
require 'bundler/setup'
require 'socket'

require 'eventmachine'

class GloriousDeath < StandardError
end

class Player
  attr_reader :health

  attr_reader :attack_power

  def initialize
    @health = rand(100) + 20
  end

  def dead?
    health <= 0
  end

  def attack_power
    rand(10) + 3
  end

  def defense_power
    rand(3) + 1
  end

  def damage(power)
    @health -= [power - defense_power, 0].max
    raise GloriousDeath if dead?
  end

  def heal
    @health += 10
  end
end

class AiPlayer < Player

end

class Game
  attr_reader :player1, :player2
  attr_reader :attacker, :defender

  def initialize(player1, player2)
    @player1, @player2 = player1, player2
    @attacker, @defender = @player1, @player2
  end

  def process_input(peer, data)
    port, ip = Socket.unpack_sockaddr_in(peer)
    puts "peer: #{ip}:#{port}"
    case data
    when /attack/i then
      @defender.damage @attacker.attack_power
    when /heal/i then
      @attacker.heal
    else
    end

    render_score
  rescue GloriousDeath
    return :death
  end

  def render_score
    "Score #{@player1.health} vs. #{@player2.health}"
  end

  def any_player_has_died?
    player1.dead? || player2.dead?
  end
end

module GameConnection
  def send_string(str)
    send_data("#{str}\r\n")
  end

  def post_init
    send_string("Welcome to V I K I N G")
    @player = Player.new
    @ai = AiPlayer.new
    @game = Game.new(@player, @ai)
  end

  def receive_data(data)
    result = @game.process_input(get_peername, data)

    if result == :death
      send_string "The defender died. YOU WIN AN EPIC VICTORY!"
      close_connection
    end

    send_string result
  end
end

EM.run {
  EM.start_server '127.0.0.1', 8081, GameConnection
  puts ">> Started on 127.0.0.1:8081"
}
