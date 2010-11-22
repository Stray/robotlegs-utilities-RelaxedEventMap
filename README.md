**What's it so relaxed about?** 

Sometimes, race conditions, or dynamic view creation, mean that a mediator only registers for a data event after the event has fired.
Common workarounds include injecting your model into your mediator. Yuk! 

The RelaxedEventMap allows you to take your time over adding your views and registering for events. 

When you mapRelaxedListener it will check whether it has previously received an instance of that particular event & type. If it has then the event is redispatched _only_ to the handler that is being registered.

Think of mapRelaxedListener as 'I'd like to listen for this event in future, oh - and if it has already happened then I'd like to get that most recent event right now as well please'.  It's like listening back into the past, but only for the most recent occurrence.


**Compatibility**

Robotlegs utility, tested against robotlegs v1.0 thru 1.4

Full test coverage is provided with asunit 3.

No swc as you should compile from source to ensure it extends the same version of robotlegs as the rest of your project.


**Usage:**     

In your context:
	
	// implement this interface:
	import org.robotlegs.core.IRelaxedEventContext;
	
	protected var _relaxedEventMap:IRelaxedEventMap;
	
	public function get relaxedEventMap():IRelaxedEventMap
	{
		return _relaxedEventMap ||= new RelaxedEventMap(eventDispatcher);
	}
	
	public function set relaxedEventMap(value:IRelaxedEventMap):void
	{
		_relaxedEventMap = value;
	}
	
	override protected function mapInjections():void
	{
		super.mapInjections();
		injector.mapValue(IRelaxedEventMap, relaxedEventMap);
	}
	

It is also necessary to add a dummy handler to tell the relaxedEventMap to pick up this event.
You can do this in your context startup, or in a dedicated bootstrap Command.                            

	// using a dedicated method that creates an empty listener for you
	relaxedEventMap.rememberEvent(SomeDataEvent.DATA_SET_UPDATED, SomeDataEvent);
    
	// or manually - for example so you can trace or log the event in the function passed here
	relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, function():void{}, SomeDataEvent);
       

Where you want to ensure the mediator receives the event, even if onRegister runs _after_ it has been fired.
Note that the parameters are similar to mapListener, but the dispatcher is always the shared eventDispatcher.
    
	// first - inject the relaxedEventMap
	[Inject]
	public var relaxedEventMap:IRelaxedEventMap;
	
	// then
	public override function onRegister():void
	{
    	relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, handler, SomeDataEvent);
    }
       

**Clean up**

In most other respects the RelaxedEventMap behaves just like the normal eventMap. The key difference is that there is only one RelaxedEventMap, where your individual mediators each have their own eventMap. If you need to de-register for the event when your view leaves the stage:

	// in the mediator, override preRemove
	public override function preRemove():void
	{
		relaxedEventMap.unmapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, handler, SomeDataEvent);
	}
	
	
** Passing the owner mediator for easier cleanup **

You can pass the mediator instance as an additional optional parameter when you mapRelaxedListener which then allows you to unmap all the listeners for that mediator (or object) in one go.

	// pass the mediator 'this' as the ownerObject
	relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, updatedHandler, SomeDataEvent, this);
	relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_DELETED, deletedHandler, SomeDataEvent, this);    
	
	// remove all the listeners for this mediator in one go:
	public override function preRemove():void
	{
		relaxedEventMap.unmapListenersFor(this);
	}


**Warnings**

Because the relaxedEventMap is shared across mediators, be very careful before using 'unmapListeners' (as inherited from EventMap) as this will remove *all* the listeners, including the dummy ones set up using rememberEvent.

You could potentially still wish to use this approach in - for example - the clean-up of a module being unloaded from your application - hence it is still available, but should only be used with caution.
  