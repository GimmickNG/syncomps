package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DefaultStyle extends Style
	{
		public static const BACKGROUND:String = "backgroundSkinColor"
		public static const DISABLED:String = "disabledSkinColor"
		public static const SELECTED:String = "selectedColor"
		public static const ICON_SIZE:String = "iconSize"
		public static const HOVER:String = "hoverColor"
		public static const DOWN:String = "downColor"
		public function DefaultStyle() 
		{
			super()
			appendStyle(BACKGROUND, 0xFFDEDEDE)
			appendStyle(SELECTED, 0xFFC0C0C0)
			appendStyle(DISABLED, 0xFFBBBBBB)
			appendStyle(HOVER, 0xFFF1F1F1)
			appendStyle(DOWN, 0xFF4ABCE8)
			appendStyle(ICON_SIZE, 16)
		}
	}

}