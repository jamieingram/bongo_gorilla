package uk.co.flumox.utils {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	
	import uk.co.flumox.data.DataConfigManager;

	/**
	 * A multithreaded loading queue 
	 * 
	 * @author jamieingram
	 */
	public class AssetQueueManager {

		private static var _INSTANCE:AssetQueueManager;
		//
		public var queueCompleteSignal:Signal;		public var itemLoadProgressSignal:Signal;
		public var itemLoadedSignal:Signal;		public var itemLoadErrorSignal:Signal;
		//
		private var _loadingItem_int:int;
		private var _numThreads_int:int;
		private var _queue_array:Array;
		private var _assets:Dictionary;
		private var _active_bool:Boolean;
		private var _completed_bool:Boolean;
		private var _currentLoaders_array:Array;

		public function AssetQueueManager($numThreads_int:int = 1) {
			_INSTANCE = this;
			_numThreads_int = $numThreads_int;
			init();
		}

		//
		public static function GET_INSTANCE():AssetQueueManager {
			if (_INSTANCE == null) {
				_INSTANCE = new AssetQueueManager();
			}
			return _INSTANCE;
		}

		//
		private function init():void {
			//
			queueCompleteSignal = new Signal();			itemLoadProgressSignal = new Signal(String, int, int);
			itemLoadedSignal = new Signal(String);
			itemLoadErrorSignal = new Signal(String);
			//
			_queue_array = null;
			//
			_assets = new Dictionary();
			//
			_currentLoaders_array = new Array();
			//
			_active_bool = false;
			_completed_bool = false;
			//
			_loadingItem_int = 0;
		}
		//
		public function addItemToQueue($filename_str:String,$frontOfQueue_bool:Boolean = false):void {
			if (_queue_array == null) _queue_array = new Array();
			//check this item has not already been loaded, or is already in the queue
			if (isItemLoaded($filename_str) == true) {
				itemLoadedSignal.dispatch($filename_str);
				return;
			}else{
				//check the item is not in the queue
				for (var i:int = 0 ; i < _queue_array.length ; i++) {
					if ($filename_str == _queue_array[i]) {
						_completed_bool = false;
						return;
					}
				}
			}
			if ($frontOfQueue_bool == false) {
				_queue_array.push($filename_str);
			} else {
				_queue_array.splice(_loadingItem_int,0,$filename_str);
			}
			_completed_bool = false;
			start();
		}
		//
		public function removeItemFromQueue($filename_str:String):void {
			if (isItemLoaded($filename_str) == true) return;
			for (var i:int = 0 ; i < _queue_array.length ; i++) {
				if (_queue_array[i] == $filename_str && i > _loadingItem_int) {
					_queue_array.splice(i,1);
				}
			}
		}
		//
		public function isItemLoaded($item_str:String):Boolean {
			if (_assets[$item_str] != null) {
				return true;
			} else {
				return false;
			}
		}
		//
		public function start():void {
			if (_active_bool == false) {
				_active_bool = true;
				for (var i:int = 0 ;i < _numThreads_int ;i++) {
					loadNextAsset();
				}
			}
		}
		//
		public function stop():void {
			_active_bool = false;
		}
		//
		public function destroy():void {
			for (var i:int = 0 ;i < _currentLoaders_array.length ;i++) {
				var loader:AssetLoader = _currentLoaders_array[i];
				loader.activateSignal.remove(onAssetActivateCalled);				loader.completeSignal.remove(onAssetLoadComplete);				loader.progressSignal.remove(onAssetLoadProgress);				loader.errorSignal.remove(onAssetLoadError);
			}
			_currentLoaders_array = new Array();
		}
		//
		private function loadNextAsset():void {
			if (_queue_array != null) {
				if (_loadingItem_int < _queue_array.length) {
					var fileName_str:String = _queue_array[_loadingItem_int];
					var loaderContext:LoaderContext = new LoaderContext(true);
					loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
					//
					var loader:AssetLoader = new AssetLoader();
					loader.loadingItem_int = _loadingItem_int;					loader.activateSignal.addOnce(onAssetActivateCalled);					loader.completeSignal.addOnce(onAssetLoadComplete);					loader.progressSignal.addOnce(onAssetLoadProgress);
					loader.errorSignal.addOnce(onAssetLoadError);
					_currentLoaders_array.push(loader);
					//
					//
					// for all assets that are not absolute links, prepend the ASSET_BASE_URL to the filename
					if (fileName_str.indexOf("http") == -1) fileName_str = DataConfigManager.GET_INSTANCE().getConfigString(Defines.CONFIG_ASSETS_BASE) + fileName_str;
					//
					try {
						//Debug.log("AssetQueueManager.loadNextAsset loading "+fileName_str);
						loader.load(new URLRequest(fileName_str), loaderContext);
					}catch (error:Error) {
						loader.activateSignal.removeAll();						loader.completeSignal.removeAll();
						loader.progressSignal.removeAll();
						loader.errorSignal.removeAll();
						removeLoaderFromArray(loader);
						Debug.log("AssetQueueManager.loadNextAsset caught load error");
						_loadingItem_int++;
						loadNextAsset();
					}
					//
					_loadingItem_int++;
				} else {
					//queue has completed
					if (_currentLoaders_array.length == 0) {
						_completed_bool = true;
						_active_bool = false;
						queueCompleteSignal.dispatch();
					}
				}
			} else {
				Debug.log("AssetQueueManager.loadNextAsset : no queue defined");
			}
		}
		//
		private function onAssetLoadProgress($event:ProgressEvent):void {
			var loaderInfo:LoaderInfo = $event.target as LoaderInfo;
			var loader:AssetLoader = loaderInfo.loader as AssetLoader;
			var loadingItem_int:int = loader.loadingItem_int;
			itemLoadProgressSignal.dispatch(_queue_array[loadingItem_int], $event.bytesLoaded, $event.bytesTotal);
			//
		}
		//
		private function onAssetLoadError($event:IOErrorEvent):void {
			var loaderInfo:LoaderInfo = $event.target as LoaderInfo;
			var loader:AssetLoader = loaderInfo.loader as AssetLoader;
			loader.activateSignal.removeAll();			loader.completeSignal.removeAll();
			loader.progressSignal.removeAll();
			loader.errorSignal.removeAll();
			removeLoaderFromArray(loader);
			//
			var message_str:String = "load error ";
			if ($event != null) {
				message_str += $event.text;
			}
			Debug.log("AssetQueueManager.onAssetLoadError : " + message_str);
			//
			var loadingFilename_str:String = _queue_array[(loader.loadingItem_int)];
			itemLoadErrorSignal.dispatch(loadingFilename_str);
			//
			loadNextAsset();
		}
		//
		private function onAssetActivateCalled($event:Event):void {
			var loaderInfo:LoaderInfo = $event.target as LoaderInfo;
			handleLoadComplete(loaderInfo);
		}
		//
		private function onAssetLoadComplete($event:Event):void {
			var loaderInfo:LoaderInfo = $event.target as LoaderInfo;
			handleLoadComplete(loaderInfo);
			//		}
		//
		private function handleLoadComplete($loaderInfo:LoaderInfo):void {
			var loader:AssetLoader = $loaderInfo.loader as AssetLoader;
			var loadedFilename_str:String = _queue_array[(loader.loadingItem_int)];
			//
			if (_assets[loadedFilename_str] == null) {
				loader.activateSignal.removeAll();
				loader.completeSignal.removeAll();
				loader.progressSignal.removeAll();
				loader.errorSignal.removeAll();
				removeLoaderFromArray(loader);
				//
				_assets[loadedFilename_str] = $loaderInfo;
				//
				itemLoadedSignal.dispatch(loadedFilename_str);
				//
				if (_active_bool == true) {
					for (var i:int = 0 ; i <= _numThreads_int - _currentLoaders_array.length ; i++) {
						loadNextAsset();
					}
				}
			}
		}
		//
		public function getMovieClipAssetByFilename($filename_str:String):MovieClip {
			var loaderInfo:LoaderInfo = _assets[$filename_str] as LoaderInfo;
			var asset_mc:MovieClip = loaderInfo.content as MovieClip;
			return asset_mc;
		}

		//
		public function getLoaderInfoByFilename($filename_str:String):LoaderInfo {
			var loaderInfo:LoaderInfo = _assets[$filename_str] as LoaderInfo;
			return loaderInfo;
		}

		//
		public function getBitmapAssetByFilename($filename_str:String):Bitmap {
			var loaderInfo:LoaderInfo = _assets[$filename_str] as LoaderInfo;
			var asset_bmp:Bitmap;
			if (loaderInfo == null) {
				Debug.log("AssetQueueManager.getBitmapAssetByFilename - no image found");
				asset_bmp = new Bitmap(new BitmapData(10,10,false,0xFF0000));
			}else{
				asset_bmp = loaderInfo.content as Bitmap;
			}
			return asset_bmp;
		}
		//
		public function getBitmapCopyByFilename($filename_str:String):Bitmap {
			var loaderInfo:LoaderInfo = _assets[$filename_str] as LoaderInfo;
			var image:Bitmap;
			try {
				var asset_bmp:Bitmap = loaderInfo.content as Bitmap;
				var copy_bmd:BitmapData = new BitmapData(asset_bmp.width, asset_bmp.height);
				copy_bmd.copyPixels(asset_bmp.bitmapData, copy_bmd.rect, new Point(0,0));
				image = new Bitmap(copy_bmd,"auto",true);
			} catch ($error:Error) {
				Debug.log("AssetQueueManager.getBitmapCopyByFilename : error retrieving "+$filename_str+" error :" + $error.message);
				var error_bmd:BitmapData = new BitmapData(50,50,false,0x252525);
				image = new Bitmap(error_bmd);
			}
			return image;
			
		}

		//
		public function checkItemsLoaded($fileStrings_array:Array):Boolean {
			var loaded_bool:Boolean = true;
			for (var i:Number = 0;i < $fileStrings_array.length;i++) {
				var fileLoaded_bool:Boolean = isItemLoaded($fileStrings_array[i].toLowerCase());
				if (fileLoaded_bool == false) {
					loaded_bool = false;
					break;
				}
			}
			return loaded_bool;
		}
		//
		private function removeLoaderFromArray($loader:AssetLoader):void {
			for (var i:int = 0;i < _currentLoaders_array.length;i++) {
				if ($loader.loadingItem_int == _currentLoaders_array[i].loadingItem_int) {
					var temp1_array:Array = _currentLoaders_array.slice(0, i);
					var temp2_array:Array = _currentLoaders_array.slice(i + 1);
					_currentLoaders_array = temp1_array.concat(temp2_array);
					break;	
				}
			}
		}

		//
		public function get isComplete_bool():Boolean {
			return _completed_bool;
		}
		public function get isActive_bool():Boolean {
			return _active_bool;
		}

		//
		public function get queue_array():Array {
			return _queue_array;
		}
		//
		public function set numThreads_int($numThreads_int:int):void {
			_numThreads_int = $numThreads_int;
		}
	}
}
