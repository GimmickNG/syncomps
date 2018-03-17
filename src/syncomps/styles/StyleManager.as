package syncomps.styles
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import syncomps.ComboBox;
	import syncomps.TextInput;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.ISynComponent;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class StyleManager
	{
		private static var cl_styleManager:StyleManager
		private var dct_styleSets:Dictionary;
		private var arr_setIndices:Array;
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
			arr_setIndices = new Array()
			dct_styleSets = new Dictionary(false)
		}
		
		public function register(component:ISynComponent):void
		{
			if(!(component && component.styleDefinition)) {
				return;
			}
			var style:Style = component.styleDefinition
			var styleClassObj:StyleChainData = registerClass(getQualifiedClassName(style))
			if(!styleClassObj.parents) {
				styleClassObj.parents = style.getInheritanceChain()
			}
			var componentClassName:String = getQualifiedClassName(component)
			var componentClassObj:StyleChainData = registerClass(componentClassName)
			registerComponent(component)
			var classChildren:Dictionary = componentClassObj.children
			var objChildren:Dictionary = styleClassObj.children
			if (!classChildren)
			{
				componentClassObj.children = classChildren = new Dictionary(false);
				for(var child:Object in objChildren)
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
		
		internal function unregister(component:ISynComponent):void
		{
			if (component && component.styleDefinition)
			{
				var className:String;
				var childArr:Dictionary;
				var continueDelete:Boolean;
				var currObj:StyleChainData, child:Object, prop:Object;
				currObj = dct_styleSets[component] as StyleChainData;
				if (currObj)
				{
					//unlink child from tree
					prop = currObj.properties as Dictionary
					for(child in prop) {
						delete prop[child];
					}
					delete dct_styleSets[component]
				}
				className = getQualifiedClassName(component)
				currObj = dct_styleSets[className] as StyleChainData
				if (currObj)
				{
					//unlink component class from tree
					childArr = currObj.children
					if(component in childArr) {
						delete childArr[component]
					}
					continueDelete = true;
					for (child in childArr)
					{
						continueDelete = false;	//do not continue if any children remaining
						break;
					}
					for (prop in currObj.properties)
					{
						continueDelete = false;	//do not continue delete if any prop is present
						break;
					}
					if (continueDelete) {
						delete dct_styleSets[className];
					}
				}
				className = getQualifiedClassName(component.styleDefinition)
				currObj = dct_styleSets[className];
				if (currObj)
				{
					//unlink entire component style from tree
					childArr = currObj.children
					if(component in childArr) {
						delete childArr[component]
					}
					continueDelete = true;
					for (child in childArr)
					{
						continueDelete = false;	//do not continue if any children remaining
						break;
					}
					for (prop in currObj.properties)
					{
						continueDelete = false;	//do not continue delete if any prop is present
						break;
					}
					if (continueDelete)
					{
						arr_setIndices.removeAt(arr_setIndices.indexOf(className))
						delete dct_styleSets[className];
					}
				}
			}
		}
		
		internal function setComponentStyle(component:ISynComponent, style:Object, value:Object):void {
			registerComponent(component).properties[style] = value;
		}
		
		internal function registerComponent(component:ISynComponent):StyleChainData
		{
			var currData:StyleChainData = dct_styleSets[component] as StyleChainData
			if (component && !currData)
			{
				registerClass(getQualifiedClassName(component))
				dct_styleSets[component] = currData = new StyleChainData(new Dictionary(false), null, null)
			}
			return currData
		}
		
		internal function registerClass(className:String):StyleChainData
		{
			var currData:StyleChainData = dct_styleSets[className] as StyleChainData;
			if (!currData)
			{
				arr_setIndices.push(className)
				dct_styleSets[className] = currData = new StyleChainData(new Dictionary(false), new Dictionary(false), null)
			}
			return currData
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
			for(var child:Object in children) {
				refreshComponent(child as ISynComponent);
			}
		}
		
		public function forceRefresh():void
		{
			var indices:Array = arr_setIndices;
			for (var j:int = indices.length - 1; j >= 0; --j)
			{
				var currValue:String = indices[j] as String;
				if(!(currValue && dct_styleSets[currValue])) {
					indices.removeAt(j)
				}
			}
			indices.sort(sortStyleSets)
			for (var i:uint = 0; i < indices.length; ++i) {
				updateChildren(dct_styleSets[indices[i]])
			}
		}
		
		private function refreshComponent(component:ISynComponent):void
		{
			if(!(component && component.styleDefinition)) {
				return;
			}
			var style:Style = component.styleDefinition
			var currObj:StyleChainData = registerClass(getQualifiedClassName(style))
			var parents:Array = currObj.parents as Array	//array of class
			if(!parents) {
				currObj.parents = parents = style.getInheritanceChain()
			}
			for (var i:uint = 0; i < parents.length; ++i)
			{
				//apply properties of classes from first to last
				var currParent:Class = parents[i] as Class
				if (currParent) {
					applyStyleDefinition(style, registerClass(getQualifiedClassName(currParent)))
				}
			}
			applyStyleDefinition(style, registerClass(getQualifiedClassName(style)))			//style class-level styles
			applyStyleDefinition(component, registerClass(getQualifiedClassName(component)))	//component class-level styles
			applyStyleDefinition(style, dct_styleSets[component] as StyleChainData)				//component instance-level styles
			style.refresh()
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
			var parentA:Array = dct_styleSets[styleAName].parents as Array
			var parentB:Array = dct_styleSets[styleBName].parents as Array
			if (parentA && parentB)
			{
				if(parentA.indexOf(getDefinitionByName(styleBName)) != -1) {
					return -1	//B is a child of A; A should come before B
				}
				else if(parentB.indexOf(getDefinitionByName(styleAName)) != -1) {
					return 1	//A is a child of B; B should come before A
				}
				else if(parentA.length > parentB.length) {
					return 1	//A has more parents than B; B should come before A
				}
				else if(parentB.length > parentA.length) {
					return -1	//B has more parents than A; A should come before B
				}
				return 0
			}
			else if(parentA) {
				return -1
			}
			else if(parentB) {
				return 1
			}
			return 0;
		}
		
		private static function get mainInstance():StyleManager
		{
			if(!cl_styleManager) {
				new StyleManager()
			}
			return cl_styleManager;
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
			mainInstance.unregister(component)
		}
	}

}

import flash.utils.Dictionary;
internal class StyleChainData
{
	public var properties:Dictionary;
	public var children:Dictionary
	public var parents:Array
	public function StyleChainData(properties:Dictionary, children:Dictionary, parents:Array)
	{
		this.properties = properties
		this.children = children
		this.parents = parents
	}
}