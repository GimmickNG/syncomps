package syncomps.menu 
{
	import flash.geom.Point;
	import syncomps.List;
	import syncomps.SynComponent;
	import flash.events.EventDispatcher;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import syncomps.data.DataProvider;
	import syncomps.events.DataProviderEvent;
	import syncomps.styles.DefaultListStyle;

	/**
	 * ...
	 * @author Gimmick
	 */
	public class SynMenu extends List
	{
		private var cl_parentMenu:SynMenu
		public function SynMenu()
		{
			super()
			init()
		}
		
		private function init():void 
		{
			dp_items = new DataProvider()
			listDirection = DefaultListStyle.HORIZONTAL
			dp_items.addEventListener(DataProviderEvent.ITEM_ADDED, setupItem, false, 0, true)
			dp_items.addEventListener(DataProviderEvent.ITEM_REMOVED, removeItemOnEvent, false, 0, true)
			dp_items.addEventListener(DataProviderEvent.DATA_REFRESH, refreshItems, false, 0, true)
		}
		
		private function refreshItems(evt:DataProviderEvent):void 
		{
			var currVal:Number = 0
			for (var i:uint = 0; i < dp_items.length; ++i)
			{
				var currItem:SynMenuItem = SynMenuItem(dp_items.getItemAt(i).objectProperty)
				if(!currItem.hasEventListener(MouseEvent.CLICK)) {
					currItem.addEventListener(MouseEvent.CLICK, displayMenuOnClick, false, 0, true)
				}
				if (currItem.submenu)
				{
					currItem.submenu.cl_parentMenu = this
					currItem.submenu.listDirection = DefaultListStyle.VERTICAL
				}
				if (parentMenu)
				{
					currItem.resizeHeight()
					currItem.width = this.width
					currItem.y = currVal
					currVal += currItem.height
				}
				else
				{
					currItem.resizeWidth()
					currItem.height = this.height
					currItem.x = currVal
					currVal += currItem.width
				}
				addChild(currItem)
			}
		}
		
		private function removeItemOnEvent(evt:DataProviderEvent):void 
		{
			var index:int = evt.index
			var item:SynMenuItem = SynMenuItem(evt.item.objectProperty)	//throw error if not proper item
			if (item.submenu)
			{
				item.submenu.cl_parentMenu = null
				item.submenu.listDirection = DefaultListStyle.HORIZONTAL
			}
			if (item.parent) {
				removeChild(item)
			}
			for (var i:uint = index; i < dp_items.length; ++i)
			{
				if (parentMenu) {	//vertical list
					dp_items.getItemAt(i).y -= item.height
				}
				else {
					dp_items.getItemAt(i).x -= item.width
				}
			}
			item.removeEventListener(MouseEvent.CLICK, displayMenuOnClick)
		}
		
		private function setupItem(evt:DataProviderEvent):void 
		{
			var item:SynMenuItem = SynMenuItem(evt.item.objectProperty)	//throw error if not proper item
			if (item.submenu)
			{
				item.submenu.cl_parentMenu = this
				item.submenu.listDirection = DefaultListStyle.VERTICAL
			}
			var index:int = evt.index
			if (parentMenu)
			{
				item.width = this.width
				item.resizeHeight()
				if(index) {
					item.y = dp_items.getItemAt(index - 1).y + dp_items.getItemAt(index - 1).height
				}
				else {
					item.y = 0
				}
			}
			else
			{
				item.height = this.height
				item.resizeWidth()
				if (index) {
					item.x = dp_items.getItemAt(index - 1).x + dp_items.getItemAt(index - 1).width
				}
				else {
					item.x = 0;
				}
			}
			for (var i:uint = index; i < dp_items.length; ++i)
			{
				if (parentMenu) {	//vertical list
					dp_items.getItemAt(i).y += item.height
				}
				else {
					dp_items.getItemAt(i).x += item.width
				}
			}
			addChild(item)
			item.addEventListener(MouseEvent.CLICK, displayMenuOnClick, false, 0, true)
		}
		
		private function displayMenuOnClick(evt:MouseEvent):void 
		{
			var item:SynMenuItem = evt.currentTarget as SynMenuItem
			if (item.submenu)
			{
				item.submenu.resizeWidth()
				item.submenu.resizeHeight()
				var globalPoint:Point;
				var localPoint:Point = new Point(item.x + item.width, item.y)
				if(!parentMenu) {	//is root menu
					localPoint.setTo(item.x, item.y + item.height)
				}
				globalPoint = localToGlobal(localPoint)
				displayMenu(item.submenu, globalPoint.x, globalPoint.y)
			}
		}
		
		private function displayMenu(submenu:SynMenu, x:Number, y:Number):void 
		{
			submenu.x = x
			submenu.y = y
			stage.addChild(submenu)
		}
		
		public function set items(itemArray:Array):void
		{
			dp_items.removeAll()
			dp_items.addItems(itemArray.filter(isMenuItem))
		}
		
		private function isMenuItem(item:Object):Boolean {
			return item is SynMenuItem
		}
		
		public function get parentMenu():SynMenu {
			return cl_parentMenu
		}
		
		//implicit override of addItem
		override public function addItemAt(item:Object, index:int):void {
			dp_items.addItemAt(SynMenuItem(item), index)	//use safe cast to throw error on wrong type
		}
		
		public function addSubmenu(submenu:SynMenu, label:String):SynMenuItem
		{
			var submenuEntry:SynMenuItem = new SynMenuItem(label, false);
			submenuEntry.submenu = submenu
			addItem(submenuEntry)
			return submenuEntry
		}
		
		public function addSubmenuAt(submenu:SynMenu, index:int, label:String):SynMenuItem
		{
			var submenuEntry:SynMenuItem = new SynMenuItem(label, false);
			submenuEntry.submenu = submenu
			addItemAt(submenuEntry, index)
			return submenuEntry
		}
		
		public function containsItem(item:SynMenuItem):Boolean {
			return dp_items.getItemByField("objectProperty", item) != null
		}
		
		public function display(stage:Stage, stageX:Number, stageY:Number):void
		{
			this.x = stageX
			this.y = stageY
			stage.addChild(this)
		}
		
		public function getItemByName(name:String):SynMenuItem {
			return dp_items.getItemByField("name", name).objectProperty as SynMenuItem
		}
		public function getItemIndex(item:SynMenuItem):int {
			return dp_items.indexOfByField("objectProperty", item)
		}
		
		public function removeAllItems():void {
			removeAll()
		}
		
		public function setItemIndex(item:SynMenuItem, index:int):void {
			dp_items.addItemAt(dp_items.removeItem(item), index)
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			super.drawGraphics(width, height, state);
			if (dp_items) {
				refreshItems(null)
			}
		}
	}

}