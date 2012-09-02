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
	 * @flowerModelElementId _TqiDIGglEeCqZchJBDddKw
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
		 * Zwraca wektor z wartościami jasności poszczególnych
		 * pikseli.
		 *
		 * @return Tablica z wartościami jasności wszystkich
		 * pikseli obrazu. Wartości zapisane są w obiektach
		 * klasy <code>Number</code>
		 */
		public function getImagePixels():Vector.<Number>
		{
			var pixelsVector:Vector.<uint> = this.bitmapData.getVector(this.bitmapData.rect);

			if( pixelsVector.length != 0 )
			{
				return getLuminositys(pixelsVector);
			}
		    else //jesli piksele obrazu nie zostały pomyślnie załadowane.
			{
				trace("Warning: No pixel in object.");
				// Zwraca pustą tablice jeśli piksele nie zostały
				// pomyślnie załadowane
				return new Vector.<Number>();
			}
		}

		// r = r*(r/(r+g+b))  ... zastosowanie zwieksza skuteczność
		// rozpoznawania
		internal function normalize():void
		{
			this.bitmapData.lock();
			var imgSize:Rectangle = this.bitmapData.rect;
			var pixelsVector:Vector.<uint> = this.bitmapData.getVector(imgSize);
			var pixel:uint;
			var red:uint;
			var green:uint;
			var blue:uint;
			var sum:uint;
			var pixelsNormalizedVector:Vector.<uint> = new Vector.<uint>(pixelsVector.length, true);

			var i:uint = pixelsVector.length;
			while (i--)
			{
				pixel = pixelsVector[i];
				red   = uint((pixel & 0x00FF0000) >> 0x10); // getRed(uint(pixel));
				green = uint((pixel & 0x0000FF00) >> 0x08); // getGreen(uint(pixel));
				blue  = uint(pixel & 0x000000FF); 			// getBlue(uint(pixel));
				sum   = red + green + blue;

				red   = uint((red / sum) * red);
				green = uint((green / sum) * green);
				blue  = uint((blue / sum) * blue);

				pixelsNormalizedVector[i] = uint((0xFF000000) | uint(red << 0x10) | uint(green << 0x08) | blue); //toARGB(uint(0xFF), red, green, blue);
			}

			this.bitmapData.setVector(imgSize, pixelsNormalizedVector);
			this.bitmapData.unlock();
		}

		private function getLuminositys(pixelsVector:Vector.<uint>):Vector.<Number>
		{
			var pixel:uint;
			var returnedVector:Vector.<Number> = new Vector.<Number>(pixelsVector.length, true);

			var val:uint;
			var i:uint = pixelsVector.length;
			while (i--)
			{
				pixel = pixelsVector[i];
				// To samo co returnedVector[i] = (getRed(pixel) + getGreen(pixel) + getBlue(pixel))/3;
				// Zsumowana wartość tych barw składowych jest dzielona przez
				// ich ilość w celu otrzymania jasności piksela.
				val  = uint((pixel & 0x00FF0000) >> 0x10);
				val += uint((pixel & 0x0000FF00) >> 0x08);
				val += uint(pixel & 0x000000FF);
				returnedVector[i] = Number(val) / 3.0;
			}
			// Zwraca jasność piksela. 
			return returnedVector;
		}

		private static function getRGBfromARGB(pixel:uint):uint
		{
			return uint(pixel & 0x00FFFFFF);
		}

		private static function getRed(pixel:uint):uint
		{
			return uint((pixel & 0x00FF0000) >> 0x10); //(pixel & (255 << 16)) >> 16;
		}
		
		private static function getGreen(pixel:uint):uint
		{
			return uint((pixel & 0x0000FF00) >> 0x08); //(pixel & (255 << 8)) >> 8;
		}
		
		private static function getBlue(pixel:uint):uint
		{
			return uint(pixel & 0x000000FF);
		}
	}
}