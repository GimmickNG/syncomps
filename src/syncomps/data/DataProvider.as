package syncomps.data 
{
	import flash.events.Event;
	import syncomps.events.DataProviderEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import syncomps.interfaces.IDataProvider;
	import flash.utils.getQualifiedSuperclassName;
	/**
	 * ...
	 * @author Gimmick
	 */
	public class DataProvider implements IDataProvider
	{
		private var arr_data:Array
		private var cl_dispatcher:IEventDispatcher
		public function DataProvider()
		{
			cl_dispatcher = new EventDispatcher(this)
			arr_data = new DispatchedArray(cl_dispatcher)
		}
		
		public function addItem(item:Object):void {
			addItemAt(item, length)
		}
		
		public function addItems(items:Array):void 
		{
			items.forEach(function add(item:Object, index:int, array:Array):void {
				addItem(item)
			}, this)
		}
		
		public function addItemAt(item:Object, index:int):void 
		{
			if (!(item is DataElement)) {
				item = new DataElement(item)
			}
			arr_data.insertAt(index, item)
		}
		
		public function removeItems():void {
			arr_data.length = 0;
		}
		
		public function removeItem(item:Object):Object 
		{
			var found:Boolean = arr_data.some(function find(data:DataElement, index:int, array:Array):Boolean
			{
				var found:Boolean = (data == item) || (data.objectProperty == item);
				if (found) {
					removeItemAt(index)
				}
				return found
			}, this);
			
			if(found) {
				return item
			}
			return null
		}
		
		public function removeItemAt(index:int):Object {
			return arr_data.removeAt(index)
		}
		
		public function getItemAt(index:int):DataElement {
			return arr_data[index]
		}
		
		public function get items():Array {
			return arr_data.concat();
		}
		
		public function set items(value:Array):void 
		{
			removeItems()
			addItems(value)
		}
		
		public function get numItems():uint {
			return arr_data.length
		}
		
		public function clone():DataProvider
		{
			var provider:DataProvider = new DataProvider()
			provider.addItems(arr_data)
			return provider
		}
		
		/* DELEGATE flash.events.IEventDispatcher */
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			cl_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return cl_dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return cl_dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			cl_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return cl_dispatcher.willTrigger(type);
		}
		
		/* Functional-style methods */
		
		public function filter(callback:Function, thisObject:* = null):IDataProvider
		{
			function filterer(item:DataElement, index:int, array:Array):Boolean {
				return callback.call(thisObject, item.objectProperty, index, array)
			}
			var provider:DataProvider = new DataProvider()
			provider.addItems(arr_data.filter(filterer, thisObject));
			return provider
		}
		
		public function forEach(callback:Function, thisObject:* = null):void
		{
			function eachFor(item:DataElement, index:int, array:Array):void {
				callback.call(thisObject, item.objectProperty, index, array)
			}
			arr_data.forEach(eachFor, thisObject);
		}
		
		public function map(callback:Function, thisObject:* = null):IDataProvider
		{
			function mapper(item:DataElement, index:int, array:Array):* {
				return callback.call(thisObject, item.objectProperty, index, array)
			}
			var provider:DataProvider = new DataProvider()
			provider.addItems(arr_data.map(mapper, thisObject));
			return provider
		}
		
		public function some(callback:Function, thisObject:* = null):Boolean
		{
			function checkSome(item:DataElement, index:int, array:Array):Boolean {
				return callback.call(thisObject, item.objectProperty, index, array)
			}
			return arr_data.some(checkSome, thisObject);
		}
		
		public function every(callback:Function, thisObject:* = null):Boolean
		{
			function checkEvery(item:DataElement, index:int, array:Array):Boolean {
				return callback.call(thisObject, item.objectProperty, index, array)
			}
			return arr_data.every(checkEvery, thisObject);
		}
		
		public function indexOf(searchFunction:Function, fromIndex:int = 0):int 
		{
			var searchIndex:int = -1
			arr_data.some(function search(data:DataElement, index:int, array:Array):Boolean
			{
				if(index < fromIndex) {
					return false
				}
				else if(searchFunction.call(this, data.objectProperty, index, array)) {
					searchIndex = index
				}
				return searchIndex != -1
			}, this);
			return searchIndex
		}
		
		public function getItemBy(searchFunction:Function):DataElement {
			return getItemAt(indexOf(searchFunction))
		}
		
		public function lastIndexOf(searchFunction:Function, fromIndex:int = int.MAX_VALUE):int 
		{
			var searchIndex:int = -1
			if(fromIndex == int.MAX_VALUE) {
				fromIndex = arr_data.length
			}
			var lastIndex:int = arr_data.length - fromIndex
			arr_data.reverse()
			arr_data.some(function search(data:DataElement, index:int, array:Array):Boolean
			{
				if(index < lastIndex) {
					return false
				}
				var found:Boolean = searchFunction.call(this, data.objectProperty, index, array)
				if(found) {
					searchIndex = index
				}
				return found
			}, this);
			arr_data.reverse()
			return searchIndex
		}
	}

}
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import syncomps.events.DataProviderEvent;
import syncomps.data.DataElement;

dynamic internal class DispatchedArray extends Array implements IEventDispatcher
{
	private var cl_dispatcher:IEventDispatcher
	public function DispatchedArray(dispatcher:IEventDispatcher)
	{
		super()
		cl_dispatcher = dispatcher
	}
	
	override AS3 function insertAt(index:int, element:*):void 
	{
		super.insertAt(index, element);
		dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_ADDED, DataElement(element), index, false, false))
	}
	
	override AS3 function pop():* 
	{
		var obj:* = super.pop();
		if (obj !== undefined) {
			dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_REMOVED, DataElement(obj), length + 1, false, false))
		}
		return obj;
	}
	
	override AS3 function push(...rest):uint 
	{
		var prevLen:uint = length
		var len:uint = super.push.apply(this, rest);
		rest.forEach(function dispatch(item:Object, index:int, array:Array):void {
			dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_ADDED, DataElement(item), index + prevLen, false, false))
		});
		return len;
	}
	
	override AS3 function removeAt(index:int):* 
	{
		var obj:* = super.removeAt(index);
		dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_REMOVED, DataElement(obj), index, false, false))
		return obj
	}
	
	override AS3 function reverse():Array 
	{
		var array:Array = super.reverse();
		dispatchEvent(new DataProviderEvent(DataProviderEvent.DATA_REFRESH, null, 0, false, false))
		return array;
	}
	
	override AS3 function shift():* 
	{
		var obj:* = super.shift();
		if (obj !== undefined) {
			dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_REMOVED, DataElement(obj), 0, false, false))
		}
		return obj
	}
	
	override AS3 function splice(...args):*
	{
		var retArr:Array = super.splice.apply(this, args)
		dispatchEvent(new DataProviderEvent(DataProviderEvent.DATA_REFRESH, null, 0, false, false))
		return retArr
	}
	
	override AS3 function unshift(...rest):uint 
	{
		var len:uint = super.unshift.apply(this, rest)
		rest.forEach(function dispatch(item:Object, index:int, array:Array):void {
			dispatchEvent(new DataProviderEvent(DataProviderEvent.ITEM_ADDED, DataElement(item), index, false, false))
		});
		return len
	}
	
	/* DELEGATE flash.events.IEventDispatcher */
	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
		cl_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	public function dispatchEvent(event:Event):Boolean {
		return cl_dispatcher.dispatchEvent(event);
	}
	
	public function hasEventListener(type:String):Boolean {
		return cl_dispatcher.hasEventListener(type);
	}
	
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
		cl_dispatcher.removeEventListener(type, listener, useCapture);
	}
	
	public function willTrigger(type:String):Boolean {
		return cl_dispatcher.willTrigger(type);
	}
}