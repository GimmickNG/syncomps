package syncomps 
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.ILabel;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class NumericStepper extends SynComponent implements ILabel
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32;
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private var spr_upButton:Sprite
		private var spr_downButton:Sprite
		private var cmpi_valueField:TextInput
		private var cl_stepTimer:Timer;
		private var num_value:Number
		private var num_max:Number;
		private var i_delta:int;
		private var num_min:Number;
		private var num_step:Number;
		private var i_formatPrecision:int;
		private var b_addedToStage:Boolean;
		private var b_dispatchClick:Boolean;
		public function NumericStepper() 
		{
			init()
		}
		private function init():void
		{
			num_step = 1.0;
			num_value = 0.0;
			i_formatPrecision = 0;
			num_max = Number.MAX_VALUE
			num_min = -Number.MAX_VALUE
			spr_upButton = new Sprite()
			cl_stepTimer = new Timer(100)
			spr_downButton = new Sprite()
			cmpi_valueField = new TextInput()
			StyleManager.unregister(cmpi_valueField)
			
			cl_stepTimer.addEventListener(TimerEvent.TIMER, increaseStep, false, 0, true)
			cmpi_valueField.restrict = "0-9.\\-";
			cmpi_valueField.enabled = false;
			cmpi_valueField.value = "0";
			
			addChild(spr_upButton)
			addChild(spr_downButton)
			addChild(cmpi_valueField)
			cmpi_valueField.addEventListener(Event.CHANGE, validateInput, false, 0, true)
			cmpi_valueField.setStyle(DefaultInnerTextStyle.BORDER, 0)	//no border colour by default
			cmpi_valueField.setStyle(DefaultStyle.BACKGROUND, 0)	//no background colour when editable
			cmpi_valueField.setStyle(DefaultStyle.DISABLED, 0)	//no background colour when not editable
			
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			addEventListener(MouseEvent.CLICK, resetTimer, false, 0, true)
			addEventListener(KeyboardEvent.KEY_UP, changeState, false, 0, true)
			addEventListener(KeyboardEvent.KEY_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
			addEventListener(Event.ADDED_TO_STAGE, setAddedToStage, false, 0, true)
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage, false, 0, true)
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			switch(evt.style)
			{
				//no border or background colour for these textfields
				case DefaultStyle.DISABLED:
				case DefaultStyle.BACKGROUND:
				case DefaultInnerTextStyle.BORDER:
					cmpi_valueField.setStyle(evt.style, 0)
					break;
				default:
					cmpi_valueField.setStyle(evt.style, evt.value)
					break;
			}
		}
		
		private function changeState(evt:Event):void
		{
			switch(evt.type)
			{
				case FocusEvent.FOCUS_OUT:
					stopEditText(evt)
					drawGraphics(width, height, DefaultStyle.BACKGROUND);
					break;
				case MouseEvent.MOUSE_DOWN:
				case KeyboardEvent.KEY_DOWN:
					changeValueOnEvent(evt);
					break;
				case KeyboardEvent.KEY_UP:
					if(!b_dispatchClick) {
						return;
					}
					b_dispatchClick = false;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.ROLL_OUT:
				case MouseEvent.RELEASE_OUTSIDE:
					if (!editing) {
						resetTimer(null)
					}
					drawGraphics(width, height, DefaultStyle.BACKGROUND)
					break;
				case MouseEvent.ROLL_OVER:
				case FocusEvent.FOCUS_IN:
					drawGraphics(width, height, DefaultStyle.HOVER);
					break;
			}
		}
		
		private function validateInput(evt:Event):void 
		{
			var input:String = cmpi_valueField.value
			if (input.indexOf('-') > 0) {
				input = "-" + input.split("-").join("")	//moves - signs which occur in the middle to the front
			}
			var periodFrontIndex:int = input.indexOf('.')
			if (periodFrontIndex != -1 && periodFrontIndex != input.lastIndexOf('.'))
			{
				//removes . signs which occur more than once
				var periodInputs:Array = input.split(".")
				input = periodInputs.shift() + "." + periodInputs.join("")
			}
			cmpi_valueField.value = input
		}
		
		private function removeFromStage(evt:Event):void 
		{
			b_addedToStage = false
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopEditText)
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, stopEditText)
		}
		
		private function setAddedToStage(evt:Event):void
		{
			b_addedToStage = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, stopEditText, false, 0, true)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stopEditText, false, 0, true)
		}
		
		private function resetTimer(evt:MouseEvent):void 
		{
			if (enabled)
			{
				var change:Boolean = !!cl_stepTimer.currentCount
				if (evt && evt.type == MouseEvent.CLICK)
				{
					var localX:Number = evt.localX
					var localY:Number = evt.localY
					if (!editing && b_addedToStage && localX > 0 && localX < (width - 40) && localY > 0 && localY < height) {
						editing = true
					}
					else if (!cl_stepTimer.currentCount)
					{
						//executes when it has been clicked (not enough time to trigger timer)
						var target:Sprite = evt.target as Sprite
						change = (target == spr_upButton || target == spr_downButton)
						if (target == spr_upButton) {
							value += num_step
						}
						else if (target == spr_downButton) {
							value -= num_step
						}
					}
				}
				
				if (change) {
					dispatchEvent(new Event(Event.CHANGE, false, false))
				}
			}
			cl_stepTimer.reset()
		}
		
		public function get textField():TextField {
			return cmpi_valueField.textField
		}
		
		public function get editing():Boolean {
			return cmpi_valueField.enabled && stage && stage.focus && cmpi_valueField.contains(stage.focus)
		}
		
		override public function set enabled(value:Boolean):void 
		{
			super.enabled = value;
			cl_stepTimer.reset()
			editing = value;
		}
		
		public function set editing(value:Boolean):void
		{
			if (enabled) {
				cmpi_valueField.enabled = value
			}
		}
		
		private function stopEditText(evt:Event):void 
		{
			if (!editing) {
				return;
			}
			else if ((evt is FocusEvent && evt.target == cmpi_valueField) || (evt is MouseEvent && !this.contains(evt.target as DisplayObject)) || (evt is KeyboardEvent && (evt as KeyboardEvent).keyCode == Keyboard.ENTER))
			{
				editing = false
				value = getNumber(cmpi_valueField.value)
				drawGraphics(width, height, str_state)
				dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
		
		private function getNumber(text:String):Number
		{
			var value:Number = 0.0;
			if(minimum > value) {
				value = minimum
			}
			if(!(text && text.length)) {
				return value;
			}
			var str:String = text;
			var periodIndex:int = text.indexOf('.');
			if (periodIndex != -1 && periodIndex != text.lastIndexOf('.'))
			{
				var nums:Array = text.split('.')
				str = nums.shift() + '.' + nums.join('')
			}
			value = Number(str)
			return value
		}
		
		private function increaseStep(evt:TimerEvent):void 
		{
			value += i_delta * num_step
			if(!(cl_stepTimer.currentCount % 15)) {
				i_delta *= 2
			}
			dispatchEvent(new Event(Event.CHANGE, false, false))
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
		
		public function get value():Number {
			return num_value
		}
		
		public function set value(num:Number):void 
		{
			num_value = num
			if(num_value > num_max) {
				num_value = num_max
			}
			else if(num_value < num_min) {
				num_value = num_min
			}
			drawGraphics(width, height, str_state)
		}
		
		private function changeValueOnEvent(evt:Event):void
		{
			if(editing || !enabled) {
				return;
			}
			else if (evt is MouseEvent && (evt.target == spr_upButton || evt.target == spr_downButton))
			{
				i_delta = 1
				drawGraphics(width, height, DefaultStyle.DOWN)
				if (evt.target == spr_downButton) {
					i_delta = -1
				}
				cl_stepTimer.start()
			}
			else if (evt is KeyboardEvent && evt.target == this)
			{
				var kEvt:KeyboardEvent = evt as KeyboardEvent
				if (kEvt.keyCode == Keyboard.UP || kEvt.keyCode == Keyboard.DOWN)
				{
					i_delta = 1
					b_dispatchClick = true
					drawGraphics(width, height, DefaultStyle.DOWN)
					if (kEvt.keyCode == Keyboard.DOWN) {
						i_delta = -1
					}
					cl_stepTimer.start()
				}
			}
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			var shapeGraphics:Graphics
			var colour:uint, colourAlpha:Number;
			if (enabled) {
				colour = uint(getStyle(state))
			}
			else {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			super.drawGraphics(width, height, state)
			
			if (!editing) {
				cmpi_valueField.value = (value - (value % num_step)).toString()
			}
			cmpi_valueField.width = width - 32;
			cmpi_valueField.height = height - 4
			var textHeight:int = cmpi_valueField.textHeight
			if((cmpi_valueField.height < textHeight && textHeight <= height) || (cmpi_valueField.textHeight && cmpi_valueField.height >= textHeight)) {
				cmpi_valueField.height = textHeight
			}
			cmpi_valueField.y = (height - cmpi_valueField.height) * 0.5;
			
			shapeGraphics = graphics
			shapeGraphics.clear();
			shapeGraphics.lineStyle(1)
			shapeGraphics.beginFill(colour, colourAlpha)
			shapeGraphics.drawRect(0, 0, width - 1, height - 1)
			shapeGraphics.endFill()
			
			shapeGraphics = spr_downButton.graphics
			shapeGraphics.clear()
			shapeGraphics.beginFill(0, 0)
			shapeGraphics.drawRect(width - 16, 0, 16, height)
			shapeGraphics.endFill()
			shapeGraphics.beginFill(0, 1)
			shapeGraphics.drawTriangles(new <Number>[width - 16, height * 0.45, width - 8, height * 0.45, width - 12, height * 0.55])
			shapeGraphics.endFill()
			
			shapeGraphics = spr_upButton.graphics
			shapeGraphics.clear()
			shapeGraphics.beginFill(0, 0)
			shapeGraphics.drawRect(width - 32, 0, 16, height)
			shapeGraphics.endFill()
			shapeGraphics.beginFill(0, 1)
			shapeGraphics.drawTriangles(new <Number>[width - 24, height * 0.45, width - 28, height * 0.55, width - 20, height * 0.55])
			shapeGraphics.endFill()
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			
			removeEventListener(MouseEvent.CLICK, resetTimer)
			removeEventListener(KeyboardEvent.KEY_UP, changeState)
			removeEventListener(KeyboardEvent.KEY_DOWN, changeState)
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState)
			removeEventListener(MouseEvent.ROLL_OVER, changeState)
			removeEventListener(MouseEvent.MOUSE_UP, changeState)
			removeEventListener(MouseEvent.ROLL_OUT, changeState)
			removeEventListener(FocusEvent.FOCUS_IN, changeState)
			removeEventListener(FocusEvent.FOCUS_OUT, changeState)
			removeEventListener(MouseEvent.RELEASE_OUTSIDE, changeState)
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage)
			removeEventListener(Event.ADDED_TO_STAGE, setAddedToStage)
			
			cmpi_valueField.removeEventListener(Event.CHANGE, validateInput)
			if(stage) {
				removeFromStage(null)
			}
			cl_stepTimer.removeEventListener(TimerEvent.TIMER, increaseStep)
		}
		
		public function get stepSize():Number {
			return num_step;
		}
		
		public function set stepSize(value:Number):void 
		{
			var precString:String = value.toString()
			num_step = value;
			i_formatPrecision = precString.length - (2 + precString.indexOf('.'))
		}
		
		public function get minimum():Number {
			return num_min;
		}
		
		public function set minimum(value:Number):void 
		{
			num_min = value;
			cmpi_valueField.restrict = "0-9."
			if(value < 0) {
				cmpi_valueField.restrict = "0-9.\-"
			}
			if(this.value < value) {
				this.value = value;
			}
		}
		
		public function get maximum():Number {
			return num_max;
		}
		
		public function set maximum(value:Number):void 
		{
			num_max = value;
			if(this.value > value) {
				this.value = value;
			}
		}
	}

}