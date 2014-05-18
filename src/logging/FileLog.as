package logging
{
	CONFIG::air import flash.filesystem.File;
	CONFIG::air import flash.filesystem.FileMode;
	CONFIG::air import flash.filesystem.FileStream;
	/**
	* ...
	* @author Pete Shand
	*/
	public class FileLog
	{
		CONFIG::air private static var targetFile:File;
		CONFIG::air private static var fileStream:FileStream;
		
		public static var LogFileName:String = "logfile.txt";
		private static var logContent:String = "";
		private static var _saveDestination:int;
		private static const newline:String = "\r\n";
		
		public static const DESTINATION_DESKTOP:int = 0;
		public static const DESTINATION_STORAGE:int = 1;
		public static const DESTINATION_DOCUMENTS:int = 2;
		public static const DESTINATION_USER:int = 3;
		
		static public function set saveDestination(destination:int):void
		{
			if (CONFIG::air) {
				_saveDestination = destination;
				if (destination == FileLog.DESTINATION_DESKTOP) targetFile = File.desktopDirectory;
				if (destination == FileLog.DESTINATION_STORAGE) targetFile = File.applicationStorageDirectory;
				if (destination == FileLog.DESTINATION_DOCUMENTS) targetFile = File.documentsDirectory;
				if (destination == FileLog.DESTINATION_USER) targetFile = File.userDirectory;
				targetFile = targetFile.resolvePath(LogFileName);
			}
		}
		
		static public function get saveDestination():int 
		{
			return _saveDestination;
		}
		
		public static function trace(msg:String):void
		{
			if (CONFIG::air) {
				if (!targetFile) {
					saveDestination = 0;
					FileLog.Clear();
				}
			}
			FileLog.ReadLogFile();
			FileLog.WriteLogFile(msg);
		}

		private static function ReadLogFile():void
		{
			if (CONFIG::air) {
				if (targetFile.exists){
					fileStream = new FileStream();
					fileStream.open(targetFile, FileMode.READ);
					logContent = fileStream.readUTFBytes(fileStream.bytesAvailable);
					fileStream.close();
				}
			}
		}

		private static function WriteLogFile(msg:String):void
		{
			if (CONFIG::air) {
				fileStream = new FileStream();
				fileStream.open(targetFile, FileMode.WRITE);
				fileStream.writeUTFBytes(logContent + msg + newline);
				fileStream.close();
			}
		}
		
		private static function Clear():void
		{
			WriteLogFile("");
		}
	}
}