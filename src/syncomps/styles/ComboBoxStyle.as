package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class ComboBoxStyle extends Style
	{
		public static const MENU:String = "menuSkinColor"
		public function ComboBoxStyle() 
		{
			super([DefaultStyle, SkinnableTextStyle], [MENU])
			init()
		}
		private function init():void {
			setStyle(MENU, 0xFFDEDEDE)
		}
	}

}