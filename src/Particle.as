package  
{
	import ru.inspirit.utils.Random;
	import ru.inspirit.utils.FluidSolver;
	
	/**
	 * Basic particle unit
	 * @author Eugene Zatepyakin
	 */
	public class Particle 
	{
		public static var MOMENTUM:Number = 0.5;
		public static var FLUID_FORCE:Number = 0.6;
		
		private var fs:FluidSolver;
		public var x:Number = 0;
		public var y:Number = 0;
		public var vx:Number = 0;
		public var vy:Number = 0;
		public var vel:Number;
		public var radius:Number;
		public var alpha:Number;
		public var mass:Number;
		
		public var next:Particle;
		private var solver:Solver;
		private var fluidIndex:int;
		
		public function Particle(solver:Solver) 
		{
			this.solver = solver;
			fs = solver.fSolver;
			//sw = solver.sw;
			alpha = 0;
		}
		
		public function init(x:Number = 0, y:Number = 0):void
		{
			this.x = x;
			this.y = y;
			vx = vy = 0;
			radius = 5;
			alpha = Random.float(.3, 1);
			mass = Random.float(.1, 1);
		}
		
		public function update():void
		{
			if (alpha == 0) return;
			
			fluidIndex = fs.getIndexForNormalizedPosition(x * solver.isw, y * solver.ish);
			
			vx = fs.u[fluidIndex] * solver.sw * mass * FLUID_FORCE + vx * MOMENTUM;
			vy = fs.v[fluidIndex] * solver.sh * mass * FLUID_FORCE + vy * MOMENTUM;
			
			x += vx;
			y += vy;
			
			if (x < 0) {
				if (fs.wrapX) {
					x += solver.sw;
				} else {
					x = 1;
					vx *= -1;
				}
			}
			else if (x > solver.sw) {
				if (fs.wrapX) {
					x -= solver.sw;
				} else {
					x = solver.sw - 1;
					vx *= -1;
				}
			}
			
			if (y < 0) {
				if (fs.wrapY) {
					y += solver.sh;
				} else {
					y = 1;
					vy *= -1;
				}
			}
			else if (y > solver.sh) {
				if (fs.wrapY) {
					y -= solver.sh;
				} else {
					y = solver.sh - 1;
					vy *= -1;
				}
			}
			
			vel = Math.sqrt((vx * vx) + (vy * vy));
			vel /= 5;
			
			if (vel > 1) vel = 1;
			if (vel < 0) vel = 0;
			vel *= 3;
			alpha = vel;
			
			//vel *= 0.2;
			//alpha = 0.05 + vel;
		}
	}
}