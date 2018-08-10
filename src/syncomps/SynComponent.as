package syncomps 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.IStyleInternal;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.Style;
	import syncomps.styles.StyleManager;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SynComponent extends Sprite implements ISynComponent
	{
		private var str_state:String;
		private var cl_style:IStyleInternal;
		public function SynComponent() {
			init();
		}
		
		private function init():void
		{
			cl_style = (new (getDefaultStyle())()) as IStyleInternal
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, handleStyleChangeEvent, false, 0, true)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGING, updateStyles, false, 0, true)
			StyleManager.register(this)
			tabEnabled = true
		}
		
		//interface methods for IStyleDefinition
		public function get styleDefinition():IStyleInternal {
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
		public function applyStyle(style:IStyleInternal):void {
			styleDefinition.applyStyle(style)
		}
		
		public function getDefaultStyle():Class {
			return null
		}
		
		public function setDefaultStyle(styleClass:Class):void { /* empty implementation - abstract method */ }
		
		private function updateStyles(evt:StyleEvent):void 
		{
			evt.preventDefault()
			if(dispatchEvent(evt)) {
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
		
		override public function set width(value:Number):void 
		{
			if(value < 0) {
				value = 0;
			}
			drawGraphics(value, height, str_state);
		}
		
		override public function set height(value:Number):void 
		{
			if(value < 0) {
				value = 0;
			}
			drawGraphics(width, value, str_state);
		}
		
		protected function get state():String {
			return str_state;
		}
		
		protected function set state(value:String):void {
			str_state = value;
		}
	}

}