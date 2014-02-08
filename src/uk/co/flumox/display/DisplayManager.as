﻿package uk.co.flumox.display {	import com.carlcalderon.arthropod.Debug;	import com.greensock.easing.Quad;	import com.greensock.plugins.AutoAlphaPlugin;	import com.greensock.plugins.TweenPlugin;		import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.StageAlign;	import flash.display.StageDisplayState;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.geom.Matrix;	import flash.geom.Rectangle;	import flash.media.Microphone;	import flash.ui.Keyboard;	import flash.utils.Dictionary;		import uk.co.flumox.data.DataConfigManager;	import uk.co.flumox.utils.Defines;	import uk.co.flumox.utils.FrameCounter;	/**	 * @author jamieingram	 */	public class DisplayManager extends Display {				private var _navigateTo_str:String;        private var _gorilla:DisplayGorilla;        private var _camera:DisplayCamera;        private var _frameCounter:FrameCounter;        private var _keys:Dictionary;        //        private var _copy_matrix:Matrix;        private var _copy_bmd:BitmapData;				public function DisplayManager() {			super();			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);		}		//		protected function onAdded($event:Event = null):void {			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;			init();		}		//		protected override function init():void {			super.init();            //            _keys = new Dictionary();            //            stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);            stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);            //            TweenPlugin.activate([AutoAlphaPlugin]);		}		//		public function initAfterAssetsLoad():void {			Debug.log("DisplayManager.initAfterAssetsLoad");            //			_gorilla = new DisplayGorilla();            _gorilla.x = DataConfigManager.GET_INSTANCE().getConfigNumber(Defines.CONFIG_GORILLA_X);            _gorilla.y = DataConfigManager.GET_INSTANCE().getConfigNumber(Defines.CONFIG_GORILLA_Y);            addChild(_gorilla);            //                        _camera = new DisplayCamera();            addChild(_camera);            _camera.x = DataConfigManager.GET_INSTANCE().getConfigNumber(Defines.CONFIG_CAMERA_X);            _camera.y = DataConfigManager.GET_INSTANCE().getConfigNumber(Defines.CONFIG_CAMERA_Y);            _camera.positionSignal.add(onCursorPositionUpdated);            //            var scale_num:Number = _gorilla.getScale();            var factor_num:Number = 0.15;            scale_num *= factor_num;            _copy_bmd = new BitmapData(_gorilla.mask_mc.width * scale_num, _gorilla.mask_mc.height * scale_num,false,0xFF0000);            var copy_bm:Bitmap = new Bitmap(_copy_bmd);            _camera.addChild(copy_bm);            //            _copy_matrix = new Matrix();            _copy_matrix.scale(factor_num,factor_num);                //            if (DataConfigManager.GET_INSTANCE().getConfigBool(Defines.CONFIG_DEBUG_ENABLED)) {                _frameCounter = new FrameCounter();                addChild(_frameCounter);                _frameCounter.start();            }            //		}		//		public function navigateTo($navigateTo_str:String):void {						Debug.log("DisplayManager.navigateTo()" + $navigateTo_str);			//Debug.log("DisplayManager.navigateTo(): "+$navigateTo_str);			//			_navigateTo_str = $navigateTo_str;		}		//        private function onCursorPositionUpdated($x:Number,$y:Number):void {            _copy_bmd.draw(_gorilla,_copy_matrix);            _gorilla.updatePosition($x,$y);        }        //        private function onStageKeyDown($event:KeyboardEvent):void {            if (_gorilla == null) return;            if (_keys[$event.charCode] != true) {                _keys[$event.charCode] = true;                if ($event.charCode == Defines.LETTER_A || $event.charCode == Keyboard.SPACE) {                    _gorilla.setAnimState("down", 0.4, false, Quad.easeOut);                }            }        }        //        private function onStageKeyUp($event:KeyboardEvent):void {            if (_gorilla == null) return;            if (_keys[$event.charCode] == true) {                if (_gorilla.currentAnim_str != "idle") {                    _gorilla.resetAnim();                }                _keys[$event.charCode] = false;            }            //            /*            if ($event.charCode == Keyboard.SPACE) {                if (_gorilla != null) {                    _gorilla.destroy();                    removeChild(_gorilla);                    _gorilla = null;                }else{                    _gorilla = new DisplayGorilla();                    addChild(_gorilla);                }            }            */        }        //	}}