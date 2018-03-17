package syncomps.data 
{
	import syncomps.events.DataProviderEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import syncomps.interfaces.IDataProvider;
	import flash.utils.getQualifiedSuperclassName;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DataProvider extends EventDispatcher implements IDataProvider
	{
		private var arr_data:Array;
		public function DataProvider() 
		{
			init()
		}
		private function init():void
		{
			arr_data = new Array()
		}
		public function get length():uint {
			return arr_data.length
		}
		public function get numItems():uint {
			return length
		}
		public function removeAll():void
		{
			arr_data.length = 0;
			dispatchEvent(new DataProviderEvent(DataProviderEvent.DATA_REFRESH, null, 0, false, false))
		}
		
		public function addItems(items:Array):void
		{
			for (var i:uint = 0; i < items.length; ++i) {
				addItem(items[i])
			}
		}
		public function addItem(item:Object):void {
			addItemAt(item, length)
		}
		public function getItemByField(field:String, value:Object):DataElement
		{
			var index:int = indexOfByField(field, value)
			if(index != -1) {
				return getItemAt(index)
			}
			return null;
		}
		public function indexOfByField(field:String, value:Object):int
		{
			if(!(field && value)) {
				return -1
			}
			for (var i:uint = 0; i < arr_data.length; ++i)
			{
				var item:Object = arr_data[i];
				if(item[field] == value) {
					return i
				}
			}
			return -1;
		}
		public function get dataProvider():DataProvider {
			return this;
		}
		public function getItemAt(index:int):DataElement {
			return arr_data[index]
		}
		public function addItemAt(item:Object, index:int):void
		{
			var itemToAdd:Object = item;
			if (!(item is DataElement))
			{
				itemToAdd = new DataElement(item);
				itemToAdd.setDispatcher(this);
			}
			arr_data.insertAt(index, itemToAdd)
			dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_ADDED, itemToAdd as DataElement, index, false, false))
		}
		
		public function removeItem(item:Object):Object {
			return removeItemAt(findItem(item))
		}
		
		private function findItem(item:Object):int
		{
			if (item is DataElement) {
				return arr_data.indexOf(item)
			}
			return indexOfByField("objectProperty", item)
		}
		public function removeItemAt(index:int):Object 
		{
			if (index >= 0 && index < arr_data.length)
			{
				var item:DataElement = arr_data.removeAt(index);
				var removedItem:Object = item.objectProperty
				item.setDispatcher(null)
				dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_REMOVED, item, index, false, false))
				return removedItem
			}
			return null
		}
		
		public function forceRefresh():void {
			dispatchEvent(new DataProviderEvent(DataProviderEvent.DATA_REFRESH, null, 0, false, false))
		}
		
		public function sort(...rest):void
		{
			arr_data.sort.apply(null, rest);
			forceRefresh()
		}
		
		public function sortOn(names:*, options:*= 0, ...rest):void
		{
			arr_data.sortOn.apply(null, [names, options, rest])
			forceRefresh()
		}
		
		public function get items():Array
		{
			var itemList:Array = new Array()
			for (var i:uint = 0; i < arr_data.length; ++i) {
				itemList.push((arr_data[i] as DataElement).objectProperty)
			}
			return itemList
		}
	}

}