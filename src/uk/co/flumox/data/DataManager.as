package uk.co.flumox.data {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.net.URLLoader;
	
	import org.osflash.signals.Signal;
	
	import uk.co.flumox.utils.AssetQueueManager;
	import uk.co.flumox.utils.Defines;
	import uk.co.flumox.utils.SkinManager;

	/**
	 * The data manager for the control module - handles the initial config load, fonts, css, assets
	 * and subsequent data communication
	 * 
	 * @author jamieingram
	 */
	public class DataManager {
		public var initialLoadCompleteSignal:Signal;		public var terminalErrorSignal:Signal;
		public var itemLoadedSignal:Signal;			//		protected var _numItemsToLoad_int:int;
		protected var _numItemsLoaded_int:int;
		//
		public function DataManager() {
			init();
		}
		//
		protected function init():void {
			initialLoadCompleteSignal = new Signal();			terminalErrorSignal = new Signal(String);			//
			//we have to load the config and skin swf - include these in the count initially
			_numItemsToLoad_int = 2;
			//			_numItemsLoaded_int = 0;
			itemLoadedSignal = new Signal();
			//
		}
		//
		public function loadInitialData():void {
			loadConfigData();
		}
		//
		private function loadConfigData():void {
			var config:DataConfigManager = DataConfigManager.GET_INSTANCE();
			var configXML_str:String = config.getConfigString(Defines.CONFIG_SETTINGS_URL);
			if(configXML_str.substr(0,4).toLowerCase() == "http") configXML_str += "?r=" + String(Math.random());
			//
			var proxy_loader:DataLoaderProxy = new DataLoaderProxy("config");
			proxy_loader.completeSignal.addOnce(onConfigDataLoadComplete);
			proxy_loader.loadURLContent(configXML_str);
		}
		//
		private function onConfigDataLoadComplete($id_str:String,$target_obj:Object):void {
			_numItemsLoaded_int++;
			itemLoadedSignal.dispatch();
			var loader:URLLoader = $target_obj as URLLoader;
			var config_xml:XML = new XML(loader.data);
			try {
				DataConfigManager.GET_INSTANCE().parseData(config_xml.config.item);
				DataStringManager.GET_INSTANCE().parseData(config_xml.strings.string);
				//
				//
			} catch($e:Error) {
				Debug.log("CoreDataManager.onConfigDataLoadComplete : cannot parse config xml - " + $e.message);
				return;
			}
			//
			loadAssets();
		}
		//
		private function loadAssets():void {
			//load swf / image assets for the control movie
			SkinManager.GET_INSTANCE().loadCompleteSignal.addOnce(onAssetsLoadComplete);
			AssetQueueManager.GET_INSTANCE().itemLoadProgressSignal.add(onAssetLoadProgress);
			SkinManager.GET_INSTANCE().load([Defines.SKIN_MAIN]);
			//
		}
		//
		private function onAssetsLoadComplete():void {
			_numItemsLoaded_int++;
			itemLoadedSignal.dispatch();
			AssetQueueManager.GET_INSTANCE().itemLoadProgressSignal.remove(onAssetLoadProgress);
			initialLoadCompleteSignal.dispatch();
		}
		//
		private function onAssetLoadProgress($id_str:String, $bytesLoaded_int:int, $bytesTotal_int:int):void {
			
		}
		//
		public function get numItemsToLoad():int {
			return _numItemsToLoad_int;
		}
		//
		public function get numItemsLoaded():int {
			return _numItemsLoaded_int;
		}
	}
}
