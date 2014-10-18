class Block {
    function initialize(aHeight, aX, aY) {
        height = aHeight;
        x = aX;
        y = aY;
    }

    function intersects(aX, aY, aSize) {
        var thisRight  = x + width;
        var thisLeft   = x;
        var thisTop    = y;
        var thisBottom = y + height;

        var otherRight  = aX + aSize;
        var otherLeft   = aX - aSize;
        var otherTop    = aY + aSize;
        var otherBottom = aY - aSize;

        return !((otherRight < thisLeft   ) ||
                 (thisRight  < otherLeft  ) ||
                 (otherTop   > thisBottom ) ||
                 (thisTop    > otherBottom));
    }

    const width = 20;
    var height  = 0;
    var x       = 0;
    var y       = 0;
}
