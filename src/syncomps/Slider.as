package syncomps 
{
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import syncomps.events.ScrollEvent;
	import syncomps.events.StyleEvent;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.ScrollBarStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.StyleManager;
	
	public class Slider extends SynComponent 
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32
		
		protected static var DEFAULT_STYLE:Class = DefaultStyle
		
		private var spr_thumb:Sprite
		private var num_max:Number;
		private var num_min:Number;
		private var b_dragging:Boolean;
		private var rect_drag:Rectangle;
		private var num_stepSize:Number;
		private var num_pageSize:Number;
		private var cmpi_end:Label
		private var cmpi_start:Label
		public function Slider() {
			init()
		}
		private function init():void
		{
			num_stepSize = 1
			spr_thumb = new Sprite()
			rect_drag = new Rectangle()
			cmpi_end = new Label()
			cmpi_start = new Label()
			
			StyleManager.unregister(cmpi_end)
			StyleManager.unregister(cmpi_start)
			
			addChild(cmpi_end)
			addChild(cmpi_start)
			addChild(spr_thumb)
			
			cmpi_start.setStyle(SkinnableTextStyle.TEXT_FORMAT, new TextFormat(null, null, null, null, null, null, null, null, TextFormatAlign.LEFT));
			cmpi_end.setStyle(SkinnableTextStyle.TEXT_FORMAT, new TextFormat(null, null, null, null, null, null, null, null, TextFormatAlign.RIGHT));
			
			setProperties(1, 0, 100)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			moveThumbTo(0)
			
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.CLICK, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_OVER, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			var prevWidth:int = width, prevHeight:int = height
			cmpi_start.setStyle(evt.style, evt.value)
			cmpi_end.setStyle(evt.style, evt.value)
			
			cmpi_end.resizeWidth()
			cmpi_start.resizeWidth()
			drawGraphics(prevWidth, prevHeight, state)
		}
		
		private function changeState(evt:Event):void
		{
			dragging &&= enabled
			if(!enabled) {
				return
			}
			else switch(evt.type)
			{
				case MouseEvent.CLICK:
					if (evt.target == this)
					{
						var newX:Number = mouseX
						if(newX < (height / 4) || newX > (width - (height / 4))) {
							return
						}
						spr_thumb.x = newX
						moveThumbTo(value)
						dispatchEvent(new Event(Event.CHANGE, false, false))
					}
					break
				case KeyboardEvent.KEY_DOWN:
					var keyCode:int = (evt as KeyboardEvent).keyCode
					if(keyCode == Keyboard.LEFT || keyCode == Keyboard.DOWN) {
						value -= stepSize
					}
					else if(keyCode == Keyboard.RIGHT || keyCode == Keyboard.UP) {
						value += stepSize
					}
					else if (keyCode == Keyboard.HOME) {
						value = minimum
					}
					else if (keyCode == Keyboard.END) {
						value = maximum
					}
					drawGraphics(width, height, DefaultStyle.DOWN)
					break;
				case MouseEvent.MOUSE_DOWN:
					if(evt.target == spr_thumb) {
						dragging = true;
					}
					drawGraphics(width, height, DefaultStyle.DOWN)
					break;
				case MouseEvent.RELEASE_OUTSIDE:
					dragging = false;
				case FocusEvent.FOCUS_OUT:
				case MouseEvent.ROLL_OUT:
					drawGraphics(width, height, DefaultStyle.BACKGROUND)
					break;
				case MouseEvent.MOUSE_UP:
					dragging = false
				case KeyboardEvent.KEY_UP:
				case MouseEvent.MOUSE_OVER:
				case FocusEvent.FOCUS_IN:
					drawGraphics(width, height, DefaultStyle.HOVER)
					break;
			}
		}
		
		private function changeValueThumb(evt:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CHANGE, false, false))
			drawGraphics(width, height, state)
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			if(width < 0 || height < 0) {
				return
			}
			var graphics:Graphics;
			var color:uint = uint(getStyle(state));
			var backgroundAlpha:Number, colorAlpha:Number;
			var background:uint = uint(getStyle(DefaultStyle.BACKGROUND));
			const halfHeight:Number = height / 2
			
			super.drawGraphics(width, height, state)
			
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			backgroundAlpha = ((background & 0xFF000000) >>> 24) / 0xFF;
			background = background & 0x00FFFFFF
			color = color & 0x00FFFFFF
			
			var quarterHeight:Number = halfHeight / 2
			graphics = spr_thumb.graphics
			graphics.clear()
			graphics.lineStyle(0, background, backgroundAlpha, true, LineScaleMode.NONE)
			graphics.beginFill(color, colorAlpha)
			graphics.lineTo(quarterHeight, quarterHeight);
			graphics.lineTo(quarterHeight, halfHeight);
			graphics.lineTo(-quarterHeight, halfHeight);
			graphics.lineTo(-quarterHeight, quarterHeight);
			graphics.endFill();
			
			graphics = this.graphics
			graphics.clear()
			graphics.beginFill(0, 0)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			graphics.lineStyle(1, background, backgroundAlpha, true, LineScaleMode.NONE, CapsStyle.SQUARE)
			graphics.moveTo(1, 0)
			graphics.lineTo(width - 1, 0)
			for (var i:Number = 0; i <= maximum; i += pageSize)
			{
				//draw vertical lines
				var percent:Number = i / maximum
				var xPos:Number = percent * (width - halfHeight)
				graphics.moveTo(xPos + quarterHeight, halfHeight)
				graphics.lineTo(xPos + quarterHeight, 0)
			}
			
			for (i = stepSize; i < maximum; i += stepSize)
			{
				//draw vertical lines
				percent = i / maximum
				xPos = percent * (width - halfHeight)
				graphics.moveTo(xPos + quarterHeight, quarterHeight)
				graphics.lineTo(xPos + quarterHeight, 0)
			}
			cmpi_end.width = cmpi_start.width = width
			cmpi_end.height = cmpi_start.height = height
			rect_drag.x = quarterHeight
			rect_drag.width = width - halfHeight
		}
		
		override public function unload():void
		{
			if(stage) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb)
			}
			super.unload()
			removeChildren()
			removeEventListener(KeyboardEvent.KEY_UP, changeState);
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState);
			removeEventListener(MouseEvent.ROLL_OVER, changeState);
			removeEventListener(MouseEvent.MOUSE_UP, changeState);
			removeEventListener(MouseEvent.ROLL_OUT, changeState);
			removeEventListener(FocusEvent.FOCUS_IN, changeState);
			removeEventListener(FocusEvent.FOCUS_OUT, changeState);
			removeEventListener(KeyboardEvent.KEY_DOWN, changeState);
			removeEventListener(MouseEvent.RELEASE_OUTSIDE, changeState);
		}
		
		public function get value():Number
		{
			var rawValue:Number = (((maximum - minimum) * ((spr_thumb.x - (height / 4)) / (width - (height / 2)))) + minimum)
			var decimalPart:Number = rawValue % stepSize
			rawValue -= decimalPart
			if (decimalPart > (stepSize/2)) {
				rawValue += stepSize
			}
			return rawValue
		}
		
		public function set value(newValue:Number):void 
		{
			if (num_stepSize) {
				newValue += newValue % num_stepSize
			}
			
			if(newValue > maximum) {
				newValue = maximum
			}
			else if(newValue < minimum) {
				newValue = minimum
			}
			
			if(newValue == value) {
				return;
			}
			
			moveThumbTo(newValue)
			drawGraphics(width, height, state)
			dispatchEvent(new Event(Event.CHANGE, false, false))
		}
		
		private function moveThumbTo(newValue:Number):void {
			spr_thumb.x = (height / 4) + ((newValue - minimum) * (width - (height / 2)) / (maximum - minimum))
		}
		
		public function get minimum():Number {
			return num_min;
		}
		
		public function get maximum():Number {
			return num_max;
		}
		
		public function setProperties(pageSize:Number, minimum:Number, maximum:Number):void
		{
			num_max = maximum
			num_min = minimum
			num_pageSize = pageSize
			cmpi_end.label = maximum.toString()
			cmpi_start.label = minimum.toString()
			cmpi_start.resizeWidth()
			cmpi_end.resizeWidth()
			if(value > maximum) {
				value = maximum
			}
			else if(value < minimum) {
				value = minimum
			}
			drawGraphics(width, height, state)
			//0|                            |---------||100
			//0||---------|                            |100
			//0||___________________________|
			//-5          <- w ->           5
			// |---------------------------------------|
			//(max+min) * (position / maxPosition) - min
			//max = spr_rightButton.x - spr_thumb.width
			//min = spr_leftButton.x + spr_leftButton.width
			//u = num_max * spr_thumb.x / (max - min)
		}
		
		public function get stepSize():Number {
			return num_stepSize;
		}
		
		public function set stepSize(value:Number):void
		{
			if (num_stepSize != value)
			{
				num_stepSize = value;
				drawGraphics(width, height, state)
			}
		}
		
		public function get dragging():Boolean {
			return b_dragging
		}
		
		public function set dragging(dragging:Boolean):void 
		{
			if (b_dragging == dragging) {
				return;
			}
			
			b_dragging = dragging;
			if (dragging)
			{
				spr_thumb.startDrag(false, rect_drag)
				stage && stage.addEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb, false, 0, true);
			}
			else
			{
				moveThumbTo(value)
				spr_thumb.stopDrag()
				stage && stage.removeEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb);
			}
		}
		
		public function get pageSize():Number {
			return num_pageSize;
		}
		
		public function set pageSize(value:Number):void
		{
			if (value != num_pageSize)
			{
				num_pageSize = value;
				drawGraphics(width, height, state)
			}
		}
	}
}