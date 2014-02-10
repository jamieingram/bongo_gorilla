package uk.co.flumox.display {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.utils.Timer;
    
    import org.osflash.signals.Signal;
    
    import uk.co.flumox.data.DataConfigManager;
    import uk.co.flumox.utils.Defines;
    import uk.co.flumox.utils.SkinManager;
    
    public class DisplayCamera extends Display {
        
        public var positionSignal:Signal;
        //
        private var _timer:Timer;
        private var _video:Video;
        private var _crosshairs_mc:MovieClip;
        private var _sample_mc:MovieClip;
        
        public function DisplayCamera() {
            super();
            init();
        }
        //
        protected override function init():void {
            super.init();
            //
            positionSignal = new Signal(Number,Number);
            //
            _video = new Video(320,240);
            _video.smoothing = true;
            var camera:Camera = Camera.getCamera(); 
            camera.setMode(320,240,12);
            if (camera != null) {
                _video.attachCamera(camera);
            }
            addChild(_video);
            _crosshairs_mc = SkinManager.GET_INSTANCE().getMovieAsset("MovieClipCrossHairs");
            addChild(_crosshairs_mc);
            _crosshairs_mc.x = _crosshairs_mc.width * 0.5;
            //
            _sample_mc = SkinManager.GET_INSTANCE().getMovieAsset("MovieClipGorillaSample");
            _sample_mc.scaleX = _sample_mc.scaleY = 0.6;
            addChild(_sample_mc);
        }
        //
        protected override function onAddedToStage($event:Event = null):void {
            var width_int:int = DataConfigManager.GET_INSTANCE().getConfigInt(Defines.CONFIG_CAMERA_WIDTH);
            _video.width = width_int;
            _video.scaleY = _video.scaleX;
            //flip the video
            _video.scaleX = -_video.scaleX;
            _video.x += _video.width;
            //
            var interval_int:int = int(1000/stage.frameRate);
            _timer = new Timer(interval_int);
            _timer.addEventListener(TimerEvent.TIMER,onTimerEvent);
            _timer.start();
        }
        //
        private function onTimerEvent($event:TimerEvent):void {
            var x_pos:Number = Math.max(Math.min(1,(this.mouseX / _video.width)),0);
            var y_pos:Number = 0.5;
            _crosshairs_mc.x = Math.min(_video.width - (_crosshairs_mc.width * 0.5),Math.max(_crosshairs_mc.width * 0.5, _video.width * x_pos));
            _crosshairs_mc.y = Math.max(_crosshairs_mc.height * 0.5, _video.height * y_pos);
            positionSignal.dispatch(x_pos,y_pos);
        }
        //
        public function setCrossHairScale($scale_num:Number):void {
            _crosshairs_mc.scaleX = _crosshairs_mc.scaleY = $scale_num;
            if ($scale_num == 1) {
                _sample_mc.gotoAndStop(1);   
            }else if ($scale_num > 1) {
                _sample_mc.gotoAndStop(2);   
            }else{
                _sample_mc.gotoAndStop(3);
            }
            
        }
    }
}