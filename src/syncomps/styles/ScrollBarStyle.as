package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollBarStyle extends Style
	{
		public static const BACKGROUND_SECONDARY:String = "secondaryBackgroundColor"
		public static const SCROLL_DIRECTION:String = "scrollDirection"
		
		public static const DIRECTION_VERTICAL:int = 8;
		public static const DIRECTION_HORIZONTAL:int = 16;
		public function ScrollBarStyle() 
		{
			super([DefaultStyle])
			appendStyle(SCROLL_DIRECTION, DIRECTION_VERTICAL)
			appendStyle(BACKGROUND_SECONDARY, 0xFF444444)
		}
	}

}