package syncomps 
{
	import flash.display.Shape;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import syncomps.events.ScrollEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import syncomps.ScrollBar;
	import syncomps.events.StyleEvent;
	import syncomps.styles.ScrollBarStyle;
	import syncomps.styles.ScrollPaneStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	
	[Event(name="synScEScroll", type="syncomps.events.ScrollEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollPane extends SynComponent
	{
		public static const DEF_WIDTH:int = 96;
		public static const DEF_HEIGHT:int = 96;
		protected static var DEFAULT_STYLE:Class = ScrollPaneStyle
		
		private var spr_source:Sprite;
		private var dsp_source:DisplayObject
		private var cl_verticalScroll:ScrollBar
		private var cl_horizontalScroll:ScrollBar
		private var b_displayScrollBars:Boolean;
		private var b_forceScrollDisplay:Boolean
		private var pt_scrollSize:Point;
		private var shp_source:Shape;
		
		public function ScrollPane() 
		{
			super();
			init()
		}
		
		private function init():void
		{
			tabChildren = false
			shp_source = new Shape()
			cl_verticalScroll = new ScrollBar()
			cl_horizontalScroll = new ScrollBar()
			pt_scrollSize = new Point(0, 0)
			spr_source = new Sprite()
			
			cl_horizontalScroll.setStyle(ScrollBarStyle.SCROLL_DIRECTION, ScrollBarStyle.DIRECTION_HORIZONTAL)
			cl_verticalScroll.setStyle(ScrollBarStyle.SCROLL_DIRECTION, ScrollBarStyle.DIRECTION_VERTICAL)
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			cl_horizontalScroll.height = 16
			cl_verticalScroll.width = 16
			addChild(spr_source)
			addChild(shp_source)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, state)
			cl_verticalScroll.addEventListener(ScrollEvent.SCROLL, scrollSourceVertical)
			cl_horizontalScroll.addEventListener(ScrollEvent.SCROLL, scrollSourceHorizontal)
			
			addEventListener(KeyboardEvent.KEY_UP, forwardEventToScroll, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, scrollPaneOnKeyEvent)
			addEventListener(MouseEvent.MOUSE_WHEEL, scrollContents, false, 0, true)
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			switch(evt.style)
			{
				case ScrollPaneStyle.SCROLL_POLICY:
					displayScrollBars(forceScrollDisplay)
					break;
				case ScrollPaneStyle.MASK_METHOD:
					useCache &&= (evt.value == ScrollPaneStyle.SCROLL_RECT)
					break;
			}
			if (spr_source)
			{
				spr_source.scrollRect = null
				spr_source.mask = null;
				refreshPane()
			}
		}
		
		private function forwardEventToScroll(evt:KeyboardEvent):void 
		{
			if(evt.target != this) {
				return;
			}
			
			if (evt.keyCode == Keyboard.LEFT || evt.keyCode == Keyboard.RIGHT) {
				cl_horizontalScroll.dispatchEvent(evt)
			}
			else if (evt.keyCode == Keyboard.UP || evt.keyCode == Keyboard.DOWN) {
				cl_verticalScroll.dispatchEvent(evt)
			}
		}
		
		private function scrollPaneOnKeyEvent(evt:KeyboardEvent):void 
		{
			if(evt.target != this) {
				return;
			}
			
			if (evt.keyCode == Keyboard.LEFT || evt.keyCode == Keyboard.RIGHT)
			{
				if(!cl_horizontalScroll.parent) {
					return;
				}
				
				if (evt.keyCode == Keyboard.LEFT) {
					--horizontalScrollPosition
				}
				else if(evt.keyCode == Keyboard.RIGHT) {
					++horizontalScrollPosition;
				}
				cl_horizontalScroll.dispatchEvent(evt)
			}
			else if (evt.keyCode == Keyboard.UP || evt.keyCode == Keyboard.DOWN)
			{
				if(!cl_verticalScroll.parent) {
					return;
				}
				
				if(evt.keyCode == Keyboard.UP) {
					--verticalScrollPosition;
				}
				else if(evt.keyCode == Keyboard.DOWN) {
					++verticalScrollPosition;
				}
				cl_verticalScroll.dispatchEvent(evt)
			}
		}
		
		private function scrollContents(evt:MouseEvent):void {
			verticalScrollPosition -= evt.delta * lineScrollSize
		}
		
		public function get lineScrollSize():Number {
			return Number(getStyle(ScrollPaneStyle.SCROLL_SIZE))
		}
		
		public function set lineScrollSize(value:Number):void
		{
			if (value != Number(getStyle(ScrollPaneStyle.SCROLL_SIZE))) {
				setStyle(ScrollPaneStyle.SCROLL_SIZE, value)
			}
		}
		
		/**
		 * Determine whether caching is used for the scroll source or not. Always returns false if not in SCROLL_RECT mode.
		 */
		public function get useCache():Boolean {
			return spr_source && spr_source.cacheAsBitmap
		}
		
		/**
		 * Caches the scroll source as a bitmap. Only available in SCROLL_RECT mode.
		 */
		public function set useCache(cacheAsBitmap:Boolean):void {
			spr_source.cacheAsBitmap = cacheAsBitmap && (maskMethod == ScrollPaneStyle.SCROLL_RECT)
		}
		
		private function scrollSourceHorizontal(evt:ScrollEvent):void
		{
			horizontalScrollPosition = evt.scrollPosition
			dispatchEvent(evt)
		}
		
		private function scrollSourceVertical(evt:ScrollEvent):void
		{
			verticalScrollPosition = evt.scrollPosition
			dispatchEvent(evt)
		}
		
		override public function get width():Number
		{
			if (shp_source && pt_scrollSize) {
				return shp_source.width + pt_scrollSize.x
			}
			return 0
		}
		
		override public function set width(value:Number):void
		{
			super.width = value
			var prevScrollValue:Number = cl_horizontalScroll.value;
			if(b_displayScrollBars) {
				displayScrollBars(b_forceScrollDisplay)
			}
			var contentBiggerThanPane:Boolean = dsp_source && dsp_source.width >= (value - pt_scrollSize.x)
			cl_horizontalScroll.enabled = contentBiggerThanPane
			prevScrollValue *= int(contentBiggerThanPane)
			horizontalScrollPosition = prevScrollValue
		}
		
		override public function get height():Number
		{
			if (shp_source && pt_scrollSize) {
				return shp_source.height + pt_scrollSize.y
			}
			return 0
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value
			var prevScrollValue:Number = cl_verticalScroll.value;
			if(b_displayScrollBars) {
				displayScrollBars(b_forceScrollDisplay)
			}
			var contentBiggerThanPane:Boolean = dsp_source && dsp_source.height >= (value - pt_scrollSize.y)
			cl_verticalScroll.enabled = contentBiggerThanPane
			prevScrollValue *= int(contentBiggerThanPane)
			verticalScrollPosition = prevScrollValue
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			shp_source.graphics.clear()
			shp_source.graphics.beginFill(0, 0)
			shp_source.graphics.drawRect(0, 0, width - pt_scrollSize.x, height - pt_scrollSize.y)
			shp_source.graphics.endFill()
			cl_verticalScroll.height = height - pt_scrollSize.y
			cl_horizontalScroll.width = width - pt_scrollSize.x
			cl_verticalScroll.x = width - cl_verticalScroll.width
			cl_horizontalScroll.y = height - cl_horizontalScroll.height
			if (pt_scrollSize.x && pt_scrollSize.y)
			{
				graphics.beginFill(0xFFFFFF, 1)
				graphics.drawRect(width - pt_scrollSize.x, height - pt_scrollSize.y, pt_scrollSize.x, pt_scrollSize.y)
				graphics.endFill()
			}
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		override public function unload():void
		{
			super.unload()
			cl_horizontalScroll.removeEventListener(ScrollEvent.SCROLL, scrollSourceHorizontal)
			cl_verticalScroll.removeEventListener(ScrollEvent.SCROLL, scrollSourceVertical)
			removeEventListener(MouseEvent.MOUSE_WHEEL, scrollContents)
			cl_horizontalScroll.unload()
			cl_verticalScroll.unload()
			spr_source.removeChildren()
			dsp_source = null;
			removeChildren()
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = cl_horizontalScroll.enabled = cl_verticalScroll.enabled = value
		}
		
		public function get source():DisplayObject {
			return spr_source.getChildAt(0);
		}
		
		public function set source(obj:DisplayObject):void 
		{
			lineScrollSize = 0;
			spr_source.mask = null;
			spr_source.scrollRect = null;
			spr_source.removeChildren()
			spr_source.addChild(obj);
			dsp_source = obj
			if(maskMethod == ScrollPaneStyle.SCROLL_RECT) {
				spr_source.scrollRect = new Rectangle(0, 0, width - pt_scrollSize.x, height - pt_scrollSize.y)
			}
			else if (maskMethod == ScrollPaneStyle.MASK) {
				spr_source.mask = shp_source
			}
		}
		
		public function displayScrollBars(forceDisplay:Boolean):void
		{
			if(!dsp_source) {
				return;
			}
			var viewportWidth:Number, horizontalPageSize:Number, maxWidth:Number;
			var viewportHeight:Number, verticalPageSize:Number, maxHeight:Number;
			var scrollPolicy:int = int(getStyle(ScrollPaneStyle.SCROLL_POLICY))
			b_displayScrollBars = true
			b_forceScrollDisplay = forceDisplay
			if (scrollPolicy & 1 && (forceDisplay || dsp_source.width > (width - pt_scrollSize.x))) {
				addChild(cl_horizontalScroll)
			}
			else if(cl_horizontalScroll.parent) {
				removeChild(cl_horizontalScroll)
			}
			if (scrollPolicy & 2 && (forceDisplay || dsp_source.height > (height - pt_scrollSize.y))) {
				addChild(cl_verticalScroll)
			}
			else if(cl_verticalScroll.parent) {
				removeChild(cl_verticalScroll)
			}
			pt_scrollSize.setTo(cl_verticalScroll.width * int(cl_verticalScroll.parent != null), cl_horizontalScroll.height * int(cl_horizontalScroll.parent != null))
			cl_horizontalScroll.enabled = !!cl_horizontalScroll.parent;
			cl_verticalScroll.enabled = !!cl_verticalScroll.parent;
			viewportHeight = height - pt_scrollSize.y
			viewportWidth = width - pt_scrollSize.x
			maxWidth = (dsp_source.width - viewportWidth)
			maxHeight = (dsp_source.height - viewportHeight)
			if(maxWidth < 0) {
				maxWidth = 0
			}
			if(maxHeight < 0) {
				maxHeight = 0
			}
			horizontalPageSize = viewportWidth * maxWidth / dsp_source.width
			verticalPageSize = viewportHeight * maxHeight / dsp_source.height
			if (lineScrollSize == 0) {
				lineScrollSize = verticalPageSize / 8	//since only vertical scroll supported
			}
			cl_horizontalScroll.setScrollProperties(horizontalPageSize, 0, maxWidth)
			cl_verticalScroll.setScrollProperties(verticalPageSize, 0, maxHeight)
			drawGraphics(width, height, state)
		}
		
		public function hideScrollBars():void
		{
			cl_verticalScroll.parent && cl_verticalScroll.parent.removeChild(cl_verticalScroll)
			cl_horizontalScroll.parent && cl_horizontalScroll.parent.removeChild(cl_horizontalScroll)
			pt_scrollSize.setTo(cl_verticalScroll.width * int(cl_verticalScroll.parent != null), cl_horizontalScroll.height * int(cl_horizontalScroll.parent != null))
			b_displayScrollBars = false;
		}
		
		public function refreshPane():void 
		{
			if (maskMethod == ScrollPaneStyle.SCROLL_RECT)
			{
				cl_horizontalScroll.value = cl_verticalScroll.value = 0
				spr_source.scrollRect = new Rectangle(0, 0, width - pt_scrollSize.x, height - pt_scrollSize.y)
			}
			else if (maskMethod == ScrollPaneStyle.MASK)
			{
				spr_source.x = spr_source.y = 0
				spr_source.mask = shp_source
			}
			drawGraphics(width, height, state)
			displayScrollBars(b_forceScrollDisplay)
		}
		
		public function get verticalScrollPosition():Number
		{
			switch(maskMethod)
			{
				case ScrollPaneStyle.MASK:
					return cl_verticalScroll.value
				case ScrollPaneStyle.SCROLL_RECT:
				default:
					return spr_source.scrollRect.y
			}
		}
		
		public function get horizontalScrollPosition():Number
		{
			switch(maskMethod)
			{
				case ScrollPaneStyle.MASK:
					return cl_horizontalScroll.value
				case ScrollPaneStyle.SCROLL_RECT:
				default:
					return spr_source.scrollRect.x
			}
		}
		
		public function set horizontalScrollPosition(val:Number):void
		{
			var newValue:Number = val;
			if(!dsp_source) {
				return;
			}
			else if(val < 0 || dsp_source.width < (width - pt_scrollSize.x)) {
				newValue = 0
			}
			else if (val > dsp_source.width) {
				newValue = dsp_source.width
			}
			if(maskMethod == ScrollPaneStyle.SCROLL_RECT) {
				spr_source.scrollRect = new Rectangle(newValue, cl_verticalScroll.value, width - pt_scrollSize.x, height - pt_scrollSize.y)
			}
			else if(maskMethod == ScrollPaneStyle.MASK) {
				spr_source.x = -newValue
			}
			cl_horizontalScroll.value = newValue
		}
		public function set verticalScrollPosition(val:Number):void
		{
			var newValue:Number = val;
			if(!dsp_source) {
				return;
			}
			else if(val < 0 || dsp_source.height < (height - pt_scrollSize.y)) {
				newValue = 0
			}
			else if (val > dsp_source.height - (height - pt_scrollSize.y)) {
				newValue = dsp_source.height - (height - pt_scrollSize.y)
			}
			
			if(maskMethod == ScrollPaneStyle.SCROLL_RECT) {
				spr_source.scrollRect = new Rectangle(cl_horizontalScroll.value, newValue, width - pt_scrollSize.x, height - pt_scrollSize.y)
			}
			else if (maskMethod == ScrollPaneStyle.MASK) {
				spr_source.y = -newValue
			}
			cl_verticalScroll.value = newValue
		}
		
		public function get horizontalScrollBar():ScrollBar {
			return cl_horizontalScroll;
		}
		
		public function get verticalScrollBar():ScrollBar {
			return cl_verticalScroll;
		}
		
		public function get forceScrollDisplay():Boolean {
			return b_forceScrollDisplay;
		}
		
		public function set forceScrollDisplay(value:Boolean):void {
			b_forceScrollDisplay = value;
		}
		
		public function get maskMethod():int {
			return int(getStyle(ScrollPaneStyle.MASK_METHOD))
		}
		
		public function set maskMethod(value:int):void {
			setStyle(ScrollPaneStyle.MASK_METHOD, value)
		}
	}

}