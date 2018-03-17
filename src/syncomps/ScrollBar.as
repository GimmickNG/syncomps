package syncomps 
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import syncomps.events.ScrollEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import syncomps.events.StyleEvent;
	import syncomps.styles.ScrollBarStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	
	[Event(name="SCROLL", type="syncomps.events.ScrollEvent")]
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollBar extends SynComponent
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32
		
		protected static var DEFAULT_STYLE:Class = ScrollBarStyle
		
		private static const REFMASK_NONE:uint = 0;
		private static const REFMASK_LEFT:uint = 1;
		private static const REFMASK_RIGHT:uint = 2;
		private static const REFMASK_THUMB:uint = 4;
		private static const REFMASK_ALL:uint = REFMASK_LEFT | REFMASK_RIGHT | REFMASK_THUMB
		
		private var spr_leftButton:Sprite
		private var spr_rightButton:Sprite
		private var spr_thumb:Sprite
		private var cl_stepTimer:Timer;
		private var num_value:Number;
		private var i_delta:int;
		private var num_pageSize:Number;
		private var num_max:Number;
		private var num_min:Number;
		private var b_dragging:Boolean;
		private var rect_drag:Rectangle;
		private var b_scrollBarChange:Boolean;
		private var num_thumbSize:Number;
		private var num_stepSize:Number;
		private var u_refreshMask:uint;
		private var b_dispatchClick:Boolean;
		public function ScrollBar() 
		{
			init()
		}
		private function init():void
		{
			num_value = num_stepSize = 0;
			spr_thumb = new Sprite()
			rect_drag = new Rectangle()
			cl_stepTimer = new Timer(100)
			spr_leftButton = new Sprite()
			spr_rightButton = new Sprite()
			cl_stepTimer.addEventListener(TimerEvent.TIMER, changeValue, false, 0, true)
			
			addChild(spr_leftButton)
			addChild(spr_rightButton)
			addChild(spr_thumb)
			u_refreshMask = REFMASK_NONE
			var sizeX:Number = DEF_WIDTH, sizeY:Number = DEF_HEIGHT
			if (direction == ScrollBarStyle.DIRECTION_VERTICAL)
			{
				sizeX = DEF_HEIGHT	//transpose values
				sizeY = DEF_WIDTH	//for vertical scrollbar
			}
			drawGraphics(sizeX, sizeY, DefaultStyle.BACKGROUND)
			value = 0
			setScrollProperties(1, 0, 100)
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			
			addEventListener(MouseEvent.CLICK, resetTimer, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, changeState, false, 0, true)
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
			b_scrollBarChange ||= (evt.style == ScrollBarStyle.SCROLL_DIRECTION)
			drawGraphics(width, height, str_state)
		}
		
		private function changeState(evt:Event):void
		{
			var state:String;
			var refreshMask:uint;
			switch(evt.type)
			{
				case KeyboardEvent.KEY_DOWN:
				case MouseEvent.MOUSE_DOWN:
					scrollOnEvent(evt);
					break;
				case MouseEvent.RELEASE_OUTSIDE:
				case FocusEvent.FOCUS_OUT:
					resetTimer(null);
				case MouseEvent.ROLL_OUT:
					refreshMask = REFMASK_NONE
					state = DefaultStyle.BACKGROUND
					break;
				case KeyboardEvent.KEY_UP:
				case MouseEvent.MOUSE_UP:
					resetTimer(null);
				case MouseEvent.MOUSE_OVER:
					refreshMask = getRefreshMaskObject(evt.target as DisplayObject)
					state = DefaultStyle.HOVER;
					break;
				case FocusEvent.FOCUS_IN:
					refreshMask = REFMASK_THUMB;
					state = DefaultStyle.HOVER;
					break;
			}
			if (!dragging && state)
			{
				if (refreshMask) {
					u_refreshMask = refreshMask
				}
				drawGraphics(width, height, state)
			}
		}
		
		private function getRefreshMaskObject(obj:DisplayObject):uint
		{
			switch(obj)
			{
				case spr_thumb:
					return REFMASK_THUMB;
				case spr_leftButton:
					return REFMASK_LEFT;
				case spr_rightButton:
					return REFMASK_RIGHT;
				default:
					return REFMASK_NONE;
			}
		}
		
		private function changeValueThumb(evt:MouseEvent):void
		{
			//tw = maximum - minimum / num_pageSize
			//tx = spr_leftButton.x at minimum (0)
			//txm = spr_rightButton.x - tw at maximum
			//0|                            |---------||100
			//max = spr_rightButton.x - spr_thumb.width
			//min = spr_leftButton.x + spr_leftButton.width
			u_refreshMask = REFMASK_THUMB
			drawGraphics(width, height, str_state)
			if (direction == ScrollBarStyle.DIRECTION_VERTICAL) {
				moveThumbTo(spr_thumb.y)
			}
			else {
				moveThumbTo(spr_thumb.x)
			}
		}
		
		private function changeValue(evt:TimerEvent):void {
			value += i_delta * num_pageSize / 8
		}
		
		private function resetTimer(evt:MouseEvent):void 
		{
			if (enabled && evt && !cl_stepTimer.currentCount)
			{
				//executes when it has been clicked (not enough time to trigger timer)
				var scrollDelta:Number = 0.0;
				var target:Object = evt.target
				if (target == spr_leftButton) {
					scrollDelta = -num_pageSize / 8
				}
				else if (target == spr_rightButton) {
					scrollDelta = num_pageSize / 8
				}
				value += scrollDelta
			}
			
			dragging = false;
			cl_stepTimer.reset()
		}
		private function scrollOnEvent(evt:Event):void
		{
			if(!enabled) {
				return;
			}
			else if (evt is KeyboardEvent)
			{
				var delta:int;
				var keyCode:int = (evt as KeyboardEvent).keyCode
				if((keyCode == Keyboard.LEFT && direction == ScrollBarStyle.DIRECTION_HORIZONTAL) || (keyCode == Keyboard.UP && direction == ScrollBarStyle.DIRECTION_VERTICAL)) {
					delta = -1
				}
				else if((keyCode == Keyboard.RIGHT && direction == ScrollBarStyle.DIRECTION_HORIZONTAL) || (keyCode == Keyboard.DOWN && direction == ScrollBarStyle.DIRECTION_VERTICAL)) {
					delta = 1
				}
				
				if (delta)
				{
					i_delta = delta;
					cl_stepTimer.start()
					b_dispatchClick = true
				}
				
				u_refreshMask = REFMASK_NONE
			}
			else if (evt is MouseEvent)
			{
				var mEvt:MouseEvent = evt as MouseEvent
				i_delta = 1
				switch(evt.target)
				{
					case spr_leftButton:
						i_delta *= -1;
					case spr_rightButton:
						cl_stepTimer.start()
						break;
					case spr_thumb:
						dragging = true;
						break;
					case this:
						var scrollDelta:Number = getThumbSize()
						if ((direction == ScrollBarStyle.DIRECTION_VERTICAL && mEvt.localY < spr_thumb.y) || (direction == ScrollBarStyle.DIRECTION_HORIZONTAL && mEvt.localX < spr_thumb.x)) {
							scrollDelta *= -1
						}
						if (scrollDelta)
						{
							if (direction == ScrollBarStyle.DIRECTION_VERTICAL) {
								moveThumbTo(spr_thumb.y + scrollDelta)
							}
							else {
								moveThumbTo(spr_thumb.x + scrollDelta)
							}
						}
						break;
				}
				u_refreshMask = getRefreshMaskObject(evt.target as DisplayObject)
			}
			drawGraphics(width, height, DefaultStyle.DOWN)
		}
		
		private function moveThumbTo(value:Number):void 
		{
			var minPosition:Number = (spr_leftButton.y + spr_leftButton.height)
			var maxPosition:Number = (spr_rightButton.y - spr_thumb.height)
			if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL)
			{
				maxPosition = (spr_rightButton.x - spr_thumb.width)
				minPosition = (spr_leftButton.x + spr_leftButton.width)
			}
			this.value = ((num_max - num_min) * ((value - minPosition) / (maxPosition - minPosition))) + num_min
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			var i:uint;
			var graphics:Graphics;
			var btnWidth:int, btnHeight:int;
			var colour:uint = uint(getStyle(state));
			var background:uint = uint(getStyle(DefaultStyle.BACKGROUND));
			var backgroundSecondary:uint = uint(getStyle(ScrollBarStyle.BACKGROUND_SECONDARY));
			var backgroundSecondaryAlpha:Number, backgroundAlpha:Number, colourAlpha:Number, activeColourAlpha:Number;
			
			super.drawGraphics(width, height, state)
			spr_leftButton.y = spr_rightButton.y = 0;
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			backgroundSecondaryAlpha = ((backgroundSecondary & 0xFF000000) >>> 24) / 0xFF;
			backgroundAlpha = ((background & 0xFF000000) >>> 24) / 0xFF;
			backgroundSecondary = backgroundSecondary & 0x00FFFFFF
			background = background & 0x00FFFFFF
			colour = colour & 0x00FFFFFF
			
			if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL)
			{
				spr_rightButton.x = width - height;
				spr_leftButton.x = 0;
				btnHeight = btnWidth = height
				if(btnWidth > width) {
					btnWidth = width * 0.25
				}
			}
			else
			{
				//leftButton becomes topButton and rightButton becomes downButton
				spr_rightButton.x = spr_leftButton.x = 0;
				spr_rightButton.y = height - width;
				btnHeight = btnWidth = width
				if(btnHeight > height) {
					btnHeight = height * 0.25
				}
			}
			var activeColor:uint;
			var leftVector:Vector.<Number> = new <Number>	[
																btnWidth * 0.6, btnHeight * 0.25,	//(middle, top) point		  *
																btnWidth * 0.3, btnHeight * 0.5,	//(left, middle) point		*
																btnWidth * 0.6, btnHeight * 0.75	//(bottom, bottom) point	  *
															];
			var rightVector:Vector.<Number> = new Vector.<Number>()
			for (i = 0; i < leftVector.length; i += 2) {
				rightVector.push(btnWidth - leftVector[i], btnHeight - leftVector[i + 1])
			}
			if (direction == ScrollBarStyle.DIRECTION_VERTICAL)
			{
				//transpose x, y coordinates
				for (i = 0; i < leftVector.length; i += 2)
				{
					var temp:Number = leftVector[i]
					leftVector[i] = leftVector[i + 1]
					leftVector[i + 1] = temp;
					
					temp = rightVector[i]
					rightVector[i] = rightVector[i + 1]
					rightVector[i + 1] = temp;
				}
			}
			
			graphics = this.graphics
			graphics.clear()
			graphics.beginFill(backgroundSecondary, backgroundSecondaryAlpha)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			
			graphics = spr_leftButton.graphics
			if (u_refreshMask & REFMASK_LEFT)
			{
				activeColor = colour
				activeColourAlpha = colourAlpha
			}
			else {
				activeColor = background
				activeColourAlpha = backgroundAlpha
			}
			graphics.clear()
			graphics.beginFill(backgroundSecondary, backgroundSecondaryAlpha)
			graphics.drawRect(0, 0, btnWidth, btnHeight)
			graphics.endFill()
			graphics.beginFill(activeColor, activeColourAlpha)
			graphics.drawTriangles(leftVector)
			graphics.endFill()
			
			graphics = spr_rightButton.graphics
			if (u_refreshMask & REFMASK_RIGHT)
			{
				activeColor = colour
				activeColourAlpha = colourAlpha
			}
			else {
				activeColor = background
				activeColourAlpha = backgroundAlpha
			}
			graphics.clear()
			graphics.beginFill(backgroundSecondary, backgroundSecondaryAlpha)
			graphics.drawRect(0, 0, btnWidth, btnHeight)
			graphics.endFill()
			graphics.beginFill(activeColor, activeColourAlpha)
			graphics.drawTriangles(rightVector)
			graphics.endFill()
			
			graphics = spr_thumb.graphics
			graphics.clear()
			if ((num_max > num_min) && (0 < num_pageSize && num_pageSize < (num_max - num_min)))
			{
				var thumbSize:Number = getThumbSize()
				if(thumbSize < 4) {
					thumbSize = 4;
				}
				if (u_refreshMask & REFMASK_THUMB)
				{
					activeColor = colour
					activeColourAlpha = colourAlpha
				}
				else
				{
					activeColor = background
					activeColourAlpha = backgroundAlpha
				}
				if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL)
				{
					spr_thumb.y = 0
					graphics.beginFill(0, 0)
					graphics.drawRect(0, 0, thumbSize, height * 0.2)
					graphics.endFill()
					graphics.beginFill(activeColor, activeColourAlpha)
					graphics.drawRect(0, height * 0.2, thumbSize, height * 0.6)
					graphics.endFill()
					graphics.beginFill(0, 0)
					graphics.drawRect(0, height * 0.8, thumbSize, height * 0.2)
					graphics.endFill()
					
					rect_drag.y = 0
					rect_drag.x = spr_leftButton.x + spr_leftButton.width
					rect_drag.width = spr_rightButton.x - (rect_drag.x + spr_thumb.width)
					rect_drag.height = 0;
				}
				else
				{
					spr_thumb.x = 0;
					graphics.beginFill(0, 0)
					graphics.drawRect(0, 0, width * 0.2, thumbSize)
					graphics.endFill()
					graphics.beginFill(activeColor, activeColourAlpha)
					graphics.drawRect(width * 0.2, 0, width * 0.6, thumbSize)
					graphics.endFill()
					graphics.beginFill(0, 0)
					graphics.drawRect(width * 0.8, 0, width * 0.2, thumbSize)
					graphics.endFill()
					
					rect_drag.x = 0
					rect_drag.y = spr_leftButton.y + spr_leftButton.height
					rect_drag.height = spr_rightButton.y - (rect_drag.y + spr_thumb.height)
					rect_drag.width = 0;
				}
			}
			graphics.endFill()
		}
		
		private function getThumbSize():Number
		{
			if (b_scrollBarChange)
			{
				if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL) {
					num_thumbSize = num_pageSize * (spr_rightButton.x - (spr_leftButton.x + spr_leftButton.width)) / (num_max - num_min)
				}
				else {
					num_thumbSize = num_pageSize * (spr_rightButton.y - (spr_leftButton.y + spr_leftButton.height)) / (num_max - num_min)
				}
				b_scrollBarChange = false
			}
			return num_thumbSize
		}
		
		override public function unload():void
		{
			if(stage) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb)
			}
			super.unload()
			removeChildren()
			removeEventListener(MouseEvent.CLICK, resetTimer);
			removeEventListener(KeyboardEvent.KEY_UP, changeState);
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState);
			removeEventListener(MouseEvent.ROLL_OVER, changeState);
			removeEventListener(MouseEvent.MOUSE_UP, changeState);
			removeEventListener(MouseEvent.ROLL_OUT, changeState);
			removeEventListener(FocusEvent.FOCUS_IN, changeState);
			removeEventListener(FocusEvent.FOCUS_OUT, changeState);
			removeEventListener(MouseEvent.RELEASE_OUTSIDE, changeState);
			removeEventListener(KeyboardEvent.KEY_DOWN, changeState);
			cl_stepTimer.removeEventListener(TimerEvent.TIMER, changeValue)
		}
		
		override public function set width(value:Number):void 
		{
			u_refreshMask = REFMASK_NONE
			if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL) {
				b_scrollBarChange = true
			}
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void 
		{
			u_refreshMask = REFMASK_NONE
			if (direction == ScrollBarStyle.DIRECTION_VERTICAL) {
				b_scrollBarChange = true
			}
			drawGraphics(width, value, str_state)
		}
		
		public function get value():Number {
			return num_value;
		}
		
		public function set value(num:Number):void 
		{
			var delta:Number = num_value
			var newValue:Number = num
			if(num_stepSize) {
				newValue -= num % num_stepSize
			}
			if(newValue > num_max) {
				newValue = num_max
			}
			else if(newValue < num_min) {
				newValue = num_min
			}
			if(newValue == num_value) {
				return;
			}
			num_value = newValue
			delta = newValue - delta
			//0|                            |---------||100
			//max = spr_rightButton.x - spr_thumb.width
			//min = spr_leftButton.x + spr_leftButton.width
			//u = num_max * spr_thumb.x / (max - min)
			u_refreshMask = REFMASK_NONE
			drawGraphics(width, height, str_state)
			var minPosition:Number, maxPosition:Number;
			if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL)
			{
				maxPosition = (spr_rightButton.x - spr_thumb.width)
				minPosition = (spr_leftButton.x + spr_leftButton.width)
				spr_thumb.x = minPosition + ((newValue - num_min) * (maxPosition - minPosition) / (num_max - num_min))
			}
			else
			{
				maxPosition = (spr_rightButton.y - spr_thumb.height)
				minPosition = (spr_leftButton.y + spr_leftButton.height)
				spr_thumb.y = minPosition + ((newValue - num_min) * (maxPosition - minPosition) / (num_max - num_min))
			}
			dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL, newValue, direction, delta, false, false))
		}
		
		public function get minimum():Number 
		{
			return num_min;
		}
		
		public function get maximum():Number 
		{
			return num_max;
		}
		
		public function get pageSize():Number 
		{
			return num_pageSize;
		}
		
		public function setScrollProperties(pageSize:Number, minimum:Number, maximum:Number):void
		{
			b_scrollBarChange = true
			num_pageSize = pageSize
			num_max = maximum
			num_min = minimum
			num_value = minimum
			u_refreshMask = REFMASK_NONE
			spr_thumb.x = spr_thumb.y = 0;
			drawGraphics(width, height, str_state)
			//0|                            |---------||100
			//0||---------|                            |100
			//0||___________________________|
			//-5          <- w ->           5
			// |---------------------------------------|
			//(max+min) * (position / maxPosition) - min
			//max = spr_rightButton.x - spr_thumb.width
			//min = spr_leftButton.x + spr_leftButton.width
			//u = num_max * spr_thumb.x / (max - min)
			if (direction == ScrollBarStyle.DIRECTION_HORIZONTAL) {
				spr_thumb.x = spr_leftButton.x + spr_leftButton.width
			}
			else {
				spr_thumb.y = spr_leftButton.y + spr_leftButton.height
			}
		}
		
		public function get direction():int {
			return int(getStyle(ScrollBarStyle.SCROLL_DIRECTION));
		}
		
		public function set direction(value:int):void {
			setStyle(ScrollBarStyle.SCROLL_DIRECTION, value)
		}
		
		public function get stepSize():Number 
		{
			return num_stepSize;
		}
		
		public function set stepSize(value:Number):void 
		{
			num_stepSize = value;
		}
		
		public function get dragging():Boolean 
		{
			return b_dragging;
		}
		
		public function set dragging(value:Boolean):void 
		{
			if (b_dragging != value)
			{
				b_dragging = value;
				if (value)
				{
					spr_thumb.startDrag(false, rect_drag)
					if(stage) {
						stage.addEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb, false, 0, true)
					}
				}
				else
				{
					spr_thumb.stopDrag()
					if(stage) {
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, changeValueThumb)
					}
				}
			}
		}
	}

}