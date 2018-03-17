package syncomps.events 
{
	import flash.events.Event;
	
	/**
	 * @eventType	syncomps.events.ScrollEvent.SCROLL
	 */
	[Event(name = "SCROLL", type = "syncomps.events.ScrollEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollEvent extends Event 
	{
		public static const SCROLL:String = "SCROLL"
		private var num_delta:Number;
		private var num_scrollPosition:Number;
		private var i_direction:int;
		public function ScrollEvent(type:String, scrollPosition:Number, direction:int, delta:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			num_scrollPosition = scrollPosition
			num_delta = delta
			i_direction = direction;
		} 
		
		public override function clone():Event {
			return new ScrollEvent(type, scrollPosition, direction, delta, bubbles, cancelable);
		} 
		
		public override function toString():String {
			return formatToString("ScrollEvent", "type", "scrollPosition", "direction", "delta", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get scrollPosition():Number {
			return num_scrollPosition;
		}
		
		public function get delta():Number {
			return num_delta;
		}
		
		public function get direction():int {
			return i_direction;
		}
		
	}
	
}