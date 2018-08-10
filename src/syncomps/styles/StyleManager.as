package syncomps.styles
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import syncomps.ComboBox;
	import syncomps.TextInput;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.IStyleInternal;
	import syncomps.interfaces.ISynComponent;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class StyleManager
	{
		/**
		 * The style bias.
		 */
		private static const STYLE_BIAS:int = -1;
		/**
		 * The default bias, for when the type is not explicitly known.
		 */
		private static const DEFAULT_BIAS:int = 0;
		/**
		 * The component bias.
		 */
		private static const COMPONENT_BIAS:int = 1;
		
		private static var cl_styleManager:StyleManager
		private var dct_styleSets:Dictionary;
		private var vec_setIndices:Vector.<String>
		public function StyleManager()
		{
			init()
			if(cl_styleManager) {
				throw new Error("Cannot initialize more than one copy of a StyleManager.")
			}
			cl_styleManager = this;
		}
		
		private function init():void
		{
			vec_setIndices = new Vector.<String>()
			dct_styleSets = new Dictionary(false)
		}
		
		public function register(component:ISynComponent):void
		{
			if(!(component && component.styleDefinition)) {
				return;
			}
			var style:IStyleInternal = component.styleDefinition
			var styleClassObj:StyleChainData = registerClass(getQualifiedClassName(style))
			if(!styleClassObj.parents) {
				styleClassObj.parents = style.getInheritanceChain()
			}
			var componentClassName:String = getQualifiedClassName(component)
			var componentClassObj:StyleChainData = registerClass(componentClassName, COMPONENT_BIAS)
			registerComponent(component)
			var classChildren:Dictionary = componentClassObj.children
			var objChildren:Dictionary = styleClassObj.children
			if (!classChildren)
			{
				componentClassObj.children = classChildren = new Dictionary(false);
				for (var child:Object in objChildren)
				{
					var currComponent:ISynComponent = child as ISynComponent
					if(getQualifiedClassName(currComponent) == componentClassName) {
						classChildren[currComponent] = componentClassName
					}
				}
			}
			classChildren[component] = objChildren[component] = componentClassName
			refreshComponent(component)
		}
		
		internal function unregisterDefinition(style:IStyleInternal):void
		{
			if (!style) {
				return;
			}
			var child:Object, prop:Object;
			var styleClassName:String = getQualifiedClassName(style)
			var styleData:StyleChainData = dct_styleSets[styleClassName];
			if (styleData)
			{
				//unlink entire component style from tree
				var childArr:Dictionary = styleData.children
				var continueDelete:Boolean = true;
				for (child in childArr)
				{
					continueDelete = false;	//do not continue if any children remaining
					break;
				}
				for (prop in styleData.properties)
				{
					continueDelete = false;	//do not continue delete if any prop is present
					break;
				}
				
				if (continueDelete)
				{
					vec_setIndices.removeAt(vec_setIndices.indexOf(styleClassName))
					delete dct_styleSets[styleClassName];
				}
			}
		}
		
		internal function unregisterAll(component:ISynComponent):void
		{
			if (!component) {
				return;
			}
			unregisterComponent(component)
			unregisterClass(getQualifiedClassName(component))
			unregisterDefinition(component.styleDefinition)
		}
		
		internal function setComponentStyle(component:ISynComponent, style:Object, value:Object):void {
			registerComponent(component).properties[style] = value;
		}
		
		internal function registerComponent(component:ISynComponent):StyleChainData
		{
			var currData:StyleChainData = dct_styleSets[component] as StyleChainData
			if (component && !currData)
			{
				var componentClassData:StyleChainData = registerClass(getQualifiedClassName(component), COMPONENT_BIAS)
				dct_styleSets[component] = currData = new StyleChainData(new Dictionary(false), null, null, COMPONENT_BIAS);
				(dct_styleSets[component] as StyleChainData).parents = componentClassData.parents = component.styleDefinition.getInheritanceChain()
			}
			return currData
		}
		
		private function unregisterComponent(component:ISynComponent):void 
		{
			var currData:StyleChainData = dct_styleSets[component] as StyleChainData;
			if (component && currData)
			{
				//unlink child from tree
				function clearChildrenIfFound(className:String, component:ISynComponent):void
				{
					var childArr:Dictionary = (dct_styleSets[className] as StyleChainData).children
					if(component in childArr) {
						delete childArr[component]
					}
				}
				clearChildrenIfFound(getQualifiedClassName(component), component)
				clearChildrenIfFound(getQualifiedClassName(component.styleDefinition), component)
				
				var prop:Dictionary = currData.properties as Dictionary
				for (var child:Object in prop) {
					delete prop[child];
				}
				delete dct_styleSets[component];
			}
		}
		
		internal function registerClass(className:String, bias:int = DEFAULT_BIAS):StyleChainData
		{
			var currData:StyleChainData = dct_styleSets[className] as StyleChainData;
			if (!currData)
			{
				vec_setIndices.push(className)
				dct_styleSets[className] = currData = new StyleChainData(new Dictionary(false), new Dictionary(false), null, bias)
			}
			return currData
		}
		
		private function unregisterClass(className:String):void 
		{
			var currData:StyleChainData = dct_styleSets[className] as StyleChainData;
			if (currData)
			{
				//unlink component class from tree
				var childArr:Dictionary = currData.children
				var continueDelete:Boolean = true;
				for (var child:Object in childArr)
				{
					continueDelete = false;	//do not continue if any children remaining
					break;
				}
				for (var property:Object in currData.properties)
				{
					continueDelete = false;	//do not continue delete if any property is present
					break;
				}
				
				if (continueDelete) {
					delete dct_styleSets[className];
				}
			}
		}
		
		public function setStyle(styleClass:Class, style:Object, value:Object, refreshAll:Boolean):void
		{
			var styleClassName:String = getQualifiedClassName(styleClass)
			var currObj:StyleChainData = registerClass(styleClassName)
			currObj.properties[style] = value
			if (refreshAll) {
				updateChildren(currObj)
			}
		}
		
		private function updateChildren(styleDescriptor:StyleChainData):void
		{
			if(!(styleDescriptor && styleDescriptor.children)) {
				return;
			}
			var children:Dictionary = styleDescriptor.children
			for (var child:Object in children) {
				refreshComponent(child as ISynComponent);
			}
		}
		
		public function forceRefresh():void
		{
			vec_setIndices = vec_setIndices.filter(filterNull).sort(sortStyleSets);
			vec_setIndices.forEach(updateAllChildren)
		}
		private function filterNull(item:String, index:int, array:Vector.<String>):Boolean {
			return (item in dct_styleSets);
		}
		private function updateAllChildren(item:String, index:int, array:Vector.<String>):void {
			updateChildren(dct_styleSets[item]);
		}
		
		private function refreshComponent(component:ISynComponent):void
		{
			if(!(component && component.styleDefinition)) {
				return;
			}
			var style:IStyleInternal = component.styleDefinition
			var currObj:StyleChainData = registerClass(getQualifiedClassName(style))
			var parents:Vector.<Class> = (currObj.parents ||= style.getInheritanceChain());
			parents.forEach(function applyStyles(item:Class, index:int, array:Vector.<Class>):void {
				item && applyStyleDefinition(style, registerClass(getQualifiedClassName(item), STYLE_BIAS))	//apply properties of classes from first to last
			})
			applyStyleDefinition(style, registerClass(getQualifiedClassName(style)))			//style class-level styles
			applyStyleDefinition(component, registerClass(getQualifiedClassName(component)))	//component class-level styles
			applyStyleDefinition(style, dct_styleSets[component] as StyleChainData)				//component instance-level styles
		}
		
		private function applyStyleDefinition(styleDefinition:IStyleDefinition, styleDescriptor:StyleChainData):void
		{
			if (!(styleDescriptor && styleDescriptor.properties)) {
				return;
			}
			var currProperties:Dictionary = styleDescriptor.properties
			for (var prop:Object in currProperties) {
				styleDefinition.setStyle(prop, currProperties[prop])
			}
		}
		
		private function sortStyleSets(styleAName:String, styleBName:String):int
		{
			/**
			 * Selects style A, i.e. style A appears before style B.
			 */
			const A_FIRST:int = -1
			/**
			 * Selects style B, i.e. style B appears before style A.
			 */
			const B_FIRST:int = 1
			var styleDataA:StyleChainData = dct_styleSets[styleAName] as StyleChainData
			var styleDataB:StyleChainData = dct_styleSets[styleBName] as StyleChainData
			var styleBias:int = (styleDataA.bias - styleDataB.bias)
			var parentA:Vector.<Class> = styleDataA.parents
			var parentB:Vector.<Class> = styleDataB.parents
			var favor:int;
			
			if(styleBias) {
				return styleBias	//always return the bias if it is not 0, i.e. if there is a bias difference
			}
			else if (parentA && parentB)
			{
				if(parentA.indexOf(getDefinitionByName(styleBName) as Class) != -1) {
					favor = A_FIRST	//B is a child of A; select style A first
				}
				else if(parentB.indexOf(getDefinitionByName(styleAName) as Class) != -1) {
					favor = B_FIRST	//A is a child of B; select style B first
				}
				favor = (parentA.length - parentB.length)
			}
			else if(parentA) {
				favor = B_FIRST	//styleB has no parents, but styleA does => select style B
			}
			else if(parentB) {
				favor = A_FIRST	//styleA has no parents, but styleB does => select style A
			}
			return favor
		}
		
		private static function get mainInstance():StyleManager {
			return cl_styleManager || new StyleManager()
		}
		
		public static function register(component:ISynComponent):void {
			mainInstance.register(component)
		}
		
		/**
		 * Sets a style property for a given class of Style. 
		 * The refreshNodes flag is used to indicate whether changes are to be updated in those components inheriting directly from (applying) the given style
		 * and not necessarily ones which derive from this style. 
		 * 
		 * To update auxiliary styles inheriting from the affected style class as well, use the updateAll() function.
		 * @param	styleClass
		 * @param	style
		 * @param	value
		 * @param	updateNodes
		 */
		public static function setStyle(styleClass:Class, style:Object, value:Object, updateNodes:Boolean):void {
			mainInstance.setStyle(styleClass, style, value, updateNodes)
		}
		
		/**
		 * Used to set the style for a given component; equivalent to calling setStyle() on a given ISynComponent.
		 * @param	component	An instance of type ISynComponent to set the style for.
		 * @param	style	The style property to set
		 * @param	value	The value of the style
		 */
		public static function setComponentStyle(component:ISynComponent, style:Object, value:Object):void {
			mainInstance.setComponentStyle(component, style, value)
		}
		
		/**
		 * Forces a top-down refresh of all styles, on all components currently registered. Updates those components whose styles inherit from modified styles as well.
		 */
		public static function updateAll():void {
			mainInstance.forceRefresh()
		}
		
		public static function unregister(component:ISynComponent):void {
			mainInstance.unregisterAll(component)
		}
		
		public static function unregisterDefinition(style:IStyleInternal):void {
			mainInstance.unregisterDefinition(style)
		}
	}

}

import flash.utils.Dictionary;
internal class StyleChainData
{
	public var children:Dictionary
	public var properties:Dictionary;
	public var parents:Vector.<Class>
	/**
	 * Used to favor styles over component classes. Component classes have a bias of 1 and styles have a bias of -1.
	 * This is used to sort the order in which styles are processed in the updateAll() method.
	 * For example, by calling biasA - biasB, components are shifted lower down the hierarchy since their biases are higher than style biases.
	 */
	public var bias:int
	
	public function StyleChainData(properties:Dictionary, children:Dictionary, parents:Vector.<Class>, bias:int)
	{
		this.properties = properties
		this.children = children
		this.parents = parents
		this.bias = bias
	}
}