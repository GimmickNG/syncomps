package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class LabeledButtonStyle extends Style
	{
		public static const EMPHASIZED_LINE_COLOR:String = "emphasizedLineColor"
		public function LabeledButtonStyle() 
		{
			super([DefaultStyle, SkinnableTextStyle], [EMPHASIZED_LINE_COLOR])
			init()
		}
		
		private function init():void {
			setStyle(EMPHASIZED_LINE_COLOR, 0xFF000000)
		}
		
	}

}