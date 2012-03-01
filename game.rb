require 'rubygems'
require 'bundler/setup'

require 'eventmachine'

class Player
  attr_reader :health

  def initialize
    @health = rand(20..100)
  end
end

class Game
  attr_reader :player1, :player2

  def initialize(player1, player2)
    @player1, @player2 = player1, player2
  end

  def start
    until any_player_has_died
      move = next_player.prompt_for_move
    end
  end
end

module GameConnection
  def post_init
    send_data "DIE!\n"
  end

  def receive_data(data)
    puts "--> #{data}"
  end
end

EM.run {
  EM.start_server '127.0.0.1', 8081, GameConnection
  puts ">> Started on 127.0.0.1:8081"
}
