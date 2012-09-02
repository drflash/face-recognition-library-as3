package com.oskarwicha.images.FaceRecognition
{
	import flash.utils.*;
	import mx.controls.Alert;

	/**
	 * Klasa służy do obsługi informacji o postępie w treningu
	 * systemu.
	 * 
	 * @author Oskar Wicha
	 * 
	 * @flowerModelElementId _Tqow0GglEeCqZchJBDddKw
	 */
	internal class ProgressTracker
	{
		private var bFinished:Boolean;
		private var task:int = 0;
		private var timer:int;
		private var log:String = "";
		
		public function ProgressTracker()
		{
			timer = getTimer();
		}

		public function advanceProgress(message:String, showLog:Boolean = false):void
		{
			var text:String = "";
			
			if(task)
				text += "Task finished in " + (getTimer() - timer) + " ms. \n";
			
			text += "Task " + (++task) + ": " + message;
			
			log += text + "\n";
			trace(text);
			
			if(showLog)
				Alert.show(log);
			
			timer = getTimer();
		}
	}
}