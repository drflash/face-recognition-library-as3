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
	
	import jp.maaash.ObjectDetection.EyesHaarCascade;
	import jp.maaash.ObjectDetection.FaceHaarCascade;
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;

	/**
	 * @flowerModelElementId _V7EkIPQwEeG4_d92CzHtyg
	 */
	[Event(name="FaceDetector.FACE_CROPPED", type="com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent")]
	[Event(name="FaceDetector.NO_FACES_DETECTED", type="com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent")]
	[Event(name="FaceDetector.FACE_DETECTION_START", type="com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent")]
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
	 * @flowerModelElementId _V7EkIPQwEeG4_d92CzHtyg
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
			initFaceDetector();
			//initEyesDetector();
			
			if (filePath != null)
			{
				loadFaceImageFromUrl(filePath);
			}
		}

		private var __croppedFaces:Vector.<Bitmap> = new Vector.<Bitmap>();
		private var _bmpTarget:Bitmap;
		private var _debug:Boolean = false;
		private var __faceDetector:ObjectDetector;
		private var __eyesDetector:ObjectDetector;
		private var _faceImage:Loader;
		private var _options:ObjectDetectorOptions;
		private var __isBusy:Boolean = false;
		private var __tempFaceImg:Bitmap;

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
			__faceDetector.detect(_bmpTarget.bitmapData);
		}
		
		/**
		 * <p>
		 * EN: Loads image on which face detection will be executed from 
		 * <code>flash.display.BitmapData</code> object.
		 * </p>
		 * 
		 * <p>
		 * PL: Ładuje zdjęcie, które ma zostać poddane detekcji twarzy
		 * z podanego jako parametr obiektu klasy <code>flash.display.BitmapData</code>.
		 * </p>
		 * 
		 * @param faceBitmap Zdjęcie, które ma zostać poddane
		 * procesowi detekcji twarzy.
		 *
		 */
		public function loadFaceImageFromBitmapData(faceBitmapData:BitmapData):void
		{
			//_filePath = null;
			logger("[Rozpoczęcie detekcji twarzy na obrazie załadowanym z obiektu klasy BitmapData]");
			_bmpTarget = new Bitmap(faceBitmapData);
			__faceDetector.detect(faceBitmapData);
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
			if(filePath)
				_faceImage.load(new URLRequest(filePath));
		}

		// Funkcje typu getter i setter.
		public function get objectDetector():ObjectDetector
		{
			return __faceDetector;
		}

		public function set objectDetector(value:ObjectDetector):void
		{
			__faceDetector = value;
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

		private function getFaceDetectorOptions():ObjectDetectorOptions
		{
			_options = new ObjectDetectorOptions;
			_options.min_size = 100;
			_options.search_mode - ObjectDetectorOptions.SEARCH_MODE_NO_OVERLAP;
		
			return _options;
		}
		
		private function getEyesDetectorOptions(x:uint, y:uint, width:uint, height:uint):ObjectDetectorOptions
		{
			_options = new ObjectDetectorOptions;
			_options.scale_factor = 1.2;
			//_options.search_mode = ObjectDetectorOptions.SEARCH_MODE_DEFAULT;
			_options.min_size = 20;
			//_options.startx = x;            /* x = start from leftmost */
		//	_options.starty = y + (height/5.5); /* y = a few pixels from the top */
		//	_options.endx =	width;        /* width = same width with the face */
			//_options.endy = height/2.0;    /* height = 1/2 of face height */
			return _options;
		}

		private function initFaceDetector():void
		{
			__faceDetector = new ObjectDetector(new FaceHaarCascade());
			__faceDetector.options = getFaceDetectorOptions();
			
			__faceDetector.addEventListener(ObjectDetectorEvent.DETECTION_START, function(e:ObjectDetectorEvent):void
			{
				this._isBusy = true;
				dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.FACE_DETECTION_START));
			});
			
			__faceDetector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, function(e:ObjectDetectorEvent):void
			{
				logger("[Odebrano zdarzenie typu ObjectDetectorEvent.COMPLETE]");
				//_detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, arguments.callee);
				var rects:Vector.<Rectangle> = e.rects;
				__croppedFaces = new Vector.<Bitmap>();
				
				if (rects && rects.length > 0)
				{
					for (var i:uint=0; i < rects.length; ++i)
					{
						var r:Rectangle = rects[i];
						// Kopiuje wykadrowaną twarz do zmiennej "cropedFace".
						__croppedFaces[i] = cropImage(_bmpTarget, r.topLeft, r.height, r.width);
						
						//__eyesDetector.options = getEyesDetectorOptions(0, 0, r.width, r.height);
						//croppedFace.bitmapData.fillRect(croppedFace.getRect(croppedFace), 0xFF000000 | uint(Math.random()*255)<<8);
						//__tempFaceImg = cropImage(croppedFace, new Point(0,int(r.height/5.5)), r.height/2.0, r.width);
						//__eyesDetector.detect(__tempFaceImg.bitmapData);
						//break;
					}
					dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.FACE_CROPPED, __croppedFaces, rects));
				}
				else
				{
					dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.NO_FACES_DETECTED));
				}
				this._isBusy = false;
			});
		}
		
		private function initEyesDetector():void
		{
			__eyesDetector = new ObjectDetector(new EyesHaarCascade());
			__eyesDetector.options = getEyesDetectorOptions(	
				ObjectDetectorOptions.INVALID_POS,
				ObjectDetectorOptions.INVALID_POS,
				ObjectDetectorOptions.INVALID_POS,
				ObjectDetectorOptions.INVALID_POS);
			__eyesDetector.addEventListener(ObjectDetectorEvent.DETECTION_START, function(e:ObjectDetectorEvent):void
			{
				this._isBusy = true;
			});
			__eyesDetector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, function(e:ObjectDetectorEvent):void
			{
				//_detector.removeEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, arguments.callee);
				var rects:Vector.<Rectangle> = e.rects;
				
				if (rects)
				{
					for each(var r:Rectangle in rects)
					{
						//croppedFace = cropImage(croppedFace,r.topLeft,r.height,r.width);
						__tempFaceImg.bitmapData.fillRect(r, 0xFF000000 | uint(Math.random()*255)<<16);
						
					}
					trace(rects.length + "\n");
					if(rects.length)
					{
						
						
						//croppedFace = cropImage(croppedFace,rects[0].topLeft,rects[0].height,rects[0].width);
						
						//dispatchEvent(new FaceDetectorEvent(FaceDetectorEvent.FACE_CROPPED, __tempFaceImg, new Rectangle()));
					}
				}
			});
		}

		private function initLoader():void
		{
			_faceImage = new Loader;
			_faceImage.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				startDetection(e.target.loader.content.bitmapData);
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
		private function startDetection(bd:BitmapData):void
		{
			logger("[Wykonuje funkcję startDetection]");
			_bmpTarget = new Bitmap(bd);
			__faceDetector.detect(_bmpTarget.bitmapData);
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

	}
}
