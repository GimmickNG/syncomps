package syncomps 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.events.ButtonEvent;
	import syncomps.events.DataProviderEvent;
	import syncomps.events.ListCellEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.IAutoResize;
	import syncomps.interfaces.IDataProvider;
	import syncomps.interfaces.ILabel;
	import syncomps.styles.SplitButtonStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	[Event(name = "change", type = "flash.events.Event")]
	[Event(name = "CLICK", type = "syncomps.events.ButtonEvent")]
	[Event(name="CELL_CLICK", type="syncomps.events.ListCellEvent")]
	[Event(name="MENU_STATE_CHANGE", type="syncomps.events.ComboBoxEvent")]
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class SplitLabeledButton extends SynComponent implements IDataProvider, IAutoResize, ILabel
	{
		public static const DEF_WIDTH:int = 96
		public static const DEF_HEIGHT:int = 32;
		protected static var DEFAULT_STYLE:Class = SplitButtonStyle
		
		private var cmpi_button:LabeledButton;
		private var cmpi_dropdown:ComboBox;
		private var shp_baseGraphics:Sprite
		
		public function SplitLabeledButton() 
		{
			super();
			init()
		}
		
		private function init():void
		{
			shp_baseGraphics = new Sprite()
			cmpi_dropdown = new ComboBox()
			cmpi_button = new LabeledButton()
			StyleManager.unregister(cmpi_button)
			StyleManager.unregister(cmpi_dropdown)
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			
			cmpi_dropdown.addEventListener(Event.CHANGE, updateButton, false, 0, true)
			cmpi_dropdown.addEventListener(ListCellEvent.CELL_CLICK, setTextAndDispatch, false, 0, true)
			cmpi_dropdown.addEventListener(DataProviderEvent.DATA_REFRESH, changeButtonText, false, 0, true)
			cmpi_dropdown.addEventListener(DataProviderEvent.ITEM_REMOVED, updateButton, false, 0, true)
			cmpi_button.addEventListener(ButtonEvent.CLICK, dispatchEvent, false, 0, true)
			cmpi_button.x = cmpi_button.y = 1;
			addChild(cmpi_dropdown)
			addChild(cmpi_button)
			addChild(shp_baseGraphics)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
		}
		
		override public function get enabled():Boolean 
		{
			return super.enabled;
		}
		
		override public function set enabled(value:Boolean):void 
		{
			cmpi_button.enabled = cmpi_dropdown.enabled = value;
			super.enabled = value;
		}
		
		public function get textField():TextField {
			return cmpi_button.textField
		}
		
		/**
		 * The internal textField of the dropdown list. Intended for use in disabling accessibility;
		 * for implementing accessibility features, use the textField property in accordance with
		 * the ILabel interface implemented by this class, since it is guaranteed that the outward-facing
		 * button textField, is a mirror of the internal dropdown textField.
		 */
		public function get listTextField():TextField {
			return cmpi_dropdown.textField
		}
		
		private function changeButtonText(evt:DataProviderEvent):void 
		{
			if (cmpi_dropdown.numItems) {
				selectedIndex = 0
			}
		}
		
		private function updateButton(evt:Event):void
		{
			var item:Object = cmpi_dropdown.selectedItem
			cmpi_dropdown.label = "";
			if (item)
			{
				icon = item.icon
				label = item.label
			}
		}
		
		private function updateStyles(evt:StyleEvent):void 
		{
			cmpi_button.setStyle(evt.style, evt.value)
			cmpi_dropdown.setStyle(evt.style, evt.value)
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		override public function unload():void 
		{
			super.unload();
			removeChildren();
			cmpi_dropdown.removeEventListener(ListCellEvent.CELL_CLICK, setTextAndDispatch)
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			super.drawGraphics(width, height, state);
			var graphics:Graphics = shp_baseGraphics.graphics
			var colour:uint = uint(getStyle(DefaultStyle.BACKGROUND))
			if(!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			graphics.clear()
			graphics.lineStyle(1, colour)
			graphics.drawRect(0, 0, width - 1, height - 1)
			graphics.lineStyle(1)
			graphics.moveTo(width - 23, 4)
			graphics.lineTo(width - 23, height - 4)
			
			cmpi_dropdown.width = width;
			cmpi_dropdown.height = height
			cmpi_button.height = height - 2;
			if (width > 24) {
				cmpi_button.width = width - 24
			}
			else {
				cmpi_button.width = width;
			}
		}
		
		override public function set width(value:Number):void {
			drawGraphics(value, height, str_state)
		}
		
		override public function set height(value:Number):void {
			drawGraphics(width, value, str_state)
		}
		
		private function setTextAndDispatch(evt:ListCellEvent):void 
		{
			evt.preventDefault()
			addEventListener(ListCellEvent.CELL_CLICK, setTextAfterEvent)
			dispatchEvent(new ListCellEvent(evt.type, evt.index, evt.item, false, true))
		}
		
		private function setTextAfterEvent(evt:ListCellEvent):void 
		{
			removeEventListener(ListCellEvent.CELL_CLICK, setTextAfterEvent)
			if(evt && evt.cancelable && evt.isDefaultPrevented()) {
				return;
			}
			selectedIndex = evt.index
		}
		
		public function resizeWidth():void 
		{
			cmpi_button.resizeWidth()
			width = cmpi_button.width + 24
		}
		
		public function resizeHeight():void
		{
			cmpi_button.resizeHeight()
			height = cmpi_button.height + 2
		}
		
		public function addItem(item:Object):void {
			cmpi_dropdown.addItem(item);
		}
		
		public function addItemAt(item:Object, index:int):void {
			cmpi_dropdown.addItemAt(item, index);
		}
		
		public function get dataProvider():DataProvider {
			return cmpi_dropdown.dataProvider;
		}
		
		public function set dataProvider(value:DataProvider):void {
			cmpi_dropdown.dataProvider = value;
		}
		
		public function getItemAt(index:int):DataElement {
			return cmpi_dropdown.getItemAt(index);
		}
		
		public function hideMenu():void {
			cmpi_dropdown.hideMenu();
		}
		
		public function get numItems():uint {
			return cmpi_dropdown.numItems;
		}
		
		public function removeItem(item:Object):Object {
			return cmpi_dropdown.removeItem(item);
		}
		
		public function removeItemAt(index:int):Object {
			return cmpi_dropdown.removeItemAt(index);
		}
		
		public function get rowHeight():int {
			return cmpi_dropdown.rowHeight;
		}
		
		public function set rowHeight(value:int):void {
			cmpi_dropdown.rowHeight = value;
		}
		
		public function get selectedIndex():int {
			return cmpi_dropdown.selectedIndex;
		}
		
		public function set selectedIndex(value:int):void {
			cmpi_dropdown.selectedIndex = value;
		}
		
		public function get value():Object
		{
			var item:Object = selectedItem
			if (item && item.hasOwnProperty("label")) {
				return item.label
			}
			return null
		}
		
		public function get selectedItem():Object {
			return cmpi_dropdown.selectedItem;
		}
		
		public function showMenu():void {
			cmpi_dropdown.showMenu();
		}
		
		public function removeAll():void {
			cmpi_dropdown.removeAll()
		}
		
		public function get icon():BitmapData 
		{
			if(selectedItem) {
				return selectedItem.icon
			}
			return cmpi_button.icon
		}
		
		public function set icon(value:BitmapData):void 
		{
			cmpi_button.icon = value;
			if(selectedItem) {
				selectedItem.icon = value;
			}
		}
		
		public function get items():Array {
			return cmpi_dropdown.items
		}
		
		public function get label():String {
			return cmpi_button.label;
		}
		
		public function set label(value:String):void {
			cmpi_button.label = value;
		}
	}

}