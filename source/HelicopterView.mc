using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

var started = false;
var gameOver = false;
var updateRate = 100;
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
        if (gameOver) {
            started = false;
            gameOver = false;
            Ui.requestUpdate();
        } else {
            callback();
        }
    }

    function onHold() {
        if (!gameOver) {
            shapePositionY -= 5;
            timer.start(method(:callback), updateRate, true);
        }
    }

    function onRelease() {
        timer.stop();
    }
}

class HelicopterView extends Ui.View {
    const shapeXPosition = 20;
    const shapeSize = 5;
    var viewStarted = false;
    var blocks = new [3];
    var height = 0;
    var width = 0;
    var timer = new Timer.Timer();

    function onTimer() {
        const blockSlideDistance = 5;

        // Slide the blocks over
        for (var i = 0; i < blocks.size(); ++i) {
            blocks[i].x = blocks[i].x - blockSlideDistance;

            // If the block is completely off the left side of
            // the screen, create a new block off the right side
            if ((blocks[i].x + blocks[i].width) < 0) {
                var result = getBlockHeightAndYPosition();
                blocks[i] = new Block(result["height"], width, result["yPos"]);
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

        // Clear the screen
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();

        // If we haven't started, set the initial position,
        // and create the initial blocks
        if (!started) {
            timer.stop();
            shapePositionY = height / 2;

            createBlocks();
        }

        // Draw the blocks
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < blocks.size(); ++i) {
            var block = blocks[i];
            dc.fillRectangle(block.x, block.y, block.width, block.height);
        }

        // Draw the player shape
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(shapeXPosition, shapePositionY, shapeSize);

        // If the user has clicked on the screen, but we haven't started
        // the processing on the view, start the timer
        if (started && !viewStarted) {
            timer.start(method(:onTimer), updateRate, true);
            viewStarted = true;
        }

        // If the bounds check fails, stop the timer and show
        // a game over screen
        if (!checkBounds()) {
            timer.stop();
            gameOver = true;

            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.drawText((width / 2), (height / 2), Gfx.FONT_LARGE, "Game Over!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText((width / 2), (height / 2) + 20, Gfx.FONT_SMALL, "Tap screen to play again", Gfx.TEXT_JUSTIFY_CENTER);

            started = false;
            viewStarted = false;
        }
    }

    function checkBounds() {
        // Check to make sure the current position doesn't overlap
        // with any of the blocks, or is off the edge
        var ok = true;

        // Verify not off the top/bottom
        ok = ok && ((shapePositionY + shapeSize) < height);
        ok = ok && ((shapePositionY - shapeSize) > 0);

        // Check all blocks for intersections
        for (var i = 0; i < blocks.size(); ++i) {
            ok = ok && !blocks[i].intersects(shapeXPosition, shapePositionY, shapeSize);
        }

        return ok;
    }

    hidden function getBlockHeightAndYPosition() {
        // Create a random block height with a maximum height
        // being the screen height - 5 times the radius of the pod
        var blockHeight = Rand.nextInt(height - (5 * shapeSize));

        // Choose a random Y position, keeping at least half the
        // block on the screen
        var yPos = Rand.nextInt(height - (blockHeight / 2));

        return { "height" => blockHeight, "yPos" => yPos };
    }

    hidden function createBlocks() {
        // Start the blocks out at halfway across the screen
        // so that we don't end up with a block right in front
        // of the user at the start of the game
        var currentX = width / 2;

        for (var i = 0; i < blocks.size(); ++i) {
            var result = getBlockHeightAndYPosition();

            blocks[i] = new Block(result["height"], currentX, result["yPos"]);

            // Update the X position for the next block
            currentX += (3 * blocks[i].width);
        }
    }
}
