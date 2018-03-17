package syncomps 
{
	import flash.accessibility.AccessibilityProperties;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
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
	import syncomps.styles.DefaultLabelStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class CheckBox extends SynComponent implements IAutoResize, ILabel
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32;
		protected static var DEFAULT_STYLE:Class = DefaultLabelStyle
		
		private var b_selected:Boolean;
		private var tf_label:SkinnableTextField;
		private var shp_graphic:Shape;
		private var b_dispatchClick:Boolean;
		
		public function CheckBox() 
		{
			init()
		}
		
		private function init():void
		{
			shp_graphic = new Shape()
			tf_label = new SkinnableTextField()
			StyleManager.unregister(tf_label)
			addChild(tf_label)
			addChild(shp_graphic)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND);
			tf_label.selectable = tf_label.multiline = tf_label.mouseEnabled = false;
			selected = false	//warning: these 3 lines redraws the graphics, 
			label = null		//so make sure width and height are preinitialized
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			accessibilityProperties = new AccessibilityProperties()
			
			addEventListener(MouseEvent.CLICK, toggleButton, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent, false, 0, true)
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			tf_label.setStyle(evt.style, evt.value)
			drawGraphics(width, height, str_state)
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
					resetButton()
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
				resetButton()
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false))
				b_dispatchClick = false
			}
		}
		
		private function startDispatchClickEvent(evt:KeyboardEvent):void 
		{
			if ((evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.SPACE))
			{
				drawGraphics(width, height, DefaultStyle.DOWN);
				b_dispatchClick = true
			}
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		override public function set width(value:Number):void
		{
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void
		{
			drawGraphics(width, value, str_state)
		}
		
		public function set label(text:String):void 
		{
			if (text && text.length) {
				tf_label.text = text;
			}
			else {
				tf_label.text = ""
			}
			drawGraphics(width, height, str_state)
		}
		
		public function get label():String {
			return tf_label.text
		}
		
		public function set labelPosition(position:int):void {
			setStyle(DefaultLabelStyle.LABEL_POSITION, position)
		}
		
		public function get labelPosition():int {
			return int(getStyle(DefaultLabelStyle.LABEL_POSITION))
		}
		
		public function get textField():TextField {
			return tf_label
		}
		
		override public function unload():void
		{
			super.unload()
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
			var widthVal:Number = tf_label.width
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_RIGHT:
				case DefaultLabelStyle.LABEL_LEFT:
					widthVal += 32;
					break;
			}
			tf_label.autoSize = TextFieldAutoSize.NONE
			width = widthVal
		}
		
		public function resizeHeight():void {
			height = tf_label.textHeight + 16
		}
		
		private function toggleButton(evt:MouseEvent):void 
		{
			selected = !selected
			drawGraphics(width, height, str_state);
			dispatchEvent(new Event(Event.CHANGE, false, false))
		}
		
		private function resetButton():void
		{
			var state:String = DefaultStyle.SELECTED
			if(b_selected) {
				state = DefaultStyle.BACKGROUND
			}
			drawGraphics(width, height, state);
		}
		
		public function set selected(state:Boolean):void
		{
			b_selected = state;
			resetButton()
		}
		
		public function get selected():Boolean {
			return b_selected
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			const shapeGraphics:Graphics = shp_graphic.graphics
			var xCenter:Number, yCenter:Number, size:Number, colourAlpha:Number;
			var colour:uint = uint(getStyle(state)), checkHeight:int = height - 16
			if(!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			var textHeight:int = tf_label.textHeight
			if(checkHeight < textHeight - 8) {
				checkHeight = textHeight - 8
			}
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_RIGHT:
				case DefaultLabelStyle.LABEL_LEFT:
					tf_label.height = height - 4
					if((tf_label.height < textHeight && textHeight <= height) || (tf_label.textHeight && tf_label.height >= textHeight)) {
						tf_label.height = textHeight
					}
					yCenter = height * 0.5;
					size = checkHeight * 0.5
					tf_label.y = 0
					tf_label.y = (height - tf_label.height) * 0.5;
					break;
				case DefaultLabelStyle.LABEL_BELOW:
				case DefaultLabelStyle.LABEL_ABOVE:
					size = checkHeight * 0.3
					tf_label.height = height - (size * 2)
					if((tf_label.height < textHeight && textHeight <= height) || (tf_label.textHeight && tf_label.height >= textHeight)) {
						tf_label.height = textHeight
					}
					xCenter = width * 0.5;
					tf_label.width = width;
					break;
			}
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_RIGHT:
					xCenter = size + 2;
					tf_label.x = (xCenter + size) + 4
					tf_label.width = width - tf_label.x
					break;
				case DefaultLabelStyle.LABEL_LEFT:
					tf_label.x = 0
					xCenter = width - (size + 2)
					tf_label.width = width - ((size * 2) + 4)
					break;
				case DefaultLabelStyle.LABEL_BELOW:
					tf_label.y = height - tf_label.height 
					tf_label.x = 0;
					yCenter = size;
					break;
				case DefaultLabelStyle.LABEL_ABOVE:
					tf_label.y = tf_label.x = 0;
					yCenter = height - size
					break;
				default:
					throw new Error("Invalid label position.")
					break;
			}
			
			//outer border (invisible)
			shapeGraphics.clear()
			shapeGraphics.beginFill(0, 0)
			shapeGraphics.drawRect(0, 0, width, height)
			shapeGraphics.endFill()
			
			//checkbox
			shapeGraphics.lineStyle(1)
			shapeGraphics.beginFill(colour, colourAlpha)
			shapeGraphics.drawRect((xCenter - size), (yCenter - size), (size * 2), (size * 2))
			shapeGraphics.endFill()
			if (b_selected)
			{
				//draw tick
				shapeGraphics.lineStyle(2, 0, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.BEVEL, 5)
				shapeGraphics.moveTo((xCenter + 1) - size, (yCenter - 1) + (size * 0.5))
				shapeGraphics.lineTo((xCenter + 1) - (size * 0.5), (yCenter - 1) + size)
				shapeGraphics.lineTo((xCenter - 1) + size, (yCenter + 1) - size)
				shapeGraphics.endFill()
			}
		}
	}

}