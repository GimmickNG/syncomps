package syncomps.events 
{
	import flash.events.Event;
	import syncomps.data.DataElement;
	
	/**
	 * @eventType	syncomps.events.ListCellEvent.CELL_CLICK
	 */
	[Event(name = "CELL_CLICK", type = "syncomps.events.ListCellEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ListCellEvent extends Event 
	{
		public static const CELL_CLICK:String = "CELL_CLICK"
		private var i_index:int;
		private var obj_item:DataElement;
		public function ListCellEvent(type:String, index:int, item:DataElement, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			i_index = index
			obj_item = item;
		} 
		
		public override function clone():Event { 
			return new ListCellEvent(type, i_index, obj_item, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ListCellEvent", "type", "index", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get index():int {
			return i_index;
		}
		
		public function get item():DataElement {
			return obj_item;
		}
		
	}
	
}