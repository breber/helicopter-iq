using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

var started = false;
var updateRate = 200;
var shapePositionX = 0;
var shapePositionY = 0;

class HelicopterDelegate extends Ui.InputDelegate {
    var timer = new Timer.Timer();

    function callback() {
        // On the first tap, start the game
        // All other taps are considered input to the
        // game, and we adjust the shape's Y position
        if (started) {
            shapePositionY -= 10;
        } else {
            started = true;
            Ui.requestUpdate();
        }
    }

    function onTap() {
        callback();
    }

    function onHold() {
        shapePositionY -= 5;
        timer.start(method(:callback), updateRate, true);
    }

    function onRelease() {
        timer.stop();
    }
}

class HelicopterView extends Ui.View {
    const shapeHeight = 5;
    var viewStarted = false;
    var blocks = new [3];
    var height = 0;
    var width = 0;
    var timer = new Timer.Timer();

    function onTimer() {
        // Slide the blocks over
        for (var i = 0; i < blocks.size(); ++i) {
            blocks[i].x = blocks[i].x - 5;

            if ((blocks[i].x + blocks[i].width) < 0) {
                var blockHeight = Rand.nextInt(height - (5 * shapeHeight));
                var yPos = Rand.nextInt(height - (blockHeight / 2));

                blocks[i] = new Block(blockHeight, width, yPos);
            }
        }

        // Slide the cursor down
        shapePositionY += 5;

        Ui.requestUpdate();
    }

    //! Update the view
    function onUpdate(dc) {
        height = dc.getHeight();
        width = dc.getWidth();

        // If we haven't started, set the initial position,
        // and create the initial blocks
        if (!started) {
            timer.stop();
            shapePositionX = 15;
            shapePositionY = height / 2;

            createBlocks();
        } else {
            if (started && !viewStarted) {
                timer.start(method(:onTimer), updateRate, true);
                viewStarted = true;
            }

            // Once we have started, check to make sure the current
            // position doesn't overlap with any of the blocks, or is
            // off the edge
            var ok = true;

            // Verify not off the top/bottom
            ok = ok && ((shapePositionY + (shapeHeight / 2)) < height);
            ok = ok && ((shapePositionY - (shapeHeight / 2)) > 0);

            // TODO: check all blocks

            if (!ok) {
                Sys.println("fail!");
                // TODO: show a fail box
                timer.stop();
            }
        }

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
            var blockHeight = Rand.nextInt(height - (5 * shapeHeight));
            var yPos = Rand.nextInt(height - (blockHeight / 2));

            blocks[i] = new Block(blockHeight, currentX, yPos);

            // Update the X position for the next block
            currentX += (3 * blocks[i].width);
        }
    }
}
