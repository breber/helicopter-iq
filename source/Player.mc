class Player {

    function initialize(aY) {
        y = aY;
    }

    function raise() {
        isRaisingTemp = true;
    }

    function startRaise() {
        isRaising = true;
    }

    function stopRaise() {
        isRaising = false;
    }

    function update() {
        if (isRaising || isRaisingTemp) {
            y -= yDelta;
            isRaisingTemp = false;
        } else {
            y += yDelta;
        }
    }

    var y = 0;
    static const x = 20;
    static const size = 5;
    static const yDelta = 5;
    hidden var isRaising = false;
    hidden var isRaisingTemp = false;
}