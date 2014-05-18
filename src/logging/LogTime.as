package logging 
{
	import com.greensock.TweenLite;
	import flash.system.System;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class LogTime 
	{
		private var interval:int = 60;
		
		public function LogTime() 
		{
			Log.saveDestination = FileLog.DESTINATION_DESKTOP;
			Log.fileName = "TimeIntervalLog.txt";
		}
		
		public function Start():void
		{
			TweenLite.delayedCall(interval, LogNow);
			LogNow();
		}
		
		public function Stop():void
		{
			TweenLite.killDelayedCallsTo(LogNow);
		}
		
		private function LogNow():void 
		{
			TweenLite.delayedCall(interval, LogNow);
			Log.Trace(this, String(new Date() )  +  " | " + String( Number(System.totalMemory/1024/1024).toFixed(2) ) );
		}
	}

}