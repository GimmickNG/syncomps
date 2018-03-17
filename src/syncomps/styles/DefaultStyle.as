package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class DefaultStyle extends Style
	{
		public static const BACKGROUND:String = "backgroundSkinColor"
		public static const DISABLED:String = "disabledSkinColor"
		public static const SELECTED:String = "selectedColor"
		public static const ICON_SIZE:String = "iconSize"
		public static const HOVER:String = "hoverColor"
		public static const DOWN:String = "downColor"
		public function DefaultStyle() 
		{
			super(null, [BACKGROUND, DISABLED, SELECTED, HOVER, DOWN, ICON_SIZE])
			init()
		}
		private function init():void
		{
			setStyle(ICON_SIZE, 16)
			setStyle(DOWN, 0xFF4ABCE8)
			setStyle(HOVER, 0xFFF1F1F1)
			setStyle(DISABLED, 0xFFBBBBBB)
			setStyle(SELECTED, 0xFFC0C0C0)
			setStyle(BACKGROUND, 0xFFDEDEDE)
		}
	}

}