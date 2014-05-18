package imag.masdar.experience.view.away3d.display.renderers.dataManipulators.mainThread 
{
	import flash.display.LoaderInfo;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import imag.masdar.core.utils.logging.Log;
	import imag.masdar.experience.view.away3d.display.renderers.dataManipulators.ISubDataManipulator;
	import imag.masdar.experience.workers.back.kinect.KinectDataManipulator;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class MainThreadDataManipulator implements ISubDataManipulator
	{
		private var _onFormatComplete:Signal = new Signal(Vector.<Vector.<Number>>);
		private var kinectDataManipulator:KinectDataManipulator;
		private var combinedPositionData:Vector.<Vector.<Number>>;
		
		private var _surfaceNormals:Vector.<Vector3D>;
		
		public function MainThreadDataManipulator(loaderInfo:LoaderInfo, includeRGB:Boolean, numberOfObjects:int, numRegisters:int, halfWidth:int, halfHeight:int, byteLength:int) 
		{
			kinectDataManipulator = new KinectDataManipulator();
			
			kinectDataManipulator.numberOfObjects = numberOfObjects;
			kinectDataManipulator.numRegisters = numRegisters;
			kinectDataManipulator.includeRGB = includeRGB;
			kinectDataManipulator.index = 0;
			kinectDataManipulator.startByteOffset = 0;
		}
		
		public function evaluate(pointCloudData:ByteArray):void 
		{
			combinedPositionData = kinectDataManipulator.process(pointCloudData);
			//_surfaceNormals = kinectDataManipulator.findSurfaceNormals();
			
			onFormatComplete.dispatch(combinedPositionData);
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