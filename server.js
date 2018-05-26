var path = require('path');
var express = require('express');

var app = express();
var port = process.env.PORT || 3000;

app.use(express.static('public'));

var grid = [];
for(var i =0 ;i < 49; i++){
    grid[i] = '.';
}
function sendBoard(res) {
    var moveResponse = {
        "type": "moveList",
        "board": JSON.stringify(grid)
    };
    //console.log(JSON.stringify(grid));
    res.send(JSON.stringify(moveResponse));
}

function print_board() {
    var buff = "";
    for (var i = 0; i < 7; i++) {
        for (var j = 0; j < 7; j++) {
            buff += grid[7 * j + i] + ' ';
        }
        console.log(buff);
        buff = "";
    }
}

app.get('/getmoves', function (req, res) {
    sendBoard(res);
});
app.get('/move', function (req, res) {
    var query = req.query;
    var moveResponse = {
        "type": "moveResponse",
        "success": false,
        "playerC": 'none',
        "x": 0,
        "y": 0
    };
    console.log(query);
    if (typeof query.playerID != 'undefined' &&
        typeof query.x != 'undefined' &&
        typeof query.y != 'undefined' &&
        grid[7 * Number(query.y) + Number(query.x)] == '.') {
        if (query.playerID == "White") {
            grid[7 * Number(query.y) + Number(query.x)] = 'O';
        }
        else if (query.playerID == "Black") {
            grid[7 * Number(query.y) + Number(query.x)] = 'X';
        }
        moveResponse.x = Number(query.x);
        moveResponse.y = Number(query.y);
        moveResponse.success = true;
        moveResponse.playerC = query.playerID;
    }
    console.log("Move res", JSON.stringify(moveResponse));
    res.send(JSON.stringify(moveResponse));
    print_board();
});


app.get('/client.js', function (req, res) {
    res.sendFile(path.join(__dirname, '', 'client.js'));
});
app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, '', 'index.html'));
});
app.get('/index.html', function (req, res) {
    res.sendFile(path.join(__dirname, '', 'index.html'));
});
app.get('/style.css', function (req, res) {
    res.sendFile(path.join(__dirname, '', 'style.css'));
});
app.get('/cross.svg', function (req, res) {
    res.sendFile(path.join(__dirname, '', 'cross.svg'));
});
app.get('*', function (req, res) {
    //res.write("None");
    //res.end();
    //res.status(404).sendFile(path.join(__dirname, '', '404.html'));
});

app.listen(port, function () {
    console.log("== Server is listening on port", port);
});
