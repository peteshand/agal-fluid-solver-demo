package imag.masdar.experience.view.away3d.display.renderers.dataManipulators.workers 
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import imag.masdar.core.utils.logging.FileLog;
	import imag.masdar.core.utils.logging.Log;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class WorkerDataManipulator 
	{
		//[Embed(source="BytesArrayFormattor.swf", mimeType="application/octet-stream")]
		//public const BytesArrayFormattorSwf:Class;
		
		private var worker:Worker;
		private var mainToBack:MessageChannel;
		private var backToMain:MessageChannel;
		private var index:int;
		
		private var byteLength:Number;
		private var startByteOffset:Number;
		
		private var sentObject:*;
		//private var dataBytes:ByteArray;
		
		public var onInit:Signal = new Signal();
		public var onFormatComplete:Signal = new Signal();
		
		public var returnPositionData:Vector.<Vector.<Number>>;
		public var returnColourData:Vector.<Vector.<Number>>;
		
		public function WorkerDataManipulator(loaderInfo:LoaderInfo, includeRGB:Boolean, numberOfObjects:int, numRegisters:int, halfWidth:int, halfHeight:int, index:int, byteLength:int) 
		{
			this.index = index;
			this.byteLength = byteLength;
			this.startByteOffset = index * byteLength;
			
			
			worker = WorkerDomain.current.createWorker(loaderInfo.bytes, true);
			
			Log.saveDestination = FileLog.DESTINATION_DESKTOP;
			//Log.Trace(this, "test");
			
			mainToBack = Worker.current.createMessageChannel(worker);
			backToMain = worker.createMessageChannel(Worker.current);
			
			backToMain.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			
			//Now that we have our two channels, inject them into the worker as shared properties.
			//This way, the worker can see them on the other side.
			worker.setSharedProperty("backToMain", backToMain);
			worker.setSharedProperty("mainToBack", mainToBack);
		 
			//Init worker with width/height of image
			worker.setSharedProperty("numberOfObjects", numberOfObjects);
			worker.setSharedProperty("numRegisters", numRegisters);
			worker.setSharedProperty("halfWidth", halfWidth);
			worker.setSharedProperty("halfHeight", halfHeight);
			worker.setSharedProperty("includeRGB", includeRGB);
			worker.setSharedProperty("index", index);
			worker.setSharedProperty("startByteOffset", startByteOffset);
			
			
			
			//Convert image data to (shareable) byteArray, and share it with the worker.
			/*dataBytes = new ByteArray();
			dataBytes.shareable = true;
			dataBytes.writeFloat(10);
			worker.setSharedProperty("dataBytes", dataBytes);*/
		 
			//Lastly, start the worker.
			worker.start();
		}
		
		protected function onBackToMain(event:Event):void
		{
			if(backToMain.messageAvailable){
				sentObject = backToMain.receive();
				if (!sentObject) return;
				
				//var msg2:* = backToMain.receive();
				if (sentObject.msg == "INIT_STARTED") {
					onInit.dispatch();
				}
				else if (sentObject.msg == "ENCODE_COMPLETE") 
				{	
					returnPositionData = Vector.<Vector.<Number>>(sentObject.returnPositionData);
					if (sentObject.returnColourData) returnColourData = Vector.<Vector.<Number>>(sentObject.returnColourData);
					onFormatComplete.dispatch(index);
				}
			}
		}
		
		public function evaluate(ba:ByteArray):void
		{
			var msgObject:Object = new Object();
			msgObject.msg = 'PROCESS';
			msgObject.ba = ba;
			mainToBack.send(msgObject);
		}
	}
}