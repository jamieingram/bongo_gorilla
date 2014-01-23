package uk.co.flumox.display.components {
	import com.carlcalderon.arthropod.Debug;
	import uk.co.flumox.display.Display;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	/**
	 * Generic class that represents any button.
	 * Each button has a unique id that is dispatched in an event when it is clicked
	 * class includes tab indexing and default sounds, as well as onReleaseOutside
	 * 
	 * @author jamieingram
	 */
	public class DisplayButton extends Display {
		
		public var clickSignal:Signal;		public var pressSignal:Signal;		public var releaseSignal:Signal;
		public var rollOutSignal:Signal;		public var rollOverSignal:Signal;
		//
		protected var _button_mc:MovieClip;
		protected var _hitArea_mc:MovieClip;
		protected var _isPressed_bool:Boolean;
		protected var _id_str:String;
		protected var _showRollover_bool:Boolean;
		protected var _clickEnabled_bool:Boolean;
		//
		private var _disabled_bool:Boolean;
		private var _onStage_bool:Boolean;
		private var _selected_bool:Boolean;

		//
		public function DisplayButton($button_mc:MovieClip,$id_str:String,$onStage_bool:Boolean = false) {
			super();
			_button_mc = $button_mc;
			_id_str = $id_str;
			_onStage_bool = $onStage_bool;
			init();
		}

		//
		protected override function init():void {
			super.init();
			//
			if (_button_mc != null) {
				if (_onStage_bool == false) {
					addChild(_button_mc);
				}
				//
				_button_mc.tabChildren = false;
				_hitArea_mc = Display.GET_MOVIE(_button_mc, "hitArea_mc");
				activate();
				//
				_button_mc.gotoAndStop(1);
				//
			}else{
				Debug.log("DisplayButton.init : button_mc is null");
			}
			clickSignal = new Signal(String);			pressSignal = new Signal(String);			releaseSignal = new Signal();
			rollOverSignal = new Signal(DisplayButton);			rollOutSignal = new Signal(DisplayButton);
			//
			_isPressed_bool = _disabled_bool = _selected_bool = false;
			_showRollover_bool = true;
			_clickEnabled_bool = true;
			//
		}
		//
		public function set isTabEnabled_bool($tabEnabled:Boolean):void {
			if (_hitArea_mc != null) _hitArea_mc.tabEnabled = $tabEnabled;
		}
		//
		public function set tabIndex_int($index_int:int):void {
			_button_mc.tabIndex = $index_int;
		}
		//
		public function disable():void {
			_disabled_bool = true;
			deactivate();
		}
		//
		public function enable():void {
			_disabled_bool = false;
			activate();
		}
		//
		public override function hide():void {
			super.hide();
			if (_onStage_bool == true && _button_mc != null) _button_mc.visible = false;
		}

		//
		public override function show():void {
			super.show();
			if (_onStage_bool == true && _button_mc != null) _button_mc.visible = true;
		}
		//
		public function click():void {
			onButtonClick();
		}
		//
		protected function onButtonRollOut($event:MouseEvent = null):void {
			if ($event != null) $event.stopImmediatePropagation();
			_isPressed_bool = false;
			if (_button_mc.totalFrames > 1 && _showRollover_bool == true) {
				if (_selected_bool == true) {
					_button_mc.gotoAndStop(3);
				}else{
					_button_mc.gotoAndStop(1);
				}
			}
			rollOutSignal.dispatch(this);
		}
		//
		protected function onButtonRollOver($event:MouseEvent = null):void {
			if ($event != null) $event.stopImmediatePropagation();
			if (_button_mc.totalFrames > 1 && _isPressed_bool == false && _showRollover_bool == true) {
				_button_mc.gotoAndStop(2);
			}
			rollOverSignal.dispatch(this);
		}

		//
		protected function onButtonClick($event:MouseEvent = null):void {
			if (_clickEnabled_bool == false) return;
			if ($event != null) $event.stopImmediatePropagation();
			if (_showRollover_bool == true) _button_mc.gotoAndStop(1);
			clickSignal.dispatch(_id_str);
		}
		//
		protected function onButtonMouseDown($event:MouseEvent):void {
			if ($event != null) $event.stopImmediatePropagation();
			_isPressed_bool = true;
			pressSignal.dispatch(_id_str);
			if (_hitArea_mc.stage != null) _hitArea_mc.stage.addEventListener(MouseEvent.MOUSE_UP,onButtonMouseUp);
			if (_button_mc.totalFrames == 3 && _showRollover_bool == true) _button_mc.gotoAndStop(3);
			//
		}
		//
		protected function onButtonMouseUp($event:MouseEvent):void {
			_isPressed_bool = false;
			releaseSignal.dispatch();
			if (_hitArea_mc.stage != null) _hitArea_mc.stage.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp);
			if (_button_mc.totalFrames > 1 && _showRollover_bool == true) _button_mc.gotoAndStop(1);
		}
		//
		override public function activate():void {
			_button_mc.alpha = 1;
			if (_hitArea_mc != null && _disabled_bool != true) {
				_hitArea_mc.buttonMode = true;
				//
				addListeners();			}
		}
		//
		override public function deactivate():void {
			_button_mc.alpha = 0.7;
			if (_hitArea_mc != null) {
				_hitArea_mc.buttonMode = false;
				_hitArea_mc.mouseChildren = false;
				//
				removeListeners();
			}
		}
		//
		private function addListeners():void {
			_hitArea_mc.addEventListener(MouseEvent.ROLL_OVER,onButtonRollOver);
			_hitArea_mc.addEventListener(MouseEvent.ROLL_OUT,onButtonRollOut);			_hitArea_mc.addEventListener(MouseEvent.CLICK, onButtonClick);
			_hitArea_mc.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown);
		}
		//
		private function removeListeners():void {
			_hitArea_mc.removeEventListener(MouseEvent.ROLL_OVER,onButtonRollOver);
			_hitArea_mc.removeEventListener(MouseEvent.ROLL_OUT,onButtonRollOut);
			_hitArea_mc.removeEventListener(MouseEvent.CLICK, onButtonClick);
			_hitArea_mc.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown);
		}
		//
		public function select():void {
			_button_mc.alpha = 1;
			if (_button_mc.totalFrames > 2) _button_mc.gotoAndStop(3);
			_selected_bool = true;
			if (_hitArea_mc != null) {
				_hitArea_mc.buttonMode = false;
				_hitArea_mc.mouseChildren = false;
				//
				removeListeners();
			}
		}
		//
		public function deselect():void {
			//_button_mc.alpha = 0.7;
			_selected_bool = false;
			_button_mc.gotoAndStop(1);
			if (_hitArea_mc != null && _disabled_bool != true) {
				_hitArea_mc.buttonMode = true;
				//
				addListeners();
			}
		}

		//
		public function set id_str($id_str:String):void {_id_str = $id_str;} 
		public function get id_str():String {return _id_str;}

		public function get button_mc():MovieClip {
			return _button_mc;
		}

		public function set clickEnabled_bool($enabled_bool:Boolean):void {
			_clickEnabled_bool = $enabled_bool;
			if (_clickEnabled_bool == false) {
				_hitArea_mc.buttonMode = false;
			}else{
				_hitArea_mc.buttonMode = true;
			}
		}

		// 
		public function set showRollover_bool($showRollover_bool:Boolean):void {
			_showRollover_bool = $showRollover_bool;
		}
		//		public function get selected_bool():Boolean {return _selected_bool;}
	}
}
