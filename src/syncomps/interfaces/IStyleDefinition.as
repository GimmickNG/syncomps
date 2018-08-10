package syncomps.interfaces 
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import syncomps.styles.Style;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IStyleDefinition extends IEventDispatcher
	{
		function get styleDefinition():IStyleInternal
		function getStyle(style:Object):Object
		function setStyle(style:Object, value:Object):void
		function applyStyle(style:IStyleInternal):void
		function getDefaultStyle():Class
		function setDefaultStyle(styleClass:Class):void
	}
	
}