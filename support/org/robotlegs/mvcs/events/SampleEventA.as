package org.robotlegs.mvcs.events
{

import flash.events.Event;

public class SampleEventA extends Event
{
	
	public static const SOMETHING_HAPPENED:String = "somethingHappened";
	
	public static const SOMETHING_ELSE_HAPPENED:String = "somethingElseHappened";
	
	public function SampleEventA(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event
	{
		return new SampleEventA(type, bubbles, cancelable);
	}
	
}

}

