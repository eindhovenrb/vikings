require 'rubygems'
require 'bundler/setup'

require 'eventmachine'

class GameServer
  attr_accessor :connections
  attr_accessor :players

  def initialize
    @connections = []
    @players = []
  end

  def render_all(str)
    connections.each { |c| c.render str }
  end

  def deal_damage_to_player(attacker, player_name, points)
    target = players.find { |p| p.name == player_name.strip }
    if target
      died, blocked = target.take_damage(points)

      if !died
        if blocked == 0
          render_all "#{attacker.name} misses #{target.name} completely. Epic fail achieved."
        else
          render_all "#{target.name} blocks #{blocked} damage from #{attacker.name}"
          render_all "#{attacker.name} deals #{points} damage to #{target.name}"
          render_all "#{target.name} has #{target.health} health left."
        end
      else
        attacker.score!
      end
    else
      render_all "#{attacker.name} missed and made a fool of himself"
    end
  end

  def start
    @signature = EM.start_server('0.0.0.0', 8081, Connection) do |conn|
      conn.game = self
      @connections << conn
    end

    EM.add_periodic_timer(2) { puts "Connections: #{@connections.size}" }
  end

  def stop
    EM.stop_server(@signature)
  end
end

class Player
  attr_reader :name
  attr_accessor :connection
  attr_accessor :game
  attr_accessor :health
  attr_accessor :score

  def render(str)
    @connection.render(str)
  end

  def render_all(str)
    @connection.render_all(str)
  end

  def initialize(connection, game, name)
    @connection = connection
    @name = name
    @game = game
    @score = 0
    @health = 100

    @game.players << self

    joined
  end

  def attack(other_player)
    @game.deal_damage_to_player self, other_player, rand(10) + 1
  end

  def score!
    @score += 1
    render_all "++ #{name} has #{score} points ++"
  end

  def take_damage(points)
    defense = rand(points) + 1
    damage = points - defense

    @health -= damage

    if dead?
      render_all "#{name} died."
      disconnect!
    end

    return [dead?, damage]
  end

  def dead?
    @health <= 0
  end

  def exit
    render_all "#{name} gives up. Loser!"
    disconnect!
  end

  def disconnect!
    connection.close_connection(true)
  end

  def joined
    render_all "#{name} has joined the arena!"
  end
end

class Connection < EM::Connection
  attr_accessor :game

  def unbind
    game.connections.delete(self)
  end

  def render_all(str)
    game.render_all(str)
  end

  def render(str)
    send_data("> #{str}\r\n")
  end

  def receive_data(data)
    cmd, opt= data.strip.split(" ")

    render 'Provide a command and a name' unless opt

    case (cmd)
    when /join/i then
      if @player.nil?
        @player = Player.new(self, game, opt.strip)
      else
        render "You've already joined."
      end
    when /look/i then
      render @game.players.map(&:name).join(", ")
    when /attack/i then
      @player.attack(opt)
    when /exit/i then
      @player.exit
    else
      render "Don't know what you mean. Do you speak English?"
    end
  end

end

EM::run {
  s = GameServer.new
  s.start
  puts "Started server"
}
