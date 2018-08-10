package syncomps.styles 
{
	import syncomps.ListCell;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DefaultListStyle extends DefaultStyle
	{
		public static const CELL_RENDERER:String = "cellRenderer"
		public static const LIST_DIRECTION:String = "listDirection";
		public static const HORIZONTAL:String = "horizontal"
		public static const VERTICAL:String = "vertical"
		public function DefaultListStyle() 
		{
			appendStyle(CELL_RENDERER, ListCell)
			appendStyle(LIST_DIRECTION, VERTICAL)
		}
	}

}