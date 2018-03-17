package syncomps.styles 
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleDefinition;
	/**
	 * The base class for all styles. Use this as an abstract class, which defines fields, or properties, used by the Style object.
	 * @author Gimmick
	 */
	public class Style extends EventDispatcher implements IStyleDefinition
	{
		protected var arr_fields:Array
		private var arr_parents:Array
		private var dct_styleSets:Dictionary
		/**
		 * 
		 * @param	baseStyles An array of Class
		 */
		public function Style(baseStyles:Array = null, fields:Array = null) 
		{
			if(!fields) {
				fields = new Array()
			}
			if(!baseStyles) {
				baseStyles = new Array()
			}
			init(baseStyles, fields)
		}
		
		private function init(inheritArray:Array, fieldArray:Array):void 
		{
			arr_fields = fieldArray
			dct_styleSets = new Dictionary(true)
			arr_parents = inheritArray.concat()
			for (var i:int = inheritArray.length - 1; i >= 0; --i) {
				copyFrom(inheritArray[i] as Class)
			}
			
			addEventListener(StyleEvent.STYLE_CHANGING, setStyleOnEvent, false, 0, true)
		}
		
		public function get styleDefinition():Style {
			return this
		}
		
		public function getDefaultStyle():Class {
			return Style
		}
		
		public function setDefaultStyle(styleClass:Class):void {
			return;
		}
		
		public function getStyle(style:Object):Object {
			return dct_styleSets[style]
		}
		
		public function getStyleDefinition():Object
		{
			var def:Object = {}
			for (var i:Object in dct_styleSets) {
				def[i] = dct_styleSets[i]
			}
			return def
		}
		
		public function setStyle(style:Object, value:Object):void
		{
			if ((style in dct_styleSets && nonStrictEquals(dct_styleSets[style], value)) || arr_fields.indexOf(style) == -1) {
				return;	
			}
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, style, value, true, true))
		}
		
		[Inline]
		private final function nonStrictEquals(varA:*, varB:*):Boolean {
			return (varA == varB) || (fastIsNaN(varA) && fastIsNaN(varB))
		}
		
		[Inline]
		private final function fastIsNaN(varA:*):Boolean {
			return varA !== varA	//NaN == NaN or NaN === NaN is always false but 1===1 so 
		}
		
		private function setStyleOnEvent(evt:StyleEvent):void
		{
			if(!evt.isDefaultPrevented()) {
				forceStyle(evt.style, evt.value)
			}
		}
		
		public function copyFrom(defaultStyleClass:Class):void 
		{
			if(!defaultStyleClass) {
				return;
			}
			var style:Style = new defaultStyleClass as Style
			var defaultStyleSet:Dictionary = style.dct_styleSets
			arr_fields = arr_fields.concat.apply(null, style.arr_fields)
			for (var prop:Object in defaultStyleSet) {
				dct_styleSets[prop] = defaultStyleSet[prop]
			}
			var parents:Array = style.arr_parents;
			if (parents)
			{
				if (!arr_parents) {
					arr_parents = parents.concat().reverse()
				}
				else for (var i:uint = 0; i < parents.length; ++i)
				{
					if(arr_parents.indexOf(parents[i]) == -1) {
						arr_parents.unshift(parents[i])
					}
				}
			}
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, null, style, true, false))
		}
		
		/**
		 * Copies all the properties which are common to both styles to the current style.
		 * Similar to copyFrom(), but does not introduce new properties.
		 * @param	style
		 */
		public function applyStyle(style:Style):void 
		{
			if (style)
			{
				addEventListener(StyleEvent.STYLE_CHANGING, applyStyleOnEvent, false, 0, true)
				dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, null, style, true, true))
			}
		}
		
		private function applyStyleOnEvent(evt:StyleEvent):void
		{
			removeEventListener(StyleEvent.STYLE_CHANGING, applyStyleOnEvent)
			if(evt.isDefaultPrevented()) {
				return;
			}
			var style:Style = evt.value as Style
			var styleSet:Dictionary = style.dct_styleSets
			for(var i:Object in dct_styleSets) {
				dct_styleSets[i] = styleSet[i]
			}
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, null, evt.value, true, false))
		}
		
		public function getInheritanceChain():Array {
			return arr_parents.concat()
		}
		
		public function refresh():void 
		{
			for (var prop:Object in dct_styleSets) {
				dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, prop, dct_styleSets[prop], true, false))
			}
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, null, null, true, false))
		}
		
		public function forceStyle(style:Object, value:Object):void 
		{
			dct_styleSets[style] = value
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, style, value, true, false))
		}
	}

}