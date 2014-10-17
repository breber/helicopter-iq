using Toybox.Application as App;

class HelicopterApp extends App.AppBase {
    function getInitialView() {
        return [ new HelicopterView(), new HelicopterDelegate() ];
    }
}
