package com.oskarwicha.images.FaceRecognition
{
	import com.oskarwicha.images.FaceDetection.Events.FaceDetectorEvent;
	import com.oskarwicha.images.FaceDetection.FaceDetector;
	import com.oskarwicha.images.FaceRecognition.Events.FaceEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	/**
	 * Zawiera zdjecie twarzy oraz tekst identyfikujący jej
	 * właściciela (jeśli znany). Umożliwia załadowanie zdjęcia
	 * twarzy z pliku jpeg, png lub z obiektu klasy
	 * <code>flash.display.Bitmap</code>.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class Face extends EventDispatcher
	{

		/**
		 * Konstruktor
		 *
		 * @param faceUrl Adres url do zdjęcia twarzy
		 * @param faceClasification Tekst identyfikujący
		 * właściciela twarzy jesli znany
		 * @cropFaceFromImg Używa detekcji twarzy do jej
		 * wykadrowania ze zdjęcia (NOT TESTED)
		 */
		public function Face(faceUrl:String = null, faceClasification:String = null, cropFaceFromImg:Boolean = false)
		{
			//TO:DO przydało by sie zwracać błąd
			// jesli podano zły adres url
			_classification = faceClasification;
			_description = "";
			_faceUrl = faceUrl;

			if (_faceUrl != null)
				loadFromUrl(cropFaceFromImg);
		}

		// Przechowuje tekst identyfikujący wlaściciela twarzy,
		// której zdjęcie zawarte jest w obiekcie "_picture".
		private var _classification:String;

		private var _crop:Boolean = false;

		private var _description:String;

		/* Ponizsze obiekty prywatne nie mają funkcji
		   umożliwiających do nich dostęp publiczny.
		 */
		private var _faceUrl:String;

		private var _globalwindowsize:int = 5;

		private var _imgLoader:Loader = new Loader();

		private const _normalize:Boolean = true;

		/* Poniższe trzy obiekty posiadają specjalne funkcje
		   (ang. getters oraz ang. setters) umozliwiające
		   publiczny dostęp do tych obiektów.
		 */
		private var _picture:Picture;

		/**
		 * Tekst identyfikujący właściciela twarzy
		 * jeśli jest on znany.

		 * @return String
		 *
		 */
		public function get classification():String
		{
			return _classification;
		}

		public function set classification(value:String):void
		{
			_classification = value;
		}

		/**
		 * Tekst zawierający dodatkowy opis.
		 *
		 * @return Face description
		 *
		 */
		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		/**
		 * Umożliwia detekcje twarzy w ładowanym do obiektu zdjęciu.
		 *
		 * @param im Bitmapa zawierająca zdjęcie
		 *
		 */
		public function detectFaceInPicture(source:Bitmap, destination:Bitmap):void
		{
			var faceDetector:FaceDetector = new FaceDetector();

			faceDetector.addEventListener(FaceDetectorEvent.NO_FACES_DETECTED, function onNoFacesDetected(e:Event):void
			{
				trace("Uwaga: Twarz nie znaleziona na zdjęciu");
			});
			faceDetector.addEventListener(FaceDetectorEvent.FACE_CROPED, function(e:Event):void
			{
				destination = faceDetector.cropedFace;
				trace("Sukces: Twarz znaleziona i wykadrowana");
				trace("Wymiary kadrowanej twarzy: " + destination.height + "x" + destination.width);
			});

			faceDetector.loadFaceImageFromBitmap(source);

		}

		/**
		 * Ładuje zdjęcie twarzy z obiekt klasy
		 * <code>flash.display.Bitmap</code>.
		 * W celu załadowania zdjęcia bezpośrednio
		 * z pliku należy użyć konstruktora klasy i
		 * podać odpowiednie dane w parametrach.
		 *
		 * @param faceBitmap Obiekt zawierający zdjęcie twarzy
		 * @param crop Jeśli ma wartość <code>false</code> to
		 * zdjęcie nie zozstanie poddane wykrywaniu i kadrowaniu
		 * twarzy (należy używać gdy zdjęcia przeszły juz ten
		 * proces wcześniej). Jesli ma wartość <code>true</code>
		 * to zdjęcie zostananie poddane procesowi detekcji twarzy
		 * w obrazie a następnie twarz zostanie wykadrowana.
		 *
		 */
		public function loadFaceImageFromBitmap(faceBitmap:Bitmap, crop:Boolean = false):void
		{
			_crop = crop;

			if (_crop)
				detectFaceInPicture(faceBitmap, faceBitmap);
			var rim:Bitmap = this.resizeImage(faceBitmap, new Rectangle(0, 0, FaceRecognition.IDEAL_IMAGE_WIDTH, FaceRecognition.IDEAL_IMAGE_HEIGHT), true);
			// Przypisuje załadowane zdjęcie twarzy do 
			// publicznej zmiennej "picture" tej klasy. 
			this.picture = new Picture(rim.bitmapData);
			// Normalizacja obrazu.
			if (_normalize)
				this.picture.normalize();
			// Wysyła zdarzenie (ang. event) zawierające referencje
			// do obiektu z załadowaną twarza.
			var ev:FaceEvent = new FaceEvent(FaceEvent.FACE_LOADED);
			ev.face = this;
			dispatchEvent(ev);
		}

		//Setters/Getters

		/**
		 * Zdjęcie twarzy
		 *
		 * @return Picture
		 *
		 */
		public function get picture():Picture
		{
			return _picture;
		}

		public function set picture(value:Picture):void
		{
			_picture = value;
		}

		private function loadFromUrl(crop:Boolean = false):void
		{
			_crop = crop;
			_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startPreprocessingLoadedImageFromUrl);
			//trace(_faceUrl);
			_imgLoader.load(new URLRequest(_faceUrl));
		}

		/**
		 * Skaluje obraz z możliwościa zachowaniem stosunku boków.
		 *
		 * @param origB Originalny obrazr
		 * @param box Rozmiar, do którego ma oryginał być
		 * przeskalowany
		 * @param fitOutside Jeśli przyjmuje wartość
		 * <code>true</code> obraz zostanie przeskalowany by
		 * wypełniał w całości obiekt <code>box</code>
		 * a wszystkie piksele wychodzace poza zostaną
		 * usunięte z wyniku funkcji. Jeśli przyjmuje
		 * warość <code>false</code> obraz zostanie tak
		 * przeskalowany by w całości zmieścił sie w
		 * <code>box</code> a puste obszary obiektu
		 * <code>box</code> zostaną wypełnione czarnymi pikselami.
		 * @return Obraz przeskalowany do zadanego rozmiaru.
		 */
		private function resizeImage(origB:Bitmap, box:Rectangle, fitOutside:Boolean):Bitmap
		{
			var origBD:BitmapData = origB.bitmapData;
			var resizedBD:BitmapData = new BitmapData(box.width, box.height, true, 0x00000000);
			var matrix:Matrix = new Matrix();

			var xRatio:Number = box.width / Number(origBD.width);
			var yRatio:Number = box.height / Number(origB.height);

			var ratio:Number;

			if (fitOutside)
				ratio = Math.max(xRatio, yRatio);
			else
				ratio = Math.min(xRatio, yRatio);

			var wNew:int = int((origBD.width * ratio));
			var hNew:int = int((origBD.height * ratio));
			var x:int;
			var y:int;

			x = int(Math.round((box.width - wNew) * 0.5));
			y = int(Math.round((box.height - hNew) * 0.5));

			var clipRect:Rectangle = new Rectangle(x, y, wNew, hNew);

			matrix.scale(ratio, ratio);
			var resizedB:Bitmap = new Bitmap();

			resizedBD.draw(origBD, matrix, null, null, clipRect, true);
			resizedB.bitmapData = resizedBD;

			return resizedB;
		}

		private function startPreprocessingLoadedImageFromUrl(e:Event):void
		{
			var imb:Bitmap = new Bitmap(new BitmapData(_imgLoader.width, _imgLoader.height, false))
			imb.bitmapData.draw(_imgLoader);
			if (_crop)
				detectFaceInPicture(imb, imb);
			var rim:Bitmap = this.resizeImage(imb, new Rectangle(0, 0, FaceRecognition.IDEAL_IMAGE_WIDTH, FaceRecognition.IDEAL_IMAGE_HEIGHT), true);
			// Przypisuje załadowany i zmniejszony obraz twarzy
			// do zmiennej publicznej "picture" tej klasy 
			this.picture = new Picture(rim.bitmapData);
			// Normalizacja obrazu.
			if (_normalize)
				this.picture.normalize();
			// Wysyła zdarzenie (ang. event) zawierające referencje,
			// do obiektu z załadowaną twarzą.
			var ev:FaceEvent = new FaceEvent(FaceEvent.FACE_LOADED);
			ev.face = this;
			dispatchEvent(ev);
			//trace("Sukces - Face.loadFromUrl");
		}
	}
}