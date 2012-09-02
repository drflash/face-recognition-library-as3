package com.oskarwicha.images.FaceRecognition.Events
{
	import flash.events.Event;
	
	/**
	 * Klasa definiująca zdarzenia wysyłane przez obiekty klasy
	 * <code>FaceRecognizer</code> gdy zakonczy się proces treningu,
	 * gdy zakonczy sie rozpoznawanie twarzy.
	 * 
	 * @author OscylO
	 * 
	 * @flowerModelElementId _TlRvsGglEeCqZchJBDddKw
	 */
	public class FaceRecognizerEvent extends Event
	{
		/**
		 * Zmienna używana do przekazania klasyfikacji obiektu
		 * klasy <code>Face</code> uzyskanej w procesie
		 * rozpoznawania. Warość ustawiana przed wysłaniem
		 * zdarzenia typu <code>FaceRecognitionEvent.PROBED</code>.
		 *
		 */
		public var classification:String = null;
		
		/**
		 * <p>
		 * EN: Small values mean high certainty of correct recognition.
		 * </p>
		 */
		public var distance:Number = Number.MAX_VALUE; 
		
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const TRAINED:String =
			"FaceRecognitionEvent_TRAINED";
		
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const PROBED:String =
			"FaceRecognitionEvent_PROBED";
		
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const LOADED_TRAINING_FACES:String =
			"FaceRecognitionEvent_LOADED_TRAINING_FACES";
		
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
		public function FaceRecognizerEvent(type:String,
			bubbles:Boolean = false, cancelable:Boolean = false)
		{
			// Używa konstruktora klasy, od której dziedziczy czyli
			// flash.events.Event w celu stworzenia podstawowego obiektu
			// zdarzenia.
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
			var ev:FaceRecognizerEvent =
				new FaceRecognizerEvent(type, bubbles, cancelable);
			ev.classification = classification;
			return ev;
		}
	
	}
}