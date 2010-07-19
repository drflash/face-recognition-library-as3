package com.oskarwicha.images.FaceRecognition
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * Rzoszerza klase <code>Bitmap</code> poprzez dodanie funkcji
	 * m.in. normalizującej obraz, zwracającej informacje o
	 * jasności poszczególnych pikseli.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class Picture extends Bitmap
	{
		/**
		 * Konstruktor
		 *
		 * @param bitmapData Zawiera dane obrazu które bedą
		 * przechowwane w obiekcie.
		 *
		 * @see flash.display.Bitmap
		 */
		public function Picture(bitmapData:BitmapData = null)
		{
			var pixelSnapping:String = "auto";
			var smoothing:Boolean = false;
			
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * Zwraca tablice z wartościami jasności poszczególnych
		 * pikseli.
		 *
		 * @return Tablica z wartościami jasności wszystkich
		 * pikseli obrazu. Wartości zapisane są w obiektach
		 * klasy <code>Number</code>
		 */
		public function getImagePixels():Array
		{
			
			var w:int = this.bitmapData.width;
			var h:int = this.bitmapData.height;
			var pixels:Array = new Array(w * h);
			var pixelsBA:ByteArray = new ByteArray();
			
			pixelsBA =
				this.bitmapData.getPixels(new Rectangle(0, 0, w, h));
			
			// Prawda jesli piksele obrazu nie zostały pomyślnie
			// załadowane.
			if (pixelsBA.length == 0)
			{
				trace("Uwaga: Brak pixeli w obiekcie.");
				// Zwraca pustą tablice jeśli piksele nie zostały
				// pomyślnie załadowane
				return new Array();
			}
			
			var ret:Array = new Array(w * h);
			var length:int = ret.length;
			
			pixelsBA.position = 0;
			
			for (var i:int = 0; i < length; i++)
				ret[i] = getLuminosity(pixelsBA);
			
			return ret;
		}
		
		private function getRed(pixel:uint):Number
		{
			return (pixel & (255 << 16)) >> 16;
		}
		
		private function getGreen(pixel:uint):Number
		{
			return (pixel & (255 << 8)) >> 8;
		}
		
		private function getBlue(pixel:uint):Number
		{
			return (pixel & 255);
		}
		
		private function getRGBfromARGB(pixel:uint):Number
		{
			return (pixel & 16777215);
		}
		
		private function getLuminosity(byteArray:ByteArray):Number
		{
			var returnedValue:Number;
			var pixel:uint = byteArray.readUnsignedInt();
			// Kolejne 3 linie kodu odczytują poziomy jasności
			// trzech podstawowych kolorów: czerwonego,
			// zielonego oraz niebieskiego.
			returnedValue = getRed(pixel);
			returnedValue += getGreen(pixel);
			returnedValue += getBlue(pixel);
			// Zsumowana wartość tych barw składowych
			// jest dzielona przez ich ilość w celu otrzymania
			// jasności piksela.
			returnedValue /= 3.0;
			// Zwraca jasność piksela. 
			return returnedValue;
		}
		
		// r = r/(r+g+b)  ... zastosowanie zwieksza skuteczność
		// rozpoznawania
		public function normalize():void
		{
			var w:int = this.bitmapData.width;
			var h:int = this.bitmapData.height;
			var pixelsBA:ByteArray =
				this.bitmapData.getPixels(new Rectangle(0, 0, w,
				h));
			var pixel:uint;
			pixelsBA.position = 0;
			var pixelsBAsize:uint = pixelsBA.bytesAvailable;
			var red:uint = 0;
			var green:uint = 0;
			var blue:uint = 0;
			
			while (pixelsBA.position < pixelsBAsize)
			{
				pixel = pixelsBA.readUnsignedInt();
				red =
					(getRed(pixel) / (getRed(pixel) + getGreen(pixel) + getBlue(pixel)) << 16);
				green =
					(getGreen(pixel) / (getRed(pixel) + getGreen(pixel) + getBlue(pixel)) << 8);
				blue =
					(getBlue(pixel) / (getRed(pixel) + getGreen(pixel) + getBlue(pixel)));
				pixel = red + green + blue;
				// Ustawia pozycje zapisu na pozycje ostatniego odczytu.
				pixelsBA.position -= 1;
				pixelsBA.writeUnsignedInt(pixel);
			}
		}
	
	}
}