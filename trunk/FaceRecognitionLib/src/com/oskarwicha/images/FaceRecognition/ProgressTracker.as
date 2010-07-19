package com.oskarwicha.images.FaceRecognition
{
	
	/**
	 * Klasa służy do obsługi informacji o postępie w treningu
	 * systemu.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class ProgressTracker
	{
		private var task:int = 0;
		
		private var sProgress:String;
		
		private var bFinished:Boolean;
		
		public function ProgressTracker()
		{
		}
		
		public function advanceProgress(message:String):void
		{
			task++;
			sProgress = "Zadanie " + task + ": " + message;
			trace(sProgress);
		}
	
	}
}