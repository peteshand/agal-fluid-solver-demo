package  
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	//import logging.FileLog;
	//import logging.Log;
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
		public var sw:uint;
		public var sh:uint;
		public var isw:Number;
		public var ish:Number;
		
		public var particleManager:ParticleManager;
		
		public var mx:uint = 0;
		public var my:uint = 0;
		public var aspectRatio:Number;
		public var aspectRatio2:Number;
		private var forceIndex:int;
		private var velocityMult:Number = 20.0;
		
		private var prevMouse:Point = new Point();
		private var NormX:Number = 0;
		private var NormY:Number = 0;
		private var VelX:Number;
		private var VelY:Number;
		
		private var worker:Worker;
		private var mainToBack:MessageChannel;
		private var backToMain:MessageChannel;
		private var index:int = 0;
		private var sentObject:*;
		private var returnObject:Object;
		private var ba:ByteArray = new ByteArray();
		
		public function Solver(worker:Worker=null, mainToBack:MessageChannel=null, backToMain:MessageChannel=null) 
		{
			this.worker = worker;
			this.mainToBack = mainToBack;
			this.backToMain = backToMain;
			
			sw = Settings.width;
			sh = Settings.height;
			isw = 1 / sw;
			ish = 1 / sh;
			
			aspectRatio = sw * ish;
			aspectRatio2 = aspectRatio * aspectRatio;
			
			VelX = -prevMouse.x * isw;
			VelY = -prevMouse.y * ish;
			
			if (worker) {
				this.backToMain = backToMain;
				this.mainToBack = mainToBack;
				this.worker = worker;
				
				index = worker.getSharedProperty("index");
				
				//Log.saveDestination = FileLog.DESTINATION_DESKTOP;
				//Log.fileName = 'worker_' + index + ".txt";
				//Log.Trace(this, "TEST");
				
			}
			
			fSolver = new FluidSolver( Settings.FLUID_WIDTH, int( Settings.FLUID_WIDTH * sh / sw ) );
			fSolver.rgb = false;
			fSolver.fadeSpeed = Settings.fadeSpeed;
			fSolver.deltaT = Settings.deltaT;
			fSolver.viscosity = Settings.viscosity;
			
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
				//msgObject.vec = vec;
				
				ba.clear();
				ba.writeObject(vec);
				msgObject.ba = ba;
				
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