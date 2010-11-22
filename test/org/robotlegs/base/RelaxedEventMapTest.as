package org.robotlegs.base {

	import asunit.framework.TestCase;
	import org.robotlegs.mvcs.events.SampleEventA;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class RelaxedEventMapTest extends TestCase {
		private var instance:RelaxedEventMap;
		
		private var eventDispatcher:EventDispatcher;

		public function RelaxedEventMapTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			eventDispatcher = new EventDispatcher();
			instance = new RelaxedEventMap(eventDispatcher);
		}

		override protected function tearDown():void {
			super.tearDown();
			instance = null;
		}

		public function testInstantiated():void {
			assertTrue("instance is RelaxedEventMap", instance is RelaxedEventMap);
		}

		public function testFailure():void {
			assertTrue("Failing test", true);
		}
		
		public function test_mapRelaxedListener_doesnt_error():void {
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, somethingHappenedHandler, SampleEventA, null, false, 0, true);
			assertTrue("MapRelaxedListener didn't error", true);
		}
		
	    public function test_past_event_fired_when_listener_added():void {
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, somethingHappenedHandler, SampleEventA);
	    	var handler:Function = addAsync(check_past_event_fired_when_listener_added, 100);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handler, SampleEventA);
	    }

	    private function check_past_event_fired_when_listener_added(e:SampleEventA):void {
	    	assertEquals('event is correct type', SampleEventA.SOMETHING_HAPPENED, e.type);
	    }
		
		public function test_unmappedListener():void {
			var handlerThatShouldNotRun:Function = addAsync(failIfFired, 100, correctFailHandler);
	    	instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
			instance.unmapListener(eventDispatcher, SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
		}
		
		 public function test_unmappedRelaxedListener():void {
			var handlerThatShouldNotRun:Function = addAsync(failIfFired, 100, correctFailHandler);
	    	instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
			instance.unmapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
		}
	
		public function test_rememberEvent_stores_the_event():void {
			instance.rememberEvent(SampleEventA.SOMETHING_HAPPENED, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	var handler:Function = addAsync(check_past_event_fired_when_listener_added, 100);
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handler, SampleEventA);
	    }
	
		/* not required - realised we need to keep the dummy listener throughout
		for cases where the view is off stage for a while before returning
		
		public function test_rememberEvent_listener_is_cleaned_up():void { 
		    instance.rememberEvent(SampleEventA.SOMETHING_HAPPENED, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	// unfortunately because the listener is by design empty, I can't find a way to test this automatically
			// so it's a trace based confirmation
			assertTrue("Manually verified that when a trace is placed in the null function used it doesn't trace", true);
	    }    */
		
		public function test_unmapListenersFor_an_object_removes_correct_listeners():void {                    
			var objectForRemovingSignals:Object = new Object();
			var objectForKeepingSignals:Object = new Object();
			
			var asyncHandler:Function = addAsync(somethingHappenedHandler, 100);
			
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, failIfFired, SampleEventA, objectForRemovingSignals);
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, alsoFailIfFired, SampleEventA, objectForRemovingSignals);
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, asyncHandler, SampleEventA, objectForKeepingSignals);
		    
			instance.unmapListenersFor(objectForRemovingSignals);
		
			eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
		}
		
		
		
		private function somethingHappenedHandler(e:SampleEventA):void
		{
			// nada
		}
		
		private function failIfFired(e:Event = null):void
		{
			assertTrue("this event should not have fired!", false);
		}
		
		private function alsoFailIfFired(e:Event = null):void
		{
			assertTrue("this event should not have fired!", false);
		} 
		
		private function correctFailHandler(e:Event = null):void
		{
			assertTrue("Good - this was supposed to fail", true);
		}
	}
}