package uk.co.flumox.application {
	
	import com.carlcalderon.arthropod.Debug;
	
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	import uk.co.flumox.data.DataConfigManager;
	import uk.co.flumox.data.DataManager;
	import uk.co.flumox.display.DisplayManager;
	import uk.co.flumox.interfaces.IApplication;
	import uk.co.flumox.utils.Defines;
	
	/**
	 * Document class for application
	 * 
	 * @author jamieingram
	 */
	public class ApplicationMain extends MovieClip implements IApplication {
		
        public static var IS_GORILLA_BOOL:Boolean = false;
		private static var _INSTANCE:ApplicationMain;
		//
		public var lastNavigateTo_str:String;
		public var currentNavigateTo_str:String;
		//
		private var _initialLoadCompleteSignal:Signal;
		private var _loadProgressSignal:Signal;
		private var _terminalErrorSignal:Signal;
		//
		private var _dataManager:DataManager;
		private var _displayManager:DisplayManager;
		
		public function ApplicationMain($isGorilla_bool:Boolean = false) {
			super();
            IS_GORILLA_BOOL = $isGorilla_bool;
			_INSTANCE = this;
		}
		
		public static function GET_INSTANCE():ApplicationMain {
			if (_INSTANCE == null) {
                Debug.error("ApplicationMain.GET_INSTANCE - no instance found");
			}
			//
			return _INSTANCE;
		}
		//
		/**** INITIAL CALLS *****/
		//
		public function init():void {
			//
			_initialLoadCompleteSignal = new Signal();
			_loadProgressSignal = new Signal(Number);
			_terminalErrorSignal = new Signal(String);
			//
            trace("TRACE OUTPUT WILL NOT APPEAR - use Arthropod for Debugging");
            Debug.password = "flumox";
            Debug.clear();
            Debug.log("starting up...");
			//
			//load the initial assets
			_dataManager = new DataManager();
			_dataManager.itemLoadedSignal.add(onDataItemLoaded);
			_dataManager.terminalErrorSignal.addOnce(onTerminalLoadError);
			_dataManager.initialLoadCompleteSignal.addOnce(onInitialLoadComplete);
			//
			_displayManager = new DisplayManager();
			addChild(_displayManager);
			//
			loadInitialData();
			//
		}
		//
		public function loadInitialData():void {
			//manage flashvars
			var root_li:LoaderInfo;
			if (this.parent == this.stage) {
				root_li = LoaderInfo(this.root.loaderInfo);
			}else{
				root_li = LoaderInfo(this.parent.loaderInfo);
			}
			var param_obj:Object = root_li.parameters;
			for(var i:* in param_obj) Debug.log(String(i) + " : " + param_obj[i]);
			var config:DataConfigManager = DataConfigManager.GET_INSTANCE();
			config.setConfigString(Defines.CONFIG_SETTINGS_URL, "xml/data.xml");
			config.parseFlashVars(param_obj);
			//
			_dataManager.loadInitialData();
		}
		
		//
		/******* INITIAL LOADING / CONFIG / INITIALISATION METHODS *******/
		//
		private function onInitialLoadComplete():void {
			//
			_displayManager.initAfterAssetsLoad();
			_initialLoadCompleteSignal.dispatch();
			//
			if ((this.stage == this.parent && this.stage != null)) {
				showInitialContent();
			}
		}
		//
		public function showInitialContent():void {
			Debug.log("ApplicationMain.showInitialContent");
		}
		//
		/******* UTILITY FUNCTIONS *******/
		
		private function onTerminalLoadError($error_str:String):void {
			_terminalErrorSignal.dispatch($error_str);
			Debug.log("ApplicationMain.onTerminalLoadError : "+$error_str);
		}
		//
		private function onDataItemLoaded():void {
			var percentage_num:Number = (_dataManager.numItemsLoaded / _dataManager.numItemsToLoad);
			_loadProgressSignal.dispatch(percentage_num);
		}
		//
		/******* GETTERS AND SETTERS *******/
		
		public function get initialLoadCompleteSignal():Signal {
			return _initialLoadCompleteSignal;
		}
		
		public function get terminalErrorSignal():Signal {
			return _terminalErrorSignal;
		}
		
		public function get displayManager():DisplayManager {
			return _displayManager;
		}
		//
		public function get dataManager():DataManager {
			return _dataManager;
		}
	}
	
}