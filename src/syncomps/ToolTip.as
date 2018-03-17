package syncomps 
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import syncomps.events.StyleEvent;
	import syncomps.interfaces.ILabel;
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ToolTip extends NativeWindow implements IStyleDefinition, ILabel
	{
		public static const DEFAULT_OFFSET:int = 16
		
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		
		private static const MAX_WIDTH:int = 380;
		private static var nwnd_toolTip:ToolTip;
		
		private var cl_style:Style
		private var num_hideDelay:Number;
		private var shp_bg:Shape;
		private var tf_text:SkinnableTextField;
		private var cl_timer:Timer;
		private var b_enabled:Boolean;
		public function ToolTip() 
		{
			var options:NativeWindowInitOptions = new NativeWindowInitOptions()
			options.maximizable = options.minimizable = options.resizable = false;
			options.systemChrome = NativeWindowSystemChrome.NONE
			options.transparent = true;
			options.type = NativeWindowType.LIGHTWEIGHT
			super(options)
			init()
			
			if(nwnd_toolTip) {
				throw new Error("Cannot initialize more than one copy of a ToolTip.")
			}
			alwaysInFront = true
			nwnd_toolTip = this;
		}
		
		private function init():void
		{
			shp_bg = new Shape()
			cl_timer = new Timer(1000, 2)
			tf_text = new SkinnableTextField()
			stage.scaleMode = StageScaleMode.NO_SCALE
			stage.align = StageAlign.TOP_LEFT
			
			StyleManager.unregister(tf_text)
			tf_text.selectable = tf_text.enabled = false;
			tf_text.antiAliasType = AntiAliasType.ADVANCED
			tf_text.x = tf_text.y = 4;
			tf_text.width = 100;
			
			stage.addChild(shp_bg)
			stage.addChild(tf_text)
			cl_style = (new (getDefaultStyle())()) as Style;
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, updateStyles, false, 0, true)
			cl_timer.addEventListener(TimerEvent.TIMER, toggleOnTimer, false, 0, true)
		}
		
		public function get textField():TextField {
			return tf_text
		}
		
		private function updateStyles(evt:StyleEvent):void {
			tf_text.setStyle(evt.style, evt.value)
		}
		
		private function hide():void
		{
			visible = false;
			cl_timer.reset()
		}
		
		/* INTERFACE syncomps.interfaces.IStyleDefinition */
		
		public function get styleDefinition():Style {
			return cl_style;
		}
		
		public function getStyle(style:Object):Object {
			return cl_style.getStyle(style)
		}
		
		public function setStyle(style:Object, value:Object):void {
			cl_style.setStyle(style, value)
		}
		
		public function applyStyle(style:Style):void {
			cl_style.applyStyle(style)
		}
		
		public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		private function toggleOnTimer(evt:TimerEvent):void
		{
			if (cl_timer.currentCount == 1)
			{
				var screens:Array = Screen.getScreensForRectangle(this.bounds);
				if(!screens.length) {
					return;
				}
				var parent:Rectangle = (screens[0] as Screen).visibleBounds
				if (parent)
				{
					if (x + width > parent.width) {
						x = parent.width - width
					}
					if (y + height > parent.height) {
						y = parent.height - height
					}
				}
				visible = true
				orderToFront()
				cl_timer.delay = num_hideDelay
			}
			else if(cl_timer.currentCount == 2) {
				hide()
			}
		}
		
		private function setText(text:String):void
		{
			tf_text.text = text;
			tf_text.multiline = false;
			tf_text.wordWrap = false;
			tf_text.autoSize = TextFieldAutoSize.LEFT;
			tf_text.text = text;
			if (tf_text.width > MAX_WIDTH)
			{
				tf_text.multiline = true;
				tf_text.wordWrap = true;
				tf_text.width = MAX_WIDTH;
			}
		}
		
		private function drawGraphics(width:int, height:int):void
		{
			var colour:uint = uint(getStyle(DefaultStyle.BACKGROUND)), colourAlpha:Number;
			if (!enabled) {
				colour = uint(getStyle(DefaultStyle.DISABLED))
			}
			colourAlpha = ((colour & 0xFF000000) >>> 24) / 0xFF;
			colour = colour & 0x00FFFFFF
			
			shp_bg.graphics.clear()
			shp_bg.graphics.lineStyle(0, 0, 0.25)
			shp_bg.graphics.beginFill(colour, colourAlpha)
			shp_bg.graphics.drawRect(0, 0, width - 1, height - 1)
			shp_bg.graphics.endFill()
		}
		
		public static function get enabled():Boolean {
			return mainInstance.b_enabled
		}
		
		public static function set enabled(value:Boolean):void {
			mainInstance.b_enabled = value
		}
		
		public static function hideToolTip():void {
			mainInstance.hide()
		}
		
		private static function get mainInstance():ToolTip
		{
			if(!nwnd_toolTip) {
				new ToolTip()
			}
			return nwnd_toolTip;
		}
		
		public static function displayDelayed(text:String, x:Number, y:Number, delay:Number = 1000, hideDelay:Number = 6000):void
		{
			var toolTip:ToolTip = mainInstance
			toolTip.x = x;
			toolTip.y = y;
			toolTip.setText(text)
			toolTip.cl_timer.reset();
			toolTip.cl_timer.delay = delay
			toolTip.num_hideDelay = hideDelay
			toolTip.width = toolTip.tf_text.width + 8
			toolTip.height = toolTip.tf_text.height + 8
			toolTip.drawGraphics(toolTip.width, toolTip.height)
			if(toolTip.b_enabled) {
				toolTip.cl_timer.start();
			}
		}
		
		public static function get styleDefinition():Style {
			return mainInstance.styleDefinition
		}
		
		public static function getStyle(style:Object):Object {
			return mainInstance.getStyle(style)
		}
		
		public static function setStyle(style:Object, value:Object):void {
			mainInstance.setStyle(style, value)
		}
		
		public static function applyStyle(style:Style):void {
			mainInstance.applyStyle(style)
		}
		
		public static function get visible():Boolean {
			return mainInstance && mainInstance.visible
		}
		
		public static function unload():void
		{
			var toolTip:ToolTip = mainInstance
			if (toolTip.closed) {
				return;
			}
			toolTip.cl_timer.removeEventListener(TimerEvent.TIMER, toolTip.toggleOnTimer)
			toolTip.stage.removeChildren()
			toolTip.close()
		}
		
	}

}