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
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;

	/**
	 * Służy do wykrywania twarzy na podanym zdjęciu.
	 * Po załadowaniu zdjecia i rozpoczęciu detekcji wykadrowany
	 * obraz twarzy zostanie przekazany przez zdarzenie typu
	 * <code>FaceDetectorEvent.FACE_CROPED</code>. Jeśli twarz
	 * nie zostanie wykryta na zdjęciu wysłane zostanie
	 * zdarzenie <code>FaceDetectorEvent.NO_FACES_DETECTED</code>.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class FaceDetector extends EventDispatcher
	{

		//private var _filePath:String;

		/**
		 * Konstruktor
		 *
		 * @param filePath Ścieżka dostępu do pliku ze zdjęciem,
		 * które ma zostac poddane detekcji twarzy.
		 *
		 *
		 */
		public function FaceDetector(filePath:String = null)
		{
			initLoader();
			initDetector();
			if (filePath != null)
			{
				loadFaceImageFromUrl(filePath);
			}
		}

		private var _cropedFace:Bitmap = new Bitmap();

		private var bmpTarget:Bitmap;

		private var debug:Boolean = false;

		private var detector:ObjectDetector;

		private var faceImage:Loader;

		private var options:ObjectDetectorOptions;

		[Inspectable]
		public function get cropedFace():Bitmap
		{
			return _cropedFace;
		}

		public function set cropedFace(value:Bitmap):void
		{
			_cropedFace = value;
			//trace("Wysłano zdarzenie : " + FaceDetectorEvent.FACE_CROPED);
			dispatchEvent(new Event(FaceDetectorEvent.FACE_CROPED));
		}

		/**
		 * Ładuje zdjęcie, które ma zostać poddane detekcji twarzy
		 * z podanego jako parametr obiektu klasy
		 * <code>flash.display.Bitmap</code>.
		 *
		 * @param faceBitmap Zdjęcie które ma zostać poddane
		 * procesowi detekcji twarzy.
		 *
		 */
		public function loadFaceImageFromBitmap(faceBitmap:Bitmap):void
		{
			//_filePath = null;
			logger("[Rozpoczęcie detekcji twarzy na obrazie załadowanym z obiektu klasy Bitmap]");
			bmpTarget = faceBitmap;
			detector.detect(bmpTarget);
		}

		/**
		 * Ładuje zdjęcie, które ma zostać poddane detekcji twarzy
		 * z podanego jako parametr adresu URL.
		 *
		 * @param filePath Adres URL pod, którym dostępne jest
		 * zdjęcie mające zostać poddane procesowi detekcji
		 * twarzy.
		 *
		 */
		public function loadFaceImageFromUrl(filePath:String):void
		{
			//_filePath = filePath;
			faceImage.load(new URLRequest(filePath));
		}

		// Funkcje typu getter i setter.
		public function get objectDetector():ObjectDetector
		{
			return detector;
		}

		public function set objectDetector(value:ObjectDetector):void
		{
			detector = value;
		}

		private function cropImage(loadBitmap:Bitmap, startPoint:Point, heightSize:int, widthSize:int):Bitmap
		{
			var loadBD:BitmapData = loadBitmap.bitmapData;
			// Tworzy nowy obiekt klasy "BitmapData" na podstawie
			// przekazanych przez parametry funkcji danych.
			var cropedBD:BitmapData = new BitmapData(widthSize, heightSize, true, 0x00000000);
			var posPoint:Point = new Point(0, 0);
			// Kopiuje piksele z zaladowanej bitmapy do nowo 
			// utworzonej
			cropedBD.copyPixels(loadBD, new Rectangle(startPoint.x, startPoint.y, widthSize, heightSize), posPoint);
			var cropedBitmap:Bitmap = new Bitmap(cropedBD);
			return cropedBitmap;
		}

		private function getDetectorOptions():ObjectDetectorOptions
		{
			options = new ObjectDetectorOptions;
			options.min_size = 50;
			options.startx = ObjectDetectorOptions.INVALID_POS;
			options.starty = ObjectDetectorOptions.INVALID_POS;
			options.endx = ObjectDetectorOptions.INVALID_POS;
			options.endy = ObjectDetectorOptions.INVALID_POS;
			return options;
		}

		private function initDetector():void
		{
			detector = new ObjectDetector;
			detector.options = getDetectorOptions();
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, function(e:ObjectDetectorEvent):void
			{
				logger("[Odebrano zdarzenie typu ObjectDetectorEvent.COMPLETE]");
				detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, arguments.callee);

				if (e.rects)
				{
					e.rects.forEach(function(r:Rectangle, idx:int, arr:Array):void
					{
						// Kopiuje wykadrowaną twarz do 
						// zmiennej "cropedFace".
						cropedFace = cropImage(bmpTarget, new Point(r.x, r.y), r.height, r.width);
					});
				}
				if (e.rects.length == 0)
				{
					dispatchEvent(new Event(FaceDetectorEvent.NO_FACES_DETECTED));
						//trace("Wysłano zdarzenie : " + FaceDetectorEvent.NO_FACES_DETECTED);
				}
				;
			});
			var events:Array = [ObjectDetectorEvent.DETECTION_START, ObjectDetectorEvent.HAARCASCADES_LOAD_COMPLETE,
								ObjectDetectorEvent.HAARCASCADES_LOADING];
			events.forEach(function(t:String, idx:int, arr:Array):void
			{
				detector.addEventListener(t, function(e:ObjectDetectorEvent):void
				{
					logger("\nCzas: " + (new Date) + " " + e.type);
				});
			});
			// Plik face.zip zawiera wzorce dzieki, którym możliwa
			// jest detekcja twarzy na obrazie.
			detector.loadHaarCascades("face.zip");
		}

		private function initLoader():void
		{
			faceImage = new Loader;
			faceImage.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				startDetection();
			});
		}

		private function logger(... args):void
		{
			if (!debug)
			{
				return;
			}
			log(args);
		}

		// Funkcja używana tylko gdy obraz ładowany jest z pliku
		private function startDetection():void
		{
			logger("[Wykonuje funkcje startDetection]");
			bmpTarget = new Bitmap(new BitmapData(faceImage.width, faceImage.height, false))
			bmpTarget.bitmapData.draw(faceImage);
			detector.detect(bmpTarget);
		}
	}
}