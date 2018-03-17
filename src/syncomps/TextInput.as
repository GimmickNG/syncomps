package syncomps
{	
	import flash.display.Sprite
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IAutoResize;
	import syncomps.interfaces.ILabel;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	public class TextInput extends SynComponent implements IAutoResize, ILabel
	{
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private var fon_currentFont:Font
		private var tf_label:SkinnableTextField;
		private var tf_input:SkinnableTextField;
		private var tff_labelFormat:TextFormat;
		public function TextInput() {
			init()
		}
		
		private function init():void
		{
			tabEnabled = false	//tf_label is tabEnabled, not this
			tf_label = new SkinnableTextField()
			tf_input = new SkinnableTextField()
			tff_labelFormat = new TextFormat()
			StyleManager.unregister(tf_label)
			StyleManager.unregister(tf_input)
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			tf_label.selectable = tf_label.multiline = tf_label.mouseEnabled = tf_label.tabEnabled = false
			tf_label.defaultTextFormat = tff_labelFormat
			tf_label.height = 24
			
			tf_input.type = TextFieldType.INPUT
			tf_input.multiline = false;
			tf_input.enabled = true;
			tf_input.height = 24;
			tf_input.width = 100;
			tf_input.addEventListener(Event.CHANGE, monitorTextInput, false, 0, true)
			tf_input.addEventListener(TextEvent.TEXT_INPUT, checkCharacterEmbedInput, false, 0, true)
			tf_input.addEventListener(MouseEvent.MOUSE_OVER, preventMouseOverCapture, false, 0, true)
			drawGraphics(100, 24, DefaultStyle.BACKGROUND)
			
			addChild(tf_input)
			addChild(tf_label)
		}
		
		private function checkCharacterEmbedInput(evt:TextEvent):void 
		{
			if (fon_currentFont && getStyle(SkinnableTextStyle.EMBED_FONTS))
			{
				var embed:Boolean = fon_currentFont.hasGlyphs(tf_input.text + evt.text)
				var embedFonts:String = SkinnableTextStyle.EMBED_FONTS
				tf_input.setStyle(embedFonts, embed)
				tf_label.setStyle(embedFonts, embed)
			}
		}
		
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		
		public function get textHeight():int {
			return tf_input.textHeight
		}
		public function get textWidth():int {
			return tf_input.textWidth
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			var value:Object = evt.value
			tf_input.setStyle(evt.style, value)
			if (evt.style == SkinnableTextStyle.TEXT_FORMAT)
			{
				var baseFormat:TextFormat = value as TextFormat
				copyFormat(baseFormat, tff_labelFormat)
				tff_labelFormat.color = 0x888888
				tff_labelFormat.italic = true
				tff_labelFormat.bold = false
				value = tff_labelFormat
				if (baseFormat && baseFormat.font && (!fon_currentFont || fon_currentFont.fontName != baseFormat.font))
				{
					var embeddedFonts:Array = Font.enumerateFonts(false)
					for (var i:uint = 0; i < embeddedFonts.length; ++i)
					{
						var currFont:Font = embeddedFonts[i] as Font;
						if (currFont.fontName == baseFormat.font)
						{
							fon_currentFont = currFont
							break;
						}
					}
				}
			}
			tf_label.setStyle(evt.style, value)
		}
		
		private function copyFormat(format:TextFormat, into:TextFormat):void
		{
			if (format && into)
			{
				into.align = format.align
				into.blockIndent = format.blockIndent
				into.bold = format.bold
				into.bullet = format.bullet
				into.color = format.color
				into.display = format.display
				into.font = format.font
				into.indent = format.indent
				into.italic = format.italic
				into.kerning = format.kerning
				into.leading = format.leading
				into.leftMargin = format.leftMargin
				into.letterSpacing = format.letterSpacing
				into.rightMargin = format.rightMargin
				into.size = format.size
				into.tabStops = format.tabStops
				into.target = format.target
				into.underline = format.underline
				into.url = format.url
			}
		}
		
		public function set isPasswordField(value:Boolean):void {
			tf_input.displayAsPassword = value
		}
		
		public function get isPasswordField():Boolean {
			return tf_input.displayAsPassword
		}
		
		private function preventMouseOverCapture(evt:MouseEvent):void 
		{
			evt.stopImmediatePropagation()
			dispatchEvent(evt)
		}
		
		private function monitorTextInput(evt:Event):void
		{
			tf_label.visible = (tf_input.text == "" || !tf_input.text.length)
			if (fon_currentFont && getStyle(SkinnableTextStyle.EMBED_FONTS))
			{
				var embed:Boolean = fon_currentFont.hasGlyphs(tf_input.text)
				var embedFonts:String = SkinnableTextStyle.EMBED_FONTS
				tf_input.setStyle(embedFonts, embed)
				tf_label.setStyle(embedFonts, embed)
			}
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		public function set placeHolder(value:String):void {
			tf_label.text = value
		}
		
		public function get placeHolder():String {
			return tf_label.text
		}
		
		public function get value():String {
			return tf_input.text
		}
		
		public function get textField():TextField {
			return tf_input
		}
		
		public function get placeHolderField():TextField {
			return tf_label
		}
		
		public function reset():void {
			tf_input.text = ""
		}
		
		public function focus():void
		{
			if (stage) {
				stage.focus = tf_input
			}
		}
		
		public function set value(value:String):void
		{
			if(tf_input.text == value) {
				return;
			}
			tf_input.text = value
			if (enabled) {
				tf_input.dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			super.drawGraphics(width, height, state)
			var colour:uint = uint(getStyle(state))
			var borderColour:uint = uint(getStyle(DefaultInnerTextStyle.BORDER))
			if(!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			tf_label.width = tf_input.width = width;
			tf_label.height = tf_input.height = height
			graphics.clear()
			graphics.lineStyle(1, borderColour & 0x00FFFFFF, ((borderColour & 0xFF000000) >>> 24) / 0xFF)
			graphics.beginFill(colour & 0x00FFFFFF, ((colour & 0xFF000000) >>> 24) / 0xFF);
			graphics.drawRect(0, 0, width - 1, height - 1);
		}
		
		override public function unload():void
		{
			super.unload()
			tf_input.removeEventListener(Event.CHANGE, monitorTextInput)
			tf_label = null;
			tf_input = null;
		}
		
		/* DELEGATE flash.text.TextField */
		
		public function replaceSelectedText(value:String):void 
		{
			tf_input.replaceSelectedText(value);
		}
		
		public function replaceText(beginIndex:int, endIndex:int, newText:String):void 
		{
			tf_input.replaceText(beginIndex, endIndex, newText);
		}
		
		public function get restrict():String 
		{
			return tf_input.restrict;
		}
		
		public function set restrict(value:String):void 
		{
			tf_input.restrict = value;
		}
		
		public function get selectedText():String 
		{
			return tf_input.selectedText;
		}
		
		public function get selectionBeginIndex():int 
		{
			return tf_input.selectionBeginIndex;
		}
		
		public function get selectionEndIndex():int 
		{
			return tf_input.selectionEndIndex;
		}
		
		public function setSelection(beginIndex:int, endIndex:int):void 
		{
			tf_input.setSelection(beginIndex, endIndex);
		}
		
		public function resizeWidth():void 
		{
			tf_label.autoSize = TextFieldAutoSize.LEFT
			var widthVal:Number = tf_label.width
			tf_label.autoSize = TextFieldAutoSize.NONE
			width = widthVal + 16
		}
		
		public function resizeHeight():void 
		{
			height = tf_input.textHeight + 16
		}
		
		public function get maxChars():int {
			return tf_input.maxChars;
		}
		
		public function set maxChars(value:int):void {
			tf_input.maxChars = value;
		}
		
		public function get caretIndex():int {
			return tf_input.caretIndex
		}	
		// end of delegate methods
		
		public function set background(val:uint):void {
			setStyle(DefaultStyle.BACKGROUND, val)
		}
		
		public function get background():uint {
			return uint(getStyle(DefaultStyle.BACKGROUND))
		}
		
		public function set borderColour(val:uint):void {
			setStyle(DefaultInnerTextStyle.BORDER, val)
		}
		
		public function get borderColour():uint {
			return uint(getStyle(DefaultInnerTextStyle.BORDER))
		}
		
		override public function set enabled(value:Boolean):void
		{
			if (value) {
				tf_input.type = TextFieldType.INPUT
			}
			else {
				tf_input.type = TextFieldType.DYNAMIC
			}
			super.enabled = value
			tf_input.selectable = value
		}
		
	}
	
}
