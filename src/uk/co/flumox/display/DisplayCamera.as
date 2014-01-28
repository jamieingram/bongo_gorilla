package uk.co.flumox.display {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.media.Camera;
    import flash.media.Video;
    
    import uk.co.flumox.data.DataConfigManager;
    import uk.co.flumox.utils.Defines;
    import uk.co.flumox.utils.SkinManager;
    
    public class DisplayCamera extends Display {
        
        private var _video:Video;
        private var _crosshairs_mc:MovieClip;
        
        public function DisplayCamera() {
            super();
            init();
        }
        //
        protected override function init():void {
            super.init();
            _video = new Video(320,240);
            _video.smoothing = true;
            var camera:Camera = Camera.getCamera(); 
            if (camera != null) { 
                _video.attachCamera(camera);
            }
            addChild(_video);
            _crosshairs_mc = SkinManager.GET_INSTANCE().getMovieAsset("MovieClipCrossHairs");
            addChild(_crosshairs_mc);
            _crosshairs_mc.x = _crosshairs_mc.width * 0.5;
            _crosshairs_mc.y = Defines.FULL_HEIGHT_INT * 0.5;
        }
        //
        protected override function onAddedToStage($event:Event = null):void {
            var height_int:int = DataConfigManager.GET_INSTANCE().getConfigInt(Defines.CONFIG_FULL_HEIGHT);
            if  (height_int == 0) height_int = Defines.FULL_HEIGHT_INT;
            var width_int:int = DataConfigManager.GET_INSTANCE().getConfigInt(Defines.CONFIG_FULL_WIDTH);
            if  (width_int == 0) width_int = Defines.FULL_WIDTH_INT;
            _video.height = height_int;
            _video.width = width_int * 0.5;
            //flip the video
            _video.scaleX = -_video.scaleX;
            _video.x += _video.width;
        }
        //
        public function updatePosition($x:Number, $y:Number):void {
            _crosshairs_mc.x = Math.min(_video.width - (_crosshairs_mc.width * 0.5),Math.max(_crosshairs_mc.width * 0.5, _video.width * $x));
            _crosshairs_mc.y = Math.max(_crosshairs_mc.height * 0.5, _video.height * $y);
        }
        //
    }
}