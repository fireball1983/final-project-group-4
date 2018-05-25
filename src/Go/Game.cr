module Go
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

    class Game
        property size : Size
        property blackPass : String
        property whitePass : String
        property board  : Board
        property turn : Color
        property sockets : Array(HTTP::WebSocket)

        def initialize(size : Size, @blackPass, @whitePass)
            @size = size
            @board = Board.new
            @turn = Color::Black
            @sockets = [] of HTTP::WebSocket
        end

        private def cell_json(index, color, json)
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

        private def board_json(board, json)
            json.array do
                board.each do |key, value|
                    cell_json(key, value, json)
                end
            end
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
            @turn = @turn == Color::Black ? Color::White : Color::Black
        end

        private def color_char(color)
            color == Color::Black ? 'B' : 'W'
        end

        private def board_string(board)
            String.build do |str|
                (0...@size.value).each do |x|
                    (0...@size.value).each do |y|
                        color = @board[{x.to_i8, y.to_i8}]?
                        char = color ? color_char(color) : 'E'
                        str << char
                    end
                end
            end
        end

        def encode
            { @turn.to_s, @size.value, board_string(@board) }
        end
    end
end
