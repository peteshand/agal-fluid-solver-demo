package  
{
	import animators.PointCloudAnimationSet;
	import animators.PointCloudAnimator;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	import away3d.tools.commands.Merge;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import methods.PixelMethod;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class ParticleBatch extends ObjectContainer3D 
	{
		private var pointGeo:PlaneGeometry;
		private var merge:Merge;
		
		private var pointCloudAnimationSet:PointCloudAnimationSet;
		
		[Embed(source="bokeh1.png", mimeType="image/png")]
		private const bokeh1Class:Class;
		private var _bokeh1:BitmapData;
		
		private static var sharedContainer:Mesh;
		private var container:Mesh;
		
		public function get bokeh1():BitmapData{
			if (!_bokeh1) _bokeh1 = (new bokeh1Class()).bitmapData;
			return _bokeh1;
		}
		
		public function ParticleBatch() 
		{
			super();
			
			var texture:BitmapTexture = new BitmapTexture(bokeh1);
			var pointMaterial:TextureMaterial = new TextureMaterial(texture);
			pointMaterial.alphaBlending = true;
			pointMaterial.blendMode = BlendMode.ADD;
			
			
			if (!sharedContainer){
				pointGeo = new PlaneGeometry(4, 4, 1, 1, false);
				
				var mergeContainer:ObjectContainer3D = new ObjectContainer3D();
				for (var i:int = 0; i < 100; ++i)
				{
					var mesh:Mesh = new Mesh(pointGeo.clone(), null);
					mesh.z = 10 + i;
					mergeContainer.addChild(mesh);
				}
				
				sharedContainer = new Mesh(pointGeo, pointMaterial);
				
				merge = new Merge();
				merge.applyToContainer(sharedContainer, mergeContainer);
				
				sharedContainer.bounds.fromSphere(new Vector3D(), 100000);
			}
			
			container = new Mesh(sharedContainer.geometry.clone(), pointMaterial);
			addChild(container);
			
			pointCloudAnimationSet = new PointCloudAnimationSet(100);
			container.animator = new PointCloudAnimator(pointCloudAnimationSet);
			
			pointMaterial.addMethod(new PixelMethod());
			
		}
		
		public function set vec(value:Vector.<Number>):void 
		{
			pointCloudAnimationSet.positionData = value;
		}
	}
}