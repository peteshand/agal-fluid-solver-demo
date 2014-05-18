package animators
{
	import away3d.animators.AnimationSetBase;
	import away3d.animators.data.VertexAnimationMode;
	import away3d.animators.IAnimationSet;
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.materials.passes.MaterialPassBase;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import flash.display3D.Context3D;
	
	import flash.utils.Dictionary;
	
	use namespace arcane;
	
	/**
	 * The animation data set used by vertex-based animators, containing vertex animation state data.
	 *
	 * @see away3d.animators.VertexAnimator
	 */
	public class PointCloudAnimationSet extends AnimationSetBase implements IAnimationSet
	{
		private var _numPoses:uint;
		private var _blendMode:String;
		private var _streamIndices:Dictionary = new Dictionary(true);
		private var _useNormals:Dictionary = new Dictionary(true);
		private var _useTangents:Dictionary = new Dictionary(true);
		private var _uploadNormals:Boolean;
		private var _uploadTangents:Boolean;
		
		public var vertexData:Vector.<Number>;
		private var vertexConstances:Vector.<Number> = new Vector.<Number>(12);
		
		public var positionData:Vector.<Number>;
		
		public var byteArrayOffset:int = 0;
		public var numRegisters:int = 100;
		
		/**
		 * Returns the number of poses made available at once to the GPU animation code.
		 */
		public function get numPoses():uint
		{
			return _numPoses;
		}
		
		/**
		 * Returns the active blend mode of the vertex animator object.
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		
		/**
		 * Returns whether or not normal data is used in last set GPU pass of the vertex shader.
		 */
		public function get useNormals():Boolean
		{
			return _uploadNormals;
		}
		
		/**
		 * Creates a new <code>PointCloudAnimationSet</code> object.
		 *
		 * @param numPoses The number of poses made available at once to the GPU animation code.
		 * @param blendMode Optional value for setting the animation mode of the vertex animator object.
		 *
		 * @see away3d.animators.data.VertexAnimationMode
		 */
		public function PointCloudAnimationSet(numRegisters:int, numPoses:uint = 2, blendMode:String = "absolute")
		{
			super();
			
			this.numRegisters = numRegisters;
			
			_numPoses = numPoses;
			_blendMode = blendMode;
			
			vertexConstances[0] = 10;
			vertexConstances[1] = (180 * Math.PI) / 10;
			vertexConstances[2] = 2;//3;
			vertexConstances[3] = numRegisters;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALVertexCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>, profile:String):String
		{
			if (_blendMode == VertexAnimationMode.ABSOLUTE)
				return getAbsoluteAGALCode(pass, sourceRegisters, targetRegisters);
			else
				return getAdditiveAGALCode(pass, sourceRegisters, targetRegisters);
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{
			_uploadNormals = Boolean(_useNormals[pass]);
			_uploadTangents = Boolean(_useTangents[pass]);
			
			var context : Context3D = stage3DProxy._context3D;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, vertexConstances, 2);
			
			if (positionData) {
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 10, positionData, numRegisters);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{
			var index:int = _streamIndices[pass];
			var context:Context3D = stage3DProxy._context3D;
			context.setVertexBufferAt(index, null);
			if (_uploadNormals)
				context.setVertexBufferAt(index + 1, null);
			if (_uploadTangents)
				context.setVertexBufferAt(index + 2, null);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALFragmentCode(pass:MaterialPassBase, shadedTarget:String, profile:String):String
		{
			return "";
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALUVCode(pass:MaterialPassBase, UVSource:String, UVTarget:String):String
		{
			return "mov " + UVTarget + "," + UVSource + "\n";
		}
		
		/**
		 * @inheritDoc
		 */
		public function doneAGALCode(pass:MaterialPassBase):void
		{
		
		}
		
		/**
		 * Generates the vertex AGAL code for absolute blending.
		 */
		private function getAbsoluteAGALCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>):String
		{
			Debug.active = true;
			
			var code:String = "// test\n";
			var len:uint = sourceRegisters.length;
			var useNormals:Boolean = Boolean(_useNormals[pass] = len > 1);
			
			
			code += "mov " + targetRegisters[0] + ", " + sourceRegisters[0] + "\n";
			
			if (useNormals) code += "mov " + targetRegisters[1] + ", " + sourceRegisters[1] + "\n";
			
			if (targetRegisters.length > 2) {
				code += "mov " + targetRegisters[2] + ", " + sourceRegisters[2] + "\n";
			}
			
			code += "mov vt1.w, vt0.z \n"; // move index into vt1.w
			code += "mov v2.xyzw, vc[vt1.w].wwww \n"; // move rgb into v1
			code += "add vt0.xy, vt0.xy, vc[vt1.w].xy \n"; // move z position back to 0
			
			code += "div vt6.x, vt0.x, vc4.y \n";
			code += "sin vt0.z, vt6.x \n";
			code += "mul vt0.z, vt0.z, vc4.x \n";
			code += "sub vt0.z, vt0.z, vc4.x \n";
			
			code += "mul vt6.y, vt1.w, vc4.z \n";
			code += "sub vt0.z, vt0.z, vt6.y \n";
			
			return code;
		}
		
		
		
		/**
		 * Generates the vertex AGAL code for additive blending.
		 */
		private function getAdditiveAGALCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>):String
		{
			var code:String = "";
			var len:uint = sourceRegisters.length;
			var regs:Array = ["x", "y", "z", "w"];
			var temp1:String = findTempReg(targetRegisters);
			var k:uint;
			var useTangents:Boolean = Boolean(_useTangents[pass] = len > 2);
			var useNormals:Boolean = Boolean(_useNormals[pass] = len > 1);
			var streamIndex:uint = _streamIndices[pass] = pass.numUsedStreams;
			
			if (len > 2)
				len = 2;
			
			code += "mov  " + targetRegisters[0] + ", " + sourceRegisters[0] + "\n";
			if (useNormals)
				code += "mov " + targetRegisters[1] + ", " + sourceRegisters[1] + "\n";
			
			for (var i:uint = 0; i < len; ++i) {
				for (var j:uint = 0; j < _numPoses; ++j) {
					code += "mul " + temp1 + ", va" + (streamIndex + k) + ", vc" + pass.numUsedVertexConstants + "." + regs[j] + "\n" +
						"add " + targetRegisters[i] + ", " + targetRegisters[i] + ", " + temp1 + "\n";
					k++;
				}
			}
			
			if (useTangents) {
				code += "dp3 " + temp1 + ".x, " + sourceRegisters[uint(2)] + ", " + targetRegisters[uint(1)] + "\n" +
					"mul " + temp1 + ", " + targetRegisters[uint(1)] + ", " + temp1 + ".x			 \n" +
					"sub " + targetRegisters[uint(2)] + ", " + sourceRegisters[uint(2)] + ", " + temp1 + "\n";
			}
			
			return code;
		}
	}
}
