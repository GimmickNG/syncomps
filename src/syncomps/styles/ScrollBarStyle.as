package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class ScrollBarStyle extends Style
	{
		public static const BACKGROUND_SECONDARY:String = "secondaryBackgroundColor"
		public static const SCROLL_DIRECTION:String = "scrollDirection"
		
		public static const DIRECTION_VERTICAL:int = 8;
		public static const DIRECTION_HORIZONTAL:int = 16;
		public function ScrollBarStyle() 
		{
			super([DefaultStyle], [BACKGROUND_SECONDARY, SCROLL_DIRECTION])
			init()
		}
		private function init():void
		{
			setStyle(BACKGROUND_SECONDARY, 0xFF444444)
			setStyle(SCROLL_DIRECTION, DIRECTION_VERTICAL)
		}
	}

}