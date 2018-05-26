/* Matthew Sessions
 * May 24, 2018
/

/* Number of rows and columns */
var rows = 7;
var cols = 7;
/* Only used to fill the grid */
var playSurface = document.getElementById("gameSurface");
/* Ajax requestor */
var xhr = new XMLHttpRequest();
/* Attach the player switching listeners */
document.getElementById("White").addEventListener("click",setColor);
document.getElementById("Black").addEventListener("click",setColor);
/* Fill grid surface with grids */
for(var x = 0; x < cols; x++){
    for (var y = 0; y < rows; y++) {
        var cross = document.createElement('div');
        cross.className = 'cross';
        cross.setAttribute('x', x);
        cross.setAttribute('y', y);
        playSurface.appendChild(cross);
        cross.addEventListener('click', gridClicked);
    }
}
/* Query server */
function query(request) {
    //    xhr.setRequestHeader('Content-Type', 'application/json');
    console.log('GET', `/?${request}`);
    xhr.open('GET', `/${request}`);
    xhr.send(null);
}
/* Animate chip placement on grid */
function chipAnimate(chip) {
    var frame = 1.0;
    function anime() {
        if (frame > 1.75) {
            clearInterval(id);
        }
        else {
            frame += .25;
            chip.style.transform = `scale(${frame})`;
        }
    }
    var id = setInterval(anime, 10);

}
/* Place piece by clicking on grid, as a listener */
function gridClicked() {
    console.log(this);
    if (this.childElementCount == 0) {
        var color = document.getElementById("cPick").value;
        if (color == 'White' || color == 'Black') {
            query(`move?playerID=${color}&x=${this.getAttribute("x")}&y=${this.getAttribute("y")}`);
            //var chip = document.createElement('div');
            //chip.className = `chip${color}`;
            //console.log(color);
            //this.appendChild(chip);
            //chipAnimate(chip);
        }
    }
}
/* Make editing text box faster */
function setColor() {
    document.getElementById("cPick").value = this.id;
}
/* playerID is either One or Two */
/* Function to be used later */
function setPoints(playerID, points) {
    var scoreBoard = document.getElementById(`player${playerID}Score`);
    scoreBoard.firstElementChild.textContent = points;
}
/* Function to be used later */
function placeChip(playerColor, x, y) {
    if (x < cols && y < rows) {
        var cross = document.getElementsByClassName("cross")[cols*x + y];
        if ((cross.childElementCount == 0)) {
            var chip = document.createElement('div');
            var color;
            //playerID == "One" ? color = "White" : color = "Black";
            chip.className = `chip${playerColor}`;
            console.log(color);
            cross.appendChild(chip);
            chipAnimate(chip);
        }
    }
}
function moveReceived(stat, playerColor, x, y){
    console.log("Writing Move");
    var statField = document.getElementById("statField");
    statField.textContent = stat;
    if(stat){
        placeChip(playerColor, x, y);
    }
}
function boardReceived(data){
    for(var x = 0; x < cols; x++){
        for(var y = 0; y < rows; y++){
            //console.log(data[2]);
            //console.log(data[y*rows + cols]);
            if(data[y*rows + x] == 'O'){
                console.log("white");
                placeChip("White", x, y);
            }
            else if(data[y*rows + x] == 'X'){
                placeChip("Black", x, y);
                console.log("black");
            }
        }
    }
}
setInterval(function () {
    query("getmoves");
}, 1000);

/* Handle response from server */
xhr.onreadystatechange = function () {
    if (xhr.readyState == XMLHttpRequest.DONE) {
        console.log(xhr.responseText);
        var data = JSON.parse(xhr.responseText);
        //console.log(xhr.textContent);
        //console.log(JSON.parse(xhr.responseText));
        if (typeof data.move != 'undefined') {
            console.log("Movdat");
            console.log(data);
        }
        if (typeof data.type != 'undefined') {
            if( data.type == "moveList"){
                console.log(JSON.parse(data.board));
                boardReceived(JSON.parse(data.board));
            }
            if (data.type == "moveResponse") {
                if ((typeof data.success != 'undefined') &&
                    (typeof data.playerC != 'undefined') &&
                    (typeof data.x != 'undefined') &&
                    (typeof data.y != 'undefined')) {
                    moveReceived(data.success, data.playerC, Number(data.x), Number(data.y));
                }
            }
        }
    }
}
