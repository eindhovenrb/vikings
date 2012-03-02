    __     _____ _  _____ _   _  ____ 
    \ \   / /_ _| |/ /_ _| \ | |/ ___|
     \ \ / / | || ' / | ||  \| | |  _ 
      \ V /  | || . \ | || |\  | |_| |
       \_/  |___|_|\_\___|_| \_|\____|
                       T H E   G A M E

This is @avdgaag's and @ariejan's entry for Eindhoven.rb Hackathon,
march 2012.

Installation
------------

 * clone the repo
 * run `bundle install` to get gem dependencies
 * run `ruby game.rb` to start the server on 0.0.0.0:8081

Rules
-----

Players enter into an arena with 100 hitpoints. By issuing attack
commands you deal damage to other players.

When you kill a player, you score 1 point and the dead player is booted
from the server.

The goal is either to score the most points, or to survive as the "man
last standing".

Usage
-----

Anyone with a telnet client can connect to the server:

 `telnet server 8081`

You may then use the following commands:

 * `join <name>` to join the battle arena.
 * `look` to see who's in the arena with you
 * `attack <name>` to attack another player
 * `exit` to bugger off

Technology
----------

We use EventMachine for this project. Although we have nothing that does
I/O, we were able to quickly setup a TCP server that can handle lots of
concurrent connections.

Future
------

Probably none. But we might re-use this bit of spaghetti for
entertainment purposes.
