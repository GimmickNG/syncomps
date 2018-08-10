package syncomps.interfaces 
{
	import flash.events.IEventDispatcher;
	import syncomps.interfaces.graphics.IDisplayObject;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface ISynComponent extends IDisplayObject, IStyleDefinition
	{
		function unload():void;
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
	}
	
}