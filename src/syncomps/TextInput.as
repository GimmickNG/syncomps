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
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	public class TextInput extends SynComponent implements IAutoResize
	{
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private var fon_currentFont:Font
		private var cmpi_label:Label;
		private var tf_input:SkinnableTextField;
		private var tff_labelFormat:TextFormat;
		public function TextInput() {
			init()
		}
		
		private function init():void
		{
			tabEnabled = false	//tf_label is tabEnabled, not this
			cmpi_label = new Label()
			tf_input = new SkinnableTextField()
			tff_labelFormat = new TextFormat()
			StyleManager.unregister(cmpi_label)
			StyleManager.unregister(tf_input)
			
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			cmpi_label.setStyle(SkinnableTextStyle.TEXT_FORMAT, tff_labelFormat)
			cmpi_label.height = 24
			
			tf_input.width = 100;
			tf_input.height = 24;
			tf_input.enabled = true;
			tf_input.multiline = false;
			tf_input.type = TextFieldType.INPUT
			tf_input.addEventListener(Event.CHANGE, monitorTextInput, false, 0, true)
			tf_input.addEventListener(TextEvent.TEXT_INPUT, checkCharacterEmbedInput, false, 0, true)
			tf_input.addEventListener(MouseEvent.MOUSE_OVER, preventMouseOverCapture, false, 0, true)
			drawGraphics(100, 24, DefaultStyle.BACKGROUND)
			
			addChild(tf_input)
			addChild(cmpi_label)
		}
		
		private function checkCharacterEmbedInput(evt:TextEvent):void 
		{
			if (fon_currentFont && getStyle(SkinnableTextStyle.EMBED_FONTS))
			{
				var embed:Boolean = fon_currentFont.hasGlyphs(tf_input.text + evt.text)
				var embedFonts:String = SkinnableTextStyle.EMBED_FONTS
				tf_input.setStyle(embedFonts, embed)
				cmpi_label.setStyle(embedFonts, embed)
			}
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
			cmpi_label.setStyle(evt.style, value)
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
			cmpi_label.visible = (tf_input.text == "" || !tf_input.text.length)
			if (fon_currentFont && getStyle(SkinnableTextStyle.EMBED_FONTS))
			{
				var embed:Boolean = fon_currentFont.hasGlyphs(tf_input.text)
				var embedFonts:String = SkinnableTextStyle.EMBED_FONTS
				tf_input.setStyle(embedFonts, embed)
				cmpi_label.setStyle(embedFonts, embed)
			}
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		public function set placeHolder(value:String):void {
			cmpi_label.label = value
		}
		
		public function get placeHolder():String {
			return cmpi_label.label
		}
		
		public function get value():String {
			return tf_input.text
		}
		
		public function get textField():TextField {
			return tf_input
		}
		
		public function get placeHolderField():TextField {
			return cmpi_label.textField
		}
		
		public function reset():void {
			tf_input.text = "";
		}
		
		public function focus():void {
			stage && (stage.focus = tf_input)
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
			var color:uint = uint(getStyle(state))
			var borderColor:uint = uint(getStyle(DefaultInnerTextStyle.BORDER))
			if(!enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			cmpi_label.width = tf_input.width = width;
			cmpi_label.height = tf_input.height = height
			graphics.clear()
			graphics.lineStyle(1, borderColor & 0x00FFFFFF, ((borderColor & 0xFF000000) >>> 24) / 0xFF)
			graphics.beginFill(color & 0x00FFFFFF, ((color & 0xFF000000) >>> 24) / 0xFF);
			graphics.drawRect(0, 0, width - 1, height - 1);
		}
		
		override public function unload():void
		{
			super.unload()
			tf_input.removeEventListener(Event.CHANGE, monitorTextInput)
			cmpi_label = null;
			tf_input = null;
		}
		
		/* DELEGATE flash.text.TextField */
		
		public function replaceSelectedText(value:String):void {
			tf_input.replaceSelectedText(value);
		}
		
		public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
			tf_input.replaceText(beginIndex, endIndex, newText);
		}
		
		public function get restrict():String {
			return tf_input.restrict;
		}
		
		public function set restrict(value:String):void {
			tf_input.restrict = value;
		}
		
		public function get selectedText():String {
			return tf_input.selectedText;
		}
		
		public function get selectionBeginIndex():int {
			return tf_input.selectionBeginIndex;
		}
		
		public function get selectionEndIndex():int {
			return tf_input.selectionEndIndex;
		}
		
		public function setSelection(beginIndex:int, endIndex:int):void {
			tf_input.setSelection(beginIndex, endIndex);
		}
		
		/* END DELEGATE */
		
		public function resizeWidth():void 
		{
			cmpi_label.resizeWidth()
			width = cmpi_label.width + 16
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
		
		public function set borderColor(val:uint):void {
			setStyle(DefaultInnerTextStyle.BORDER, val)
		}
		
		public function get borderColor():uint {
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
