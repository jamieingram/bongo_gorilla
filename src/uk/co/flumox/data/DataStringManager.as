package uk.co.flumox.data {
	import com.carlcalderon.arthropod.Debug;
	
	import uk.co.flumox.data.item.Data;

	/**
	 * A data object for the storage of dictionary strings defined in the xml file
	 * 
	 * @author jamieingram
	 */
	public class DataStringManager extends Data {
		
		private static var _INSTANCE:DataStringManager;
		public var strings_obj:Object;
		//
		public function DataStringManager($singletonEnforcer:SingletonEnforcer) {
			_INSTANCE = this;
			init();
		}
		//
		public static function GET_INSTANCE() : DataStringManager {
			if(_INSTANCE == null) _INSTANCE = new DataStringManager(new SingletonEnforcer());
			return _INSTANCE;
		}
		//
		private function init():void {
			strings_obj = new Object();
		}
		//
		public function parseData($xmlList:XMLList):void {
			for (var i:int = 0;i < $xmlList.length(); i++) {
				var node:XML = $xmlList[i];
				var id_str:String = node.@id.toString();
				strings_obj[id_str] = node.toString();
			}
		}
		//
		public function setString($id_str:String,$value_str:String):void {
			strings_obj[$id_str] = $value_str;
		}
		//
		public function getString($id_str:String):String {
			
			var value_str:String = strings_obj[$id_str];
			if (value_str == null) {
				Debug.log("DataStringManager.getString : no string value found for "+$id_str+". Called from "+arguments.callee.prototype);
				value_str = "";
			}
			return value_str;
		}
		//
	}
}

class SingletonEnforcer { } 
