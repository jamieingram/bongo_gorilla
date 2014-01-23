package uk.co.flumox.utils {
	import org.osflash.signals.natives.NativeSignal;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	/**
	 * A Custom loader class implementing signals
	 * 
	 * @author jamieingram
	 */
	public class AssetLoader extends Loader {
		
		public var loadingItem_int:int;
		public var activateSignal:NativeSignal;		public var completeSignal:NativeSignal;
		public var progressSignal:NativeSignal;
		public var errorSignal:NativeSignal;

		public function AssetLoader() {
			activateSignal = new NativeSignal(this.contentLoaderInfo, Event.ACTIVATE);
			completeSignal = new NativeSignal(this.contentLoaderInfo,Event.COMPLETE);
			progressSignal = new NativeSignal(this.contentLoaderInfo,ProgressEvent.PROGRESS);			errorSignal = new NativeSignal(this.contentLoaderInfo,IOErrorEvent.IO_ERROR);
			//
		}
	}
}
