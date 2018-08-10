package syncomps.interfaces 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IStyleInternal extends IStyleDefinition 
	{
		function forceStyle(style:Object, value:Object):void;
		
		function getInheritanceChain():Vector.<Class>;
		function getStyleProperties():Dictionary;
		function getFields():Array;
	}
	
}