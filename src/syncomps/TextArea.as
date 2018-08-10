package syncomps 
{
	import flash.display.Sprite
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;
	import syncomps.events.ScrollEvent;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.graphics.IAutoResize;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.ScrollPaneStyle;
	import syncomps.styles.SkinnableTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class TextArea extends TextInput
	{
		private var cmpi_scrollBars:ScrollBar;
		private var num_prevTextHeight:Number;
		public function TextArea()
		{
			super()
			init()
		}
		
		private function init():void 
		{
			cmpi_scrollBars = new ScrollBar()
			StyleManager.unregister(cmpi_scrollBars)
			
			num_prevTextHeight = 0.0;
			placeHolderField.wordWrap = textField.wordWrap = true;
			placeHolderField.multiline = textField.multiline = true;
			cmpi_scrollBars.setScrollProperties(textField.height, 0, textField.maxScrollV)
			addChild(cmpi_scrollBars)
			cmpi_scrollBars.width = 16;
			cmpi_scrollBars.visible = false
			textField.addEventListener(Event.CHANGE, checkHeight)
			textField.addEventListener(Event.SCROLL, changeScrollPosition)
			cmpi_scrollBars.addEventListener(ScrollEvent.SCROLL, changeTextScroll)
		}
		
		private function changeTextScroll(evt:ScrollEvent):void {
			textField.scrollV = cmpi_scrollBars.value
		}
		
		private function changeScrollPosition(evt:Event):void {
			cmpi_scrollBars.value = textField.scrollV
		}
		
		private function checkHeight(evt:Event):void 
		{
			var textHeight:Number = textField.textHeight
			if (textHeight != num_prevTextHeight)
			{
				cmpi_scrollBars.visible = textHeight > textField.height
				cmpi_scrollBars.setScrollProperties(textField.bottomScrollV - textField.scrollV, 0, textField.maxScrollV)
				textField.width = width
				if(cmpi_scrollBars.visible) {
					textField.width -= cmpi_scrollBars.width
				}
				num_prevTextHeight = textHeight
			}
		}
		override public function set width(value:Number):void 
		{
			super.width = value;
			cmpi_scrollBars.x = width - cmpi_scrollBars.width
			if(cmpi_scrollBars.visible) {
				textField.width = width - cmpi_scrollBars.width
			}
		}
		override public function set height(value:Number):void 
		{
			super.height = value;
			cmpi_scrollBars.height = value;
		}
	}

}