package org.robotlegs.base {
	
	import org.robotlegs.base.EventMap;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import org.robotlegs.core.IRelaxedEventMap;
	
	public class RelaxedEventMap extends EventMap implements IRelaxedEventMap {
		
		protected var eventsReceivedByClass:Dictionary;
		protected var emptyListeners:Array;
		
		public function RelaxedEventMap(eventDispatcher:IEventDispatcher) {
			super(eventDispatcher);
			eventsReceivedByClass = new Dictionary();
			emptyListeners = [];
		} 
		
		public function mapRelaxedListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
	   	{
			eventClass ||= Event;
			if((eventsReceivedByClass[eventClass] != null) && (eventsReceivedByClass[eventClass][type] != null))
			{
				var eventToSupply:Event = eventsReceivedByClass[eventClass][type];
				var temporaryDispatcher:EventDispatcher = new EventDispatcher();
				temporaryDispatcher.addEventListener(type, listener);
				temporaryDispatcher.dispatchEvent(eventToSupply);
			}
			
			mapListener(this.eventDispatcher, type, listener, eventClass, useCapture, priority, useWeakReference);
		}
		
		public function rememberEvent(type:String, eventClass:Class = null):void
		{
			var emptyListener:Function = function():void { }; 
			emptyListeners.push(emptyListener);
			mapListener(this.eventDispatcher, type, emptyListener, eventClass);
		}

		override protected function routeEventToListener(event:Event, listener:Function, originalEventClass:Class):void
		{
			if (event is originalEventClass)
			{
				eventsReceivedByClass[originalEventClass] ||= new Dictionary();
				eventsReceivedByClass[originalEventClass][event.type] = event;
				                    
				if(emptyListeners.indexOf(listener) == -1)
				{
					listener(event);
				}
				
			}
		}

	}
}