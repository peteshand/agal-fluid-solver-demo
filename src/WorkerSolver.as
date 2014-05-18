package  
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import logging.FileLog;
	import logging.Log;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class WorkerSolver extends BaseSolver 
	{
		private var worker:Worker;
		private var mainToBack:MessageChannel;
		private var backToMain:MessageChannel;
		private var sentObject:*;
		
		private var _vec:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		public function WorkerSolver(stage:Stage) 
		{
			worker = WorkerDomain.current.createWorker(stage.loaderInfo.bytes, true);
			
			mainToBack = Worker.current.createMessageChannel(worker);
			backToMain = worker.createMessageChannel(Worker.current);
			backToMain.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			
			worker.setSharedProperty("backToMain", backToMain);
			worker.setSharedProperty("mainToBack", mainToBack);
			
			worker.setSharedProperty("index", 0);
			//worker.setSharedProperty("dataBytes", numRegisters);
			Log.saveDestination = FileLog.DESTINATION_DESKTOP;
			Log.fileName = "mainTest.txt";
			//Log.Trace(this, "TEST");
			
			
			worker.start();
		}
		
		private function onBackToMain(e:Event):void 
		{
			if(backToMain.messageAvailable){
				sentObject = backToMain.receive();
				if (!sentObject) return;
				
				//Log.Trace(this, "sentObject.msg = " + sentObject.msg);
				//var msg2:* = backToMain.receive();
				if (sentObject.msg == "UPDATE") {
					_vec = Vector.<Vector.<Number>>(sentObject.vec);
					onUpdate.dispatch();
				}
				/*else if (sentObject.msg == "ENCODE_COMPLETE") 
				{	
					returnPositionData = Vector.<Vector.<Number>>(sentObject.returnPositionData);
					if (sentObject.returnColourData) returnColourData = Vector.<Vector.<Number>>(sentObject.returnColourData);
					onFormatComplete.dispatch(index);
				}*/
			}
		}
		
		override public function init():void 
		{
			var msgObject:Object = new Object();
			msgObject.msg = 'INIT';
			mainToBack.send(msgObject);
			onInit.dispatch();
		}
		
		override public function handleForce(x:Number, y:Number):void
		{
			var msgObject:Object = new Object();
			msgObject.msg = 'HandleForce';
			msgObject.x = x;
			msgObject.y = y;
			mainToBack.send(msgObject);
		}
		
		override public function Update():void 
		{
			var msgObject:Object = new Object();
			msgObject.msg = 'Update';
			mainToBack.send(msgObject);
		}
		
		override public function get vec():Vector.<Vector.<Number>> 
		{
			return _vec;
		}
	}

}