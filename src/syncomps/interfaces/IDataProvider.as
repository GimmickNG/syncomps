package syncomps.interfaces 
{
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IDataProvider 
	{
		function addItem(item:Object):void;
		function addItemAt(item:Object, index:int):void;
		function removeItem(item:Object):Object;
		function removeItemAt(index:int):Object;
		function getItemAt(index:int):DataElement;
		function removeAll():void;
		function get items():Array;
		function get numItems():uint;
		function get dataProvider():DataProvider
	}
	
}