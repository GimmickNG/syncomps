package syncomps 
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class GraphicButton extends SimpleButton
	{
		public function GraphicButton(graphic:DisplayObject) {
			super(graphic, graphic, graphic, graphic)
		}
		public function unload():void {
			upState = overState = downState = hitTestState = null
		}
	}

}