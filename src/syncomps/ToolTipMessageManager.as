package syncomps 
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class ToolTipMessageManager
	{
		private static var cl_messageManager:ToolTipMessageManager
		private var dct_messages:Dictionary;
		public function ToolTipMessageManager()
		{
			dct_messages = new Dictionary(true)
			if(cl_messageManager) {
				throw new Error("Cannot initialize more than one copy of a ToolTipMessageManager.")
			}
			cl_messageManager = this;
		}
		
		private function setMessage(object:InteractiveObject, message:String):void
		{
			if (!(object && message)) {
				return;
			}
			removeToolTipListeners(object)
			dct_messages[object] = message;
			addToolTipListeners(object)
		}
		
		private function removeToolTipListeners(obj:InteractiveObject):void
		{
			obj.removeEventListener(MouseEvent.ROLL_OVER, displayToolTipOnEvent)
			obj.removeEventListener(MouseEvent.ROLL_OUT, hideToolTipOnEvent)
		}
		private function addToolTipListeners(obj:InteractiveObject):void
		{
			obj.addEventListener(MouseEvent.ROLL_OVER, displayToolTipOnEvent, false, 0, true)
			obj.addEventListener(MouseEvent.ROLL_OUT, hideToolTipOnEvent, false, 0, true)
		}
		
		private function hideToolTipOnEvent(evt:MouseEvent):void 
		{
			if (ToolTip.visible) {
				ToolTip.hideToolTip()
			}
		}
		
		private function displayToolTipOnEvent(evt:MouseEvent):void
		{
			var currTarget:DisplayObject = evt.currentTarget as DisplayObject
			if (currTarget && currTarget.stage) {
				displayToolTip(evt.stageX, evt.stageY, currTarget.stage.nativeWindow, currTarget)
			}
		}
		
		private function getMessage(object:DisplayObject):String
		{
			if (object) {
				return dct_messages[object];
			}
			return null
		}
		
		private function removeMessage(object:InteractiveObject):void
		{
			if(!object) {
				return;
			}
			removeToolTipListeners(object)
			delete dct_messages[object]
		}
		
		private function setMessages(targets:Array, messages:Array):void
		{
			targets.forEach(function applyMessage(item:InteractiveObject, index:int, array:Array):void {
				messages && index < messages.length && setMessage(item, messages[index] as String)
			}, this);
		}
		
		private function removeMessages(targets:Array):void
		{
			targets && targets.forEach(function deleteMessage(item:InteractiveObject, index:int, array:Array):void {
				removeMessage(item)
			}, this);
		}
		
		private function unloadAll():void
		{
			var messages:Dictionary = dct_messages
			for (var obj:Object in messages)
			{
				removeToolTipListeners(obj as InteractiveObject)
				delete messages[obj]
			}
		}
		
		private static function getMessage(object:DisplayObject):String {
			return mainInstance.getMessage(object)
		}
		
		public static function setMessage(object:InteractiveObject, message:String):void {
			mainInstance.setMessage(object, message)
		}
		
		public static function setMessages(targets:Array, messages:Array):void {
			mainInstance.setMessages(targets, messages)
		}
		
		public static function removeMessage(object:InteractiveObject):void {
			mainInstance.removeMessage(object)
		}
		
		public static function removeMessages(targets:Array):void {
			mainInstance.removeMessages(targets)
		}
		
		public static function unloadAll():void {
			mainInstance.unloadAll()
		}
		
		private static function displayToolTip(x:Number, y:Number, callingWindow:NativeWindow, target:DisplayObject, delay:Number = 1000):void
		{
			var message:String = mainInstance.getMessage(target)
			if (callingWindow && message)
			{
				var screenPt:Point = callingWindow.globalToScreen(new Point(x, y))
				ToolTip.displayDelayed(message, screenPt.x + ToolTip.DEFAULT_OFFSET, screenPt.y + ToolTip.DEFAULT_OFFSET, delay)
			}
		}
		
		
		private static function get mainInstance():ToolTipMessageManager
		{
			if(!cl_messageManager) {
				new ToolTipMessageManager()
			}
			return cl_messageManager;
		}
		
	}

}