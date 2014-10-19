using Toybox.Math;

class Rand {
    static function next() {
        if (!initialized) {
            Math.srand(0);
            initialized = true;
        }

        return Math.rand();
    }

    static function nextInt(maxVal) {
        return next() % maxVal;
    }

    hidden static var initialized = false;
}
