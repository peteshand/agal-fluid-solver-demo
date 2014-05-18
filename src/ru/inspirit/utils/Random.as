package ru.inspirit.utils
{

	/**
	* Random generation functions
	* @author Eugene Zatepyakin
	*/
	public class Random
	{

		public static function random():Number
		{
			return Math.random();
		}

		public static function float(min:Number, max:Number = NaN):Number
		{
			if (isNaN(max)) { max = min; min=0; }
			return random()*(max-min)+min;
		}

		public static function boolean(chance:Number = 0.5):Boolean
		{
			return (random() < chance);
		}

		public static function sign(chance:Number = 0.5):int
		{
			return (random() < chance) ? 1 : -1;
		}

		public static function bit(chance:Number = 0.5):int
		{
			return (random() < chance) ? 1 : 0;
		}

		public static function integer(min:Number, max:Number = NaN):int
		{
			if (isNaN(max)) { max = min; min=0; }
			return Math.floor(float(min,max));
		}

	}

}