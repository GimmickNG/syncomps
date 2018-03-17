package syncomps.events 
{
	import flash.events.Event;
	
	/**
	 * @eventType	syncomps.events.ComboBoxEvent.MENU_STATE_CHANGE
	 */
	[Event(name="MENU_STATE_CHANGE", type="syncomps.events.ComboBoxEvent")]
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ComboBoxEvent extends Event 
	{
		public static const MENU_STATE_CHANGE:String = "MENU_STATE_CHANGE"
		private var b_menuState:Boolean;
		public function ComboBoxEvent(type:String, menuOpen:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			b_menuState = menuOpen
		} 
		
		public override function clone():Event { 
			return new ComboBoxEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ComboBoxEvent", "type", "menuOpen", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get menuOpen():Boolean {
			return b_menuState;
		}
		
	}
	
}