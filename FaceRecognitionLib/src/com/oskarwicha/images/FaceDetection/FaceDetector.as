package com.oskarwicha.images.FaceDetection
{
	import com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import jp.maaash.ObjectDetection.HaarCascade;
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;

	/**
	 * <p>
	 * EN: Detects one face on image which path was passed to 
	 * constructor. To get image with cropped face you have to
	 * listen to <code>FaceDetectorEvent.FACE_CROPED</code>
	 * event. If face hasn't been detected 
	 * <code>FaceDetectorEvent.NO_FACES_DETECTED</code> event
	 * is disspatched.
	 * </p>
	 * 
	 * <p>
	 * PL: Służy do wykrywania twarzy na podanym zdjęciu.
	 * Po załadowaniu zdjecia i rozpoczęciu detekcji wykadrowany
	 * obraz twarzy zostanie przekazany przez zdarzenie typu
	 * <code>FaceDetectorEvent.FACE_CROPED</code>. Jeśli twarz
	 * nie zostanie wykryta na zdjęciu wysłane zostanie
	 * zdarzenie <code>FaceDetectorEvent.NO_FACES_DETECTED</code>.
	 * </p>
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class FaceDetector extends EventDispatcher
	{

		//private var _filePath:String;

		/**
		 * <p>
		 * EN: Constructor
		 * </p>
		 * 
		 * <p>
		 * PL: Konstruktor
		 * </p>
		 * 
		 * @param filePath 
		 * <p>
		 * EN: Path to image file on witch FaceDetector
		 * will look for face
		 * </p>
		 * 
		 * <p>
		 * PL: Ścieżka dostępu do pliku ze zdjęciem,
		 * które ma zostać poddane detekcji twarzy.
		 * </p>
		 * 
		 */
		public function FaceDetector(filePath:String = null)
		{
			initLoader();
			initDetector();
			_debug = true;
			
			if (filePath != null)
			{
				loadFaceImageFromUrl(filePath);
			}
		}

		private var _cropedFace:Bitmap = new Bitmap();
		private var _bmpTarget:Bitmap;
		private var _debug:Boolean = false;
		private var _detector:ObjectDetector;
		private var _faceImage:Loader;
		private var _options:ObjectDetectorOptions;

		[Inspectable]
		public function get cropedFace():Bitmap
		{
			return _cropedFace;
		}

		public function set cropedFace(value:Bitmap):void
		{
			_cropedFace = value;
			//trace("Wysłano zdarzenie : " + FaceDetectorEvent.FACE_CROPED);
			dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.FACE_CROPPED));
		}

		/**
		 * <p>
		 * EN: Loads image on which face detection will be executed from 
		 * <code>flash.display.Bitmap</code> object.
		 * </p>
		 * 
		 * <p>
		 * PL: Ładuje zdjęcie, które ma zostać poddane detekcji twarzy
		 * z podanego jako parametr obiektu klasy <code>flash.display.Bitmap</code>.
		 * </p>
		 * 
		 * @param faceBitmap Zdjęcie, które ma zostać poddane
		 * procesowi detekcji twarzy.
		 *
		 */
		public function loadFaceImageFromBitmap(faceBitmap:Bitmap):void
		{
			//_filePath = null;
			logger("[Rozpoczęcie detekcji twarzy na obrazie załadowanym z obiektu klasy Bitmap]");
			_bmpTarget = faceBitmap;
			_detector.detect(_bmpTarget);
		}

		/**
		 * <p>
		 * EN: Loads image on which face detection will be executed from URL.
		 * </p>
		 * 
		 * <p>
		 * PL: Ładuje zdjęcie, które ma zostać poddane detekcji twarzy
		 * z podanego jako parametr adresu URL.
		 * </p>
		 * 
		 * @param filePath Adres URL pod, którym dostępne jest
		 * zdjęcie mające zostać poddane procesowi detekcji
		 * twarzy.
		 *
		 */
		public function loadFaceImageFromUrl(filePath:String):void
		{
			//_filePath = filePath;
			_faceImage.load(new URLRequest(filePath));
		}

		// Funkcje typu getter i setter.
		public function get objectDetector():ObjectDetector
		{
			return _detector;
		}

		public function set objectDetector(value:ObjectDetector):void
		{
			_detector = value;
		}

		private function cropImage(loadBitmap:Bitmap, startPoint:Point, heightSize:int, widthSize:int):Bitmap
		{
			// Tworzy nowy obiekt klasy "BitmapData" na podstawie
			// przekazanych przez parametry funkcji danych.
			var cropedBD:BitmapData = new BitmapData(widthSize, heightSize, true, 0);
			// Kopiuje piksele z zaladowanej bitmapy do nowo 
			// utworzonej
			cropedBD.copyPixels(loadBitmap.bitmapData, new Rectangle(startPoint.x, startPoint.y, widthSize, heightSize), new Point(0, 0));

			return new Bitmap(cropedBD); //croped Bitmap
		}

		private function getDetectorOptions(useSoloMode:Boolean = false):ObjectDetectorOptions
		{
			_options = new ObjectDetectorOptions;
			_options.min_size = 50;
			_options.startx = ObjectDetectorOptions.INVALID_POS;
			_options.starty = ObjectDetectorOptions.INVALID_POS;
			_options.endx = ObjectDetectorOptions.INVALID_POS;
			_options.endy = ObjectDetectorOptions.INVALID_POS;
			
			if(useSoloMode)
				_options.search_mode = ObjectDetectorOptions.SEARCH_MODE_SOLO;

			return _options;
		}

		private function initDetector():void
		{
			_detector = new ObjectDetector;
			_detector.options = getDetectorOptions();
			_detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, function(e:ObjectDetectorEvent):void
			{
				logger("[Odebrano zdarzenie typu ObjectDetectorEvent.COMPLETE]");
				//_detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, arguments.callee);

				if (e.rects)
				{
					e.rects.forEach(function(r:Rectangle, idx:int, arr:Array):void
					{
						// Kopiuje wykadrowaną twarz do 
						// zmiennej "cropedFace".
						cropedFace = cropImage(_bmpTarget, new Point(r.x, r.y), r.height, r.width);
					});
				}
				
				if (e.rects.length == 0)
				{
					dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.NO_FACES_DETECTED));
						//trace("Wysłano zdarzenie : " + FaceDetectorEvent.NO_FACES_DETECTED);
				}
			});
			
			/*var events:Array = [ObjectDetectorEvent.DETECTION_START, ObjectDetectorEvent.HAARCASCADES_LOAD_COMPLETE,
								ObjectDetectorEvent.HAARCASCADES_LOADING];
			
			events.forEach(function(t:String, idx:int, arr:Array):void
			{
				_detector.addEventListener(t, function(e:ObjectDetectorEvent):void
				{
					logger("\nCzas: " + (new Date) + " " + e.type);
				});
			});*/
			
			// Plik face.zip zawiera wzorce dzieki, którym możliwa
			// jest detekcja twarzy na obrazie.
			_detector.loadHaarCascades("face.zip");
		}

		private function initLoader():void
		{
			_faceImage = new Loader;
			_faceImage.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				startDetection();
			});
		}

		private function logger(... args):void
		{
			if (!_debug)
			{
				return;
			}
			log(args);
		}

		// Funkcja używana tylko gdy obraz ładowany jest z pliku
		private function startDetection():void
		{
			logger("[Wykonuje funkcje startDetection]");
			_bmpTarget = new Bitmap(new BitmapData(_faceImage.width, _faceImage.height, false))
			_bmpTarget.bitmapData.draw(_faceImage);
			_detector.detect(_bmpTarget);
		}
	}
}
