package syncomps.styles 
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.IStyleInternal;
	
	/**
	 * Dispatched when a style property is changing.
	 */
	[Event(name = "synStEStyleChanging", type = "syncomps.events.StyleEvent")]
	
	/**
	 * The base class for all styles. Use this as an abstract class, which defines fields, or properties, used by the Style object.
	 * @author Gimmick
	 */
	public class Style extends EventDispatcher implements IStyleInternal
	{
		private var arr_fields:Array
		private var dct_styleSets:Dictionary
		private var vec_parents:Vector.<Class>
		
		/**
		 * Creates a style.
		 * @param	baseStyles	An array of Class which the style inherits properties from.
		 * @param	fields	The fields which are to be inherited from the parent styles.
		 */
		public function Style(baseStyles:Array = null)
		{
			var inheritArray:Vector.<Class> = Vector.<Class>(baseStyles || []);
			
			arr_fields = new Array()
			vec_parents = inheritArray
			dct_styleSets = new Dictionary(true)
			inheritArray.reverse().forEach(function copy(item:Class, index:int, array:Vector.<Class>):void {
				copyFrom(item)
			});
		}
		
		public function get styleDefinition():IStyleInternal {
			return this
		}
		
		public function getDefaultStyle():Class {
			return getDefinitionByName(getQualifiedClassName(this)) as Class
		}
		
		public function setDefaultStyle(styleClass:Class):void { /* no default implementation: abstract */ }
		
		public function getStyle(style:Object):Object {
			return dct_styleSets[style]
		}
		
		public function getStyleProperties():Dictionary
		{
			var properties:Dictionary = new Dictionary(true)
			for (var prop:Object in dct_styleSets) {
				properties[prop] = dct_styleSets[prop]
			}
			return properties
		}
		
		protected function appendStyle(style:Object, value:Object):void
		{
			if(arr_fields.lastIndexOf(style) != -1) {
				return;
			}
			arr_fields.push(style)
			forceStyle(style, value)
		}
		
		public function setStyle(style:Object, value:Object):void
		{
			if (arr_fields.indexOf(style) == -1 || (style in dct_styleSets && ((dct_styleSets[style] === value) || (dct_styleSets[style] == value) || (isNaN(dct_styleSets[style] as Number) && isNaN(value as Number))))) {
				return;	//do not set style if it is not present in traits, or if it is the same
			}
			else if(dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, style, value, true, true))) {
				forceStyle(style, value)
			}
		}
		
		public function getFields():Array {
			return arr_fields && arr_fields.concat()
		}
		
		public function copyFrom(defaultStyleClass:Class):void 
		{
			if(!defaultStyleClass) {
				return;
			}
			
			var style:IStyleInternal = new defaultStyleClass() as IStyleInternal
			if(!dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, null, style, true, true))) {
				return;
			}
			
			var defaultStyleSet:Dictionary = style.getStyleProperties()
			arr_fields = arr_fields.concat(style.getFields())
			for (var prop:Object in defaultStyleSet) {
				dct_styleSets[prop] = defaultStyleSet[prop]
			}
			
			var parents:Vector.<Class> = style.getInheritanceChain()
			if (parents)
			{
				vec_parents ||= parents.concat().reverse();
				parents.forEach(function addParents(item:Class, index:int, array:Vector.<Class>):void
				{
					if(vec_parents.lastIndexOf(item) == -1) {
						vec_parents.unshift(item);
					}
				});
			}
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, null, style, true, false))
		}
		
		/**
		 * Copies all the properties which are common to both styles to the current style.
		 * Similar to copyFrom(), but does not introduce new properties.
		 * @param	style
		 */
		public function applyStyle(style:IStyleInternal):void 
		{
			if (!style) {
				return;
			}
			var styleSet:Dictionary = style.getStyleProperties()
			for (var property:Object in dct_styleSets)
			{
				if (property in styleSet && dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, property, styleSet[property], true, true))) {
					forceStyle(property, styleSet[property])
				}
			}
		}
		
		public function getInheritanceChain():Vector.<Class> {
			return vec_parents && vec_parents.concat()
		}
		
		public function forceStyle(style:Object, value:Object):void
		{
			dct_styleSets[style] = value
			dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGE, style, value, true, false))
		}
	}

}