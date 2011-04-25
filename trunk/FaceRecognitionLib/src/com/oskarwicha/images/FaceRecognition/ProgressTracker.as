package com.oskarwicha.images.FaceRecognition
{

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

		public function ProgressTracker()
		{
		}

		private var bFinished:Boolean;

		private var sProgress:String;
		private var task:int = 0;

		public function advanceProgress(message:String):void
		{
			task++;
			sProgress = "Zadanie " + task + ": " + message;
			trace(sProgress);
		}
	}
}