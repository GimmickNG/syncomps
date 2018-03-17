package syncomps 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.StyleManager;
	
	[Event(name="STYLE_CHANGE", type="syncomps.events.StyleEvent")]
	[Event(name="STYLE_CHANGING", type="syncomps.events.StyleEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SkinnableTextField extends TextField implements ISynComponent
	{
		protected static var DEFAULT_STYLE:Class = SkinnableTextStyle;
		
		private var cl_style:Style;
		private var b_enabled:Boolean;
		public function SkinnableTextField() 
		{
			super();
			init()
		}
		
		private function init():void 
		{
			cl_style = (new (getDefaultStyle())()) as Style
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGING, updateStyles, false, 0, true)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, applyStylesOnEvent, false, 0, true)
			StyleManager.register(this)
			b_enabled = true
		}
		
		private function applyStylesOnEvent(evt:StyleEvent):void 
		{
			switch(evt.style)
			{
				case SkinnableTextStyle.TEXT_FORMAT:
					var format:TextFormat = evt.value as TextFormat
					if (format)
					{
						defaultTextFormat = format
						setTextFormat(format)
					}
				break;
				case SkinnableTextStyle.EMBED_FONTS:
					embedFonts = evt.value
				break;
			}
			dispatchEvent(evt)
		}
		
		private function updateStyles(evt:StyleEvent):void 
		{
			evt.preventDefault()
			addEventListener(StyleEvent.STYLE_CHANGING, updateStyleOnChange, false, 0, true)
			dispatchEvent(evt)
		}
		
		private function updateStyleOnChange(evt:StyleEvent):void 
		{
			removeEventListener(StyleEvent.STYLE_CHANGING, updateStyleOnChange)
			if(!evt.isDefaultPrevented()) {
				styleDefinition.forceStyle(evt.style, evt.value)
			}
		}
		
		public function get enabled():Boolean {
			return b_enabled
		}
		public function set enabled(value:Boolean):void {
			b_enabled = value
		}
		
		public function unload():void {
			StyleManager.unregister(this)
		}
		override public function get text():String 
		{
			return super.text;
		}
		
		override public function set text(value:String):void 
		{
			super.text = value;
			if (getStyle(SkinnableTextStyle.TEXT_FORMAT) as TextFormat) {
				setTextFormat(getStyle(SkinnableTextStyle.TEXT_FORMAT) as TextFormat)
			}
		}
		public function refresh():void
		{
			var textFormat:TextFormat = getStyle(SkinnableTextStyle.TEXT_FORMAT) as TextFormat
			if (textFormat)
			{
				if (textFormat.color != null)
				{
					//color is common for all text in field
					if(enabled) {
						textFormat.color = getStyle(SkinnableTextStyle.ENABLED)
					}
					else {
						textFormat.color = getStyle(SkinnableTextStyle.DISABLED)
					}
				}
				setTextFormat(textFormat)
				defaultTextFormat = textFormat
			}
			cl_style.refresh()
		}
		
		/* DELEGATE IStyleDefinition */
		
		public function get styleDefinition():Style {
			return cl_style
		}
		
		public function getStyle(style:Object):Object {
			return styleDefinition.getStyle(style);
		}
		
		public function setStyle(style:Object, value:Object):void
		{
			StyleManager.setComponentStyle(this, style, value)
			styleDefinition.setStyle(style, value);
		}
		
		public function applyStyle(style:Style):void {
			styleDefinition.applyStyle(style)
		}
		
		public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
	}

}