using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

const updateRate = 100;

var gameState = WAITING;
var player;

class HelicopterDelegate extends Ui.InputDelegate {
    function onTap() {
        // If we are waiting, the user has indicated they
        // want to start a game, so move to the starting state
        // and tell the UI to update
        if (gameState == WAITING) {
            gameState = STARTING;
            Ui.requestUpdate();
        } else if (gameState == STARTING) {
            // We shouldn't be in this state in the input delegate
        } else if (gameState == RUNNING) {
            // The game is running, so a call in the input delegate
            // means the user wants to float the pod up
            player.raise();
        } else if (gameState == FINISHED) {
            // If the game is over, a tap indicates they want to
            // start a new game, so move to the WAITING state
            gameState = WAITING;
            Ui.requestUpdate();
        }
    }

    function onHold() {
        // We only want to process hold events if the
        // game is currently running. If the game isn't running
        // they should just tap on the screen to perform their action
        if (gameState == RUNNING) {
            player.startRaise();
        }
    }

    function onRelease() {
        if (gameState == RUNNING) {
            player.stopRaise();
        }
    }
}

class HelicopterView extends Ui.View {
    var blocks = new [3];
    var height = 0;
    var width = 0;
    var timer = new Timer.Timer();

    function callback() {
        var blockSlideDistance = 5;

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

        // Update the player's position
        player.update();

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
        if (gameState == WAITING) {
            timer.stop();
            player = new Player(height / 2);

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
        dc.fillCircle(player.x, player.y, player.size);

        // If the user has clicked on the screen, but we haven't started
        // the processing on the view, start the timer
        if (gameState == STARTING) {
            timer.start(method(:callback), updateRate, true);
            gameState = RUNNING;
        }

        // If the bounds check fails, stop the timer and show
        // a game over screen
        if (!checkBounds()) {
            timer.stop();
            gameState = FINISHED;

            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.drawText((width / 2), (height / 2), Gfx.FONT_LARGE, "Game Over!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText((width / 2), (height / 2) + 20, Gfx.FONT_SMALL, "Tap screen to play again", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    function checkBounds() {
        // Check to make sure the current position doesn't overlap
        // with any of the blocks, or is off the edge
        var ok = true;

        // Verify not off the top/bottom
        ok = ok && ((player.y + player.size) < height);
        ok = ok && ((player.y - player.size) > 0);

        // Check all blocks for intersections
        for (var i = 0; i < blocks.size(); ++i) {
            ok = ok && !blocks[i].intersects(player.x, player.y, player.size);
        }

        return ok;
    }

    hidden function getBlockHeightAndYPosition() {
        // Create a random block height with a maximum height
        // being the screen height - 5 times the radius of the pod
        var blockHeight = Rand.nextInt(height - (5 * player.size));

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
