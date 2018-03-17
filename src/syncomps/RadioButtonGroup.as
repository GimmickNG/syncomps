package syncomps 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import syncomps.RadioButton;
	
	[Event(name="change", type="flash.events.Event")]
	/**
	 * ...
	 * @author Gimmick
	 */
	public class RadioButtonGroup extends EventDispatcher
	{
		private var i_numItems:int;
		private var dct_buttons:Dictionary;
		private var rd_selected:RadioButton;
		private var rd_lastSelected:RadioButton;
		public function RadioButtonGroup() {
			init()
		}
		private function init():void {
			dct_buttons = new Dictionary(true)
		}
		
		public function get selectedButton():RadioButton {
			return rd_selected;
		}
		
		public function get selectedData():Object {
			return selectedButton.data
		}
		
		public function get numItems():uint {
			return i_numItems;
		}
		
		public function unloadAll():void
		{
			rd_selected = rd_lastSelected = null;
			for (var button:Object in dct_buttons)
			{
				(button as RadioButton).unload();
				delete dct_buttons[button];
			}
		}
		
		public function selectButton(radioButton:RadioButton):void
		{
			rd_lastSelected = rd_selected
			rd_selected = radioButton;
			for (var button:Object in dct_buttons)
			{
				if(button != radioButton) {
					(button as RadioButton).selected = false
				}
			}
			radioButton.selected = true;
		}
		
		/**
		 * Deselects all radio buttons in the group, for when an indeterminate state is to be represented.
		 */
		public function deselectAll():void
		{
			rd_selected = rd_lastSelected = null;
			for (var button:Object in dct_buttons) {
				(button as RadioButton).selected = false
			}
		}
		
		internal function deselectButton(radioButton:RadioButton):void
		{
			if (radioButton == rd_selected) {
				selectButton(rd_lastSelected)
			}
		}
		
		internal function unregister(radioButton:RadioButton):void 
		{
			radioButton.removeEventListener(Event.CHANGE, selectButtonOnEvent)
			if(rd_selected == radioButton) {
				selectButton(rd_lastSelected)
			}
			if(radioButton && dct_buttons[radioButton]) {
				delete dct_buttons[radioButton]
			}
		}
		
		internal function register(radioButton:RadioButton):void
		{
			dct_buttons[radioButton] = this
			if(!rd_lastSelected && rd_selected) {
				rd_lastSelected = rd_selected
			}
			rd_selected = radioButton
			radioButton.addEventListener(Event.CHANGE, selectButtonOnEvent, false, 0, true)
		}	
		
		private function selectButtonOnEvent(evt:Event):void 
		{
			var currButton:RadioButton = evt.currentTarget as RadioButton
			if (currButton.selected)
			{
				selectButton(currButton)
				dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
	}
}