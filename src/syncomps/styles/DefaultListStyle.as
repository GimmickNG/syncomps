package syncomps.styles 
{
	import syncomps.ListCell;
	/**
	 * ...
	 * @author Gimmick
	 */
	public final class DefaultListStyle extends Style 
	{
		public static const CELL_RENDERER:String = "cellRenderer"
		public static const LIST_DIRECTION:String = "listDirection";
		public static const HORIZONTAL:String = "horizontal"
		public static const VERTICAL:String = "vertical"
		public function DefaultListStyle() 
		{
			super([DefaultStyle], [CELL_RENDERER, LIST_DIRECTION])
			init()
		}
		private function init():void
		{
			setStyle(CELL_RENDERER, ListCell)
			setStyle(LIST_DIRECTION, VERTICAL)
		}
	}

}