package uk.co.flumox.data.item {
	import flash.utils.describeType;

	/**
	 * Base class for all custom data objects - includes method for easy conversion of all properties to a string
	 * 
	 * @author jamieingram
	 */
	public class Data 
	{
		public function toString():String {
			var out_str:String = "";
			out_str += describeType(this).@name + " [";
			var vars_xmlList:XMLList = describeType(this).child("variable");
			for each(var var_xml:XML in vars_xmlList) {
				out_str += "\n\t";
				out_str += " " + var_xml.@name + " ";
				if (var_xml.@type == "Object") {
					for (var i:String in this[var_xml.@name]) {
						out_str += i+" : "+this[var_xml.@name][i]+ " | ";
					}
				}else{
					out_str += this[var_xml.@name];
				}
			}
			out_str += "\n]";
			return out_str;
		}

		//
		public function parseXML($xml:XML):void {
			
		}
		//
		public function parseXMLList($xml_list:XMLList):void {
			
		}
	}
	//

}