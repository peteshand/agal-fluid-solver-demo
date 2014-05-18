package ru.inspirit.utils 
{

	/**
	 * @author Eugene Zatepyakin
	 */
	public class NumberUtils 
	{
		public static function normalize(value:Number, minimum:Number, maximum:Number):Number
		{
			return (value - minimum) / (maximum - minimum);
		}

		public static function interpolate(normValue:Number, minimum:Number, maximum:Number):Number
		{
			return minimum + (maximum - minimum) * normValue;
		}

		public static function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number
		{
			return min2 + (max2 - min2) * ( (value - min1) / (max1 - min1) );
		}
	}
}
