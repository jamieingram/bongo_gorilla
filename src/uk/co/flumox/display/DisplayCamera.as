package uk.co.flumox.display {
    import flash.events.Event;
    import flash.media.Camera;
    import flash.media.Video;
    
    public class DisplayCamera extends Display {
        
        private var _video:Video;
        
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
            
        }
        //
        protected override function onAddedToStage($event:Event = null):void {
            _video.height = stage.stageHeight;
            _video.width = stage.stageWidth * 0.5;
            //flip the video
            _video.scaleX = -_video.scaleX;
            _video.x += _video.width;
        }
    }
}