package imag.masdar.experience.view.away3d.display.renderers.dataManipulators.workers 
{
	import flash.display.LoaderInfo;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import imag.masdar.core.utils.logging.Log;
	import imag.masdar.experience.view.away3d.display.renderers.dataManipulators.ISubDataManipulator;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class WorkerDataManipulators implements ISubDataManipulator
	{
		private var numberOfWorkers:int = 1;
		private var includeRGB:Boolean;
		private var byteLength:int;
		private var _surfaceNormals:Vector.<Vector3D>;
		
		//private var workerDataManipulator:WorkerDataManipulator;
		private var workerDataManipulators:Vector.<WorkerDataManipulator> = new Vector.<WorkerDataManipulator>();
		
		//public var onInit:Signal = new Signal();
		private var _onFormatComplete:Signal = new Signal(Vector.<Vector.<Number>>);
		
		private var returnPositionDatas:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>(numberOfWorkers);
		//private var returnColourDatas:Vector.<Vector.<Vector.<Number>>> = new Vector.<Vector.<Vector.<Number>>>(numberOfWorkers);
		
		private var combinedPositionData:Vector.<Vector.<Number>>;
		//private var combinedColourData:Vector.<Vector.<Number>>;
		
		public function WorkerDataManipulators(loaderInfo:LoaderInfo, includeRGB:Boolean, numberOfObjects:int, numRegisters:int, halfWidth:int, halfHeight:int, byteLength:int) 
		{
			this.includeRGB = includeRGB;
			this.byteLength = byteLength;
			
			for (var i:int = 0; i < numberOfWorkers; ++i){
				var workerDataManipulator:WorkerDataManipulator = new WorkerDataManipulator(loaderInfo, includeRGB, numberOfObjects/numberOfWorkers, numRegisters, halfWidth, halfHeight, i, byteLength/numberOfWorkers);
				//workerDataManipulator.onInit.add(onWorkerInit);
				workerDataManipulator.onFormatComplete.add(OnFormatComplete);
				workerDataManipulators.push(workerDataManipulator);
			}
		}
		
		public function evaluate(pointCloudData:ByteArray):void 
		{
			for (var i:int = 0; i < workerDataManipulators.length; ++i) 
			{	
				workerDataManipulators[i].evaluate(pointCloudData);
			}
		}
		
		private function onWorkerInit():void 
		{
			//onInit.dispatch();
		}
		
		private function OnFormatComplete(index:int):void 
		{
			returnPositionDatas[index] = workerDataManipulators[index].returnPositionData;
			//if (includeRGB) returnColourDatas[index] = workerDataManipulators[index].returnColourData;
			
			for (var i:int = 0; i < returnPositionDatas.length; ++i) {
				if (!returnPositionDatas[i]) return;
			}
			
			combinedPositionData = new Vector.<Vector.<Number>>();
			//combinedColourData = new Vector.<Vector.<Number>>();
			for (var j:int = 0; j < returnPositionDatas.length; ++j) {
				//combinedPositionData[j] = new Vector.<Number>();
				//combinedColourData[j] = new Vector.<Number>();
				for (var k:int = 0; k < returnPositionDatas[j].length; ++k) {
					combinedPositionData.push(returnPositionDatas[j][k]);
					//if (includeRGB) combinedColourData.push(returnColourDatas[j][k]);
				}
			}
			
			onFormatComplete.dispatch(combinedPositionData);
			
			for (var m:int = 0; m < returnPositionDatas.length; ++m) {
				returnPositionDatas[index] = null;
				//if (includeRGB) returnColourDatas[index] = null;
			}
			
			trace("OnFormatComplete");
			
		}
		
		public function get onFormatComplete():Signal 
		{
			return _onFormatComplete;
		}
		
		public function get surfaceNormals():Vector.<Vector3D> 
		{
			return _surfaceNormals;
		}
	}
}