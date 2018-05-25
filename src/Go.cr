require "./Go/*"
require "kemal"
require "json"

URL = "localhost"
GAME_CACHE = {} of Int64 => Go::Game

def lookup_game(cache, id) : Go::Game?
    return nil
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
    if game_id = env.params.url["id"].to_i64?
        if game = (GAME_CACHE[game_id]? || lookup_game(GAME_CACHE, game_id))
            black = true
            id = game_id
            size = game.size.value
            render "src/Go/views/game.ecr"
        else
            render_404
        end
    else
        render_404
    end
end

ws "/game/:id" do |socket, env|
    if game_id = env.params.url["id"].to_i64?
        if game = (GAME_CACHE[game_id]? || lookup_game(GAME_CACHE, game_id))
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
    else
        render_404
    end
end

GAME_CACHE[1_i64] = Go::Game.new(Go::Size::Small)

Kemal.run
