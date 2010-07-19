package com.oskarwicha.images.FaceRecognition
{
	import com.oskarwicha.images.FaceDetection.FaceDetector;
	import com.oskarwicha.images.FaceRecognition.Events.FaceEvent;
	import com.oskarwicha.images.FaceRecognition.Events.FaceRecognitionEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Główna klasa w tym pakiecie. Używana jest do
	 * rozpoczęcia ładowania zdjeć do treningu systemu
	 * oraz samego treningu z wykorzystaniem tych zdjęć.
	 * Za jej pośrednictwem inicjowany jest również proces
	 * rozpoznawania nie sklasyfikowanej twarzy z wykorzystaniem
	 * metody wykorzystującej koncepcje Eigenfaces.
	 *
	 *  @author Oskar Wicha
	 *
	 */
	public class FaceRecognition extends EventDispatcher
	{
		/**
		 * Wartość szerokokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_WIDTH:uint = 50;
		
		/**
		 * Wartość wysokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_HEIGHT:uint = 50;
		
		private var ef:EigenFaceGen = new EigenFaceGen();
		
		private var featureSpace:FeatureSpace = new FeatureSpace();
		
		[ArrayElementType("Face")]
		private var facesArray:Array = new Array();
		
		// Zmienna używana żeby wiadome było kiedy wysłać
		// zdarzenie "FaceRecognition_LoadedTrainingFaces".
		private var loadedTrainingFacesCounter:uint;
		
		private var amountOfTrainingFaces:uint;
		
		/**
		 * Konstruktor
		 *
		 * @param target Nie trzeba podawać tego parametru
		 *
		 */
		public function FaceRecognition(target:IEventDispatcher =
			null)
		{
			super(target);
		}
		
		/**
		 * Trenuje system używając do tego celu załadowanych
		 * zdjęć treningowych (do ładowania zdjeć można użyć
		 * funkcji <code>this.loadTrainingFaces</code>) oraz
		 * tekstów identyfikujących właścicieli tych twarzy.
		 *
		 * @param numVecs Ilość tworzonych wektorów. Ta sama
		 * wartoś powinna zostać użyta dla tego parametru co
		 * dla parametru w funkcji <code>this.probe()</code>.
		 */
		public function train(numVecs:int = 10):void
		{
			trace("Trenuje ...");
			ef.processTrainingSet(facesArray, new ProgressTracker());
			var facesArrayLength:uint = facesArray.length;
			var i:uint = 0;
			var f:Face;
			while (i < facesArrayLength)
			{
				f = facesArray[i] as Face;
				var featureVectors:Array =
					ef.getEigenFaces(f.picture, numVecs);
				//trace(featureVectors);
				featureSpace.insertIntoDatabase(f, featureVectors);
				++i;
			}
			trace("Trening zakończony");
			var ev:FaceRecognitionEvent =
				new FaceRecognitionEvent(FaceRecognitionEvent.TRAINED);
			dispatchEvent(ev);
		}
		
		/**
		 * Idefikuje twarz i zwraca obiekt klasy <code>Face</code>
		 * przekazany jako parametr ale z zaktualizowanymi wartościami
		 * <code>classification</code> oraz <code>description</code>.
		 * Identyfikator przypuszczalnego właściciela twarzy jest w
		 * <code>classification</code>.
		 *
		 * @param f Obiekt ze zdjeciem twarzy, która ma zostać
		 * poddana identyfikacji.
		 * @param classthreshold Ilość obiektów klasy
		 * <code>FeatureVector</code> używanych do porównania
		 * (zestaw treningowy musi mieć conajmniej tyle zdjęć
		 * co wartość podana w tym parametrze).
		 * @param numVecs Ilość wektorów. Ta sama wartość musi
		 * zostać podana przy wywołaniu funkcji
		 * <code>this.train()</code>.
		 * @return Obiekt klasy <code>Face</code>
		 * przekazany jako parametr ale z zaktualizowaną wartościa
		 * <code>classification</code> oraz <code>description</code>.
		 * Identyfikator przypuszczalnego właściciela twarzy jest w
		 * <code>probe().classification</code>.
		 */
		public function probe(f:Face, classthreshold:int = 5,
			numVecs:int = 10):Face
		{
			if (!f || !ef)
				return null;
			
			[ArrayElementType("Number")]
			var rslt:Array = ef.getEigenFaces(f.picture, numVecs);
			var fv:FeatureVector = new FeatureVector();
			fv.setFeatureVector(rslt);
			
			[ArrayElementType("Number")]
			var fvtest:Array = fv.getFeatureVector();
			var classification:String =
				featureSpace.knn(FeatureSpace.EUCLIDEAN_DISTANCE,
				fv, classthreshold);
			f.classification = classification;
			f.description = "Twarz do rozpoznania.";
			trace("Twarz zidentyfikowana jako: " + classification);
			var ev:FaceRecognitionEvent =
				new FaceRecognitionEvent(FaceRecognitionEvent.PROBED);
			ev.classification = classification;
			dispatchEvent(ev);
			return f;
		}
		
		/**
		 * Ładuje treningowy zestaw zdjęć twarzy i informacje o nich.
		 *
		 * @param faceClasificationList Tablica z obiektami
		 * <code>String</code> zawierającymi tekst identyfikujący
		 * właściciela twarzy
		 * @param faceUrlList Tablica z obiektami
		 * <code>String</code> zawierającymi adresy url do zdjęć twarzy.
		 *
		 */
		public function loadTrainingFaces(faceClasificationList:Array,
			faceUrlList:Array):void
		{
			var amountOfFacesToBeLoaded:uint = 0;
			
			loadedTrainingFacesCounter = 0;
			amountOfTrainingFaces = 0;
			
			if (faceClasificationList.length == faceUrlList.length)
			{
				amountOfFacesToBeLoaded = faceUrlList.length;
				
				for (var i:uint = 0; i < amountOfFacesToBeLoaded; i++)
				{
					
					var faceUrl:String = faceUrlList[i] as String;
					var faceClasification:String =
						faceClasificationList[i] as String;
					//trace("Klasyfikacja twarzy: " + faceClasification + " adres zdjęcia: " + faceUrl);
					var face:Face = new Face(faceUrl);
					face.classification = faceClasification;
					face.description =
						"Twarz w zestawie treningowym.";
					facesArray.push(face);
					(facesArray[int(facesArray.length - 1)] as Face).addEventListener(FaceEvent.FACE_LOADED,
						onTrainingFaceLoaded);
				}
			}
			else
			{
				trace("Error: Tablice faceClasificationList oraz faceUrlList nie mają tej samej długości.");
			}
		}
		
		private function onTrainingFaceLoaded(e:FaceEvent):void
		{
			loadedTrainingFacesCounter++;
			if (facesArray.length == loadedTrainingFacesCounter)
			{
				var ev:Event =
					new Event(FaceRecognitionEvent.LOADED_TRAINING_FACES);
				dispatchEvent(ev);
			}
		}
	
	}
}