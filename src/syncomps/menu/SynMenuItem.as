package syncomps.menu 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.KeyboardEvent;
	import syncomps.ListCell;
	import syncomps.SynComponent;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SynMenuItem extends ListCell
	{
		private var shp_checked:Shape;
		private var cmpi_submenu:SynMenu
		private var bmd_icon:BitmapData;
		public function SynMenuItem(label:String = "", isSeparator:Boolean = false) 
		{
			super()
			this.label = label;
		}
		
		public function get submenu():SynMenu 
		{
			return cmpi_submenu;
		}
		
		public function set submenu(value:SynMenu):void 
		{
			cmpi_submenu = value;
		}
		/*public function get icon():BitmapData
		public function set icon(icon:BitmapData):void;
		public function get checked():Boolean;
		public function set checked(isChecked:Boolean):void;
		public function get data():Object;
		public function set data(data:Object):void;
		public function get enabled():Boolean;
		public function set enabled(isSeparator:Boolean):void;
		public function get isSeparator():Boolean;
		public function get keyEquivalent():String;
		public function set keyEquivalent(keyEquivalent:String):void;
		public function get keyEquivalentModifiers():Array;
		public function set keyEquivalentModifiers(modifiers:Array):void;
		public function get label():String;
		public function set label(label:String):void;
		public function get menu():SynMenu
		public function get mnemonicIndex():int;
		public function set mnemonicIndex(index:int):void;
		public function get name():String;
		public function set name(name:String):void;
		*/
	}
}