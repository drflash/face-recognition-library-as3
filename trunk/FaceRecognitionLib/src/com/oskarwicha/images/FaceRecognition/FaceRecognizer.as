package com.oskarwicha.images.FaceRecognition
{
	import com.oskarwicha.images.FaceRecognition.Events.FaceEvent;
	import com.oskarwicha.images.FaceRecognition.Events.FaceRecognizerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 * @flowerModelElementId _V8YywPQwEeG4_d92CzHtyg
	 */
	[Event(name="FaceRecognitionEvent.LOADED_TRAINING_FACES", type="com.oskarwicha.images.FaceRecognition.Events.FaceRecognizerEvent")]
	[Event(name="FaceRecognitionEvent.PROBED", type="com.oskarwicha.images.FaceRecognition.Events.FaceRecognizerEvent")]
	[Event(name="FaceRecognitionEvent.TRAINED", type="com.oskarwicha.images.FaceRecognition.Events.FaceRecognizerEvent")]
	
	/**
	 * <p>
	 * EN: Main class in this package. You should use it
	 * to load face images to be used in system training
	 * then train the system. When system is trained then
	 * method <code>probe</code> should be used to recognize
	 * a face with unknown classification.
	 * </p>
	 * 
	 * <p>
	 * PL: Główna klasa w tym pakiecie. Używana jest do
	 * rozpoczęcia ładowania zdjęć do treningu systemu
	 * oraz samego treningu z wykorzystaniem tych zdjęć.
	 * Za jej pośrednictwem inicjowany jest również proces
	 * rozpoznawania nie sklasyfikowanej twarzy z wykorzystaniem
	 * metody wykorzystującej koncepcje Eigenfaces.
	 * </p>
	 * @author Oskar Wicha
	 *
	 * @flowerModelElementId _To65kGglEeCqZchJBDddKw
	 */
	public class FaceRecognizer extends EventDispatcher implements IExternalizable
	{
		/**
		 * Wartość wysokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_HEIGHT:uint = 48;
		/**
		 * Wartość szerokokości, do której skalowane są
		 * wszystkie zdjecia twarzy.
		 */
		public static const IDEAL_IMAGE_WIDTH:uint = 48;
		
		private var __faceUrlList : Vector.<String>;
		private var __faceClassificationList : Vector.<String>;
		private var __detectFaces : Boolean;
		private var __isTrained:Boolean = false;
		private var __isBusy:Boolean = false;
		private var __numVecs:uint = 10;
		/**
		 * @flowerModelElementId _V8b2EvQwEeG4_d92CzHtyg
		 */
		private var __ef:EigenFaceGen;
		/**
		 * @flowerModelElementId _V8cdIPQwEeG4_d92CzHtyg
		 */
		private var __facesVector:Vector.<Face>;
		/**
		 * @flowerModelElementId _V8cdIfQwEeG4_d92CzHtyg
		 */
		private var __featureSpace:FeatureSpace;
		
		// Zmienna używana żeby wiadome było kiedy wysłać
		// zdarzenie "FaceRecognition_LoadedTrainingFaces".
		private var __loadedTrainingFacesCounter:uint;
		
		/**
		 * Konstruktor
		 *
		 */
		public function FaceRecognizer()
		{
			super(null);
			registerClassAlias("Face", Face);
			registerClassAlias("FeatureSpace", FeatureSpace);
			registerClassAlias("KMatrix", KMatrix);
			registerClassAlias("EigenFaceGen", EigenFaceGen);
			registerClassAlias("FaceRecognition", FaceRecognizer);
		}
		
		/**
		 * <p>
		 * EN: Not implemented yet
		 * </p>
		 * <p>
		 * PL: Jeszcze nie zaimplementowana funkcja
		 * </p>
		 */
		public function loadModel(bytes:ByteArray):FaceRecognizer
		{
			var faceRec:FaceRecognizer = (bytes.readObject() as FaceRecognizer);
			
			this.__ef = faceRec.__ef;
			this.__featureSpace = faceRec.__featureSpace;
			this.__faceClassificationList = faceRec.__faceClassificationList;
			this.__detectFaces = faceRec.__detectFaces;
			this.__faceUrlList = faceRec.__faceUrlList;
			this.__isTrained = faceRec.isTrained;
			
			return faceRec;
		}
		
		/**
		 * <p>
		 * EN: Returns "model" created during training procedure. 
		 * Eliminates need for training the system every time it is restarted.
		 * To load model use function <code>loadModel</code>.
		 * </p>
		 * <p>
		 * PL: Zwraca "model" storzony podczas procesu treningu systemu. Model
		 * ten może zoastać zapisany np. w bazie danych a nastepnie załadowany
		 * przy użyciu funkcji <code>loadModel</code>.
		 * </p>
		 */
		public function get model():ByteArray
		{
			if(!this.isTrained)
			{
				throw new Error("Error: FaceRecognizer is not trained so there is no working model.");
				return null;
			}
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(this);
			bytes.position = 0;
			return bytes;
		}
		
		/**
		 * <p>
		 * EN: Returns list o faces in training set having classifiaction
		 * passed as parameter.
		 * </p>
		 * <p>
		 * PL: Zwraca listę twarzy w zestawie treningowym posiadających 
		 * taką samą klasyfikację jak przekazana przez parametr.
		 * </p>
		 */
		public function getFacesWithClassification(classification : String):Vector.<Face>
		{
			var numOfFaces:uint = __facesVector.length;
			var faces:Vector.<Face> = new Vector.<Face>();
			
			for(var i:uint = 0; i< numOfFaces; ++i)
				if(__facesVector[i].classification == classification)
					faces[faces.length] = __facesVector[i];
			
			return faces;
		}
		
		/**
		 * <p>
		 * EN: Loads training set of face images and their classifications.
		 * </p>
		 * <p>
		 * PL: Ładuje treningowy zestaw zdjęć twarzy i informacje o nich.
		 * </p>
		 * 
		 * @param faceClassificationList 
		 * <p>
		 * EN: Vector with objects of type <code>String</code> containing
		 * text identifying owner of the face.
		 * </p>
		 * <p>
		 * PL: Wektor z obiektami <code>String</code> zawierającymi tekst
		 * identyfikujący właściciela twarzy
		 * </p>
		 * @param faceUrlList 
		 * <p>
		 * EN: Vector with object of type <code>String</code> containing
		 * URLs to face images in training set.
		 * </p>
		 * <p>
		 * PL: Wektor z obiektami <code>String</code> zawierającymi
		 * adresy url do zdjęć twarzy w zestawie treningowym.
		 * </p>
		 * @param detectFaces 
		 * <p>
		 * EN: If <code>true</code> images are going to undergo face 
		 * detection process after which faces will be cropped. It slows
		 * training process significantly.
		 * </p>
		 * <p>
		 * PL: Jeśli <code>true</code> zdjęcia zostają poddane detekcji
		 * twarzy a nastepnie wykadrowaniu tak by zawierały tylko twarze. Znacząco 
		 * spowalnia proces ładowania zdjęć.
		 * </p>
		 * 
		 * @exception  Vectors faceClasificationList and faceUrlList lengths must agree.
		 *
		 */
		public function loadTrainingFaces(faceClassificationList:Vector.<String>,
										  faceUrlList:Vector.<String>,
										  detectFaces:Boolean = false):void
		{
			var amountOfFacesToBeLoaded:uint = 0;
			__facesVector = new Vector.<Face>();
			__featureSpace = new FeatureSpace();
			
			if(faceUrlList.length != faceClassificationList.length)
			{
				throw new Error("Error: The number of images URLs (faceUrlList) must" +
					" be equal to the number of classification (faceClassificationList)!" +
					"len(faceUrlList)=" + faceUrlList.length + "len(faceClassificationList)=" +
					faceClassificationList.length);
				return;
			}
			
			if(faceUrlList.length == 0)
			{
				throw new Error("Error: Empty training data was given. You'll need more than one" +
					" sample to learn a model.");
				return;
			}
			
			__faceClassificationList = faceClassificationList;
			__faceUrlList = faceUrlList;
			__detectFaces = detectFaces;
			__loadedTrainingFacesCounter = 0;
			
			if (faceClassificationList.length == __faceUrlList.length)
			{
				if (__loadedTrainingFacesCounter < __faceUrlList.length)
				{
					var face:Face = new Face(
						__faceUrlList[__loadedTrainingFacesCounter],
						__faceClassificationList[__loadedTrainingFacesCounter],
						__detectFaces);
					
					face.description = "Face in a training set";
					face.addEventListener(FaceEvent.FACE_LOADED, onTrainingFaceLoaded);
					trace("Face images loading started");
				}
				
				/*for (var i:uint = 0; i < amountOfFacesToBeLoaded; ++i)
				{
				//trace("Klasyfikacja twarzy: " + faceClasificationList[i] + " adres zdjęcia: " + faceUrlList[i]); //test
				var face:Face = new Face(_faceUrlList[i], _faceClasificationList[i], detectFaces);
				face.description = "Face in a training set";
				face.addEventListener(FaceEvent.FACE_LOADED, onTrainingFaceLoaded);
				facesVector[facesVector.length] = face;
				}*/
			}
			else
			{
				throw new Error("Vectors faceClasificationList and faceUrlList lengths must agree.");
			}
		}
		
		/**
		 * <p>
		 * EN: Identyfies face and returns <code>Face</code> object
		 * passed as parameter but with updated values of 
		 * <code>classification</code> and <code>description</code>. 
		 * </p>
		 * <p>
		 * PL: Idefikuje twarz i zwraca obiekt klasy <code>Face</code>
		 * przekazany jako parametr ale z zaktualizowanymi wartościami
		 * <code>classification</code> oraz <code>description</code>.
		 * Identyfikator przypuszczalnego właściciela twarzy jest w
		 * <code>classification</code>.
		 * </p>
		 * 
		 * @param f 
		 * <p>
		 * EN: Object with image of face that will undergo recognition
		 * process.
		 * </p>
		 * <p>
		 * PL: Obiekt ze zdjeciem twarzy, która ma zostać poddana
		 * identyfikacji.
		 * </p>
		 * @param classthreshold 
		 * <p>
		 * EN: Number of <code>FeatureVector</code> objects to be used
		 * in comparision process.
		 * </p>
		 * <p>
		 * PL: Ilość obiektów klasy <code>FeatureVector</code> używanych
		 * do porównania.
		 * </p>
		 * @param distanceTreshold 
		 * <p>
		 * EN: Images from training set distent form probed image more than
		 * this value will not be used. If default value is used most 
		 * similar face clasyfication will always be returned. If you want
		 * classification to be returned only if system is realy sure of its 
		 * clasification determination than use value between 30000 - 100000.
		 * </p>
		 * <p>
		 * PL: Obrazy z zestawu treningowego
		 * odległe o więcej niż tą wartość zostają pominięte.
		 * </p>
		 * @return 
		 * <p>
		 * EN: Object of class <code>Face</code> passed as parameter
		 * with updated <code>classifiaction</code> property 
		 * (<code>null</code> if face not recognized).
		 * </p>
		 * <p>
		 * PL: Obiekt klasy <code>Face</code>
		 * przekazany jako parametr ale z zaktualizowaną wartościa
		 * <code>classification</code> oraz <code>description</code>.
		 * Identyfikator przypuszczalnego właściciela twarzy jest w
		 * <code>probe().classification</code>. Zwracana jest wartość
		 * <code>null</code> jeśli nie zidentyfikowano twarzy.
		 * </p>
		 */
		public function probe(f:Face, classThreshold:uint = 5, distanceTreshold:Number = Number.MAX_VALUE):Face
		{
			if (!f || !__ef)
				return null;
			
			if(!this.isTrained)
			{
				throw new Error("Error: This Eigenfaces model is not computed yet. Did you call train()?");
				return null;
			}
			
			var rslt:Vector.<Number> = __ef.getEigenFaces(f.picture, __numVecs);
			var fv:FeatureVector = new FeatureVector();
			fv.featureVectorData = rslt;
			var recognizedAs:DiPair = __featureSpace.knn(FeatureSpace.EUCLIDEAN_DISTANCE, fv, classThreshold, distanceTreshold);
			if(recognizedAs == null)
			{
				f.description = "Face not recognized";
				return null;
			}
			else
			{
				f.description = "Face recognized";
			}
			
			f.classification = recognizedAs.fVec.face.classification;
			
			var ev:FaceRecognizerEvent = new FaceRecognizerEvent(FaceRecognizerEvent.PROBED);
			ev.classification = recognizedAs.fVec.face.classification;
			ev.distance = recognizedAs.dist;
			dispatchEvent(ev);
			return f;
		}
		
		/**
		 * <p>
		 * EN: Returns vector of <code>FdPair</code> objects sorted by distance to 
		 * <code>Face</code> object passed as param <code>f</code>.
		 * </p>
		 * <p>
		 * PL: Zwraca tablice z obiektami twarzy w zestawie treningowym
		 * wraz z ich odleglosciami od twarzy podanej jako parametr
		 * <code>f</code>.
		 * </p>
		 * 
		 *
		 * @param f 
		 * <p>
		 * EM: Object with face image to be used in face recognition attempt.
		 * </p>
		 * <p>
		 * PL: Obiekt ze zdjeciem twarzy, która ma zostać
		 * poddana identyfikacji.
		 * </p>
		 * @returns 
		 * <p>
		 * EN: Vector with <code>FdPair/<code> objecs, sorted base on distance values.
		 * </p>
		 * <p>
		 * PL: Wektor z obiektami <code>FdPair/<code>, posortowany na podstawie dystansu.
		 * </p>
		 */
		public function getDistancesToTrainingFaces(f:Face):Vector.<FdPair>
		{
			if (!f || !__ef || !__numVecs || !__ef.isTrained())
				return null;
			
			var fv:FeatureVector = new FeatureVector();
			fv.featureVectorData = __ef.getEigenFaces(f.picture, __numVecs);
			return __featureSpace.orderByDistance(FeatureSpace.EUCLIDEAN_DISTANCE, fv);
		}
		
		/**
		 * <p>
		 * EN: Trains system using face images (to load images 
		 * use <code>this.loadTrainingFaces</code> function)
		 * and texts identyfying owners of those faces. 
		 * </p>
		 * <p>
		 * PL: Trenuje system używając do tego celu załadowanych
		 * zdjęć treningowych (do ładowania zdjeć można użyć
		 * funkcji <code>this.loadTrainingFaces</code>) oraz
		 * tekstów identyfikujących właścicieli tych twarzy.
		 * </p>
		 *
		 * @param numVecs
		 * <p>
		 * EN: Number of vectors to be created.
		 * </p>
		 * <p>
		 * PL: Ilość tworzonych wektorów.
		 * </p>
		 */
		public function train(numVecs:uint = 10):void
		{
			trace("Training ..."); //test
			__ef = new EigenFaceGen();
			
			if(numVecs > 0)
				__numVecs = numVecs;
			else
				throw new Error("Error: numVecs must be more than 0");
			
			this._isBusy = true;
			__ef.processTrainingSet(__facesVector, new ProgressTracker());
			var facesArrayLength:uint = __facesVector.length;
			var i:uint = 0;
			var f:Face;
			var eigenFaces:Vector.<Number>;
			
			this._isTrained = false;
			while (i < facesArrayLength)
			{
				f = __facesVector[i++];
				eigenFaces = __ef.getEigenFaces(f.picture, __numVecs);
				__featureSpace.insertIntoDatabase(f, eigenFaces);
			}
			this._isTrained = true;
			this._isBusy = false;
		}
		
		private function onTrainingFaceLoaded(e:FaceEvent):void
		{
			(e.target as Face).removeEventListener(FaceEvent.FACE_LOADED, arguments.callee);
			__facesVector[__facesVector.length] = (e.target as Face);
			
			if (++__loadedTrainingFacesCounter < __faceUrlList.length)
			{
				var face:Face = new Face(
					__faceUrlList[__loadedTrainingFacesCounter],
					__faceClassificationList[__loadedTrainingFacesCounter],
					__detectFaces);
				
				face.description = "Face in a training set";
				face.addEventListener(FaceEvent.FACE_LOADED, onTrainingFaceLoaded);
				//trace(".");
			}
			
			if (__loadedTrainingFacesCounter == __faceUrlList.length)
			{
				trace(__loadedTrainingFacesCounter + " face images loaded");
				dispatchEvent(new Event(FaceRecognizerEvent.LOADED_TRAINING_FACES));
			}
		}
		
		public function writeExternal(output:IDataOutput):void
		{			
			//output.writeUnsignedInt(FaceRecognizer.IDEAL_IMAGE_HEIGHT);
			//output.writeUnsignedInt(FaceRecognizer.IDEAL_IMAGE_WIDTH);
			output.writeBoolean(__isTrained);
			output.writeObject(__featureSpace);
			output.writeObject(__ef);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			//if(input.readUnsignedInt() == FaceRecognizer.IDEAL_IMAGE_HEIGHT ||
			//  input.readUnsignedInt() == FaceRecognizer.IDEAL_IMAGE_WIDTH)
			{
				__isTrained = input.readBoolean();
				__featureSpace = input.readObject() as FeatureSpace;
				__ef = input.readObject() as EigenFaceGen;
			}
		}
		
		[Bindable(event="isBusyChange")]
		public function get isBusy():Boolean
		{
			return this._isBusy;
		}
		
		protected function get _isBusy():Boolean
		{
			return __isBusy;
		}
		
		protected function set _isBusy(value:Boolean):void
		{
			if(__isBusy !== value)
			{
				__isBusy = value;
				dispatchEvent(new Event("isBusyChange"));
			}
		}
		
		public function get isTrained():Boolean
		{
			return this._isTrained;
		}
		
		protected function get _isTrained():Boolean
		{
			return __isTrained;
		}
		
		protected function set _isTrained(value:Boolean):void
		{
			if(__isTrained !== value)
				__isTrained = value;
			
			if(__isTrained)
			{
				trace("Trained"); //test
				dispatchEvent(new FaceRecognizerEvent(FaceRecognizerEvent.TRAINED));
			}
		}
		
	}
}