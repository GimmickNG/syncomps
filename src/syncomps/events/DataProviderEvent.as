package syncomps.events 
{
	import flash.events.Event;
	import syncomps.data.DataElement;
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.ITEM_ADDED
	 */
	[Event(name = "synDPEItemAdded", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.ITEM_REMOVED
	 */
	[Event(name = "synDPEItemRemoved", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * @eventType	syncomps.events.DatProviderEvent.DATA_REFRESH
	 */
	[Event(name = "synDPEDataRefresh", type = "syncomps.events.DataProviderEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DataProviderEvent extends Event 
	{
		public static const ITEM_ADDED:String = "synDPEItemAdded"
		static public const ITEM_REMOVED:String = "synDPEItemRemoved";
		static public const DATA_REFRESH:String = "synDPEDataRefresh";
		
		private var i_index:int
		private var obj_item:DataElement
		public function DataProviderEvent(type:String, item:DataElement, index:int, bubbles:Boolean = false, cancelable:Boolean = false)
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