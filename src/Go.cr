require "./Go/*"
require "kemal"
require "json"

URL = "localhost"
GAME_CACHE = {} of String => Go::Game

def query_game(db, id) : Go::Game?
    return nil
end

def lookup_game(db, cache, id) : Go::Game?
    if game = cache[id]?
        return game
    else
        loaded_game = query_game(db, id)
        cache[id] = loaded_game if loaded_game
        return loaded_game
    end
end

def handle_message(id, game, socket, message)
    split_command = message.split(" ")
    command = split_command[0]
    if command == "place"
        x = split_command[1].to_i8
        y = split_command[2].to_i8
        color = split_command[3] == "Black" ? Go::Color::Black : Go::Color::White

        game.update(x, y, color)
        game.sockets.each { |socket| socket.send game.to_string }
    end
end

get "/" do |env|
    "Hello!"
end

get "/game/:id" do |env|
    game_id = env.params.url["id"]
    game_password = env.params.query["password"]?
    if game = lookup_game(nil, GAME_CACHE, game_id)
        id = game_id
        size = game.size.value
        black = nil

        if game_password == game.blackPass
            black = true
        elsif game_password == game.whitePass
            black = false
        end

        black.try { |black| render "src/Go/views/game.ecr", "src/Go/views/base.ecr"} || render_404
    else
        render_404
    end
end

ws "/game/:id" do |socket, env|
    game_id = env.params.url["id"]
    if game = lookup_game(nil, GAME_CACHE, game_id)
        socket.send game.to_string
        game.sockets << socket

        socket.on_message do |message|
            game.try { |game| handle_message(game_id, game, socket, message) }
        end

        socket.on_close do 
            game.try { |game| game.sockets.delete socket }
        end
    else
        render_404
    end
end

GAME_CACHE["debug"] = Go::Game.new(Go::Size::Small, "black", "white")

Kemal.run
