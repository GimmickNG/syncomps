package syncomps
{
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import syncomps.LabeledButton;
	import syncomps.SynComponent;
	import syncomps.data.DataElement;
	import syncomps.data.DataProvider;
	import syncomps.interfaces.IDataProvider;
	import syncomps.styles.DefaultStyle;
	
	public class PieMenu extends SynComponent implements IDataProvider
	{
		protected static const DEFAULT_STYLE:Class = DefaultStyle
		private var i_sliceValue:int;
		private var b_menuOpen:Boolean;
		private var dp_menuItems:DataProvider
		private var shp_connectingLines:Shape;
		private var shp_pieMenuStar:Shape
		public function PieMenu()
		{
			super()
			init()
		}
		private function init():void
		{
			i_sliceValue = 0;
			b_menuOpen = false;
			mouseEnabled = false;
			shp_pieMenuStar = new Shape()
			shp_connectingLines = new Shape()
			dp_menuItems = new DataProvider()	
			
			drawMenuShape()
			addEventListener(MouseEvent.CLICK, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_UP, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_OUT, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_OVER, changeState, false, 0, true)
			addEventListener(MouseEvent.MOUSE_DOWN, changeState, false, 0, true)
			dp_menuItems.addEventListener(Event.CHANGE, changeState, false, 0, true)
		}
		
		private function changeState(evt:Event):void 
		{
			if (evt is MouseEvent)
			{
				var mEvt:MouseEvent = evt as MouseEvent
				var objects:Array = getObjectsUnderPoint(new Point(mEvt.stageX, mEvt.stageY))
				var index:int;
				for (var i:int = objects.length - 1, sliceValue:int = -1; sliceValue == -1 && i >= 0; --i)
				{
					if (!(objects[i] == shp_connectingLines || objects[i] == shp_pieMenuStar)) {
						sliceValue = dp_menuItems.indexOfByField("objectProperty", objects[i]);
					}
				}
			}
			i_sliceValue = sliceValue
			var state:String;
			switch(evt.type)
			{
				case MouseEvent.CLICK:
					trace("clicekd", evt.target)
					break;
				case MouseEvent.MOUSE_DOWN:
					state = DefaultStyle.DOWN
					break;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.MOUSE_OVER:
					state = DefaultStyle.HOVER
					break;
				case MouseEvent.MOUSE_OUT:
					state = DefaultStyle.BACKGROUND
					break;
				case Event.CHANGE:
				default:
					state = str_state
					break;
			}
			drawGraphics(width, height, state);
		}
		override public function getDefaultStyle():Class {
			return DEFAULT_STYLE
		}
		private function drawMenuShape():void 
		{
			var newStar:Vector.<Number> = new Vector.<Number>()	
			var points:Vector.<Number> = new Vector.<Number>()
			var xSwing:Number = 1.0, ySwing:Number = 1.0;
			var i:uint;
			
			for (i = 0; i < 10; i += 2)
			{
				//calculate angles
				var currAngle:Number = 0.628318530718 * i	//PI * i / 5
				points.push(Math.cos(currAngle), Math.sin(currAngle));
				
				if (points[i] < xSwing) {
					xSwing = points[i]		//calculate x swing (min)
				}
				
				if (points[i + 1] < ySwing) {
					ySwing = points[i + 1]	//calculate y swing (min)
				}
			}
			var xCorrection:Number = 32 / (1 - xSwing)
			var yCorrection:Number = 32 / (1 - ySwing)
			for (i = 0; i < points.length; i += 2)
			{
				points[i] *= xCorrection
				points[i + 1] *= yCorrection
			}
			newStar.push(points[0], points[1]);
			for (i = 0; i < points.length * 2; i += 4) {
				newStar.push(points[i % points.length], points[(i + 1) % points.length]);
			}
			var graphics:Graphics = shp_pieMenuStar.graphics
			graphics.clear()
			graphics.beginFill(0, 1)
			graphics.drawPath(new <int>[1, 2, 2, 2, 2, 2], newStar, GraphicsPathWinding.NON_ZERO)
			graphics.endFill()
			shp_pieMenuStar.rotation = -19
		}
		
		override protected function drawGraphics(width:int, height:int, state:String):void 
		{
			var currItem:DisplayObject;
			var dirX:Number, dirY:Number;
			var sliceValue:int = i_sliceValue
			var i:uint, j:int, k:int, fillColor:uint;
			var colorStyle:uint = uint(getStyle(state))
			trace("color is", state, getStyle(state))
			var disabledStyle:uint = uint(getStyle(DefaultStyle.DISABLED))
			var backgroundStyle:uint = uint(getStyle(DefaultStyle.BACKGROUND))
			if (!enabled) {
				colorStyle = disabledStyle
			}
			const graphics:Graphics = shp_connectingLines.graphics
			var path:Vector.<Number> = new Vector.<Number>(12, true)
			graphics.clear()
			for (i = 0; i < numItems; ++i)
			{
				currItem = dp_menuItems.getItemAt(i).objectProperty as DisplayObject
				fillColor = backgroundStyle
				if (i == sliceValue) {
					fillColor = colorStyle
				}
				else if(!(currItem is InteractiveObject && (currItem as InteractiveObject).mouseEnabled)) {
					fillColor = disabledStyle
				}
				path[0] = path[6] = currItem.x
				path[1] = path[9] = currItem.y
				path[2] = path[8] = currItem.x + currItem.width
				path[3] = path[7] = currItem.y + currItem.height
				graphics.beginFill(fillColor & 0x00FFFFFF, ((fillColor & 0xFF000000) >>> 24) / 0xFF)
				graphics.drawTriangles(path)
				graphics.endFill()
			}
		}
		
		public function showMenu(width:uint, height:uint):void
		{
			var i:uint
			b_menuOpen = true;
			addChild(shp_connectingLines)
			const numItems:uint = dp_menuItems.length
			const itemAngle:Number = 6.28318530718 / numItems //--> 2*PI / numItems
			const halfWidth:Number = 0.5 * width
			const halfHeight:Number = 0.5 * height
			for (i = 0; i < dp_menuItems.length; ++i)
			{
				var angle:Number = itemAngle * i
				var currItem:DisplayObject = dp_menuItems.getItemAt(i).objectProperty as DisplayObject
				var halfItemHeight:Number = 0.5 * currItem.height
				var halfItemWidth:Number = 0.5 * currItem.width
				currItem.x = (Math.cos(angle) * (halfWidth - halfItemWidth)) - (halfItemWidth);
				currItem.y = (Math.sin(angle) * (halfHeight - halfItemHeight)) - (halfItemHeight);
				addChild(currItem)
			}
			addChild(shp_pieMenuStar)
			drawGraphics(width, height, DefaultStyle.BACKGROUND)
		}
		
		public function hideMenu():void
		{
			b_menuOpen = false;
			removeChildren()
		}
		
		//use safe cast onwards as only DOs allowed (error thrown if not correct type)
		public function addItem(item:Object):void {
			dp_menuItems.addItem(DisplayObject(item))
		}
		
		public function addItemAt(item:Object, index:int):void {
			dp_menuItems.addItemAt(DisplayObject(item), index)
		}
		
		public function addItems(...items):void 
		{
			for (var i:uint = 0; i < items.length; ++i) {
				addItem(items[i])
			}
		}
		
		public function removeItem(item:Object):Object {
			return dp_menuItems.removeItem(item)
		}
		
		public function removeItemAt(index:int):Object {
			return dp_menuItems.removeItemAt(index)
		}
		
		public function getItemAt(index:int):DataElement {
			return dp_menuItems.getItemAt(index)
		}
		
		public function removeAll():void 
		{
			removeChildren()
			dp_menuItems.removeAll()
			addChild(shp_connectingLines)
			addChild(shp_pieMenuStar)
		}
		
		public function get items():Array {
			return dp_menuItems.items;
		}
		
		public function get numItems():uint {
			return dp_menuItems.numItems;
		}
		
		public function get dataProvider():DataProvider {
			return dp_menuItems;
		}
		
		public function get menuOpen():Boolean {
			return b_menuOpen;
		}
		
	}
}