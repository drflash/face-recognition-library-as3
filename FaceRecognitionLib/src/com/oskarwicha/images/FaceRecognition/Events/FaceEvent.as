package com.oskarwicha.images.FaceRecognition.Events
{
	import com.oskarwicha.images.FaceRecognition.Face;
	
	import flash.events.Event;
	
	/**
	 * Klasa zdarzenia wysyłanego przez obiekty klasy
	 * <code>Face</code>, gdy zdjęcie twarzy zostanie
	 * pomyślnie załadowane przez obiekt.
	 * 
	 * @author Oskar Wicha
	 * 
	 * @flowerModelElementId _TlH-sGglEeCqZchJBDddKw
	 */
	public class FaceEvent extends Event
	{
		/**
		 * Zmienna wskazująca na opiekt klasy Face,
		 * który dokonał pomyslnego załadowania
		 * zdjęcia twarzy.
		 */
		public var face:Face;
		
		/**
		 * Publiczna stała statyczna przechowyjąca
		 * tekst używany do identyfikacji typu
		 * zdarzenia (event'u).
		 *
		 */
		public static const FACE_LOADED:String = "FaceEvent_FACE_LOADED";
		
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
		 * @flowerModelElementId _TlMQIWglEeCqZchJBDddKw
		 */
		public function FaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
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
			var ev:FaceEvent =	new FaceEvent(type, bubbles, cancelable);
			ev.face = face;
			return ev;
		}
	
	}
}