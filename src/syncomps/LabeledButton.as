package syncomps 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import syncomps.events.ButtonEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.interfaces.graphics.IIcon;
	import syncomps.interfaces.graphics.ILabel;
	import syncomps.styles.LabeledButtonStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name = "synBEButtonClick", type = "syncomps.events.ButtonEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class LabeledButton extends SynComponent implements IAutoResize, ILabel, IIcon
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32;
		
		protected static var DEFAULT_STYLE:Class = LabeledButtonStyle
		
		private var cmpi_label:Label
		private var b_emphasized:Boolean;
		private var b_dispatchClick:Boolean;
		private var shp_emphasizedOverlay:Shape
		public function LabeledButton() {
			init();
		}
		
		private function init():void
		{
			cmpi_label = new Label()
			shp_emphasizedOverlay = new Shape()
			StyleManager.unregister(cmpi_label)
			
			cmpi_label.x = 4;
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			label = null;
			
			addChild(cmpi_label)
			addChild(shp_emphasizedOverlay)
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
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
			var prevWidth:int = this.width, prevHeight:int = this.height
			cmpi_label.setStyle(evt.style, evt.value)
			
			cmpi_label.resizeWidth()
			cmpi_label.resizeHeight()
			drawGraphics(prevWidth, prevHeight, state)
		}
		
		private function dispatchClickEvent(evt:Event):void 
		{
			if (evt.type == MouseEvent.CLICK || b_dispatchClick)
			{
				drawGraphics(width, height, DefaultStyle.HOVER);
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
		
		public function set label(text:String):void {
			cmpi_label.label = text
		}
		
		public function get label():String {
			return cmpi_label.label
		}
		
		public function set emphasized(value:Boolean):void 
		{
			if (b_emphasized != value)
			{
				b_emphasized = value
				drawGraphics(width, height, state)
			}
		}
		public function get emphasized():Boolean {
			return b_emphasized
		}
		
		public function set icon(icon:DisplayObject):void
		{
			cmpi_label.icon = icon
			drawGraphics(width, height, state)
		}
		
		public function get iconSize():int {
			return int(getStyle(DefaultStyle.ICON_SIZE))
		}
		
		public function set iconSize(value:int):void {
			setStyle(DefaultStyle.ICON_SIZE, value)
		}
		
		public function get icon():DisplayObject {
			return cmpi_label.icon
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
			cmpi_label.resizeWidth()
			width = cmpi_label.width + 16
		}
		
		public function resizeHeight():void
		{
			cmpi_label.resizeHeight()
			height = cmpi_label.height + 16
		}
		
		public function get textField():TextField {
			return cmpi_label.textField
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			if(width < 0 || height < 0) {
				return;
			}
			
			graphics.clear()
			shp_emphasizedOverlay.graphics.clear()
			super.drawGraphics(width, height, state)
			var color:uint = uint(getStyle(state)), colorAlpha:Number;
			if (!enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			graphics.beginFill(color, colorAlpha)
			graphics.drawRect(0, 0, width, height);
			graphics.endFill()
			
			cmpi_label.resizeWidth()
			cmpi_label.resizeHeight()
			if(cmpi_label.width > width) {
				cmpi_label.width = width
			}
			if(cmpi_label.height > height) {
				cmpi_label.height = height
			}
			
			cmpi_label.x = int((width - cmpi_label.width) * 0.5)
			cmpi_label.y = int((height - cmpi_label.height) * 0.5)
			if (emphasized && enabled)
			{
				shp_emphasizedOverlay.graphics.lineStyle(1, uint(getStyle(LabeledButtonStyle.EMPHASIZED_LINE_COLOR)))
				shp_emphasizedOverlay.graphics.drawRect(0, 0, width - 1, height - 1)
				shp_emphasizedOverlay.graphics.beginFill(uint(getStyle(LabeledButtonStyle.EMPHASIZED_LINE_COLOR)), 1)
				shp_emphasizedOverlay.graphics.drawTriangles(new <Number>[width - 1, height * 0.25, width * 0.95, height * 0.5, width - 1, height * 0.75])
				shp_emphasizedOverlay.graphics.drawTriangles(new <Number>[1, height * 0.25, width * 0.05, height * 0.5, 1, height * 0.75])
				shp_emphasizedOverlay.graphics.endFill()
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
		
		public function hideText():void {
			cmpi_label.hideText()
		}
		
		public function showText():void {
			cmpi_label.showText()
		}
	}

}