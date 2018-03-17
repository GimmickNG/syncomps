package syncomps 
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.ui.Keyboard;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.events.DataProviderEvent;
	import syncomps.events.ListCellEvent;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import syncomps.ScrollPane;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IAutoResize;
	import syncomps.interfaces.IDataProvider;
	import syncomps.styles.DefaultListStyle;
	import syncomps.styles.ScrollPaneStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="CELL_CLICK", type="syncomps.events.ListCellEvent")]
	[Event(name="MENU_STATE_CHANGE", type="syncomps.events.ComboBoxEvent")]
	[Event(name="DATA_REFRESH", type="syncomps.events.DataProviderEvent")]
	[Event(name="ITEM_ADDED", type="syncomps.events.DataProviderEvent")]
	[Event(name = "ITEM_REMOVED", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class List extends SynComponent implements IDataProvider, IAutoResize
	{
		protected static var DEFAULT_STYLE:Class = DefaultListStyle
		
		protected var dp_items:DataProvider;
		protected var vec_list:Vector.<ListCell>
		private var fn_iconGenerator:Function;
		private var cl_scrollPane:ScrollPane;
		private var spr_contents:Sprite;
		private var i_selectedIndex:int;
		private var i_cellHeight:int;
		public function List() 
		{
			init()
		}
		
		private function init():void
		{
			tabChildren = false;
			i_selectedIndex = -1
			i_cellHeight = ListCell.DEF_HEIGHT
			vec_list = new Vector.<ListCell>()
			cl_scrollPane = new ScrollPane()
			spr_contents = new Sprite()
			cl_scrollPane.x = cl_scrollPane.y = 1
			cl_scrollPane.source = spr_contents
			cl_scrollPane.lineScrollSize = i_cellHeight
			cl_scrollPane.setStyle(ScrollPaneStyle.SCROLL_POLICY, ScrollPaneStyle.POLICY_VERTICAL)
			cl_scrollPane.displayScrollBars(false)
			
			addChild(cl_scrollPane)
			addEventListener(FocusEvent.FOCUS_IN, selectItem)
			addEventListener(KeyboardEvent.KEY_DOWN, selectItem)
			addEventListener(KeyboardEvent.KEY_UP, passEventToCell)
			
			drawGraphics(64, 64, DefaultStyle.BACKGROUND)
		}
		
		private function updateListOnChange(evt:Event):void 
		{
			for (var i:uint = 0; i < dp_items.length; ++i) {
				setupListCell(vec_list[i], dp_items.getItemAt(i), (i & 1) != 0);
			}
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function passEventToCell(evt:KeyboardEvent):void 
		{
			var index:int = selectedIndex
			if (evt.keyCode == Keyboard.ENTER && evt.target == this && 0 <= index && index < vec_list.length) {
				vec_list[index].dispatchEvent(evt)
			}
		}
		
		private function selectItem(evt:Event):void 
		{
			var kEvt:KeyboardEvent = evt as KeyboardEvent
			var index:int = i_selectedIndex
			if(kEvt)
			{
				if (kEvt.keyCode == Keyboard.DOWN) {
					index++;
				}
				else if(kEvt.keyCode == Keyboard.UP) {
					index--;
				}
			}
			
			if(index < 0) {
				index = 0
			}
			else if(index >= vec_list.length) {
				index = vec_list.length - 1
			}
			
			if(evt is FocusEvent || kEvt.keyCode == Keyboard.DOWN || kEvt.keyCode == Keyboard.UP) {
				setSelectedCell(index)
			}
			else if(kEvt && kEvt.target == this && kEvt.keyCode == Keyboard.ENTER) {
				vec_list[index].dispatchEvent(evt)
			}
		}
		
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		
		public function get numItems():uint {
			return dp_items.length
		}
		public function addItem(item:Object):void {
			addItemAt(item, dp_items.length)
		}
		public function removeItem(item:Object):Object {
			return dp_items.removeItem(item)
		}
		public function removeItemAt(index:int):Object {
			return dp_items.removeItemAt(index)
		}
		public function addItemAt(item:Object, index:int):void {
			dp_items.addItemAt(item, index)
		}
		public function getItemAt(index:int):DataElement {
			return dp_items.getItemAt(index)
		}
		public function addItems(items:Array):void {
			dp_items.addItems(items)
		}
		public function removeAll():void {
			dp_items.removeAll()
		}
		public function get items():Array {
			return dp_items.items
		}
		
		public function get dataProvider():DataProvider {
			return dp_items
		}
		
		public function set dataProvider(provider:DataProvider):void
		{
			if(provider && provider == dp_items) {
				return;
			}
			if (dp_items)
			{
				dp_items.removeEventListener(Event.CHANGE, updateListOnChange)
				dp_items.removeEventListener(DataProviderEvent.ITEM_ADDED, updateListOnEvent)
				dp_items.removeEventListener(DataProviderEvent.ITEM_REMOVED, updateListOnEvent)
				dp_items.removeEventListener(DataProviderEvent.DATA_REFRESH, updateListOnEvent)
			}
			if (provider)
			{
				provider.addEventListener(Event.CHANGE, updateListOnChange, false, 0, true)
				provider.addEventListener(DataProviderEvent.ITEM_REMOVED, updateListOnEvent, false, 0, true)
				provider.addEventListener(DataProviderEvent.DATA_REFRESH, updateListOnEvent, false, 0, true)
				provider.addEventListener(DataProviderEvent.ITEM_ADDED, updateListOnEvent, false, 0, true)
			}
			selectedIndex = -1
			dp_items = provider
			rebuildList(0)
		}
		
		private function updateListOnEvent(evt:DataProviderEvent):void
		{
			const selectedIndex:int = i_selectedIndex
			const index:int = evt.index;
			rebuildList(index)
			switch(evt.type)
			{
				case DataProviderEvent.ITEM_ADDED:
					if (index < i_selectedIndex) {
						setSelectedCell(selectedIndex + 1)
					}
					break;
				case DataProviderEvent.ITEM_REMOVED:
					if (index < selectedIndex) {
						setSelectedCell(selectedIndex - 1)
					}
					else if (index == selectedIndex)
					{
						if (index > 0) {
							setSelectedCell(index - 1)
						}
						else {
							setSelectedCell(0)
						}
					}
					break;
				default:
					break;
			}
			dispatchEvent(evt)
		}
		
		public function get rowHeight():int {
			return i_cellHeight;
		}
		
		public function set rowHeight(value:int):void 
		{
			i_cellHeight = value;
			cl_scrollPane.lineScrollSize = value
		}
		
		public function get selectedIndex():int 
		{
			return i_selectedIndex;
		}
		
		public function set selectedIndex(value:int):void 
		{
			setSelectedCell(value)
		}
		
		public function get iconFunction():Function 
		{
			return fn_iconGenerator;
		}
		
		public function set listDirection(direction:String):void
		{
			setStyle(DefaultListStyle.LIST_DIRECTION, direction)
			drawGraphics(width, height, str_state)
		}
		
		public function get listDirection():String {
			return String(getStyle(DefaultListStyle.LIST_DIRECTION))
		}
		
		public function set iconFunction(value:Function):void {
			fn_iconGenerator = value;
		}
		
		private function rebuildList(start:uint):void
		{
			var listCell:ListCell;
			if (dp_items)
			{
				var currItem:DataElement;
				while (vec_list.length > dp_items.length)
				{
					listCell = vec_list.pop()
					listCell.removeEventListener(MouseEvent.CLICK, dispatchClick)
					spr_contents.removeChild(listCell)
					listCell.unload()
				}
				for (var i:int = start; i < vec_list.length; ++i) {
					setupListCell(vec_list[i], dp_items.getItemAt(i).objectProperty, (i & 1) != 0)
				}
				while (vec_list.length < dp_items.length)
				{
					listCell = createListCell();
					listCell.index = vec_list.length;
					setupListCell(listCell, dp_items.getItemAt(vec_list.length).objectProperty, (vec_list.length & 1) != 0)
					listCell.addEventListener(MouseEvent.CLICK, dispatchClick, false, 0, true)
					vec_list.push(listCell)
					spr_contents.addChild(listCell)
				}
			}
			else while (vec_list.length)
			{
				listCell = vec_list.pop()
				listCell.removeEventListener(MouseEvent.CLICK, dispatchClick)
				spr_contents.removeChild(listCell)
				listCell.unload()
			}
			cl_scrollPane.refreshPane()
			drawGraphics(width, height, str_state)
		}
		
		private function setupListCell(listCell:ListCell, objectProperties:Object, darkenCell:Boolean):void 
		{
			if (darkenCell) {
				listCell.transform.colorTransform = new ColorTransform(.95, .95, .95)	//darken odd rows
			}
			if(objectProperties.hasOwnProperty("label")) {
				listCell.label = objectProperties.label
			}
			if(objectProperties.hasOwnProperty("icon") && objectProperties.icon) {
				listCell.icon = objectProperties.icon
			}
			else if (fn_iconGenerator != null) {
				listCell.icon = fn_iconGenerator.call(listCell, objectProperties)
			}
			else {
				listCell.icon = null
			}
		}
		
		private function createListCell():ListCell {
			return ListCell(new (getStyle(DefaultListStyle.CELL_RENDERER) as Class)())
		}
		
		private function dispatchClick(evt:MouseEvent):void
		{
			var index:int = (evt.currentTarget as ListCell).index
			addEventListener(ListCellEvent.CELL_CLICK, setSelectedCellOnEvent, false, 0, true)
			dispatchEvent(new ListCellEvent(ListCellEvent.CELL_CLICK, index, dp_items.getItemAt(index), false, true))
		}
		
		private function setSelectedCellOnEvent(evt:ListCellEvent):void 
		{
			removeEventListener(ListCellEvent.CELL_CLICK, setSelectedCellOnEvent)
			if (!evt.isDefaultPrevented()) {
				setSelectedCell(evt.index)
			}
		}
		
		private function setSelectedCell(index:uint):void 
		{
			for (var i:uint = 0; i < vec_list.length; ++i) {
				vec_list[i].selected = false;
			}
			if (index < vec_list.length)
			{
				vec_list[index].selected = true;
				var scaledIndex:int = i_cellHeight * index;
				if ((scaledIndex + i_cellHeight) >= int(cl_scrollPane.verticalScrollPosition + height) || scaledIndex < cl_scrollPane.verticalScrollPosition) {
					cl_scrollPane.verticalScrollPosition = scaledIndex
				}
			}
			i_selectedIndex = index;
		}
		
		override public function get height():Number {
			return cl_scrollPane.height + cl_scrollPane.y + 1
		}
		
		override public function get width():Number {
			return cl_scrollPane.width + cl_scrollPane.x + 1
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			super.drawGraphics(width, height, state)
			graphics.clear()
			graphics.lineStyle(1)
			var colour:uint = uint(getStyle(state)), colourAlpha:Number
			if (!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			graphics.beginFill(colour, colourAlpha)
			graphics.drawRect(0, 0, width - 1, height - 1)
			const cellHeight:int = i_cellHeight
			cl_scrollPane.height = height - 2;
			cl_scrollPane.width = width - 2;
			var currX:int
			for (var i:uint = 0; i < vec_list.length; ++i)
			{
				var cell:ListCell = vec_list[i]
				if (listDirection == DefaultListStyle.HORIZONTAL)
				{
					cell.x = currX
					cell.resizeWidth();
					currX += cell.width;
					cell.height = height - 2;
				}
				else if (listDirection == DefaultListStyle.VERTICAL)
				{
					cell.y = i * cellHeight;
					cell.height = cellHeight;
					cell.width = width - 2;
				}
			}
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			dataProvider = null;
			cl_scrollPane.unload()
			spr_contents.removeChildren()
			for (var i:uint = 0; i < vec_list.length; ++i)
			{
				var listCell:ListCell = vec_list[i]
				listCell.removeEventListener(MouseEvent.CLICK, dispatchClick)
				listCell.unload()
			}
			vec_list.length = 0;
			i_selectedIndex = -1;
			i_cellHeight = ListCell.DEF_HEIGHT;
		}
		
		public function resizeWidth():void 
		{
			var maxWidth:int;
			for (var i:uint = 0; i < vec_list.length; ++i)
			{
				var listCell:ListCell = vec_list[i];
				listCell.resizeWidth()
				if(maxWidth < listCell.width) {
					maxWidth = listCell.width
				}
			}
			drawGraphics(maxWidth, height, str_state)
		}
		
		public function resizeHeight():void
		{
			if (listDirection == DefaultListStyle.VERTICAL) {
				drawGraphics(width, vec_list.length * i_cellHeight, str_state)
			}
			else {
				drawGraphics(width, i_cellHeight, str_state)
			}
		}
		
		public function displayScrollBars(forceDisplay:Boolean):void {
			cl_scrollPane.displayScrollBars(forceDisplay);
		}
		
		public function hideScrollBars():void
		{
			cl_scrollPane.hideScrollBars();
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value == cl_scrollPane.enabled) {
				return;	//no change
			}
			for (var i:uint = 0; i < vec_list.length; ++i) {
				vec_list[i].enabled = value;
			}
			super.enabled = cl_scrollPane.enabled = value
		}
	}

}