package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class DefaultInnerTextStyle extends Style
	{
		public static const BORDER:String = "borderColor"
		public function DefaultInnerTextStyle() 
		{
			super([DefaultStyle, SkinnableTextStyle], [BORDER])
			init()
		}
		
		private function init():void {
			setStyle(BORDER, 0xFF000000)
		}
		
	}

}