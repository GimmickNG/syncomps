package syncomps 
{
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.events.DataProviderEvent;
	import syncomps.events.ListEvent;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.interfaces.IDataProvider;
	import syncomps.interfaces.graphics.ILabel;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.ComboBoxStyle;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.ScrollPaneStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	/**
	 * Dispatched when the menu is toggled or when the selection changes.
	 */
	[Event(name="change", type="flash.events.Event")]
	/**
	 * Dispatched when a cell is clicked.
	 */
	[Event(name = "synLCECellClick", type = "syncomps.events.ListEvent")]
	/**
	 * Dispatched when the dataProvider property is changed.
	 */
	[Event(name = "synDPEDataRefresh", type = "syncomps.events.DataProviderEvent")]
	/**
	 * Dispatched when an item is added to the list.
	 */
	[Event(name = "synDPEItemAdded", type = "syncomps.events.DataProviderEvent")]
	/**
	 * Dispatched when an item is removed from the list.
	 */
	[Event(name = "synDPEItemRemoved", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ComboBox extends SynComponent implements IDataProvider, IAutoResize, ILabel
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32
		
		protected static var DEFAULT_STYLE:Class = ComboBoxStyle
		
		private var cmpi_activeItem:TextInput;
		private var dp_provider:DataProvider;
		private var dp_master:DataProvider;
		private var b_autoComplete:Boolean;
		private var b_autoFilter:Boolean;
		private var i_selectedIndex:int;
		private var b_menuOpen:Boolean;
		private var b_filtering:Boolean;
		private var cmpi_list:List;
		public function ComboBox() 
		{
			init()
		}
		private function init():void
		{
			cmpi_list = new List()
			cmpi_activeItem = new TextInput()
			dataProvider = new DataProvider()
			StyleManager.unregister(cmpi_activeItem)
			
			cmpi_activeItem.addEventListener(Event.CHANGE, stopPropagation)
			cmpi_activeItem.addEventListener(Event.CHANGE, filterDataOnChange, false, 0, true)
			cmpi_activeItem.addEventListener(FocusEvent.FOCUS_OUT, dispatchChangeOnKey, false, 0, true)
			cmpi_activeItem.addEventListener(TextEvent.TEXT_INPUT, autoCompleteText, false, 0, true)
			cmpi_activeItem.addEventListener(KeyboardEvent.KEY_DOWN, dispatchChangeOnKey, false, 0, true)
			cmpi_activeItem.addEventListener(MouseEvent.MOUSE_OVER, propagateMouseEvent, false, 0, true)
			cmpi_activeItem.setStyle(DefaultInnerTextStyle.BORDER, 0x00000000)	//no border color by default
			cmpi_activeItem.setStyle(DefaultStyle.BACKGROUND, 0x00000000)	//no background color when editable
			cmpi_activeItem.setStyle(DefaultStyle.DISABLED, 0x00000000)	//no background color when not editable
			cmpi_activeItem.borderColor = 0x00000000
			cmpi_activeItem.height = 24
			cmpi_activeItem.width = 72
			cmpi_activeItem.x = 4;
			autoComplete = true;
			editable = false;
			
			rowHeight = 24;
			i_selectedIndex = 0
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			cmpi_list.addEventListener(ListEvent.CELL_CLICK, propagateCellClick, false, 0, true);
			
			addEventListener(KeyboardEvent.KEY_UP, changeItem)
			addEventListener(KeyboardEvent.KEY_DOWN, changeState)
			addEventListener(MouseEvent.CLICK, toggleMenu, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.ROLL_OVER, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_IN, changeState, false, 0, true)
			addEventListener(FocusEvent.FOCUS_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, changeState, false, 0, true)
			addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, changeState, false, 0, true)
			cmpi_list.addEventListener(DataProviderEvent.ITEM_ADDED, updateEntries, false, 0, true)
			cmpi_list.addEventListener(DataProviderEvent.ITEM_REMOVED, updateEntries, false, 0, true)
			cmpi_list.addEventListener(DataProviderEvent.DATA_REFRESH, updateEntries, false, 0, true)
			
			addChild(cmpi_activeItem)
		}
		
		private function filterDataOnChange(evt:Event):void 
		{
			if(!(dp_master && autoFilter && editable)) {
				return;
			}
			var prevOpen:Boolean = menuOpen
			var input:TextInput = evt.currentTarget as TextInput
			var enteredText:String = input.value.toLocaleLowerCase()
			b_filtering = enteredText && enteredText.length
			dp_provider.items = dp_master.items.filter(function filter(item:Object, index:int, array:Array):Boolean {
				return item.label.toLocaleLowerCase().indexOf(enteredText) != -1
			})
			input.value = enteredText
			menuOpen = prevOpen
		}
		
		private function stopPropagation(evt:Event):void {
			evt.stopPropagation()
		}
		
		private function dispatchChangeOnKey(evt:Event):void 
		{
			if (evt is FocusEvent && stage && stage.focus) {
				stage.focus = null
			}
			else if ((evt is KeyboardEvent) && (evt as KeyboardEvent).keyCode == Keyboard.ENTER) {
				dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, evt.bubbles, false, ""))
			}
		}
		
		private function autoCompleteText(evt:TextEvent):void 
		{
			if (!(autoComplete && dp_provider)) {
				return;
			}
			var currIndex:int = cmpi_activeItem.caretIndex
			var currValue:String = (cmpi_activeItem.value.slice(0, currIndex) + evt.text).toLocaleLowerCase()
			dp_provider.some(function completeText(item:Object, index:int, array:Array):Boolean
			{
				var currTypeLabel:String = item.label
				var matchText:Boolean = currTypeLabel && currTypeLabel.toLocaleLowerCase().indexOf(currValue) == 0
				if(matchText)
				{
					evt.preventDefault()
					cmpi_activeItem.value = currTypeLabel
					cmpi_activeItem.setSelection(currTypeLabel.length, currIndex + 1)
				}
				return matchText
			});
		}
		
		private function updateEntries(evt:DataProviderEvent):void 
		{
			switch(evt.type)
			{
				case DataProviderEvent.ITEM_ADDED:
					if(selectedIndex < 0 || selectedIndex >= dp_provider.numItems) {
						selectedIndex = 0;
					}
				case DataProviderEvent.ITEM_REMOVED:
					if(evt.index == selectedIndex) {
						selectedIndex = 0;
					}
				break;
				case DataProviderEvent.DATA_REFRESH:
					selectedIndex = -1;
				break;
			}
			if (!b_filtering) {
				dp_master = dp_provider.clone()
			}
			if(menuOpen) {
				drawGraphics(width, height, state)
			}
			dispatchEvent(evt)
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			switch(evt.style)
			{
				//no border or background color for these textfields
				case DefaultStyle.DISABLED:
				case DefaultStyle.BACKGROUND:
				case DefaultInnerTextStyle.BORDER:
					cmpi_activeItem.setStyle(evt.style, 0)
					break;
				default:
					cmpi_activeItem.setStyle(evt.style, evt.value)
					break;
			}
			cmpi_list.setStyle(evt.style, evt.value)
			drawGraphics(width, height, state)
		}
		
		private function propagateCellClick(evt:ListEvent):void 
		{
			if (evt)
			{
				evt.preventDefault()
				if(dispatchEvent(new ListEvent(evt.type, evt.index, evt.item, evt.bubbles, true))) {
					selectedIndex = evt.index
				}
			}
			hideMenu()
		}
		
		private function changeState(evt:Event):void
		{
			switch(evt.type)
			{
				case KeyboardEvent.KEY_DOWN:
					var keyCode:int = (evt as KeyboardEvent).keyCode
					if(keyCode != Keyboard.UP && keyCode != Keyboard.DOWN) {
						return;
					}
				case MouseEvent.MOUSE_DOWN:
					if (!cmpi_activeItem.contains(evt.target as DisplayObject)) {
						drawGraphics(width, height, DefaultStyle.DOWN);
					}
					break;
				case FocusEvent.MOUSE_FOCUS_CHANGE:
					var relatedObject:InteractiveObject = (evt as FocusEvent).relatedObject
					if(!relatedObject || !(contains(relatedObject) || cmpi_list.contains(relatedObject))) {
						menuOpen = false
					}
				case FocusEvent.FOCUS_OUT:
				case MouseEvent.MOUSE_UP:
				case MouseEvent.RELEASE_OUTSIDE:
				case MouseEvent.ROLL_OUT:
					drawGraphics(width, height, DefaultStyle.BACKGROUND);
					break;
				case MouseEvent.ROLL_OVER:
				case FocusEvent.FOCUS_IN:
					drawGraphics(width, height, DefaultStyle.HOVER)
					break;
			}
		}
		
		private function changeItem(evt:KeyboardEvent):void 
		{
			var keyCode:int = evt.keyCode
			var index:int = selectedIndex
			if(!(dp_provider && dp_provider.numItems)) {
				return;
			}
			if (keyCode == Keyboard.DOWN) {
				index ++;
			}
			else if(keyCode == Keyboard.UP) {
				index --;
			}
			else {
				return;
			}
			
			if(selectedIndex != index) {
				drawGraphics(width, height, DefaultStyle.BACKGROUND)	//DOWN or UP pressed
			}
			if(index < 0) {
				index = 0
			}
			else if(index >= dp_provider.numItems) {
				index = dp_provider.numItems - 1
			}
			if (selectedIndex != index)
			{
				selectedIndex = index
				dispatchEvent(new ListEvent(ListEvent.CELL_CLICK, index, dp_provider.getItemAt(index), false, false))
			}
		}
		
		private function propagateMouseEvent(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation()
			dispatchEvent(evt)
		}
		
		public function get editable():Boolean {
			return cmpi_activeItem.enabled
		}
		
		public function set editable(value:Boolean):void {
			cmpi_activeItem.enabled = value
		}
		
		public function get textField():TextField {
			return cmpi_activeItem.textField
		}
		
		private function hideList(evt:MouseEvent):void
		{
			var target:DisplayObject = evt.target as DisplayObject
			if (!target || contains(target) || cmpi_list.contains(target)) { 
				return;
			}
			menuOpen = false
			drawGraphics(width, height, state)
		}
		
		public function set dataProvider(provider:DataProvider):void
		{
			if(provider && provider == dp_provider) {
				return;
			}
			cmpi_list.dataProvider = dp_provider = provider
			if (provider && provider.numItems) {
				label = provider.getItemAt(0).label
			}
		}
		
		public function get dataProvider():DataProvider {
			return dp_provider
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			dataProvider = null
			
			removeEventListener(MouseEvent.CLICK, toggleMenu)
			removeEventListener(MouseEvent.MOUSE_UP, changeState)
			removeEventListener(MouseEvent.ROLL_OUT, changeState)
			removeEventListener(MouseEvent.ROLL_OVER, changeState)
			removeEventListener(FocusEvent.FOCUS_IN, changeState)
			removeEventListener(FocusEvent.FOCUS_OUT, changeState)
			removeEventListener(MouseEvent.MOUSE_DOWN, changeState)
			removeEventListener(KeyboardEvent.KEY_DOWN, changeItem)
			removeEventListener(MouseEvent.RELEASE_OUTSIDE, changeState)
		}		
		
		private function toggleMenu(evt:MouseEvent):void
		{
			if (!(cmpi_activeItem.enabled && cmpi_activeItem.contains(evt.target as DisplayObject))) {
				menuOpen = !menuOpen
			}
		}
		
		public function showMenu():void {
			menuOpen = true;
		}
		
		public function hideMenu():void {
			menuOpen = false;
		}
		
		public function get selectedIndex():int {
			return i_selectedIndex;
		}
		
		private function setSelectedCell(index:int):void {
			cmpi_list.selectedIndex = i_selectedIndex = index;
		}
		
		public function set selectedIndex(index:int):void
		{			
			menuOpen = false
			setSelectedCell(index)
			if (0 <= index && index < dp_provider.numItems)
			{
				var prevLabel:String = label;
				label = dp_provider.getItemAt(index).label
				if (!(selectedIndex == index && label == prevLabel)) {
					dispatchEvent(new Event(Event.CHANGE, false, false))
				}
			}
		}
		
		public function get selectedItem():DataElement
		{
			if(i_selectedIndex >= 0 && i_selectedIndex < dp_provider.numItems) {
				return dp_provider.getItemAt(i_selectedIndex)
			}
			return null;
		}
		
		public function get numItems():uint {
			return dp_provider.numItems
		}
		
		public function addItem(item:Object):void {
			dp_provider.addItem(item)
		}
		
		public function addItems(items:Array):void {
			dp_provider.addItems(items)
		}
		
		public function addItemAt(item:Object, index:int):void {
			dp_provider.addItemAt(item, index)
		}
		
		public function getItemAt(index:int):DataElement {
			return dp_provider.getItemAt(index)
		}
		
		public function removeItem(item:Object):Object {
			return dp_provider.removeItem(item)
		}
		public function removeItemAt(index:int):Object {
			return dp_provider.removeItemAt(index)
		}
		
		public function removeItems():void {
			dp_provider.removeItems()
		}
		
		public function resizeWidth():void 
		{
			var maxStr:String = "";
			var prevPlaceholder:String = cmpi_activeItem.placeHolder
			dp_provider.forEach(function calculateMaxWidth(item:Object, index:int, array:Array):void
			{
				var currStr:String = item.label
				if(currStr.length > maxStr.length) {
					maxStr = currStr
				}
			});
			cmpi_activeItem.placeHolder = maxStr
			cmpi_activeItem.resizeWidth()
			width = cmpi_activeItem.width + 20
			cmpi_activeItem.placeHolder = prevPlaceholder
		}
		
		public function resizeHeight():void 
		{
			cmpi_activeItem.resizeHeight()
			height = cmpi_activeItem.height + 4
		}
		
		/* DELEGATE syncomps.data.DataProvider */
		
		public function getItemBy(searchFunction:Function):DataElement {
			return dp_provider.getItemBy(searchFunction);
		}
		
		public function indexOf(searchFunction:Function, fromIndex:int = 0):int {
			return dp_provider.indexOf(searchFunction, fromIndex);
		}
		
		/* DELEGATE syncomps.List */
		
		public function get cellSize():int {
			return cmpi_list.cellSize;
		}
		
		public function set cellSize(value:int):void {
			cmpi_list.cellSize = value;
		}
		
		public function set items(value:Array):void {
			dp_provider.items = value;
		}
		
		public function get items():Array {
			return dp_provider.items
		}
		
		public function set label(text:String):void {
			cmpi_activeItem.value = text
		}
		
		public function get label():String {
			return cmpi_activeItem.value
		}
		
		public function get rowHeight():int {
			return cmpi_list.cellSize;
		}
		
		public function set rowHeight(value:int):void {
			cmpi_list.cellSize = value;
		}
		
		public function get menuOpen():Boolean {
			return b_menuOpen;
		}
		
		internal function get menu():List {
			return cmpi_list
		}
		
		public function set menuOpen(value:Boolean):void 
		{
			if (b_menuOpen != value)
			{
				b_menuOpen = value;
				drawGraphics(width, height, state)
				dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
		
		public function get autoComplete():Boolean {
			return b_autoComplete;
		}
		
		public function set autoComplete(value:Boolean):void {
			b_autoComplete = value;
		}
		
		public function get autoFilter():Boolean {
			return b_autoFilter;
		}
		
		public function set autoFilter(value:Boolean):void {
			b_autoFilter = value;
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			var bgGraphics:Graphics = graphics
			var color:uint, colorAlpha:Number
			if(enabled) {
				color = uint(getStyle(state))
			}
			else {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			cmpi_activeItem.width = width - (24 + cmpi_activeItem.x)
			if(width < 24) {
				cmpi_activeItem.width = width - cmpi_activeItem.x
			}
			cmpi_activeItem.height = height - 4
			var textHeight:int = cmpi_activeItem.textHeight + 4
			if((cmpi_activeItem.height < textHeight && textHeight <= height) || (cmpi_activeItem.textHeight && cmpi_activeItem.height >= textHeight)) {
				cmpi_activeItem.height = textHeight
			}
			else if(height < cmpi_activeItem.textHeight) {
				cmpi_activeItem.height = height
			}
			cmpi_activeItem.y = (height - (cmpi_activeItem.height)) * 0.5
			if(cmpi_activeItem.y < 0) {
				cmpi_activeItem.y = 0
			}
			bgGraphics.clear();
			bgGraphics.lineStyle(1)
			bgGraphics.beginFill(color, colorAlpha)
			bgGraphics.drawRect(0, 0, width - 1, height - 1)
			bgGraphics.endFill()
			bgGraphics.beginFill(0, 1)
			if (menuOpen)
			{
				bgGraphics.drawTriangles(new <Number>[width - 12, height * 0.45, width - 16, height * 0.55, width - 8, height * 0.55])
				if (stage)
				{
					var stagePt:Point, basePt:Point = new Point()
					var menuWidth:int, menuHeight:int;
					var sideWidth:int;
					cmpi_list.resizeHeight()
					basePt.setTo(0, height - 1)
					stagePt = localToGlobal(basePt)
					sideWidth = stage.stageWidth - stagePt.x
					menuHeight = stage.stageHeight - stagePt.y
					cmpi_list.displayScrollBars(false)
					if (menuHeight < cmpi_list.height && (stagePt.y / menuHeight) > 0.75)
					{
						menuHeight = cmpi_list.height
						if (stagePt.y < menuHeight) {
							menuHeight = stagePt.y
						}
						basePt.setTo(0, 1 - menuHeight)
						stagePt = localToGlobal(basePt)
					}
					cmpi_list.y = stagePt.y
					menuWidth = width - 8
					basePt.setTo(0, 0)
					stagePt = localToGlobal(basePt)
					if(menuWidth > stage.stageWidth - stagePt.x) {
						menuWidth = stage.stageWidth - stagePt.x
					}
					
					if (stagePt.x < 0)
					{
						menuWidth += stagePt.x
						stagePt.x = 0;
					}
					if (stagePt.y < 0)
					{
						menuHeight += stagePt.y
						stagePt.y = 0;
					}
					cmpi_list.x = stagePt.x
					drawMenu(menuWidth, menuHeight)
				}
			}
			else
			{
				bgGraphics.drawTriangles(new <Number>[width - 16, height * 0.45, width - 8, height * 0.45, width - 12, height * 0.55])
				if(cmpi_list.parent) {
					cmpi_list.parent.removeChild(cmpi_list)
				}
			}
			bgGraphics.endFill()
		}
		
		protected function drawMenu(width:int, maxHeight:int):void
		{
			var height:int = maxHeight;
			var reqHeight:int = (cmpi_list.numItems * cmpi_list.cellSize) + 2
			if(reqHeight < maxHeight) {
				height = reqHeight
			}
			cmpi_list.width = width - 1;
			cmpi_list.height = height;
			if (stage) {
				stage.addChild(cmpi_list)
			}
		}
		
		/* PROTECTED GETTERS AND SETTERS */
		
		protected function get activeItem():TextInput {
			return cmpi_activeItem;
		}
		
		protected function set activeItem(value:TextInput):void {
			cmpi_activeItem = value;
		}
		
		protected function get filtering():Boolean {
			return b_filtering;
		}
		
		protected function set filtering(value:Boolean):void {
			b_filtering = value;
		}
		
		protected function get dropDown():List {
			return cmpi_list;
		}
		
		protected function set dropDown(value:List):void {
			cmpi_list = value;
		}
		
		public function get list():List {
			return cmpi_list
		}
	}

}