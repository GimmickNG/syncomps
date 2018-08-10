package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollPaneStyle extends Style
	{
		public static const POLICY_HORIZONTAL:int = 1;
		public static const POLICY_VERTICAL:int = 2;
		public static const POLICY_BOTH:int = 3;
		public static const POLICY_NONE:int = 0;
		
		public static const MASK:int = 4;
		public static const SCROLL_RECT:int = 5;
		public static const MASK_METHOD:String = "maskMethod"
		public static const SCROLL_SIZE:String = "scrollSize"
		public static const SCROLL_POLICY:String = "scrollPolicy"
		public function ScrollPaneStyle() 
		{
			super([DefaultStyle, ScrollBarStyle])
			appendStyle(SCROLL_POLICY, POLICY_NONE)
			appendStyle(MASK_METHOD, MASK)
			appendStyle(SCROLL_SIZE, 1)
		}
	}

}