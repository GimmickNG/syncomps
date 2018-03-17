package syncomps 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IAutoResize;
	import syncomps.interfaces.ILabel;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name = "click", type = "flash.events.MouseEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ListCell extends SynComponent implements IAutoResize, ILabel
	{
		public static const DEF_WIDTH:uint = 96;
		public static const DEF_HEIGHT:uint = 24;
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private var i_index:int;
		private var bmp_icon:Bitmap;
		private var b_selected:Boolean;
		private var b_dispatchClick:Boolean;
		private var tf_label:SkinnableTextField
		public function ListCell() 
		{
			super()
			init()
		}
		private function init():void
		{
			tf_label = new SkinnableTextField()
			bmp_icon = new Bitmap(null, PixelSnapping.ALWAYS, true)
			
			tf_label.selectable = tf_label.multiline = tf_label.mouseEnabled = false;
			b_selected = false;
			addChild(tf_label)
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			label = null
			
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent, false, 0, true)
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function updateStyles(evt:StyleEvent):void {
			tf_label.setStyle(evt.style, evt.value)
		}
		
		private function changeState(evt:Event):void
		{
			switch(evt.type)
			{
				case MouseEvent.MOUSE_DOWN:
					drawGraphics(width, height, DefaultStyle.DOWN);
					break;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.RELEASE_OUTSIDE:
				case MouseEvent.ROLL_OUT:
				case FocusEvent.FOCUS_OUT:
					resetBackground()
					break;
				case MouseEvent.ROLL_OVER:
				case FocusEvent.FOCUS_IN:
					drawGraphics(width, height, DefaultStyle.HOVER);
					break;
			}
		}
		
		private function dispatchClickEvent(evt:KeyboardEvent):void 
		{
			if (b_dispatchClick)
			{
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false))
				b_dispatchClick = false
			}
			resetBackground()
		}
		
		private function startDispatchClickEvent(evt:KeyboardEvent):void 
		{
			if (!b_dispatchClick && (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.SPACE))
			{
				drawGraphics(width, height, DefaultStyle.DOWN);
				b_dispatchClick = true
			}
		}
		
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		
		public function set selected(value:Boolean):void
		{
			b_selected = value
			resetBackground()
		}
		public function get selected():Boolean {
			return b_selected
		}
		
		public function get iconSize():int {
			return int(getStyle(DefaultStyle.ICON_SIZE))
		}
		
		public function set iconSize(value:int):void {
			setStyle(DefaultStyle.ICON_SIZE, value)
		}
		
		private function resetBackground():void
		{
			if(b_selected) {
				drawGraphics(width, height, DefaultStyle.SELECTED)
			}
			else {
				drawGraphics(width, height, DefaultStyle.BACKGROUND)
			}
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			var colour:uint = uint(getStyle(state)), colourAlpha:Number;
			if (!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			super.drawGraphics(width, height, state)
			graphics.clear();
			graphics.beginFill(colour, colourAlpha)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			tf_label.y = (height - (tf_label.height + 4)) * 0.5
			if (tf_label.y < 0)
			{
				tf_label.y = 0;
				tf_label.height = height
			}
			bmp_icon.y = (height - (bmp_icon.height)) * 0.5
			if (width > 12 && bmp_icon.bitmapData)
			{
				addChild(bmp_icon)
				bmp_icon.x = 8
			}
			else if(bmp_icon.parent) {
				removeChild(bmp_icon)
			}
			if (bmp_icon.parent) {
				tf_label.x = bmp_icon.x + bmp_icon.width + 4
			}
			else if(width > 8) {
				tf_label.x = 8
			}
			else {
				tf_label.x = width * 0.25
			}
			tf_label.width = width - tf_label.x
		}
		
		override public function unload():void
		{
			super.unload()
			i_index = -1
			icon = null
			removeChildren()
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState)
			removeEventListener(MouseEvent.MOUSE_UP, changeState)
			removeEventListener(MouseEvent.ROLL_OUT, changeState)
			removeEventListener(MouseEvent.ROLL_OVER, changeState)
			removeEventListener(FocusEvent.FOCUS_IN, changeState)
			removeEventListener(FocusEvent.FOCUS_OUT, changeState)
			removeEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent)
			removeEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent)
		}
		
		public function resizeWidth():void 
		{
			tf_label.autoSize = TextFieldAutoSize.LEFT
			drawGraphics(tf_label.x + tf_label.width + 4, height, str_state)
			tf_label.autoSize = TextFieldAutoSize.NONE
		}
		
		public function resizeHeight():void 
		{
			var maxHeight:int = bmp_icon.height
			if(tf_label.height > maxHeight) {
				maxHeight = tf_label.height
			}
			drawGraphics(width, maxHeight + 4, str_state)
		}
		
		public function get textField():TextField {
			return tf_label
		}
		
		public function get label():String
		{
			return tf_label.text;
		}
		
		public function set label(value:String):void 
		{
			if (value && value.length) {
				tf_label.text = value
			}
			else {
				tf_label.text = " ";
			}
			tf_label.height = tf_label.textHeight + 4
			if (!(value && value.length)) {
				tf_label.text = ""
			}
		}
		
		public function get index():int 
		{
			return i_index;
		}
		
		public function set index(value:int):void 
		{
			i_index = value;
		}
		
		public function get icon():BitmapData {
			return bmp_icon.bitmapData;
		}
		
		public function set icon(value:BitmapData):void 
		{
			var width:int = this.width
			var height:int = this.height
			bmp_icon.bitmapData = value;
			if (bmp_icon.width && bmp_icon.height) {
				bmp_icon.width = bmp_icon.height = iconSize
			}
			drawGraphics(width, height, str_state)
		}
		
	}

}