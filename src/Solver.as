package  
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.Endian;
	import logging.FileLog;
	import logging.Log;
	import org.osflash.signals.Signal;
	import ru.inspirit.utils.FluidSolver;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Solver extends BaseSolver 
	{
		public var fSolver:FluidSolver;
		private var forceSpeed:Number;
		public var sw:uint = 1080;
		public var sh:uint = 500;
		public const FLUID_WIDTH:uint = 60;
		public var isw:Number = 1 / sw;
		public var ish:Number = 1 / sh;
		
		public var particleManager:ParticleManager;
		
		public var mx:uint = 0;
		public var my:uint = 0;
		public var aspectRatio:Number = sw * ish;
		public var aspectRatio2:Number = aspectRatio * aspectRatio;
		private var forceIndex:int;
		private var velocityMult:Number = 20.0;
		
		private var prevMouse:Point = new Point();
		private var NormX:Number = NormX = 0 * isw;
		private var NormY:Number = NormY = 0 * ish;
		private var VelX:Number = (0 - prevMouse.x) * isw;
		private var VelY:Number = (0 - prevMouse.y) * ish;
		
		private var worker:Worker;
		private var mainToBack:MessageChannel;
		private var backToMain:MessageChannel;
		private var index:int = 0;
		private var sentObject:*;
		private var returnObject:Object;
		
		public function Solver(worker:Worker=null, mainToBack:MessageChannel=null, backToMain:MessageChannel=null) 
		{
			if (worker) {
				this.backToMain = backToMain;
				this.mainToBack = mainToBack;
				this.worker = worker;
				
				index = worker.getSharedProperty("index");
				
				Log.saveDestination = FileLog.DESTINATION_DESKTOP;
				Log.fileName = 'worker_' + index + ".txt";
				//Log.Trace(this, "TEST");
				
			}
			
			fSolver = new FluidSolver( FLUID_WIDTH, int( FLUID_WIDTH * sh / sw ) );
			fSolver.rgb = false;
			fSolver.fadeSpeed = .007;
			fSolver.deltaT = .3;
			fSolver.viscosity = 0.001;
			
			particleManager = new ParticleManager(this, particlesPerBatch, batches);
			
			
			
		}
		
		override public function init():void 
		{
			var velRange:Number = 0.00001;
			for (var i:int = 0; i < numOfParticles; i++) 
			{
				addForce(Math.random(), Math.random(), (Math.random() * velRange) - (velRange/2), (Math.random() * velRange) - (velRange/2), true);
			}
			onInit.dispatch();
		}
		
		public function onMainToBack(event:Event):void 
		{
			if (mainToBack.messageAvailable) {
				sentObject = mainToBack.receive();
				if (sentObject.msg == "INIT")
				{
					init();
				}
				else if (sentObject.msg == "HandleForce")
				{
					handleForce(sentObject.x, sentObject.y);
				}
				else if (sentObject.msg == "Update")
				{
					Update();
				}
			}
		}
		
		override public function Update():void 
		{
			fSolver.update();
			particleManager.update(null, false);
			
			onUpdate.dispatch();
			
			if (backToMain){
				var msgObject:Object = new Object();
				msgObject.msg = 'UPDATE';
				msgObject.vec = this.vec;
				backToMain.send(msgObject);
			}
		}
		
		private function addForce(x:Number, y:Number, dx:Number, dy:Number, addParticle:Boolean=true):void
		{
			forceSpeed = dx * dx  + dy * dy * aspectRatio2;
			if(forceSpeed > 0) {
				if (x < 0) x = 0;
				else if (x > 1) x = 1;
				if (y < 0) y = 0;
				else if (y > 1) y = 1;
				
				
				forceIndex = fSolver.getIndexForNormalizedPosition(x, y);
				if (addParticle) particleManager.addParticles(x * sw, y * sh, 1);
				fSolver.uOld[forceIndex] += dx * velocityMult;
				fSolver.vOld[forceIndex] += dy * velocityMult;
			}
		}
		
		override public function handleForce(x:Number, y:Number):void
		{
			//Log.Trace(this, "x="+x + " y="+y);
			NormX = x * isw;
			NormY = y * ish;
			VelX = (x - prevMouse.x) * isw;
			VelY = (y - prevMouse.y) * ish;
			addForce(NormX, NormY, VelX, VelY, false);
			prevMouse.x = x;
			prevMouse.y = y;
		}
		
		override public function get vec():Vector.<Vector.<Number>> 
		{
			return particleManager.vec;
		}
		
		override public function set vec(value:Vector.<Vector.<Number>>):void 
		{
			particleManager.vec = value;
		}
	}

}