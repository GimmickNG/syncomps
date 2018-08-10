package syncomps.events 
{
	import flash.events.Event;
	
	/**
	 * @eventType	syncomps.events.ScrollEvent.SCROLL
	 */
	[Event(name = "synScEScroll", type = "syncomps.events.ScrollEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ScrollEvent extends Event 
	{
		public static const SCROLL:String = "synScEScroll";
		
		private var i_direction:int;
		private var num_delta:Number;
		private var num_scrollPosition:Number;
		public function ScrollEvent(type:String, scrollPosition:Number, direction:int, delta:Number = 0, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
			num_delta = delta
			i_direction = direction;
			num_scrollPosition = scrollPosition
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