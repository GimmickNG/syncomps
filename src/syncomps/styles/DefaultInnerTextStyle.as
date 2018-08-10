package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DefaultInnerTextStyle extends Style
	{
		public static const BORDER:String = "borderColor"
		public function DefaultInnerTextStyle() 
		{
			super([DefaultStyle, SkinnableTextStyle])
			appendStyle(BORDER, 0xFF000000)
		}
	}

}