package syncomps.data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	/**
	 * ...
	 * @author Gimmick
	 */
	use namespace flash_proxy;
	dynamic public class DataElement extends Proxy
	{
		private var obj_proxy:Object;
		private var cl_dispatcher:EventDispatcher
		private var vec_properties:Vector.<String>;
		public function DataElement(initObj:Object)
		{
			obj_proxy = initObj
			if(!initObj) {
				obj_proxy = new Object()
			}
			vec_properties = new Vector.<String>();
			for (var prop:* in obj_proxy) {
				vec_properties.push(prop)
			}
		}
		override flash_proxy function callProperty(methodName:*, ...args):*
		{
			var functor:Function = getProperty(methodName) as Function
			if (functor != null) {
				return functor.apply(this, args);
			}
			return undefined;
		}
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			var result:Boolean = delete obj_proxy[name];
			if (cl_dispatcher) {
				cl_dispatcher.dispatchEvent(new Event(Event.CHANGE, false, false))
			}
			return result;
		}
		override flash_proxy function getDescendants(name:*):* {
			return obj_proxy[name];
		}
		override flash_proxy function getProperty(name:*):* {
			return obj_proxy[name];
		}
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in obj_proxy;
		}
		override flash_proxy function isAttribute(name:*):Boolean {
			return name in obj_proxy;
		}
		override flash_proxy function nextName(index:int):String {
			return vec_properties[index-1];
		}
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (!index)
			{
				var propNames:Vector.<String> = vec_properties;
				propNames.length = 0;
				for (var k:* in obj_proxy) {
					propNames.push(k);
				}
			}
			if(index < vec_properties.length) {
				return index + 1;
			}
			return 0;
		}
		override flash_proxy function nextValue(index:int):* {
			return obj_proxy[vec_properties[index-1]];
		}
		override flash_proxy function setProperty(name:*, value:*):void
		{
			var prevValue:* = getProperty(name);
			obj_proxy[name] = value;
			if (cl_dispatcher && (prevValue === undefined || prevValue !== value)) {
				cl_dispatcher.dispatchEvent(new Event(Event.CHANGE, false, false))
			}
		}
		
		internal function setDispatcher(dispatcher:EventDispatcher):void {
			cl_dispatcher = dispatcher
		}
		
		/**
		 * Returns the proxy's underlying object.
		 */
		public function get objectProperty():Object {
			return obj_proxy
		}
	}

}