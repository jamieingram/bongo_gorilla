package uk.co.flumox.utils {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	
	import org.osflash.signals.Signal;
	
	import uk.co.flumox.data.DataConfigManager;

	/**
	 * A class to handle the loading and retrieval of assets in skin swf files
	 * 
	 * @author jamieingram
	 */
	public class SkinManager {
		public var itemLoadedSignal:Signal;
		private static var _INSTANCE:SkinManager;
		private var _skinsLoaded_bool:Boolean;
		//
		private var _loadCompleteSignal:Signal;
		private var _loadErrorSignal:Signal;
		private var _toLoad_array:Array;
		private var _loaderInfo_obj:Object;

		public function SkinManager($singletonEnforcer:SingletonEnforcer) {
			_INSTANCE = this;
			init();
		}

		//
		public static function GET_INSTANCE():SkinManager {
			if(_INSTANCE == null) _INSTANCE = new SkinManager(new SingletonEnforcer());
			return _INSTANCE;
		}

		//
		private function init():void {
			itemLoadedSignal = new Signal(String);
			_loadCompleteSignal = new Signal();
			_loadErrorSignal = new Signal(String);
			_skinsLoaded_bool = false;
			_loaderInfo_obj = new Object();
		}

		//
		public function load($swfUrl_array:Array):void {
			_toLoad_array = $swfUrl_array;
			for (var i:int = 0 ;i < _toLoad_array.length ;i++) {
				AssetQueueManager.GET_INSTANCE().itemLoadedSignal.add(onSkinLoadComplete);
				AssetQueueManager.GET_INSTANCE().itemLoadErrorSignal.add(onSkinLoadError);
				AssetQueueManager.GET_INSTANCE().queueCompleteSignal.addOnce(onQueueComplete);
				var config:DataConfigManager = DataConfigManager.GET_INSTANCE();
				var filename_str:String = config.getConfigString(Defines.CONFIG_SKINS_DIR) + _toLoad_array[i];
				AssetQueueManager.GET_INSTANCE().addItemToQueue(filename_str);
				AssetQueueManager.GET_INSTANCE().start();
			}
		}

		//
		private function onSkinLoadError($filename_str:String):void {
			_loadErrorSignal.dispatch($filename_str);
			Debug.log("SkinManager.onSkinLoadError : " + $filename_str);
		}

		//
		private function onSkinLoadComplete($filename_str:String):void {
			var config:DataConfigManager = DataConfigManager.GET_INSTANCE();
			for (var i:int = 0 ;i < _toLoad_array.length ;i++) {
				if ($filename_str == config.getConfigString(Defines.CONFIG_SKINS_DIR) + _toLoad_array[i]) {
					//store a reference to this loaderInfo object based on the name of the file
					var filename_str:String = $filename_str.substr($filename_str.lastIndexOf("/") + 1);
					_loaderInfo_obj[filename_str] = AssetQueueManager.GET_INSTANCE().getLoaderInfoByFilename($filename_str);
					itemLoadedSignal.dispatch(filename_str);
				}
			}
		}

		//
		private function onQueueComplete():void {
			AssetQueueManager.GET_INSTANCE().itemLoadedSignal.remove(onSkinLoadComplete);
			AssetQueueManager.GET_INSTANCE().itemLoadErrorSignal.remove(onSkinLoadError);
			AssetQueueManager.GET_INSTANCE().queueCompleteSignal.remove(onQueueComplete);
			_skinsLoaded_bool = true;
			_loadCompleteSignal.dispatch();
		}

		//
		public function isSkinLoaded($id_str:String):Boolean {
			var loaded_bool:Boolean = false;
			if (_loaderInfo_obj[$id_str] != null) {
				loaded_bool = true;
			}
			return loaded_bool;
		}

		public function getMovieAsset($className_str:String,$skinId_str:String = "skin_main.swf", $returnErrorHolder:Boolean = true):MovieClip {
			
			var ClassRef:Class = getClassRef($className_str, $skinId_str);
			
			if (ClassRef != null) {
				var item_mc:MovieClip = new ClassRef() as MovieClip;
				return item_mc;
			} else if($returnErrorHolder) {
				Debug.log("SkinManager.getMovieAsset : " + $className_str + " class not available");
				return Utils.GENERATE_DUMMY_MOVIE();
			}
			return null;
			
		}
		//
		public function getBitmapCopy($className_str:String,$transparent_bool:Boolean = true,$skinId_str:String = "skin_main.swf"):Bitmap {
			var ClassRef:Class = getClassRef($className_str, $skinId_str);
			var image:Bitmap;
			try {
				var item_mc:MovieClip = new ClassRef() as MovieClip;
				var copy_bmd:BitmapData = new BitmapData(item_mc.width, item_mc.height,$transparent_bool);
				copy_bmd.draw(item_mc);
				image = new Bitmap(copy_bmd);
				image.smoothing = true;
			}catch ($error:Error) {
				var error_bmd:BitmapData = new BitmapData(10,10,false,0xFF0000);
				image = new Bitmap(error_bmd);
			}
			return image;
			
		}
		public function getClassRef($className_str:String,$skinId_str:String = "skin_main.swf"):Class {
			//iterate through all the loaderInfo objects to find the definition for this class
			//
			try {
				var loaderInfo:LoaderInfo = _loaderInfo_obj[$skinId_str];
				if (loaderInfo != null) {
					var ClassRef:Class = loaderInfo.applicationDomain.getDefinition($className_str) as Class;
					return ClassRef;
				} else {
					Debug.log("SkinManager.getClassRef : no loaderInfo for id " + $skinId_str);
					return null;
				}
			}catch ($error:Error) {
				Debug.log("SkinManager.getClassRef : class " + $className_str + " not available");
			}
			return null;
		}
		//
		public function getBitmap($className_str:String, $skinId_str:String, bmpWidth:int, bmpHeight:int):BitmapData {
			var ClassRef:Class = getClassRef($className_str, $skinId_str);
			if (ClassRef != null) {
				var item_bmp:BitmapData = new ClassRef(bmpWidth, bmpHeight) as BitmapData;
				return item_bmp;
			} else {
				Debug.log("SkinManager.getBitmap : " + $className_str + " class not available");
				var bitmap_data:BitmapData = new BitmapData(10, 10, false, 0xFF0000);
				return bitmap_data;
			}
			return null;
		}
		//
		public function get loadCompleteSignal():Signal {
			return _loadCompleteSignal;
		}

		//
		public function get loadErrorSignal():Signal {
			return _loadErrorSignal;
		}

		//
		public function get skinsLoaded_bool():Boolean {
			return _skinsLoaded_bool;
		}
	}
}

class SingletonEnforcer {
}
