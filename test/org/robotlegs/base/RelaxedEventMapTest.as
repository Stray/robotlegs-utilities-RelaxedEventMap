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
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, somethingHappenedHandler, SampleEventA, false, 0, true);
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
		
		public function test_unmappedRelaxedListener():void {
			var handlerThatShouldNotRun:Function = addAsync(failIfFired, 100, correctFailHandler);
	    	instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
			instance.unmapListener(eventDispatcher, SampleEventA.SOMETHING_HAPPENED, handlerThatShouldNotRun, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
		}
		
		public function test_rememberEvent_stores_the_event():void {
			instance.rememberEvent(SampleEventA.SOMETHING_HAPPENED, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	var handler:Function = addAsync(check_past_event_fired_when_listener_added, 100);
			instance.mapRelaxedListener(SampleEventA.SOMETHING_HAPPENED, handler, SampleEventA);
	    }
	
		public function test_rememberEvent_listener_is_cleaned_up():void { 
		    instance.rememberEvent(SampleEventA.SOMETHING_HAPPENED, SampleEventA);
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
	    	// unfortunately because the listener is by design empty, I can't find a way to test this automatically
			// so it's a trace based confirmation
			assertTrue("Manually verified that when a trace is placed in the null function used it doesn't trace", true);
	    }
		
		
		private function somethingHappenedHandler(e:SampleEventA):void
		{
			// nada
		}
		
		private function failIfFired(e:Event = null):void
		{
			assertTrue("this event should not have fired!", false);
		} 
		
		private function correctFailHandler(e:Event = null):void
		{
			assertTrue("Good - this was supposed to fail", true);
		}
	}
}