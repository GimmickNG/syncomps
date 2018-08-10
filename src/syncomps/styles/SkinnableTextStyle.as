package syncomps.styles 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SkinnableTextStyle extends Style
	{
		public static const ENABLED:String = "enabledTextColor"
		public static const DISABLED:String = "disabledTextColor"
		public static const EMBED_FONTS:String = "embedFonts"
		public static const TEXT_FORMAT:String = "textFormat"
		
		public function SkinnableTextStyle() 
		{
			super()
			appendStyle(DISABLED, 0xFF808080)
			appendStyle(ENABLED, 0xFF000000)
			appendStyle(EMBED_FONTS, false)
			appendStyle(TEXT_FORMAT, null)
		}
	}

}