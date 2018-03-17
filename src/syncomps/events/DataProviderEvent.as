package syncomps.events 
{
	import flash.events.Event;
	import syncomps.data.DataElement;
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.ITEM_ADDED
	 */
	[Event(name = "ITEM_ADDED", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.ITEM_REMOVED
	 */
	[Event(name = "ITEM_REMOVED", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.DATA_REFRESH
	 */
	[Event(name = "DATA_REFRESH", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DataProviderEvent extends Event 
	{
		public static const ITEM_ADDED:String = "ITEM_ADDED"
		static public const ITEM_REMOVED:String = "ITEM_REMOVED";
		static public const DATA_REFRESH:String = "DATA_REFRESH";
		private var obj_item:DataElement
		private var i_index:int
		public function DataProviderEvent(type:String, item:DataElement, index:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			obj_item = item;
			i_index = index
		} 
		
		public override function clone():Event {
			return new DataProviderEvent(type, item, index, bubbles, cancelable);
		} 
		
		public override function toString():String {
			return formatToString("DataProviderEvent", "type", "item", "index", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get index():int {
			return i_index;
		}
		
		public function get item():DataElement {
			return obj_item;
		}
		
	}
	
}