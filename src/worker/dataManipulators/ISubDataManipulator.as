package imag.masdar.experience.view.away3d.display.renderers.dataManipulators 
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Pete Shand
	 */
	public interface ISubDataManipulator 
	{
		function evaluate(pointCloudData:ByteArray):void;
		
		function get onFormatComplete():Signal;
		function get surfaceNormals():Vector.<Vector3D>;
	}
}