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
	import syncomps.interfaces.IStyleDefinition;
	import syncomps.interfaces.IStyleInternal;
	import syncomps.styles.DefaultInnerTextStyle;
	import syncomps.styles.Style;
	import syncomps.styles.DefaultStyle;
	import syncomps.styles.StyleManager;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ToolTip extends NativeWindow implements IStyleDefinition
	{
		public static const DEFAULT_OFFSET:int = 16
		
		protected static var DEFAULT_STYLE:Class = DefaultInnerTextStyle
		private static const MAX_WIDTH:Number = 380;
		private static var nwnd_toolTip:ToolTip;
		
		private var tf_text:SkinnableTextField;
		private var cl_style:IStyleInternal
		private var b_enabled:Boolean;
		private var i_maxWidth:int;
		private var shp_bg:Shape;
		private var cl_timer:Timer;
		private var num_hideDelay:Number;
		public function ToolTip() 
		{
			var options:NativeWindowInitOptions = new NativeWindowInitOptions()
			options.maximizable = options.minimizable = options.resizable = false;
			options.systemChrome = NativeWindowSystemChrome.NONE
			options.type = NativeWindowType.LIGHTWEIGHT
			options.transparent = true;
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
			stage.scaleMode = StageScaleMode.NO_SCALE
			stage.align = StageAlign.TOP_LEFT
			cl_timer = new Timer(1000, 2)
			shp_bg = new Shape()
			tf_text = new SkinnableTextField()
			cl_style = (new (getDefaultStyle())()) as IStyleInternal
			
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGE, redrawOnStyleChange, false, 0, true)
			styleDefinition.addEventListener(StyleEvent.STYLE_CHANGING, updateStyles, false, 0, true)
			StyleManager.unregister(tf_text)
			b_enabled = true
			
			maxWidth = MAX_WIDTH
			tf_text.selectable = tf_text.enabled = false;
			tf_text.antiAliasType = AntiAliasType.ADVANCED
			tf_text.autoSize = TextFieldAutoSize.LEFT;
			tf_text.x = tf_text.y = 4;
			tf_text.width = 100;
			
			stage.addChild(shp_bg)
			stage.addChild(tf_text)
			stage.tabChildren = false;
			addEventListener(MouseEvent.ROLL_OVER, hideOnEvent, false, 0, true);
			cl_timer.addEventListener(TimerEvent.TIMER, toggleOnTimer, false, 0, true);
		}
		
		private function updateStyles(evt:StyleEvent):void 
		{
			evt.preventDefault()
			if (dispatchEvent(evt)) {
				styleDefinition.forceStyle(evt.style, evt.value)
			}
		}
		
		private function redrawOnStyleChange(evt:StyleEvent):void 
		{
			var bounds:Rectangle = textField.getBounds(null)
			stage.stageWidth = bounds.width + 8
			stage.stageHeight = bounds.height + 8
			tf_text.setStyle(evt.style, evt.value)
			drawGraphics(stage.stageWidth, stage.stageHeight)
		}
		
		private function hideOnEvent(evt:MouseEvent):void {
			hide()
		}
		
		private function hide():void
		{
			visible = false;
			cl_timer.reset()
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
				cl_timer.delay = num_hideDelay
			}
			else if(cl_timer.currentCount == 2) {
				hide()
			}
		}
		
		/* DELEGATES */
		private function resetTimer():void {
			cl_timer.reset()
		}
		
		private function setDelays(timerDelay:Number, hideDelay:Number):void
		{
			cl_timer.delay = timerDelay
			num_hideDelay = hideDelay
		}
		
		private function startDisplay():void {
			cl_timer.start()
		}
		
		/* INTERFACE syncomps.interfaces.IStyleDefinition <=> DELEGATE syncomps.ToolTipGUI */
		public function get styleDefinition():IStyleInternal {
			return cl_style
		}
		
		public function getStyle(style:Object):Object {
			return styleDefinition.getStyle(style);
		}
		
		public function setStyle(style:Object, value:Object):void {
			styleDefinition.setStyle(style, value);
		}
		
		public function applyStyle(style:IStyleInternal):void {
			styleDefinition.applyStyle(style)
		}
		
		public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		public function setDefaultStyle(styleClass:Class):void {
			DEFAULT_STYLE = styleClass
		}
		
		public function get textField():TextField {
			return tf_text
		}
		
		public function get maxWidth():int {
			return i_maxWidth;
		}
		
		public function set maxWidth(value:int):void {
			i_maxWidth = value;
		}
		
		private function setText(text:String):void
		{
			tf_text.text = text;
			tf_text.multiline = tf_text.wordWrap = (tf_text.width > maxWidth)
			if (tf_text.width > maxWidth) {
				tf_text.width = maxWidth;
			}
		}
		
		private function drawGraphics(width:int, height:int):void
		{
			var color:uint = uint(getStyle(DefaultStyle.BACKGROUND)), colorAlpha:Number;
			if (!b_enabled) {
				color = uint(getStyle(DefaultStyle.DISABLED))
			}
			colorAlpha = ((color & 0xFF000000) >>> 24) / 0xFF;
			color = color & 0x00FFFFFF
			
			shp_bg.graphics.clear()
			shp_bg.graphics.lineStyle(0, 0, 0.25)
			shp_bg.graphics.beginFill(color, colorAlpha)
			shp_bg.graphics.drawRect(0, 0, width - 1, height - 1)
			shp_bg.graphics.endFill()
		}
		
		public function set enabled(value:Boolean):void
		{
			b_enabled = value;
			if (!value) {
				hide()
			}
		}
		
		private static function get mainInstance():ToolTip {
			return nwnd_toolTip || new ToolTip()
		}
		
		public static function get enabled():Boolean {
			return mainInstance.b_enabled
		}
		
		public static function set enabled(value:Boolean):void {
			mainInstance.enabled = value
		}
		
		public static function hideToolTip():void {
			mainInstance.hide()
		}
		
		public static function displayDelayed(text:String, xVal:Number, yVal:Number, delay:Number = 1000, hideDelay:Number = 6000):void
		{
			var toolTip:ToolTip = mainInstance
			toolTip.x = xVal;
			toolTip.y = yVal;
			toolTip.resetTimer()
			toolTip.setText(text)
			toolTip.setDelays(delay, hideDelay)
			
			var bounds:Rectangle = toolTip.textField.getBounds(null)
			toolTip.stage.stageWidth = bounds.width + 8
			toolTip.stage.stageHeight = bounds.height + 8
			toolTip.drawGraphics(toolTip.stage.stageWidth, toolTip.stage.stageHeight)
			
			if(enabled) {
				toolTip.startDisplay();
			}
		}
		
		public static function get styleDefinition():IStyleInternal {
			return mainInstance.styleDefinition
		}
		
		public static function getStyle(style:Object):Object {
			return mainInstance.getStyle(style)
		}
		
		public static function setStyle(style:Object, value:Object):void {
			mainInstance.setStyle(style, value)
		}
		
		public static function applyStyle(style:IStyleInternal):void {
			mainInstance.applyStyle(style)
		}
		
		public static function get visible():Boolean {
			return mainInstance && mainInstance.visible
		}
		
		public static function get maxWidth():int {
			return mainInstance.maxWidth
		}
		
		public static function set maxWidth(maxWidth:int):void {
			mainInstance.maxWidth = maxWidth
		}
		public static function unload():void
		{
			var toolTip:ToolTip = mainInstance
			with (toolTip)
			{
				if (closed) {
					return;
				}
				cl_timer.removeEventListener(TimerEvent.TIMER, toolTip.toggleOnTimer)
				stage.removeChildren()
				close()
			}
		}
	}

}