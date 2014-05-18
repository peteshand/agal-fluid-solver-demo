package  
{
	import ru.inspirit.utils.ColorUtils;
	import ru.inspirit.utils.NumberUtils;
	import ru.inspirit.utils.Random;

	import flash.display.BitmapData;

	/**
	 * Particle manager implementing simple LinkedList
	 * @author Eugene Zatepyakin
	 */
	public class ParticleManager 
	{
		private var numOfParticles:int;
		private var particlesPerBatch:int;
		private var batches:int;
		
		public static const VMAX:Number = 0.013;
		public static const VMAX2:Number = VMAX * VMAX;
		
		public var head:Particle;
		public var tail:Particle;
		
		private var solver:Solver;
		
		private var _vec:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		public function ParticleManager(solver:Solver, particlesPerBatch:int, batches:int) 
		{
			this.solver = solver;
			this.particlesPerBatch = particlesPerBatch;
			this.batches = batches;
			
			this.numOfParticles = particlesPerBatch * batches;
			
			for (var i:int = 0; i < batches; i++) 
			{
				vec.push(new Vector.<Number>());
			}
			
			reset();
		}
		
		private var batchCount:int;
		private var particleCount:int;
		private var p:Particle;
		private var a:int;
		private var c:uint;
		private var vxNorm:Number;
		private var vyNorm:Number;
		private var satInc:Number;
		private var v2:Number;
		private var m:Number;
		private var rgb:Object;
		
		public function update(bmp:BitmapData, lines:Boolean):void
		{
			batchCount = 0;
			particleCount = 0;
			
			p = head;			
			
			while (p)
			{
				if (p.alpha > 0) 
				{
					p.update();
					a = int(p.alpha * 0xFF + .5);
					c = a << 24 | a << 16 | a << 8 | a;
				}
				
				vec[batchCount][particleCount++] = p.x;
				vec[batchCount][particleCount++] = -p.y;
				vec[batchCount][particleCount++] = 0;
				vec[batchCount][particleCount++] = p.alpha;
				
				if (particleCount >= particlesPerBatch * 4) {
					particleCount = 0;
					batchCount++;
				}
				p = p.next;
			}
			
		}
		
		public function reset():void
		{
			p = new Particle(solver);
			head = tail = p;
			
			for (var i:int = 1; i < numOfParticles; i++)
			{
				p = new Particle(solver);
				tail.next = p;
				tail = p;
			}
		}
		
		public function addParticles(x:Number, y:Number, n:int):void
		{
			while ( --n > -1) {
				addParticle(x + Random.float(-15, 15), y + Random.float(-15, 15));
			}
		}
		
		public function addParticle(x:Number, y:Number):void
		{
			p = head;
			
			head = head.next;
			tail.next = p;
			p.next = null;
			tail = p;
			
			tail.init(x, y);
		}
		
		static private var x:int;
		static private var y:int;
		static private var dx:int;
		static private var dy:int;
		static private var xinc:int;
		static private var yinc:int;
		static private var cumul:int;
		static private var i:int;
		
		public static function line(bmp:BitmapData, x0:int, y0:int, x1:int, y1:int, c:uint):void
		{	
			x = x0;
			y = y0;		
			dx = x1 - x0;
			dy = y1 - y0;
			xinc = ( dx > 0 ) ? 1 : -1;
			yinc = ( dy > 0 ) ? 1 : -1;			
			
			dx = (dx ^ (dx >> 31)) - (dx >> 31);//abs
			dy = (dy ^ (dy >> 31)) - (dy >> 31);
			
			bmp.setPixel32(x, y, c);
			
			if ( dx > dy ) {
				cumul = dx >> 1 ;
		  		for ( i = 1; i <= dx; ++i ) {
					x += xinc;
					cumul += dy;
					if (cumul >= dx){
			  			cumul -= dx;
			  			y += yinc;
					}
					bmp.setPixel32(x, y, c);
				}
			} else {
		  		cumul = dy >> 1;
		  		for ( i = 1; i <= dy; ++i ) {
					y += yinc;
					cumul += dx;
					if ( cumul >= dy ) {
			  			cumul -= dy;
			  			x += xinc;
					}
					bmp.setPixel32(x, y, c);
				}
			}
		}
		
		public function get vec():Vector.<Vector.<Number>> 
		{
			return _vec;
		}
		
		public function set vec(value:Vector.<Vector.<Number>>):void 
		{
			_vec = value;
		}
		
	}
	
}