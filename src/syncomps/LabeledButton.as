package syncomps 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import syncomps.events.ButtonEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IAutoResize;
	import syncomps.interfaces.ILabel;
	import syncomps.styles.LabeledButtonStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name = "CLICK", type = "syncomps.events.ButtonEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class LabeledButton extends SynComponent implements IAutoResize, ILabel
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32;
		
		protected static var DEFAULT_STYLE:Class = LabeledButtonStyle
		
		private var tf_label:SkinnableTextField;
		private var bmp_icon:Bitmap;
		private var b_emphasized:Boolean;
		private var spr_group:Sprite;
		private var b_dispatchClick:Boolean;
		private var num_maxWidth:Number;
		public function LabeledButton() {
			init();
		}
		
		private function init():void
		{
			bmp_icon = new Bitmap()
			spr_group = new Sprite()
			tf_label = new SkinnableTextField()
			StyleManager.unregister(tf_label)
			
			spr_group.addChild(bmp_icon)
			spr_group.addChild(tf_label)
			spr_group.x = 4;
			tf_label.multiline = tf_label.enabled = tf_label.selectable = false;
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			label = null;
			showText()
			
			addChild(spr_group)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			addEventListener(MouseEvent.CLICK, dispatchClickEvent, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent, false, 0, true)
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			tf_label.setStyle(evt.style, evt.value)
			num_maxWidth = tf_label.getLineMetrics(0).width + 4
		}
		
		private function dispatchClickEvent(evt:Event):void 
		{
			if (evt.type == MouseEvent.CLICK || b_dispatchClick)
			{
				drawGraphics(width, height, DefaultStyle.BACKGROUND);
				dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, true, false))
			}
			b_dispatchClick = false
		}
		
		private function startDispatchClickEvent(evt:KeyboardEvent):void 
		{
			if ((evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.SPACE))
			{
				drawGraphics(width, height, DefaultStyle.DOWN);
				b_dispatchClick = true
			}
		}
		
		public function set label(text:String):void
		{
			var prevWidth:int = width;
			var prevHeight:int = height;
			tf_label.text = ''
			if(text && text.length) {
				tf_label.text = text
			}
			num_maxWidth = tf_label.getLineMetrics(0).width + 4
			drawGraphics(prevWidth, prevHeight, str_state)
		}
		
		public function get label():String {
			return tf_label.text
		}
		
		public function set emphasized(value:Boolean):void 
		{
			if (b_emphasized != value)
			{
				b_emphasized = value
				drawGraphics(width, height, str_state)
			}
		}
		public function get emphasized():Boolean {
			return b_emphasized
		}
		
		public function set icon(bitmap:BitmapData):void
		{
			var width:int = this.width
			var height:int = this.height
			bmp_icon.bitmapData = bitmap
			tf_label.x = 0;
			if (bmp_icon.width)
			{
				bmp_icon.width = bmp_icon.height = iconSize
				tf_label.x = bmp_icon.width + 4;
			}
			drawGraphics(width, height, str_state)
		}
		
		public function get iconSize():int {
			return int(getStyle(DefaultStyle.ICON_SIZE))
		}
		
		public function set iconSize(value:int):void {
			setStyle(DefaultStyle.ICON_SIZE, value)
		}
		
		public function get icon():BitmapData {
			return bmp_icon.bitmapData
		}
		
		private function changeState(evt:Event):void
		{
			switch(evt.type)
			{
				case MouseEvent.MOUSE_DOWN:
					drawGraphics(width, height, DefaultStyle.DOWN);
					break;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.ROLL_OUT:
				case FocusEvent.FOCUS_OUT:
					drawGraphics(width, height, DefaultStyle.BACKGROUND);
					break;
				case MouseEvent.ROLL_OVER:
				case FocusEvent.FOCUS_IN:
					drawGraphics(width, height, DefaultStyle.HOVER);
					break;
			}
		}
		
		public function resizeWidth():void 
		{
			tf_label.autoSize = TextFieldAutoSize.LEFT
			var widthVal:Number = tf_label.width
			if(bmp_icon.bitmapData && bmp_icon.parent) {
				widthVal += bmp_icon.bitmapData.width + 16
			}
			tf_label.autoSize = TextFieldAutoSize.NONE
			width = widthVal
		}
		
		public function resizeHeight():void {
			height = tf_label.textHeight + 16
		}
		
		public function get textField():TextField {
			return tf_label
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			var colour:uint = uint(getStyle(state)), colourAlpha:Number;
			var sizeShift:int = int(enabled && emphasized)
			graphics.clear()
			if (!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			else if (emphasized) {
				graphics.lineStyle(1, uint(getStyle(LabeledButtonStyle.EMPHASIZED_LINE_COLOR)))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			graphics.beginFill(colour, colourAlpha)
			graphics.drawRect(0, 0, width - sizeShift, height - sizeShift);
			graphics.endFill()
			bmp_icon.x = 0
			
			var iconSpacing:int = 0;
			if (bmp_icon.width && bmp_icon.height) {
				iconSpacing = bmp_icon.width
			}
			
			tf_label.height = height
			if(tf_label.textHeight && tf_label.height >= tf_label.textHeight + 4) {
				tf_label.height = tf_label.textHeight + 4
			}
			
			tf_label.width = num_maxWidth
			bmp_icon.y = (tf_label.height - bmp_icon.height) * 0.5
			if (tf_label.width > width - (8 + iconSpacing)) {
				tf_label.width = width - (8 + iconSpacing)
			}
			spr_group.x = (width - spr_group.width) * 0.5
			spr_group.y = (height - spr_group.height) * 0.5
			if (emphasized && enabled)
			{
				graphics.lineStyle(undefined)
				graphics.beginFill(uint(getStyle(LabeledButtonStyle.EMPHASIZED_LINE_COLOR)), 1)
				graphics.drawTriangles(new <Number>[width - sizeShift, height * 0.25, width * 0.95, height * 0.5, width - sizeShift, height * 0.75])
				graphics.drawTriangles(new <Number>[sizeShift, height * 0.25, width * 0.05, height * 0.5, sizeShift, height * 0.75])
				graphics.endFill()
			}
		}
		override public function unload():void
		{
			super.unload()
			removeChildren();
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState)
			removeEventListener(MouseEvent.MOUSE_UP, changeState)
			removeEventListener(MouseEvent.ROLL_OUT, changeState)
			removeEventListener(MouseEvent.ROLL_OVER, changeState)
			removeEventListener(FocusEvent.FOCUS_IN, changeState)
			removeEventListener(FocusEvent.FOCUS_OUT, changeState)
			removeEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent)
			removeEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent)
		}
		
		public function hideText():void 
		{
			if (tf_label.parent) {
				spr_group.removeChild(tf_label)
			}
		}
		
		public function showText():void {
			spr_group.addChild(tf_label)
		}
		
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
	}

}