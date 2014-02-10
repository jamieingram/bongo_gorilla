package uk.co.flumox.data {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.net.SharedObject;
	import flash.utils.describeType;
	
	import uk.co.flumox.utils.Defines;

	/**
	 * A config object manager that stores config variables from flashvars or config xml
	 * 
	 * @author jamieingram
	 */
	public class DataConfigManager {
		
		private static var _INSTANCE:DataConfigManager;
		private var _config_obj:Object;
		private var _config_so:SharedObject;
		//
		public function DataConfigManager($singletonEnforcer:SingletonEnforcer) {
			_INSTANCE = this;
			init();
		}
		//
		public static function GET_INSTANCE():DataConfigManager {
			if(_INSTANCE == null) _INSTANCE = new DataConfigManager(new SingletonEnforcer());
			return _INSTANCE;
		}
		//
		private function init():void {
			_config_obj = new Object();
			_config_so = SharedObject.getLocal("config");
		}
		//
		public function parseFlashVars($param_obj:Object):void {
			var defines_xml:XML = describeType(Defines);
			var vars_list:XMLList = defines_xml.constant.@name;
			for (var i:int = 0 ; i < vars_list.length() ; i++) {
				var var_str:String = vars_list[i].toString();
				if ($param_obj[Defines[var_str]] != undefined) {
					if ($param_obj[Defines[var_str]] == "true") {
						_config_obj[Defines[var_str]] = true;
					}else if ($param_obj[Defines[var_str]] == "false") {
						_config_obj[Defines[var_str]] = false;
					}else{
						_config_obj[Defines[var_str]] = $param_obj[Defines[var_str]];
					}
					Debug.log("DataConfigManager.parseFlashVars : set "+Defines[var_str] + " to " + $param_obj[Defines[var_str]]);
				}
			}
		}
		//
		public function parseData($xmlList:XMLList):void {
			//take values from xml - don't override values that may have been set by flashvars (i.e. already exist)
			//
			for (var i:int = 0;i < $xmlList.length(); i++) {
				var node:XML = $xmlList[i];
				var id_str:String = node.@id;
				var type_str:String = node.@type;
				if (_config_obj[id_str] == undefined) {
					switch (type_str) {
						case "str":
							_config_obj[id_str] = node.toString();
						break;
						case "int":
							_config_obj[id_str] = int(node.toString());
						break;
						case "num":
							_config_obj[id_str] = Number(node.toString());
						break;
						case "bool":
							if (node.toString().toLowerCase() == "true") {
								_config_obj[id_str] = true;
							}else{
								_config_obj[id_str] = false;
							}
						break;
						case "array":
							_config_obj[id_str] = node.toString().split(",");
						break;
					}
				}else{
					Debug.log("DataConfigManager.parseData. Using flash var value for "+id_str+". Value = "+_config_obj[id_str]);
				}
			}
		}
		//
		public function setConfigString($id_str:String,$value_str:String):void {
			_config_obj[$id_str] = $value_str;
		}
		//
		public function setConfigBool($id_str:String, $val_bool:Boolean):void {
			_config_obj[$id_str] = $val_bool;
		}
		//
		public function getConfigString($id_str:String):String {
			var value_str:String = _config_obj[$id_str];
			if (value_str == null) {
				value_str = "";
				Debug.log("DataConfigManager.getConfigString : no config value found for "+$id_str);
			}
			return value_str;
		}
		//
		public function getConfigInt($id_str:String):int {
			
			var value_int:int = int(_config_obj[$id_str]);
			if (isNaN(value_int) == true){
				Debug.log("DataConfigManager.getConfigInt : no config value found for "+$id_str);
				value_int = 0;
			}
			return value_int;
		}
		
		public function getConfigBool($id_str : String) : Boolean {
			var value_bool:Boolean = _config_obj[$id_str];
			return value_bool;
		}
		
		public function getConfigNumber($id_str:String):Number {
			var value_num:Number = Number(_config_obj[$id_str]);
			if (isNaN(value_num)){
				Debug.log("DataConfigManager.getConfigNumber : no config value found for "+$id_str);
			}
			return value_num;
		}
		//
		public function getConfigArray($id_str : String) : Array {
			var values_array:Array = _config_obj[$id_str];
			if (values_array == null) {
				Debug.log("DataConfigManager.getConfigArray : no config value found for "+$id_str);
			}
			return values_array;
		}
	}
}

class SingletonEnforcer { } 
