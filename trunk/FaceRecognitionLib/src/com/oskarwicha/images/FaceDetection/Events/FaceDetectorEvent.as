package com.oskarwicha.images.FaceDetection.Events
{
	import flash.events.Event;
	
	/**
	 * Klasa zdarzeń wysyłanych przez obiekty klasy
	 * <code>FaceDetector</code> gdy obiekt tej klasy zakończy
	 * proces detekcji twarzy.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class FaceDetectorEvent extends Event
	{
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const NO_FACES_DETECTED:String =
			"FaceDetectorEvent_NO_FACES_DETECTED";
		
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const FACE_CROPED:String =
			"FaceDetectorEvent_FACE_CROPED";
		
		/**
		 * Konstruktor klasy.
		 * Używany do stworzenia obiektu zdażenia (event'u)
		 * zazwyczaj przed jego wysłaniem.
		 *
		 * @param type Typ zdarzenia, które ma zostać utworzone i
		 * jest zdefiniowane w tej klasie
		 * @param bubbles Zmienna kontrolująca sposób propagacji
		 * zdarzenia
		 * @param cancelable Decyduje czy jeden z obiektów
		 * odbierających zdarzenie może je powstrzymać przed
		 * dalszą propagacją
		 *
		 */
		public function FaceDetectorEvent(type:String,
			bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Funkcja nadpisująca już istniejącą funkcje o takiej
		 * samej nazwie w klasie <code>flash.events.Event</code>.
		 * Umożliwia zrobienie kopii obiektu zdarzenia.
		 *
		 * @return Kopia obiektu
		 *
		 */
		public override function clone():Event
		{
			var ev:FaceDetectorEvent =
				new FaceDetectorEvent(type, bubbles, cancelable);
			return ev;
		}
	
	}
}