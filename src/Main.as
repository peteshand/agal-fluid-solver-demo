package 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Worker;
	import worker.FluidWorker;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	[SWF(backgroundColor = "#000000", width = "1080", height = "500", frameRate = "60")]
	
	public class Main extends Sprite 
	{
		private var view:View3D;
		private var dust:Dust;
		private var fluidWorker:FluidWorker;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (Worker.current.isPrimordial) {
				init3DScene();
			}
			else {
				fluidWorker = new FluidWorker();
			}
		}
		
		private function init3DScene():void 
		{
			view = new View3D();
			addChild(view);
			view.antiAlias = 4;
			view.backgroundColor = 0x000000;
			
			var awayStats:AwayStats = new AwayStats(view);
			addChild(awayStats);
			
			var scaleContainer:ObjectContainer3D = new ObjectContainer3D();
			scaleContainer.scale(2.31);
			view.scene.addChild(scaleContainer);
			
			for (var i:int = 0; i < 1; i++) 
			{
				dust = new Dust(stage);
				dust.x = -stage.stageWidth / 2;
				dust.y = stage.stageHeight / 2;
				scaleContainer.addChild(dust);
			}
			
			
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function Update(e:Event):void 
		{
			view.render();
		}
	}
}