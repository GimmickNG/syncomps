package syncomps.events 
{
	import flash.events.Event;
	
	/**
	 * @eventType	syncomps.events.ButtonEvent.CLICK
	 */
	[Event(name = "synBEButtonClick", type = "syncomps.events.ButtonEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ButtonEvent extends Event 
	{
		public static const CLICK:String = "synBEButtonClick";
		
		public function ButtonEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event {
			return new ButtonEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ButtonEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}