require "./Go/*"
require "kemal"

# TODO: Write documentation for `Go`
module Go
  # TODO: Put your code here
end

URL = "localhost"

get "/" do |env|
    black = true
    id = 1
    size = 9
    render "src/Go/views/game.ecr"
end

Kemal.run
