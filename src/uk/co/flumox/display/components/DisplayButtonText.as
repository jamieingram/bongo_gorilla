package uk.co.flumox.display.components {
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import uk.co.flumox.data.item.DataItemTextFieldSettings;
	import uk.co.flumox.display.Display;
	import uk.co.flumox.utils.Defines;
	import uk.co.flumox.utils.FontManager;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;

	/**
	 * Extension of the DisplayButton class to represent a button that is made
	 * up of just a text field. Includes rollover colour, with colour fade
	 * 
	 * @author jamieingram
	 */
	public class DisplayButtonText extends DisplayButton {
		protected var _textColour_num:Number;
		protected var _textColourOver_num:Number;
		protected var _title_txt:TextField;
		private var _titleLabel_mc:MovieClip;
		private var _back_mc:MovieClip;
		private var _text_str:String;
		private var _paddingLeft_int:int;
		private var _paddingRight_int:int;
		private var _fixedWidth_int:int;

		public function DisplayButtonText($button_mc:MovieClip, $id_str:String, $onStage_bool:Boolean = true, $paddingLeft_int:int = 0, $paddingRight_int:int = 0, $fixedWidth_int:int = 0) {
			super($button_mc, $id_str, $onStage_bool);
			_paddingLeft_int = $paddingLeft_int;
			_paddingRight_int = $paddingRight_int;
			_fixedWidth_int = $fixedWidth_int;
			init();
		}

		// 
		protected override function init():void {
			super.init();
			_titleLabel_mc = Display.GET_MOVIE(_button_mc, "titleLabel_mc",true);
			_title_txt = Display.GET_TEXTFIELD(_titleLabel_mc, "label_txt",true);
			// 
			_back_mc = GET_MOVIE(_button_mc, "back_mc", true);
			if (_back_mc != null) _back_mc.gotoAndStop(1);
			// 
			_textColour_num = Defines.COLOUR_WHITE;
			_textColourOver_num = Defines.COLOUR_WHITE;
			// 
			TweenPlugin.activate([TintPlugin]);
			// 
			_text_str = "";
		}

		// 
		public function setText($text_str:String, $style_str:String, $colourOver_num:Number = -1, $isHTML_boo:Boolean = false, $isMultiline_boo:Boolean = false):void {
			// 
			_text_str = $text_str;
			if ($colourOver_num != -1) _textColourOver_num = $colourOver_num;
			// 
			var settings:DataItemTextFieldSettings = new DataItemTextFieldSettings($style_str,$isMultiline_boo,$isHTML_boo);
			settings.isHTML_bool = $isHTML_boo;
			FontManager.GET_INSTANCE().setupText(_title_txt, $text_str, settings);
			_textColour_num = Number(_title_txt.getTextFormat().color);
			if ($colourOver_num == -1) _textColourOver_num = _textColour_num;
			//
			_titleLabel_mc.x = _paddingLeft_int;
			//
			if (_fixedWidth_int != 0) {
				_hitArea_mc.width = _fixedWidth_int;
				if (_back_mc != null) _back_mc.width = _fixedWidth_int;
			} else {
				_hitArea_mc.width = _title_txt.width + _paddingLeft_int + _paddingRight_int;
				//
				if (_back_mc != null) {
					_back_mc.width = Math.round(_hitArea_mc.width + 3 + _paddingRight_int);
				}
				//
				if (_back_mc != null) _hitArea_mc.height = _back_mc.height;
			}
		}
		//
		override public function activate():void {
			super.activate();
			if (_titleLabel_mc != null) _titleLabel_mc.alpha = 1;
		}
		//
		override public function deactivate():void {
			super.deactivate();
			_button_mc.alpha = 1;
			if (_titleLabel_mc != null) _titleLabel_mc.alpha = 0.5;
		}
		// 
		public function get titleHeight():Number {
			if (_title_txt != null) {
				return _title_txt.height;
			} else {
				return 0;
			}
		}

		// 
		public function set hitAreaHeight($height_num:Number):void {
			_hitArea_mc.height = $height_num;
		}

		// 
		protected override function onButtonRollOut($event:MouseEvent = null):void {
			super.onButtonRollOut($event);
			if (_showRollover_bool == true) {
				setTextColour(_textColour_num, 1, 0.1);
				if (_back_mc != null) _back_mc.gotoAndStop(1);
			}
		}

		// 
		protected override function onButtonRollOver($event:MouseEvent = null):void {
			super.onButtonRollOver($event);
			if (_showRollover_bool == true) {
				setTextColour(_textColourOver_num, 1);
				if (_back_mc != null && _back_mc.totalFrames > 1) _back_mc.gotoAndStop(2);
			}
		}

		// 
		public override function deselect():void {
			super.deselect();
			setTextColour(_textColour_num, 1, 0.1);
			if (_back_mc != null) _back_mc.gotoAndStop(1);
		}

		// 
		public override function select():void {
			super.select();
			setTextColour(_textColourOver_num, 1);
			if (_back_mc != null && _back_mc.totalFrames > 1) _back_mc.gotoAndStop(2);
		}

		// 
		public function setTextColour($colour_num:Number, $targetAlpha_num:Number = -1, $tweenSpeed_num:Number = 0.2):void {
			if (_titleLabel_mc != null) {
				TweenLite.killTweensOf(_titleLabel_mc);
				var params_obj:Object = {tint:$colour_num, ease:Quad.easeOut};
				if ($targetAlpha_num != -1) {
					params_obj["alpha"] = $targetAlpha_num;
				}
				TweenLite.to(_titleLabel_mc, $tweenSpeed_num, params_obj);
			}
		}

		// 
		public function set textColour_num($textColour_num:Number):void {
			_textColour_num = $textColour_num;
			setTextColour(_textColour_num, 1, 0.1);
		}

		// 
		public function set textColourOver_num($textColour_num:Number):void {
			_textColourOver_num = $textColour_num;
		}

		// 
		public function get textColour_num():Number {
			return _textColour_num;
		}

		// 
		public function get text_str():String {
			return _text_str;
		}

		// 
		public function get titleLabel_mc():MovieClip {
			return _titleLabel_mc;
		}
		//
		public function get title_txt():TextField {
			return _title_txt;
		}
		//
		public function get hitArea_mc():MovieClip {
			return _hitArea_mc;
		}
		//
		public function get back_mc():MovieClip {
			return _back_mc; 
		}
		public function set buttonWidth($buttonWidth_num:Number):void {
			_back_mc.width = _hitArea_mc.width = Math.round($buttonWidth_num);
			if (_back_mc.width > _titleLabel_mc.width) {
				_titleLabel_mc.x = (_back_mc.width - _titleLabel_mc.width) * 0.5;
			}
		}

		public function set buttonHeight($buttonHeight_num:Number):void {
			_back_mc.height = _hitArea_mc.height = $buttonHeight_num;
		}
		// 
		public override function get displayWidth():Number {
			return _hitArea_mc.width;
		}

		public function get paddingLeft_int():int {
			return _paddingLeft_int;
		}
		// 
	}
}
