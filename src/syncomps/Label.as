package syncomps 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	import syncomps.events.StyleEvent;
	import syncomps.styles.DefaultLabelStyle;
	import syncomps.styles.DefaultStyle;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class Label extends SynComponent 
	{
		public static const DEF_WIDTH:uint = 96;
		public static const DEF_HEIGHT:uint = 24;
		protected static var DEFAULT_STYLE:Class = DefaultLabelStyle
		
		private var spr_icon:Sprite;
		private var tf_label:SkinnableTextField
		public function Label() 
		{
			super()
			init()
		}
		
		private function init():void
		{
			tf_label = new SkinnableTextField()
			spr_icon = new Sprite()
			
			mouseChildren = mouseEnabled = tabEnabled = false;
			tf_label.selectable = tf_label.multiline = false;
			addChild(tf_label)
			addChild(spr_icon)
			
			addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			drawGraphics(DEF_WIDTH, DEF_HEIGHT, DefaultStyle.BACKGROUND)
			label = null
		}
		
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		
		override public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function updateStyles(evt:StyleEvent):void
		{
			tf_label.setStyle(evt.style, evt.value)
			drawGraphics(width, height, state)
		}
		
		public function get iconSize():int {
			return int(getStyle(DefaultStyle.ICON_SIZE))
		}
		
		public function set iconSize(value:int):void {
			setStyle(DefaultStyle.ICON_SIZE, value)
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void
		{
			if(width < 0 || height < 0) {
				return;
			}
			super.drawGraphics(width, height, state)
			graphics.clear()
			graphics.beginFill(0, 0)
			graphics.drawRect(0, 0, width, height)
			graphics.endFill()
			var iconSize:int = this.iconSize
			var maxPadding:Number = (4 * (1 - Math.pow(1.2, -width)))
			var labelPosition:int = int(getStyle(DefaultLabelStyle.LABEL_POSITION))
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_LEFT:
				case DefaultLabelStyle.LABEL_RIGHT:
					if(height < iconSize) {
						iconSize = height
					}
					else if((iconSize + maxPadding) > width) {
						iconSize = width - maxPadding
					}
					break;
				case DefaultLabelStyle.LABEL_ABOVE:
				case DefaultLabelStyle.LABEL_BELOW:
					if(iconSize + maxPadding > height) {
						iconSize = height - maxPadding
					}
					else if(iconSize > width) {
						iconSize = width
					}
					break;
			}
			if (icon && icon.width && icon.height) {
				spr_icon.width = spr_icon.height = iconSize
			}
			else {
				maxPadding = 0
			}
			tf_label.x = tf_label.y = spr_icon.x = spr_icon.y = 0
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_LEFT:
					spr_icon.x = width - spr_icon.width
				case DefaultLabelStyle.LABEL_RIGHT:	//fallthrough
					spr_icon.y = (height - spr_icon.height) / 2;
					break;
				case DefaultLabelStyle.LABEL_ABOVE:
					spr_icon.y = height - spr_icon.height
				case DefaultLabelStyle.LABEL_BELOW:	//fallthrough
					spr_icon.x = (width - spr_icon.width) / 2;
					break;
			}
			switch(labelPosition)
			{
				case DefaultLabelStyle.LABEL_RIGHT:
					tf_label.x = spr_icon.x + spr_icon.width + maxPadding
					tf_label.width = width - tf_label.x
					tf_label.height = height
					break
				case DefaultLabelStyle.LABEL_LEFT:
					tf_label.width = spr_icon.x - maxPadding
					tf_label.height = height
					break;
				case DefaultLabelStyle.LABEL_ABOVE:
					spr_icon.y = height - (spr_icon.height)
					tf_label.height = height - (spr_icon.y + maxPadding)
					break;
				case DefaultLabelStyle.LABEL_BELOW:
					tf_label.height = height - tf_label.y
					break;
			}
		}
		
		override public function unload():void
		{
			super.unload()
			icon = null
			removeChildren()
		}
		
		public function resizeWidth():void 
		{
			tf_label.width = tf_label.getLineMetrics(0).width + 4
			var extraSpace:Number = 0;
			if(spr_icon.width) {
				extraSpace = 4 * (1 - Math.pow(1.2, -(spr_icon.width + tf_label.width)))
			}
			drawGraphics(spr_icon.width + tf_label.width + extraSpace, height, state)
		}
		
		private function autoSizeText():void 
		{
			var lineMetrics:TextLineMetrics = tf_label.getLineMetrics(0)
			tf_label.height = lineMetrics.height + lineMetrics.descent
			tf_label.width = lineMetrics.width
		}
		
		public function resizeHeight():void 
		{
			var maxHeight:int = iconSize
			tf_label.height = tf_label.textHeight + 4
			if(maxHeight < tf_label.height) {
				maxHeight = tf_label.height
			}
			drawGraphics(width, maxHeight, state)
		}
		
		public function get textField():TextField {
			return tf_label
		}
		
		public function get label():String {
			return tf_label.text;
		}
		
		public function set label(value:String):void
		{
			var prevWidth:Number = width
			var prevHeight:Number = height
			tf_label.text = value || "";
			autoSizeText()
			drawGraphics(prevWidth, prevHeight, state)
		}
		
		public function set htmlLabel(value:String):void
		{
			var prevWidth:Number = width
			var prevHeight:Number = height
			tf_label.htmlText = value || "";
			autoSizeText()
			drawGraphics(prevWidth, prevHeight, state)
		}
		
		public function get htmlLabel():String {
			return tf_label.htmlText
		}
		
		public function get icon():DisplayObject {
			return (spr_icon.numChildren && spr_icon.getChildAt(0)) as DisplayObject;
		}
		
		public function set icon(value:DisplayObject):void 
		{
			spr_icon.removeChildren()
			if (!value) {
				return;
			}
			
			spr_icon.addChild(value);
			if (spr_icon.width && spr_icon.height) {
				spr_icon.width = spr_icon.height = iconSize
			}
			drawGraphics(this.width, this.height, state)
		}
		
		public function hideText():void 
		{
			if (tf_label.parent)
			{
				removeChild(tf_label)
				drawGraphics(width, height, state)
			}
		}
		
		public function showText():void
		{
			if (!tf_label.parent)
			{
				addChild(tf_label)
				drawGraphics(width, height, state)
			}
		}
	}

}