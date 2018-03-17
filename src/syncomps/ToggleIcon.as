package syncomps
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.display.Shape;
	
	public class ToggleIcon extends Sprite
	{
		public static const ON:Boolean = true;
		public static const OFF:Boolean = false;
		
		private var spr_icon:Sprite;
		private var bmp_on:Bitmap;
		private var bmp_off:Bitmap;
		
		public function ToggleIcon() {
			init(null, null, false)
		}
		public function update(bitmapOn:BitmapData, bitmapOff:BitmapData):void
		{
			bmp_off.bitmapData = bitmapOff
			bmp_on.bitmapData = bitmapOn	
		}
		private function init(bitmapOn:BitmapData, bitmapOff:BitmapData, visibleInit:Boolean):void 
		{
			spr_icon = new Sprite()
			bmp_on = new Bitmap()
			bmp_off = new Bitmap()
			
			update(bitmapOn, bitmapOff)
			
			spr_icon.addChild(bmp_on)
			spr_icon.addChild(bmp_off)
			
			bmp_on.visible = visibleInit
			bmp_off.visible = !visibleInit
			
			mouseChildren = false
			addChild(spr_icon)
		}
		
		public function get state():Boolean {
			return bmp_on.visible
		}
		
		public function set state(state:Boolean):void
		{
			bmp_on.visible = state
			bmp_off.visible = !state
		}
		
		public function get enabled():Boolean {
			return mouseEnabled
		}
		
		public function set enabled(value:Boolean):void {
			mouseEnabled = mouseChildren = value;
		}
		
		public function unload():void
		{
			removeChildren()
			update(null, null)
			spr_icon.removeChildren()
		}
	}
	
}
