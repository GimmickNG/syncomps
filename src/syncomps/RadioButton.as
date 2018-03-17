package syncomps 
{
	import flash.display.Graphics;
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
	
	[Event(name="click", type="flash.events.MouseEvent")]
	/**
	 * ...
	 * @author Gimmick
	 */
	public class RadioButton extends SynComponent implements IAutoResize, ILabel
	{
		public static const DEF_WIDTH:int = 96;
		public static const DEF_HEIGHT:int = 32;
		protected static var DEFAULT_STYLE:Class = DefaultLabelStyle
		
		private var tf_label:SkinnableTextField
		private var rdg_group:RadioButtonGroup;
		private var b_dispatchClick:Boolean
		private var b_selected:Boolean;
		private var shp_graphic:Shape;
		private var obj_data:Object;
		public function RadioButton() {
			init()
		}
		
		private function init():void
		{
			shp_graphic = new Shape()
			tf_label = new SkinnableTextField()
			StyleManager.unregister(tf_label)
			addChild(tf_label)
			addChild(shp_graphic)
			tf_label.selectable = tf_label.multiline = tf_label.mouseEnabled = false;
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND);
			
			selected = false	//warning: redraws; place after adding children
			label = null
			
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			
			addEventListener(MouseEvent.CLICK, selectButton, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent, false, 0, true)
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
					if(b_selected) {
						drawGraphics(width, height, DefaultStyle.SELECTED);
					}
					else {
						drawGraphics(width, height, DefaultStyle.BACKGROUND);
					}
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
				redrawButton()
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false))
				b_dispatchClick = false
			}
		}
		
		private function startDispatchClickEvent(evt:KeyboardEvent):void 
		{
			if (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.SPACE)
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
		
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		
		public function set label(text:String):void 
		{
			if (text && text.length) {
				tf_label.text = text;
			}
			else {
				tf_label.text = " "
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
		
		private function selectButton(evt:MouseEvent):void 
		{
			selected = true
			drawGraphics(width, height, str_state);
		}
		
		private function redrawButton():void
		{
			var state:String = DefaultStyle.BACKGROUND
			if(b_selected) {
				state = DefaultStyle.SELECTED;
			}
			drawGraphics(width, height, state);
		}
		
		public function get textField():TextField {
			return tf_label
		}
		
		public function set selected(state:Boolean):void
		{
			if (b_selected != state)
			{
				b_selected = state;
				redrawButton()
				dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
		
		public function get selected():Boolean {
			return b_selected
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			const shapeGraphics:Graphics = shp_graphic.graphics
			var colour:uint = uint(getStyle(state)), checkHeight:int = height - 16
			var xCenter:Number, yCenter:Number, size:Number;
			var textHeight:int = tf_label.textHeight
			var colourAlpha:Number;
			if (!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
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
					tf_label.y = (height - (tf_label.height + 4)) * 0.5;
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
			
			shapeGraphics.clear()
			shapeGraphics.beginFill(0, 0)
			shapeGraphics.drawRect(0, 0, width, height)
			shapeGraphics.endFill()
			shapeGraphics.lineStyle(1)
			shapeGraphics.beginFill(colour, colourAlpha)
			shapeGraphics.drawCircle(xCenter, yCenter, size);
			shapeGraphics.endFill()
			if (b_selected)
			{
				shapeGraphics.lineStyle(undefined)
				shapeGraphics.beginFill(0, 1)
				shapeGraphics.drawCircle(xCenter, yCenter, size * 0.4);
				shapeGraphics.endFill()
			}
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			removeEventListener(MouseEvent.CLICK, selectButton)
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState)
			removeEventListener(MouseEvent.MOUSE_UP, changeState)
			removeEventListener(MouseEvent.ROLL_OUT, changeState)
			removeEventListener(MouseEvent.ROLL_OVER, changeState)
			removeEventListener(FocusEvent.FOCUS_IN, changeState)
			removeEventListener(FocusEvent.FOCUS_OUT, changeState)
			removeEventListener(KeyboardEvent.KEY_UP, dispatchClickEvent)
			removeEventListener(KeyboardEvent.KEY_DOWN, startDispatchClickEvent)
			group = null;
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
		
		public function get group():RadioButtonGroup {
			return rdg_group;
		}
		
		public function set group(value:RadioButtonGroup):void 
		{
			if(rdg_group == value) {
				return;
			}
			else if(rdg_group) {
				rdg_group.unregister(this)
			}
			
			if (value) {
				value.register(this)
			}
			rdg_group = value;
		}
		
		public function get data():Object {
			return obj_data;
		}
		
		public function set data(value:Object):void {
			obj_data = value;
		}
	}

}