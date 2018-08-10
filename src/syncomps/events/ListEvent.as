package syncomps.events 
{
	import flash.events.Event;
	import syncomps.data.DataElement;
	
	/**
	 * @eventType	syncomps.events.ListEvent.CELL_CLICK
	 */
	[Event(name = "synLCECellClick", type = "syncomps.events.ListEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ListEvent extends Event 
	{
		public static const CELL_CLICK:String = "synLCECellClick";
		
		private var i_index:int;
		private var obj_item:DataElement;
		public function ListEvent(type:String, index:int, item:DataElement, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
			i_index = index
			obj_item = item;
		} 
		
		public override function clone():Event { 
			return new ListEvent(type, i_index, obj_item, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ListEvent", "type", "index", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get index():int {
			return i_index;
		}
		
		public function get item():DataElement {
			return obj_item;
		}
		
	}
	
}