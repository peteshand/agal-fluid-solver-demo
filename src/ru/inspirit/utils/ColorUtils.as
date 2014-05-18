package ru.inspirit.utils 
{
	
	/**
	 * Various color related functions
	 * @author Eugene Zatepyakin
	 */
	public class ColorUtils 
	{
		
		public static function HSB2GRB(h:Number = 1, s:Number = 1, b:Number = 1):Object
		{
			h = int(h) % 360;
			var i:int = int(int(h / 60.0) % 6);
			var f:Number = h / 60.0 - int(h / 60.0);
			var p:Number = b * (1 - s);
			var q:Number = b * (1 - s * f);
			var t:Number = b * (1 - (1 - f) * s);
			switch (i) {   
				case 0: return { r:b, g:t, b:p };
				case 1: return { r:q, g:b, b:p };
				case 2: return { r:p, g:b, b:t };
				case 3: return { r:p, g:q, b:b };
				case 4: return { r:t, g:p, b:b };
				case 5: return { r:b, g:p, b:q };
			}
			return { r:0, g:0, b:0 };
		}
		
	}
	
}