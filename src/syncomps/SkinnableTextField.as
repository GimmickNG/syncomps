package syncomps 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleInternal;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.StyleManager;
	
	/**
	 * Dispatched when a style property is about to change.
	 */
	[Event(name="synStEStyleChanging", type="syncomps.events.StyleEvent")]
	
	/**
	 * Dispatched when a style property has changed.
	 */
	[Event(name="synStEStyleChange", type="syncomps.events.StyleEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SkinnableTextField extends TextField implements ISynComponent
	{
		protected static var DEFAULT_STYLE:Class = SkinnableTextStyle;
		
		//TODO add Label class which uses this and has icon control
		private var cl_style:IStyleInternal
		private var b_enabled:Boolean;
		public function SkinnableTextField() 
		{
			super();
			init()
		}
		
		private function init():void 
		{
			cl_style = (new (getDefaultStyle())()) as IStyleInternal
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
			if (dispatchEvent(evt)) {
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
		
		override public function set text(value:String):void 
		{
			super.text = value;
			if (getStyle(SkinnableTextStyle.TEXT_FORMAT) as TextFormat) {
				setTextFormat(getStyle(SkinnableTextStyle.TEXT_FORMAT) as TextFormat)
			}
		}
		
		/* DELEGATE IStyleDefinition */
		public function get styleDefinition():IStyleInternal {
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
		
		public function applyStyle(style:IStyleInternal):void {
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