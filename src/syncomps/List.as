package syncomps 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.events.DataProviderEvent;
	import syncomps.events.ListEvent;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import syncomps.ScrollPane;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.IStyleInternal;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.interfaces.IDataProvider;
	import syncomps.interfaces.graphics.IIcon;
	import syncomps.interfaces.graphics.ILabel;
	import syncomps.interfaces.ISynComponent;
	import syncomps.styles.DefaultListStyle;
	import syncomps.styles.ScrollPaneStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	
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
	public class List extends SynComponent implements IDataProvider, IAutoResize
	{
		protected static var DEFAULT_STYLE:Class = DefaultListStyle
		
		private var dp_items:DataProvider
		private var vec_list:Vector.<DisplayObject>
		
		private var fn_iconGenerator:Function;
		private var cl_scrollPane:ScrollPane;
		private var spr_contents:Sprite;
		private var i_selectedIndex:int;
		private var i_cellSize:int;
		private var i_columnWidth:int;
		private var i_maxColumnsOrRows:int;
		private var i_maxCellPerpendicularSize:int
		private var cl_childStyleDefinition:IStyleInternal
		public function List() {
			init()
		}
		
		private function init():void
		{
			tabChildren = false;
			i_selectedIndex = -1
			i_cellSize = ListCell.DEF_HEIGHT
			vec_list = new Vector.<DisplayObject>()
			cl_childStyleDefinition = new GenericStyle()
			cl_scrollPane = new ScrollPane()
			spr_contents = new Sprite()
			cl_scrollPane.x = cl_scrollPane.y = 1
			cl_scrollPane.source = spr_contents
			cl_scrollPane.lineScrollSize = i_cellSize
			cl_scrollPane.setStyle(ScrollPaneStyle.SCROLL_POLICY, ScrollPaneStyle.POLICY_VERTICAL)
			cl_scrollPane.displayScrollBars(false)
			
			addChild(cl_scrollPane)
			addEventListener(FocusEvent.FOCUS_IN, selectItem)
			addEventListener(KeyboardEvent.KEY_DOWN, selectItem)
			addEventListener(KeyboardEvent.KEY_UP, passEventToCell)
			cl_childStyleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateCellStyles)
			
			maxColumnsOrRows = 1
			drawGraphics(64, 64, DefaultStyle.BACKGROUND)
		}
		
		private function updateCellStyles(evt:StyleEvent):void 
		{
			vec_list.forEach(function updateStyles(item:DisplayObject, index:int, array:Vector.<DisplayObject>):void {
				(item is ISynComponent) && (item as ISynComponent).setStyle(evt.style, evt.value)
			})
		}
		
		private function updateListOnChange(evt:Event):void 
		{
			dp_items.forEach(function setupCells(item:Object, index:int, array:Array):void {
				setupListCell(vec_list[index], item, darken(index));
			});
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
			}
			dispatchEvent(evt)
		}
		
		public function get maxCellPerpendicularSize():int {
			return i_maxCellPerpendicularSize
		}
		
		public function set maxCellPerpendicularSize(value:int):void
		{
			if (value != i_maxCellPerpendicularSize)
			{
				i_maxCellPerpendicularSize = value
				drawGraphics(width, height, state)
			}
		}
		
		public function get cellSize():int {
			return i_cellSize;
		}
		
		public function set cellSize(value:int):void 
		{
			i_cellSize = value;
			cl_scrollPane.lineScrollSize = value
			drawGraphics(width, height, state)
		}
		
		public function get selectedIndex():int {
			return i_selectedIndex;
		}
		
		public function set selectedIndex(value:int):void {
			setSelectedCell(value)
		}
		
		public function get iconFunction():Function {
			return fn_iconGenerator;
		}
		
		public function set listDirection(direction:String):void
		{
			setStyle(DefaultListStyle.LIST_DIRECTION, direction)
			drawGraphics(width, height, state)
		}
		
		public function get listDirection():String {
			return String(getStyle(DefaultListStyle.LIST_DIRECTION))
		}
		
		public function set maxColumnsOrRows(max:int):void
		{
			if(max < 1) {
				max = 1
			}
			if (max != i_maxColumnsOrRows)
			{
				i_maxColumnsOrRows = max
				rebuildList(0)
			}
		}
		
		public function get maxColumnsOrRows():int {
			return i_maxColumnsOrRows
		}
		
		public function set iconFunction(value:Function):void {
			fn_iconGenerator = value;
		}
		
		private function rebuildList(start:uint):void
		{
			var listCell:DisplayObject
			if (dp_items)
			{
				var currItem:DataElement;
				while (vec_list.length > dp_items.numItems) {
					unloadCell(vec_list.pop())
				}
				for (var i:int = start; i < vec_list.length; ++i) {
					setupListCell(vec_list[i], dp_items.getItemAt(i).objectProperty, darken(i))
				}
				while (vec_list.length < dp_items.numItems)
				{
					var object:Object = dp_items.getItemAt(vec_list.length).objectProperty
					listCell = createListCell();
					setupListCell(listCell, object, darken(vec_list.length))
					listCell.addEventListener(MouseEvent.CLICK, dispatchClick, false, 0, true)
					vec_list.push(listCell)
					spr_contents.addChild(listCell)
				}
			}
			else while (vec_list.length) {
				unloadCell(vec_list.pop())
			}
			cl_scrollPane.refreshPane()
			drawGraphics(width, height, state)
		}
		
		private function setupListCell(listCell:DisplayObject, objectProperties:Object, darkenCell:Boolean):void 
		{
			if (darkenCell) {
				listCell.transform.colorTransform = new ColorTransform(.95, .95, .95)	//darken odd rows
			}
			else {
				listCell.transform.colorTransform = new ColorTransform()
			}
			
			if(objectProperties.hasOwnProperty("label") && listCell is ILabel) {
				(listCell as ILabel).label = objectProperties.label
			}
			
			var iconCell:IIcon = listCell as IIcon
			if (iconCell)
			{
				if(objectProperties.hasOwnProperty("icon")) {
					iconCell.icon = objectProperties.icon
				}
				else {
					iconCell.icon = (fn_iconGenerator && fn_iconGenerator.call(listCell, objectProperties)) as DisplayObject
				}
			}
			
			var styledCell:IStyleDefinition = listCell as IStyleDefinition
			if (styledCell) {
				styledCell.applyStyle(cl_childStyleDefinition)
			}
		}
		
		private function createListCell():DisplayObject {
			return (new (getStyle(DefaultListStyle.CELL_RENDERER) as Class)()) as DisplayObject
		}
		
		private function dispatchClick(evt:MouseEvent):void
		{
			var index:int = vec_list.indexOf(evt.currentTarget as DisplayObject)
			if(dispatchEvent(new ListEvent(ListEvent.CELL_CLICK, index, dp_items.getItemAt(index), false, true))) {
				setSelectedCell(index)
			}
		}
		
		private function setSelectedCell(index:uint):void 
		{
			if (index < vec_list.length)
			{
				var scaledIndex:int = i_cellSize * index;
				if ((scaledIndex + i_cellSize) >= int(cl_scrollPane.verticalScrollPosition + height) || scaledIndex < cl_scrollPane.verticalScrollPosition) {
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
			var color:uint = uint(getStyle(state)), colorAlpha:Number
			if (!enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			graphics.lineStyle(1, 0, colorAlpha)
			graphics.beginFill(color, colorAlpha)
			graphics.drawRect(0, 0, width - 1, height - 1)
			const cellSize:int = i_cellSize
			cl_scrollPane.height = height - 2;
			cl_scrollPane.width = width - 2;
			var i:uint, currPos:int, max:Number = 0;
			var barWidth:int = width, barHeight:int = height
			if(cl_scrollPane.verticalScrollBar.parent) {
				barWidth -= cl_scrollPane.verticalScrollBar.width
			}
			if(cl_scrollPane.horizontalScrollBar.parent) {
				barHeight -= cl_scrollPane.horizontalScrollBar.height
			}
			while(i < vec_list.length)
			{
				for (var j:uint = 0; i < vec_list.length && j < maxColumnsOrRows; ++j, ++i)
				{
					var cell:DisplayObject = vec_list[i]
					if (listDirection == DefaultListStyle.HORIZONTAL)
					{
						cell.height = (barHeight / maxColumnsOrRows) - 2;
						if(maxCellPerpendicularSize > 0 && cell.height > maxCellPerpendicularSize) {
							cell.height = maxCellPerpendicularSize
						}
						cell.y = cell.height * j;
						cell.x = currPos
						cell.width = cellSize
						if(cell.width > max) {
							max = cell.width
						}
					}
					else if (listDirection == DefaultListStyle.VERTICAL)
					{
						cell.width = (barWidth / maxColumnsOrRows) - 2;
						if(maxCellPerpendicularSize > 0 && cell.width > maxCellPerpendicularSize) {
							cell.width = maxCellPerpendicularSize
						}
						cell.x = j * cell.width;
						cell.y = currPos
						cell.height = cellSize;
						if(cell.height > max) {
							max = cell.height
						}
					}
				}
				currPos += max
			}
		}
		
		public function resizeWidth():void 
		{
			var maxWidth:int;
			vec_list.forEach(function resizeItems(item:DisplayObject, index:int, array:Vector.<DisplayObject>):void
			{
				if(item is IAutoResize) {
					(item as IAutoResize).resizeWidth();
				}
				
				if(maxWidth < item.width) {
					maxWidth = item.width
				}
			});
			if (listDirection == DefaultListStyle.VERTICAL) {
				drawGraphics(maxWidth * maxColumnsOrRows, height, state)
			}
			else
			{
				var columnCount:int = Math.ceil(vec_list.length / maxColumnsOrRows)
				drawGraphics(maxWidth * columnCount, height, state)
			}
		}
		
		public function resizeHeight():void
		{
			if (listDirection == DefaultListStyle.VERTICAL) {
				drawGraphics(width, vec_list.length * cellSize / maxColumnsOrRows, state)
			}
			else {
				drawGraphics(width, maxCellPerpendicularSize * maxColumnsOrRows, state)
			}
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			dataProvider = null;
			cl_scrollPane.unload()
			spr_contents.removeChildren()
			vec_list.forEach(function unloadItems(item:DisplayObject, index:int, array:Vector.<DisplayObject>):void {
				unloadCell(item)
			});
			vec_list.length = 0;
			i_selectedIndex = -1;
			i_cellSize = ListCell.DEF_HEIGHT;
		}
		
		private function unloadCell(listCell:DisplayObject):void
		{
			listCell.removeEventListener(MouseEvent.CLICK, dispatchClick)
			if (listCell.parent == spr_contents) {
				spr_contents.removeChild(listCell)
			}
			if (listCell is ISynComponent) {
				(listCell as ISynComponent).unload()
			}
		}
		public function calculateCellSize():int
		{
			const maxFit:Number = Math.ceil(vec_list.length / maxColumnsOrRows)
			if (listDirection == DefaultListStyle.HORIZONTAL) {
				return width / maxFit
			}
			return height / maxFit
		}
		
		public function displayScrollBars(forceDisplay:Boolean):void {
			cl_scrollPane.displayScrollBars(forceDisplay);
		}
		
		public function hideScrollBars():void {
			cl_scrollPane.hideScrollBars();
		}
		
		public function setCellStyle(style:Object, value:Object):void {
			cl_childStyleDefinition.setStyle(style, value);
		}
		
		public function getCellStyle(style:Object):Object {
			return cl_childStyleDefinition.getStyle(style);
		}
		
		/* DELEGATE syncomps.interfaces.IDataProvider */
		
		public function addItem(item:Object):void {
			dp_items.addItem(item);
		}
		
		public function addItemAt(item:Object, index:int):void {
			dp_items.addItemAt(item, index);
		}
		
		public function addItems(items:Array):void {
			dp_items.addItems(items);
		}
		
		public function getItemAt(index:int):DataElement {
			return dp_items.getItemAt(index);
		}
		
		public function getItemBy(predicate:Function):DataElement {
			return dp_items.getItemBy(predicate);
		}
		
		public function indexOf(searchFunction:Function, fromIndex:int = 0):int {
			return dp_items.indexOf(searchFunction, fromIndex);
		}
		
		public function get items():Array {
			return dp_items.items;
		}
		
		public function set items(value:Array):void {
			dp_items.items = value;
		}
		
		public function get numItems():uint {
			return dp_items.numItems;
		}
		
		public function removeItem(item:Object):Object {
			return dp_items.removeItem(item);
		}
		
		public function removeItemAt(index:int):Object {
			return dp_items.removeItemAt(index);
		}
		
		public function removeItems():void {
			dp_items.removeItems();
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value == cl_scrollPane.enabled) {
				return;	//no change
			}
			super.enabled = cl_scrollPane.enabled = value
		}
		
		private function darken(index:int):Boolean {
			return index % ((maxColumnsOrRows * 2)) >= maxColumnsOrRows
		}
	}

}

import syncomps.styles.*;
import syncomps.events.StyleEvent;

/**
 * Generic style class that accepts all attributes.
 */
class GenericStyle extends Style
{
	public function GenericStyle() {
		super()
	}
	
	override public function setStyle(style:Object, value:Object):void 
	{
		if(dispatchEvent(new StyleEvent(StyleEvent.STYLE_CHANGING, style, value, true, true))) {
			forceStyle(style, value)
		}
	}
}