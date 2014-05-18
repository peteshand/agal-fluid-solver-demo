package worker.dataManipulators 
{
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import imag.masdar.core.utils.logging.Log;
	import imag.masdar.experience.BaseObject;
	import imag.masdar.experience.view.away3d.display.renderers.dataManipulators.mainThread.MainThreadDataManipulator;
	import imag.masdar.experience.view.away3d.display.renderers.dataManipulators.workers.WorkerDataManipulators;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class DataManipulator
	{
		//private var subDataManipulator:ISubDataManipulator;
		
		//public var settings:KinectSettings;
		private var includeRGB:Boolean;
		private var _explicitWidth:uint;
		private var _explicitHeight:uint;
		private var halfWidth:int;
		private var halfHeight:int;
		private var numberOfDots:int
		private var numberOfObjects:int;
		
		private var totalBytes:int;
		private var byteLength:int = 0;
		
		public var limit:int = 400;//360//
		public var numRegisters:int = limit / 4;
		
		//public var dataProcessed:Signal = new Signal();
		public var combinedPositionData:Vector.<Vector.<Number>>;
		public var surfaceNormals:Vector.<Vector3D>;
		
		public function DataManipulator() 
		{
			//settings = config.kinect.getSettings();
			
			//_explicitWidth = settings.pointCloudResolution.x;
			//_explicitHeight = settings.pointCloudResolution.y;
			
			halfWidth = _explicitWidth * .5;
			halfHeight = _explicitHeight * .5;
			
			includeRGB = settings.pointCloudIncludeRGB;
			
			numberOfDots = (_explicitWidth * _explicitHeight) / (settings.pointCloudDensity - 1);
			
			numberOfObjects = Math.floor(numberOfDots / numRegisters) / 6;
			
			totalBytes = numberOfDots * 2 * 3;
			byteLength = numberOfDots;
			if (includeRGB) {
				totalBytes *= 2;
				byteLength *= 2;
			}
			
			if (config.kinect.useWorkersForKinectDataManipulation) subDataManipulator = new WorkerDataManipulators(core.stage.loaderInfo, includeRGB, numberOfObjects, numRegisters, halfWidth, halfHeight, byteLength);
			else subDataManipulator = new MainThreadDataManipulator(core.stage.loaderInfo, includeRGB, numberOfObjects, numRegisters, halfWidth, halfHeight, byteLength);
			subDataManipulator.onFormatComplete.add(OnFormatComplete);
		}
		
		public function evaluate(pointCloudData:ByteArray):void 
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			pointCloudData.position = 0;
			pointCloudData.readBytes(byteArray, 0, byteLength);
			
			subDataManipulator.evaluate(byteArray);
		}
		
		private function OnFormatComplete(combinedPositionData:Vector.<Vector.<Number>>):void 
		{
			this.combinedPositionData = combinedPositionData;
			//this.surfaceNormals = subDataManipulator.surfaceNormals;
			dataProcessed.dispatch();
		}
		
	}

}