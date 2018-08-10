package syncomps 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import syncomps.events.ButtonEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.interfaces.graphics.ILabel;
	import syncomps.styles.DefaultLabelStyle;
	import syncomps.styles.DefaultStyle;
	
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
		
		private var rdg_group:RadioButtonGroup;
		private var b_dispatchClick:Boolean
		private var b_selected:Boolean;
		private var shp_graphic:Shape;
		private var cmpi_label:Label;
		private var obj_data:Object;
		public function RadioButton() {
			init()
		}
		
		private function init():void
		{
			shp_graphic = new Shape()
			cmpi_label = new Label()
			////StyleManager.unregister(tf_label)
			
			addChild(cmpi_label)
			addChild(shp_graphic)
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
				dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, true, false))
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
		
		public function set label(text:String):void 
		{
			cmpi_label.label = text
			drawGraphics(width, height, state)
		}
		
		public function get label():String {
			return cmpi_label.label
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
			drawGraphics(width, height, state);
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
			return cmpi_label.textField
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
			var color:uint = uint(getStyle(state)), checkHeight:int = height - 16
			var size:Number = cmpi_label.iconSize / 2, colorAlpha:Number;
			if(!enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			
			//outer border (invisible)
			graphics.clear()
			graphics.beginFill(0, 0)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			
			//checkbox
			shapeGraphics.clear()
			shapeGraphics.lineStyle(1)
			shapeGraphics.beginFill(color, colorAlpha)
			shapeGraphics.drawCircle(size, size, size);
			shapeGraphics.endFill()
			if (b_selected)
			{
				shapeGraphics.lineStyle(undefined)
				shapeGraphics.beginFill(0, 1)
				shapeGraphics.drawCircle(size, size, size * 0.4);
				shapeGraphics.endFill()
			}
			cmpi_label.icon = shp_graphic
			cmpi_label.height = height
			cmpi_label.width = width
		}
		
		override public function unload():void
		{
			super.unload()
			
			group = null;
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
		}
		
		public function resizeWidth():void 
		{
			cmpi_label.resizeWidth()
			drawGraphics(width, height, state)
		}
		
		public function resizeHeight():void
		{
			cmpi_label.resizeHeight()
			drawGraphics(width, height, state)
		}
		
		public function get iconSize():int {
			return cmpi_label.iconSize;
		}
		
		public function set iconSize(value:int):void
		{
			cmpi_label.iconSize = value;
			drawGraphics(width, height, state)
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