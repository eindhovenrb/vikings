require 'rubygems'
require 'bundler/setup'

require 'eventmachine'

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
