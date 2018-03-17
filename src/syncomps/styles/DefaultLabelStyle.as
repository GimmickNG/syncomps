package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class DefaultLabelStyle extends Style
	{
		public static const LABEL_LEFT:int = 1;
		public static const LABEL_RIGHT:int = 2;
		public static const LABEL_ABOVE:int = 4;
		public static const LABEL_BELOW:int = 8;
		public static const LABEL_POSITION:String = "labelPosition"
		public function DefaultLabelStyle() 
		{
			super([DefaultStyle, SkinnableTextStyle], [LABEL_POSITION])
			init()
		}
		private function init():void {
			setStyle(LABEL_POSITION, LABEL_RIGHT)
		}
	}

}