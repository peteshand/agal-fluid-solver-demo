package methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	
	use namespace arcane;

	public class PixelMethod extends EffectMethodBase
	{
		public var colourData:Vector.<Number>;
		public var numRegisters:int = 25;
		
		public function PixelMethod()
		{
			super();
		}

		override arcane function initVO(vo : MethodVO) : void
		{
			vo.needsProjection = true;
		}

		override arcane function initConstants(vo : MethodVO) : void
		{
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			data[index+3] = 1;
			data[index+6] = 0;
			data[index+7] = 0;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			var context:Context3D = stage3DProxy.context3D;
			    
			if (colourData) {
				//context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colourData, numRegisters);
			}
		}

		arcane override function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			//var fogColor : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			//var fogData : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			//var temp : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			//regCache.addFragmentTempUsages(temp, 1);
			//var temp2 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			//var temp3 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			//var temp4 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			var code : String = "";
			
			//vo.fragmentConstantsIndex = fogColor.index * 4;
			
			
			
			//code += "// frag test \n";
			
			code += "mul ft1.x, ft1.x, v2.w \n"; // move index into vt1.w
			
			//trace("fogColor = " + fogColor);
			//trace("fogData = " + fogData);
			//trace("targetReg = " + targetReg);
			
			//code += "mov ft0.x, fc[v1.w].x \n";
			
			//regCache.removeFragmentTempUsage(temp);
			
			return code;
		}
	}
}
