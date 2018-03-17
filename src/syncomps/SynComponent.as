package syncomps 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.Style;
	import syncomps.styles.StyleManager;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SynComponent extends Sprite implements ISynComponent
	{
		protected var str_state:String;
		protected var cl_style:Style;
		public function SynComponent() {
			init();
		}
		
		//interface methods for IStyleDefinition
		public function get styleDefinition():Style {
			return cl_style
		}
		
		public function setStyle(style:Object, value:Object):void
		{
			StyleManager.setComponentStyle(this, style, value);
			styleDefinition.setStyle(style, value)
		}
		
		public function getStyle(style:Object):Object {
			return styleDefinition.getStyle(style)
		}
		public function applyStyle(style:Style):void {
			styleDefinition.applyStyle(style)
		}
		
		public function getDefaultStyle():Class {
			return null
		}
		public function setDefaultStyle(styleClass:Class):void {
			return;
		}
		
		private function init():void
		{
			tabEnabled = true
			cl_style = (new (getDefaultStyle())()) as Style
			StyleManager.register(this)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, handleStyleChangeEvent, false, 0, true)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGING, updateStyles, false, 0, true)
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
		
		private function handleStyleChangeEvent(evt:StyleEvent):void
		{
			if(evt.style == null && evt.value == null) {
				drawGraphics(width, height, str_state)	//refresh flag is (null, null)
			}
			dispatchEvent(evt)
		}
		
		public function get enabled():Boolean { 
			return mouseEnabled || tabEnabled || tabChildren || mouseChildren;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (enabled != value)
			{
				tabEnabled = tabChildren = mouseEnabled = mouseChildren = value;
				drawGraphics(width, height, str_state)
			}
		}
		
		public function unload():void
		{
			StyleManager.unregister(this)
			clearGraphics()
			str_state = null;
		}
		
		protected function clearGraphics():void {
			graphics.clear()
		}
		
		protected function drawGraphics(width:int, height:int, state:String):void {
			str_state = state
		}
		
		public function refresh():void
		{
			cl_style.refresh()
			drawGraphics(width, height, str_state)
		}
	}

}