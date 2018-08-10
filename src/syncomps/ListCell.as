package syncomps 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import syncomps.events.ButtonEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.interfaces.graphics.IIcon;
	import syncomps.interfaces.graphics.ILabel;
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
	public class ListCell extends SynComponent implements IAutoResize, ILabel, IIcon
	{
		public static const DEF_WIDTH:uint = 96;
		public static const DEF_HEIGHT:uint = 24;
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private var i_index:int;
		private var cmpi_label:Label;
		private var b_selected:Boolean;
		private var cl_scrollTimer:Timer
		private var b_dispatchClick:Boolean;
		public function ListCell() 
		{
			super()
			init()
		}
		private function init():void
		{
			cmpi_label = new Label()
			cl_scrollTimer = new Timer(1000, 1)
			
			b_selected = false;
			addChild(cmpi_label)
			
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
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
			cl_scrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, changeLabelScrollH, false, 0, true)
		}
		
		private function changeLabelScrollH(evt:TimerEvent):void {
			cmpi_label.textField.scrollH = cmpi_label.textField.maxScrollH
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			cmpi_label.setStyle(evt.style, evt.value)
			drawGraphics(width, height, state)
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
				dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, true, false))
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
			super.drawGraphics(width, height, state)
			var color:uint = uint(getStyle(state)), colorAlpha:Number;
			var maxPadding:Number = (8 * (1 - Math.pow(1.2, -width)))
			if (!enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			
			graphics.clear();
			graphics.beginFill(color, colorAlpha)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			
			cmpi_label.resizeHeight()
			cmpi_label.x = maxPadding
			cmpi_label.width = width - cmpi_label.x
			if (height < cmpi_label.height) {
				cmpi_label.height = height
			}
			cmpi_label.y = (height - cmpi_label.height) * 0.5
			
			cl_scrollTimer.reset();
			cmpi_label.textField.scrollH = 0
			if(cmpi_label.textField.maxScrollH && state == DefaultStyle.HOVER) {
				cl_scrollTimer.start();
			}
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
			cmpi_label.resizeWidth()
			drawGraphics(cmpi_label.x + cmpi_label.width + 4, height, state)
		}
		
		public function resizeHeight():void 
		{
			cmpi_label.resizeHeight()
			drawGraphics(width, height, state)
		}
		
		public function get textField():TextField {
			return cmpi_label.textField
		}
		
		public function get label():String {
			return cmpi_label.label;
		}
		
		public function set label(value:String):void {
			cmpi_label.label = value || "";
		}
		
		public function get index():int {
			return i_index;
		}
		
		public function set index(value:int):void {
			i_index = value;
		}
		
		public function get icon():DisplayObject {
			return cmpi_label.icon
		}
		
		public function set icon(value:DisplayObject):void 
		{
			cmpi_label.icon = value
			drawGraphics(width, height, state)
		}
		
	}

}