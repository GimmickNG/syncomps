package syncomps.interfaces 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface ISynComponent extends IStyleDefinition, IEventDispatcher
	{
		function unload():void;
		function refresh():void;
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
	}
	
}