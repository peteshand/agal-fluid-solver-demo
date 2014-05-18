package logging 
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	
	public class Log 
	{
		static public function Trace(origin:*, msg:String):void
		{
			msg = getDefinitionByName(getQualifiedClassName(origin)) + " " + msg;
			if (CONFIG::air) FileLog.trace(msg);
			trace(msg);
		}
		
		static public function set saveDestination(destination:int):void
		{
			if (CONFIG::air) FileLog.saveDestination = destination;
		}
		
		static public function get saveDestination():int 
		{
			if (CONFIG::air) return FileLog.saveDestination;
			return -1;
		}
		
		static public function set fileName(value:String):void
		{
			if (CONFIG::air) {
				FileLog.LogFileName = value;
				saveDestination = FileLog.saveDestination;
			}
		}
		
		static public function get fileName():String 
		{
			if (CONFIG::air) return FileLog.LogFileName;
			return -1;
		}
	}
}