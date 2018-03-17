package syncomps.interfaces 
{
	import syncomps.styles.Style;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IStyleDefinition 
	{
		function get styleDefinition():Style
		function getStyle(style:Object):Object
		function setStyle(style:Object, value:Object):void
		function applyStyle(style:Style):void
		function getDefaultStyle():Class
		function setDefaultStyle(styleClass:Class):void
	}
	
}