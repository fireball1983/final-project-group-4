require "./Go/*"
require "kemal"
require "json"

enum Color
    Black
    White
end

enum Size
    Small = 9,
    Medium = 13,
    Large = 19
end

alias Board = Hash(Tuple(Int8, Int8), Color)


def cell_json(index, color, json)
    json.object do
        json.field "index" do
            json.object do
                json.field "x", index[0]
                json.field "y", index[1]
            end
        end
        json.field "color", color.to_s
    end
end

def board_json(board, json)
    json.array do
        board.each do |key, value|
            cell_json(key, value, json)
        end
    end
end

class Game
    property size : Size
    property board  : Board
    property turn : Color
    property sockets : Array(HTTP::WebSocket)

    def initialize(size : Size)
        @size = size
        @board = Board.new
        @turn = Color::Black
        @sockets = [] of HTTP::WebSocket
    end

    def to_string
        JSON.build do |json|
            json.object do
                json.field "turn", @turn.to_s
                json.field "board" { board_json(@board, json) }
            end
        end
    end

    def update(x, y, color)
        @board[{x, y}] = color
    end
end

URL = "localhost"
GAME_CACHE = {} of Int64 => Game

def lookup_game(cache, id) : Game?
    return nil
end

def handle_message(id, game, socket, message)
    split_command = message.split(" ")
    command = split_command[0]
    if command == "place"
        x = split_command[1].to_i8
        y = split_command[2].to_i8
        color = split_command[3] == "Black" ? Color::Black : Color::White

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

GAME_CACHE[1_i64] = Game.new(Size::Small)

Kemal.run
