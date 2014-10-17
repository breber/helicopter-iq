class Rand {
    static function next() {
        holdRand = holdRand * 214013 + 2531011;
        return ((holdRand >> 16) & 0x7fff);
    }

    static function nextInt(maxVal) {
        return next() % maxVal;
    }

    hidden static var holdRand = 0;
}
