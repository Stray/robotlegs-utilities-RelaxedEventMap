package org.robotlegs.mvcs.events
{

import flash.events.Event;

public class SampleEventB extends Event
{
	
	public static const SOMETHING_HAPPENED:String = "somethingHappened";
	
	public function SampleEventB(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event
	{
		return new SampleEventB(type, bubbles, cancelable);
	}
	
}

}

