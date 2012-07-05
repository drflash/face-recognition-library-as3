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
	 * @flowerModelElementId _To65kGglEeCqZchJBDddKw
	 */
	public class FaceRecognition extends EventDispatcher
	{

		/**
		 * Wartość wysokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_HEIGHT:uint = 50;
		/**
		 * Wartość szerokokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_WIDTH:uint = 50;

		/**
		 * Konstruktor
		 *
		 * @param target Nie trzeba podawać tego parametru
		 *
		 */
		public function FaceRecognition(target:IEventDispatcher = null)
		{
			super(target);
		}

		private var amountOfTrainingFaces:uint;

		private var ef:EigenFaceGen = new EigenFaceGen();

		private var facesVector:Vector.<Face> = new Vector.<Face>();

		private var featureSpace:FeatureSpace = new FeatureSpace();

		// Zmienna używana żeby wiadome było kiedy wysłać
		// zdarzenie "FaceRecognition_LoadedTrainingFaces".
		private var loadedTrainingFacesCounter:uint;

		public function loadTrainedData():void
		{


		}

		/**
		 * Ładuje treningowy zestaw zdjęć twarzy i informacje o nich.
		 *
		 * @param faceClasificationList Tablica z obiektami
		 * <code>String</code> zawierającymi tekst identyfikujący
		 * właściciela twarzy
		 * @param faceUrlList Tablica z obiektami
		 * <code>String</code> zawierającymi adresy url do zdjęć twarzy.
		 * @exception  IllegalArgumentException Vectors faceClasificationList and faceUrlList lengths must agree.
		 *
		 */
		public function loadTrainingFaces(faceClasificationList:Vector.<String>, faceUrlList:Vector.<String>):void
		{
			var amountOfFacesToBeLoaded:uint = 0;

			loadedTrainingFacesCounter = 0;
			amountOfTrainingFaces = 0;

			if (faceClasificationList.length == faceUrlList.length)
			{
				amountOfFacesToBeLoaded = faceUrlList.length;

				for (var i:uint = 0; i < amountOfFacesToBeLoaded; ++i)
				{
					//trace("Klasyfikacja twarzy: " + faceClasificationList[i] + " adres zdjęcia: " + faceUrlList[i]); //test
					var face:Face = new Face(faceUrlList[i]);
					face.classification = faceClasificationList[i];
					face.description = "Twarz w zestawie treningowym.";
					facesVector[facesVector.length] = face;
					facesVector[uint(facesVector.length - 1)].addEventListener(FaceEvent.FACE_LOADED, onTrainingFaceLoaded);
				}
			}
			else
			{
				throw new Error("Vectors faceClasificationList and faceUrlList lengths must agree.");
			}
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
		public function probe(f:Face, classThreshold:int = 5, numVecs:int = 10):Face
		{
			if (!f || !ef)
				return null;

			var rslt:Vector.<Number> = ef.getEigenFaces(f.picture, numVecs);
			var fv:FeatureVector = new FeatureVector();
			fv.setFeatureVector(rslt);

			var fvtest:Vector.<Number> = fv.getFeatureVector();
			var classification:String = featureSpace.knn(FeatureSpace.EUCLIDEAN_DISTANCE, fv, classThreshold);
			f.classification = classification;
			f.description = "Twarz do rozpoznania.";
			//trace("Twarz zidentyfikowana jako: " + classification); //test
			var ev:FaceRecognitionEvent = new FaceRecognitionEvent(FaceRecognitionEvent.PROBED);
			ev.classification = classification;
			dispatchEvent(ev);
			return f;
		}

		/**
		 * Zwraca tablice z obiektami twarzy w zestawie treningowym
		 * wraz z ich odleglosciami od twarzy podanej jako parametr
		 * <code>f</code>.
		 *
		 * @param f Obiekt ze zdjeciem twarzy, która ma zostać
		 * poddana identyfikacji.
		 * @param numVecs Ilość wektorów. Ta sama wartość musi
		 * zostać podana przy wywołaniu funkcji
		 * <code>this.train()</code>.
		*/
		public function returnDistancesToTrainingFaces(f:Face, numVecs:int = 10):Array
		{
			var rslt:Vector.<Number> = ef.getEigenFaces(f.picture, numVecs);
			var fv:FeatureVector = new FeatureVector();
			fv.setFeatureVector(rslt);
			return featureSpace.orderByDistance(FeatureSpace.EUCLIDEAN_DISTANCE, fv);
		}

		public function saveTrainedData():void
		{
			//trace(this.toString());
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
			trace("Trenuje ..."); //test
			ef.processTrainingSet(facesVector, new ProgressTracker());
			var facesArrayLength:uint = facesVector.length;
			var i:uint = 0;
			var f:Face;
			while (i < facesArrayLength)
			{
				f = facesVector[i];
				featureSpace.insertIntoDatabase(f, ef.getEigenFaces(f.picture, numVecs));
				++i;
			}
			trace("Trening zakończony"); //test
			var ev:FaceRecognitionEvent = new FaceRecognitionEvent(FaceRecognitionEvent.TRAINED);
			dispatchEvent(ev);
		}

		private function onTrainingFaceLoaded(e:FaceEvent):void
		{
			++loadedTrainingFacesCounter;
			if (facesVector.length == loadedTrainingFacesCounter)
			{
				dispatchEvent(new Event(FaceRecognitionEvent.LOADED_TRAINING_FACES));
			}
		}
	}
}