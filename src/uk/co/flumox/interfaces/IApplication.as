package uk.co.flumox.interfaces {
	
	import org.osflash.signals.Signal;

	import flash.events.IEventDispatcher;

	/**
	 * @author jamieingram
	 */
	public interface IApplication extends IEventDispatcher {
		
		function loadInitialData():void;
		function get initialLoadCompleteSignal():Signal;
	}
}