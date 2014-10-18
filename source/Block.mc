class Block {
    function initialize(aHeight, aX, aY) {
        height = aHeight;
        x = aX;
        y = aY;
    }

    function intersects(aX, aY, aSize) {
        var thisRight = x + width;
        var thisLeft = x;
        var thisTop = y;
        var thisBottom = y + height;

        var otherRight = aX + (aSize / 2);
        var otherLeft = aX - (aSize / 2);
        var otherTop = aY + (aSize / 2);
        var otherBottom = aY - (aSize / 2);

        return !((otherRight < thisLeft) ||
                 (thisRight < otherLeft) ||
                 (otherTop > thisBottom) ||
                 (thisTop > otherBottom));
    }

    const width = 20;
    var height  = 0;
    var x       = 0;
    var y       = 0;
}
