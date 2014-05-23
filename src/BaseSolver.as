package  
{
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class BaseSolver 
	{
		public static var batches:int = Settings.batches;
		public static var particlesPerBatch:int = 125;
		public static var numOfParticles:uint = particlesPerBatch * batches;
		
		public var onInit:Signal = new Signal();
		public var onUpdate:Signal = new Signal();
		
		public function BaseSolver() 
		{
			
		}
		
		public function Update():void 
		{
			
		}
		
		public function handleForce(x:Number, y:Number):void
		{
			
		}
		
		public function init():void 
		{
			
		}
		
		public function get vec():Vector.<Vector.<Number>> 
		{
			return new Vector.<Vector.<Number>>();
		}
		
		public function set vec(value:Vector.<Vector.<Number>>):void 
		{
			
		}
	}

}