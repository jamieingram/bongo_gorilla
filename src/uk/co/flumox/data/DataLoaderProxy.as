package uk.co.flumox.data {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	/**
	 * A wrapper class to load external assets / url content
	 * 
	 * @author jamieingram
	 */
	public class DataLoaderProxy {
		
		public var errorSignal:Signal;
		public var completeSignal:Signal;
		//
		private var _id_str:String;
		private var _loader:Loader;
		private var _target_obj:Object;
		//
		private var _progressSignal:NativeSignal;
		private var _completeSignal:NativeSignal;
		private var _errorSignal:NativeSignal;

		public function DataLoaderProxy($id_str:String) {
			_id_str = $id_str;
			init();
		}
		//
		private function init():void {
			errorSignal = new Signal(String);
			completeSignal = new Signal(String,Object);
		}
		//
		public function loadURLContent($url_str:String,$params_obj:Object = null,$format_str:String = null):void {
			Debug.log("DataLoaderProxy.loadURLContent - " + $url_str);
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest($url_str);
			if ($format_str == null) $format_str = URLLoaderDataFormat.TEXT;
			if ($params_obj != null && $url_str.indexOf("http") != -1) {
				var variables:URLVariables = new URLVariables();
				for (var i:String in $params_obj) {
					variables[i] = $params_obj[i];
				}
				request.data = variables;
				request.method = URLRequestMethod.POST;
			}
			loader.dataFormat = $format_str;
			_completeSignal = new NativeSignal(loader,Event.COMPLETE);
			_errorSignal = new NativeSignal(loader,IOErrorEvent.IO_ERROR, IOErrorEvent);
			_completeSignal.addOnce(onLoadComplete);
			//
			try {
				loader.load(request);
			}catch ($error:Error) {
				Debug.log("DataLoaderProxy.loadURLContent : "+ $error.message);
				dispatchError();
			}
		}
		//
		public function loadContent($url_str:String):void {
			//Debug.log("DataLoaderProxy.loadContent - " + $url_str);
			_loader = new Loader();
			_completeSignal = new NativeSignal(_loader.contentLoaderInfo,Event.COMPLETE);
			_progressSignal = new NativeSignal(_loader.contentLoaderInfo,ProgressEvent.PROGRESS, ProgressEvent);
			_completeSignal.addOnce(onLoadComplete);
			_progressSignal.add(onLoadProgress);
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			//context.securityDomain = SecurityDomain.currentDomain;
			try {
				_loader.load(new URLRequest($url_str),context);
			}catch ($error:Error) {
				Debug.log("DataLoaderProxy.loadContent : "+ $error.message);
				dispatchError();
			}
		}
		//
		private function onLoadComplete($event:Event):void {
			_completeSignal.remove(onLoadComplete);
			_progressSignal.remove(onLoadProgress);
			_securityErrorSignal.remove(onSecurityError);
			_target_obj = $event.target;
			_loader = null;
			completeSignal.dispatch(_id_str,_target_obj);
		}
		//
		private function onLoadProgress($event:ProgressEvent):void {
			
		}
		//
		private function onLoadError($event:IOErrorEvent):void {
			//
			Debug.log("DataLoaderProxy.onLoadError : "+$event.text);
			dispatchError();
		}
		//
		private function onSecurityError($event:SecurityErrorEvent):void {
			Debug.log("DataLoaderProxy.onSecurityError : "+$event.text);
			dispatchError();
		}
		//
		private function dispatchError():void {
			_completeSignal.remove(onLoadComplete);
			_progressSignal.remove(onLoadProgress);
			_errorSignal.remove(onLoadError);
			_securityErrorSignal.remove(onSecurityError);
			errorSignal.dispatch(_id_str);
		}
		//
		public function get target():Object{return _target_obj;}
	}
}