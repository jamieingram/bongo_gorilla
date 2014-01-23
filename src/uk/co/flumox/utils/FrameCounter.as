package uk.co.flumox.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	//
	public class FrameCounter extends Sprite {
		
		private var _count_txt:TextField;
		private var _framesElapsed:Number;
		private var _timeElapsed:Number;
		private var _timer:Timer;
		private var _period:Number;
		private var _frameRate:Number;
		//
		public function FrameCounter(period:Number = 100) {
			_period = period;
			//
			init();
		}
		//
		private function init():void {
			//
			_count_txt = new TextField();
			_count_txt.type = TextFieldType.DYNAMIC;
			_count_txt.width = 100;
			_count_txt.height = 20;
			_count_txt.autoSize = TextFieldAutoSize.LEFT;
			//
			var count_tf:TextFormat = new TextFormat();
			count_tf.font = "_sans";
			count_tf.color = 0xFF0000;
			count_tf.size = 24;
			_count_txt.defaultTextFormat = count_tf;
			addChild(_count_txt);
			//
			_framesElapsed = 0;
			_frameRate = 0;
			_timeElapsed = 0;
			//
		}
		//
		public function start():void {
			_timer = new Timer(_period);
			_timer.addEventListener(TimerEvent.TIMER, checkFrameRate,false,0,true);
			_timer.start();
			//
			addEventListener(Event.ENTER_FRAME, changeFramesElapsed,false,0,true);
		}
		//
		public function stop():void {
			_timer.stop();
			removeEventListener(Event.ENTER_FRAME,changeFramesElapsed);
		}
		//
		private function changeFramesElapsed(event:Event):void {
			_framesElapsed++;
		}
		//
		private function checkFrameRate(event:Event):void {
			//
			var newTimeElapsed:Number = getTimer();
			//
			var diff:Number = newTimeElapsed - _timeElapsed;
			//
			var newFrameRate:Number = Math.round((1 / (diff / 1000)) * _framesElapsed);
			//take average of this and last value
			var averageRate:Number = Math.round((_frameRate + newFrameRate) / 2);
			//
			_frameRate = averageRate;
			//
			_count_txt.text = String(_frameRate);
			//
			_timeElapsed = newTimeElapsed;
			//
			_framesElapsed = 0;
		}
	}
}