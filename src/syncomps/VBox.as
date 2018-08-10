package syncomps 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.events.DataProviderEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.ScrollPaneStyle;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class VBox extends SynComponent 
	{
		protected static var DEFAULT_STYLE:Class = DefaultStyle
		
		private var dp_items:DataProvider
		
		private var cl_scrollPane:ScrollPane;
		private var spr_contents:Sprite;
		private var num_spacing:Number;
		private var num_xPadding:Number;
		private var num_yPadding:Number;
		public function VBox() {
			init()
		}
		
		private function init():void
		{
			tabChildren = false;
			spr_contents = new Sprite()
			cl_scrollPane = new ScrollPane()
			dataProvider = new DataProvider()
			cl_scrollPane.source = spr_contents
			cl_scrollPane.x = cl_scrollPane.y = 1
			num_spacing = num_xPadding = num_yPadding = 0
			
			cl_scrollPane.setStyle(ScrollPaneStyle.SCROLL_POLICY, ScrollPaneStyle.POLICY_VERTICAL)
			cl_scrollPane.displayScrollBars(false)
			
			addChild(cl_scrollPane)
			drawGraphics(64, 64, DefaultStyle.BACKGROUND)
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
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
				dp_items.removeEventListener(DataProviderEvent.ITEM_ADDED, updateListOnEvent)
				dp_items.removeEventListener(DataProviderEvent.ITEM_REMOVED, updateListOnEvent)
				dp_items.removeEventListener(DataProviderEvent.DATA_REFRESH, updateListOnEvent)
			}
			dp_items = provider
			if (provider)
			{
				provider.addEventListener(DataProviderEvent.ITEM_REMOVED, updateListOnEvent, false, 0, true)
				provider.addEventListener(DataProviderEvent.DATA_REFRESH, updateListOnEvent, false, 0, true)
				provider.addEventListener(DataProviderEvent.ITEM_ADDED, updateListOnEvent, false, 0, true)
			}
			rebuildList(0)
		}
		
		private function updateListOnEvent(evt:DataProviderEvent):void
		{
			rebuildList(evt.index)
			dispatchEvent(evt)
		}
		
		private function rebuildList(start:uint):void
		{
			if (dp_items)
			{
				spr_contents.removeChildren(dp_items.numItems)
				dp_items.forEach(function addChildren(item:DisplayObject, index:int, array:Array):void {
					spr_contents.addChild(item)
				});
			}
			cl_scrollPane.refreshPane()
			drawGraphics(width, height, state)
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
			cl_scrollPane.height = height - 2;
			cl_scrollPane.width = width - 2;
			var currY:Number = num_yPadding
			const xSpace:Number = num_xPadding * 2
			dp_items.forEach(function alignItems(item:DisplayObject, index:int, array:Array):void
			{
				item.width = width - xSpace
				item.x = num_xPadding
				item.y = currY
				
				currY += item.height + num_spacing
			}, this);
		}
		
		public function resizeWidth():void 
		{
			var maxWidth:int;
			dp_items.forEach(function resizeAll(item:DisplayObject, index:int, array:Array):void
			{
				if(item is IAutoResize) {
					(item as IAutoResize).resizeWidth();
				}
				
				if(item.width > maxWidth) {
					maxWidth = item.width
				}
			}, this);
			
			drawGraphics(maxWidth, height, state)
		}
		
		public function resizeHeight():void
		{
			var totalHeight:int
			const spacing:Number = num_spacing;
			dp_items.forEach(function resizeAll(item:DisplayObject, index:int, array:Array):void
			{
				if(item is IAutoResize) {
					(item as IAutoResize).resizeHeight()
				}
				
				totalHeight += item.height + spacing;
			}, this);
			drawGraphics(width, totalHeight, state)
		}
		
		override public function unload():void
		{
			super.unload()
			removeChildren()
			dataProvider = null;
			cl_scrollPane.unload()
			spr_contents.removeChildren()
		}
		
		public function displayScrollBars(forceDisplay:Boolean):void {
			cl_scrollPane.displayScrollBars(forceDisplay);
		}
		
		public function hideScrollBars():void {
			cl_scrollPane.hideScrollBars();
		}
		
		public function addItem(item:Object):void {
			dp_items.addItem(DisplayObject(item));
		}
		
		public function addItemAt(item:Object, index:int):void {
			dp_items.addItemAt(DisplayObject(item), index);
		}
		
		public function addItems(items:Array):void
		{
			dp_items.addItems(items.filter(function isDisplayObject(item:Object, index:int, array:Array):Boolean {
				return item is DisplayObject
			}));
		}
		
		public function getItemAt(index:int):DataElement {
			return dp_items.getItemAt(index);
		}
		
		public function getItemBy(predicate:Function):DataElement {
			return dp_items.getItemBy(predicate);
		}
		
		public function indexOf(searchFunction:Function):int {
			return dp_items.indexOf(searchFunction);
		}
		
		public function get items():Array {
			return dp_items.items;
		}
		
		public function set items(value:Array):void
		{
			dp_items.items = value && value.filter(function isDisplayObject(item:Object, index:int, array:Array):Boolean {
				return item is DisplayObject
			});
		}
		
		public function get numItems():uint {
			return dp_items.numItems;
		}
		
		public function removeItem(item:Object):Object {
			return dp_items.removeItem(DisplayObject(item));
		}
		
		public function removeItemAt(index:int):Object {
			return dp_items.removeItemAt(index);
		}
		
		public function removeItems():void {
			dp_items.removeItems();
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value != cl_scrollPane.enabled) {
				super.enabled = cl_scrollPane.enabled = value
			}
		}
		
		public function get spacing():Number {
			return num_spacing;
		}
		
		public function set spacing(value:Number):void
		{
			if (spacing != value)
			{
				num_spacing = value;
				drawGraphics(width, height, state)
			}
		}
		
		public function get xPadding():Number {
			return num_xPadding;
		}
		
		public function set xPadding(value:Number):void 
		{
			if (xPadding != value)
			{
				num_xPadding = value;
				drawGraphics(width, height, state)
			}
		}
		
		public function get yPadding():Number {
			return num_yPadding;
		}
		
		public function set yPadding(value:Number):void 
		{
			if (yPadding != value)
			{
				num_yPadding = value;
				drawGraphics(width, height, state)
			}
		}
	}

}