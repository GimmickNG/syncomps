package syncomps.interfaces 
{
	import flash.events.IEventDispatcher;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IDataProvider extends IEventDispatcher
	{
		function addItem(item:Object):void
		function addItems(items:Array):void
		function addItemAt(item:Object, index:int):void
		
		function removeItems():void
		function removeItem(item:Object):Object
		function removeItemAt(index:int):Object 
		
		function getItemAt(index:int):DataElement
		function indexOf(searchFunction:Function, fromIndex:int = 0):int
		function getItemBy(predicate:Function):DataElement
		
		function get items():Array
		function set items(items:Array):void
		
		function get numItems():uint
	}
	
}