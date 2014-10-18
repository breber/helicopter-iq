using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Timer as Timer;

var started = false;
var shapePositionX = 0;
var shapePositionY = 0;

class HelicopterDelegate extends Ui.InputDelegate {
    function onTap() {
        // On the first tap, start the game
        // All other taps are considered input to the
        // game, and we adjust the shape's Y position
        if (started) {
            shapePositionY -= 10;
        } else {
            started = true;
        }

        Ui.requestUpdate();
    }
}

class HelicopterView extends Ui.View {
    var blocks = new [3];
    const shapeHeight = 5;
    var height = 0;
    var width = 0;
    var timer = new Timer();

    //! Update the view
    function onUpdate(dc) {
        Sys.println( "onUpdate" );
        height = dc.getHeight();
        width = dc.getWidth();

        // If we haven't started, set the initial position,
        // and create the initial blocks
        if (!started) {
            shapePositionX = 10;
            shapePositionY = height / 2;

            createBlocks();
        } else {
            // Once we have started, check to make sure the current
            // position doesn't overlap with any of the blocks, or is
            // off the edge
            var ok = true;

            // Verify not off the top/bottom
            ok = ok && ((shapePositionY + (shapeHeight / 2)) < height);
            ok = ok && ((shapePositionY - (shapeHeight / 2)) > 0);

            for (var i = 0; i < blocks.size(); ++i) {
                ok = ok && blocks[i].contains();
            }

            if (!ok) {
                Sys.println( "fail!" );
                // TODO: show a fail box
            }
        }

        //updateBlocks();

        // Clear the screen
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();

        // Draw the helecopter shape
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(shapePositionX, shapePositionY, shapeHeight);

        // Draw the blocks
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < blocks.size(); ++i) {
            var block = blocks[i];

            dc.fillRectangle(block.x, block.y, block.width, block.height);
        }
    }

    function createBlocks() {
        var currentX = 35;

        for (var i = 0; i < blocks.size(); ++i) {
            var blockHeight = Rand.nextInt(height - (4 * shapeHeight));
            var yPos = Rand.nextInt(height - (blockHeight / 2));

            blocks[i] = new Block(blockHeight, currentX, yPos);

            // Update the X position for the next block
            currentX += (3 * blocks[i].width);
        }
    }
}
