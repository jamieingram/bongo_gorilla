package uk.co.flumox.data {
	import com.carlcalderon.arthropod.Debug;
	
	import flash.utils.describeType;
	
	import uk.co.flumox.utils.Defines;

	/**
	 * A config object manager that stores config variables from flashvars or config xml
	 * 
	 * @author jamieingram
	 */
	public class DataConfigManager {
		
		private static var _INSTANCE:DataConfigManager;
		public var config_obj:Object;
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
			config_obj = new Object();
		}
		//
		public function parseFlashVars($param_obj:Object):void {
			var defines_xml:XML = describeType(Defines);
			var vars_list:XMLList = defines_xml.constant.@name;
			for (var i:int = 0 ; i < vars_list.length() ; i++) {
				var var_str:String = vars_list[i].toString();
				if ($param_obj[Defines[var_str]] != undefined) {
					if ($param_obj[Defines[var_str]] == "true") {
						config_obj[Defines[var_str]] = true;
					}else if ($param_obj[Defines[var_str]] == "false") {
						config_obj[Defines[var_str]] = false;
					}else{
						config_obj[Defines[var_str]] = $param_obj[Defines[var_str]];
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
				if (config_obj[id_str] == undefined) {
					switch (type_str) {
						case "str":
							config_obj[id_str] = node.toString();
						break;
						case "int":
							config_obj[id_str] = int(node.toString());
						break;
						case "num":
							config_obj[id_str] = Number(node.toString());
						break;
						case "bool":
							if (node.toString().toLowerCase() == "true") {
								config_obj[id_str] = true;
							}else{
								config_obj[id_str] = false;
							}
						break;
						case "array":
							config_obj[id_str] = node.toString().split(",");
						break;
					}
				}else{
					Debug.log("DataConfigManager.parseData. Using flash var value for "+id_str+". Value = "+config_obj[id_str]);
				}
			}
		}
		//
		public function setConfigString($id_str:String,$value_str:String):void {
			config_obj[$id_str] = $value_str;
		}
		//
		public function setConfigBool($id_str:String, $val_bool:Boolean):void {
			config_obj[$id_str] = $val_bool;
		}
		//
		public function getConfigString($id_str:String):String {
			var value_str:String = config_obj[$id_str];
			if (value_str == null) {
				value_str = "";
				Debug.log("DataConfigManager.getConfigString : no config value found for "+$id_str);
			}
			return value_str;
		}
		//
		public function getConfigInt($id_str:String):int {
			
			var value_int:int = int(config_obj[$id_str]);
			if (isNaN(value_int) == true){
				Debug.log("DataConfigManager.getConfigInt : no config value found for "+$id_str);
				value_int = 0;
			}
			return value_int;
		}
		
		public function getConfigBool($id_str : String) : Boolean {
			var value_bool:Boolean = config_obj[$id_str];
			return value_bool;
		}
		
		public function getConfigNumber($id_str:String):Number {
			var value_num:Number = Number(config_obj[$id_str]);
			if (!value_num){
				Debug.log("DataConfigManager.getConfigNumber : no config value found for "+$id_str);
			}
			return value_num;
		}
		//
		public function getConfigArray($id_str : String) : Array {
			var values_array:Array = config_obj[$id_str];
			if (values_array == null) {
				Debug.log("DataConfigManager.getConfigArray : no config value found for "+$id_str);
			}
			return values_array;
		}
	}
}

class SingletonEnforcer { } 
