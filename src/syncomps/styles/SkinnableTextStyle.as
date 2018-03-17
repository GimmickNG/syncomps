package syncomps.styles 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class SkinnableTextStyle extends Style
	{
		public static const ENABLED:String = "enabledTextColor"
		public static const DISABLED:String = "disabledTextColor"
		public static const EMBED_FONTS:String = "embedFonts"
		public static const TEXT_FORMAT:String = "textFormat"
		
		public function SkinnableTextStyle() 
		{
			super(null, [EMBED_FONTS, TEXT_FORMAT, ENABLED, DISABLED])
			init()
		}
		
		private function init():void
		{
			setStyle(ENABLED, 0xFF000000)
			setStyle(DISABLED, 0xFF808080)
			setStyle(EMBED_FONTS, false)
			setStyle(TEXT_FORMAT, null)
		}
	}

}