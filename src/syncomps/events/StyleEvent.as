package syncomps.events 
{
	import flash.events.Event;
	
	/**
	 * @eventType	syncomps.events.StyleEvent.STYLE_CHANGE
	 */
	[Event(name = "STYLE_CHANGE", type = "syncomps.events.StyleEvent")]
	
	/**
	 * @eventType	syncomps.events.StyleEvent.STYLE_CHANGING
	 */
	[Event(name = "STYLE_CHANGING", type = "syncomps.events.StyleEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class StyleEvent extends Event 
	{
		public static const STYLE_CHANGE:String = "STYLE_CHANGE"
		static public const STYLE_CHANGING:String = "STYLE_CHANGING";
		private var obj_style:Object;
		private var obj_value:Object;
		public function StyleEvent(type:String, style:Object, value:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			obj_style = style
			obj_value = value
		} 
		
		public override function clone():Event { 
			return new StyleEvent(type, style, value, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("StyleEvent", "type", "style", "value", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get value():Object {
			return obj_value;
		}
		
		public function get style():Object {
			return obj_style;
		}
		
		public function set value(value:Object):void {
			obj_value = value;
		}
		
	}
	
}