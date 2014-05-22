package worker 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import logging.FileLog;
	import logging.Log;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class FluidWorker 
	{
		protected var _worker:Worker;
		protected var mainToBack:MessageChannel;
		protected var backToMain:MessageChannel;
		private var solver:Solver;
		
		private var _vec:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		public function FluidWorker() 
		{
			
			_worker = Worker.current;
			mainToBack = MessageChannel(Worker(_worker).getSharedProperty("mainToBack"));
			if (mainToBack) mainToBack.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			
			backToMain = MessageChannel(Worker(_worker).getSharedProperty("backToMain"));
			backToMain.send( { msg:"INIT_STARTED" } );
			
			solver = new Solver(_worker, mainToBack, backToMain);
			
			
		}
		
		protected function onMainToBack(event:Event):void
		{
			solver.onMainToBack(event);
		}
	}
}