package syncomps.styles 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class LabeledButtonStyle extends DefaultInnerTextStyle
	{
		public static const EMPHASIZED_LINE_COLOR:String = "emphasizedLineColor"
		public function LabeledButtonStyle() {
			appendStyle(EMPHASIZED_LINE_COLOR, 0xFF000000)
		}
	}

}