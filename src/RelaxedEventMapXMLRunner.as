package {
	import asunit.textui.TestRunner;
	import asunit.textui.XMLResultPrinter;
	
	public class RelaxedEventMapXMLRunner extends TestRunner {

		public function RelaxedEventMapXMLRunner() {
			// start(clazz:Class, methodName:String, showTrace:Boolean)
			// NOTE: sending a particular class and method name will
			// execute setUp(), the method and NOT tearDown.
			// This allows you to get visual confirmation while developing
			// visual entities
			setPrinter(new XMLResultPrinter());
			start(AllTests, null, TestRunner.SHOW_TRACE);
		}
	}
}
