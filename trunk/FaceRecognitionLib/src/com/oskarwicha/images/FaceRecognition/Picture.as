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
		 * Zwraca tablice z wartościami jasności poszczególnych
		 * pikseli.
		 *
		 * @return Tablica z wartościami jasności wszystkich
		 * pikseli obrazu. Wartości zapisane są w obiektach
		 * klasy <code>Number</code>
		 */
		public function getImagePixels():Vector.<Number>
		{
			var pixelsVector:Vector.<uint> = this.bitmapData.getVector(this.bitmapData.rect);

			// Prawda jesli piksele obrazu nie zostały pomyślnie
			// załadowane.
			if (pixelsVector.length == 0)
			{
				trace("Uwaga: Brak pixeli w obiekcie.");
				// Zwraca pustą tablice jeśli piksele nie zostały
				// pomyślnie załadowane
				return new Vector.<Number>();
			}

			return getLuminosity(pixelsVector);
		}

		// r = r*(r/(r+g+b))  ... zastosowanie zwieksza skuteczność
		// rozpoznawania
		internal function normalize():void
		{
			var pixelsVector:Vector.<uint> = this.bitmapData.getVector(this.bitmapData.rect);
			pixelsVector.fixed = true;
			var pixel:uint;
			var red:uint;
			var green:uint;
			var blue:uint;
			var sum:uint;
			var pixelsNormalizedVector:Vector.<uint> = new Vector.<uint>(pixelsVector.length, true);

			var i:int = pixelsVector.length;
			while (i--)
			{
				pixel = pixelsVector[i];
				red = getRed(uint(pixel));
				green = getGreen(uint(pixel));
				blue = getBlue(uint(pixel));
				sum = red + green + blue;

				red = uint((red / sum) * red);
				green = uint((green / sum) * green);
				blue = uint((blue / sum) * blue);

				pixelsNormalizedVector[i] = uint((0xFF000000) | (red << 0x10) | (green << 0x08) | blue); //toARGB(uint(0xFF), red, green, blue);
			}

			this.bitmapData.setVector(this.bitmapData.rect, pixelsNormalizedVector);
		}

		private final function getBlue(pixel:uint):uint
		{
			return uint(pixel & 0x000000FF);
		}

		private final function getGreen(pixel:uint):uint
		{
			return uint((pixel & 0x0000FF00) >> 0x08); //(pixel & (255 << 8)) >> 8;
		}

		private final function getLuminosity(pixelsVector:Vector.<uint>):Vector.<Number>
		{
			var pixel:uint;
			var returnedVector:Vector.<Number> = new Vector.<Number>(pixelsVector.length, true);

			var i:int = pixelsVector.length;
			while (i--)
			{
				pixel = pixelsVector[i];
				// To samo co returnedVector[i] = (getRed(pixel) + getGreen(pixel) + getBlue(pixel))/3;
				// Zsumowana wartość tych barw składowych
				// jest dzielona przez ich ilość w celu otrzymania
				// jasności piksela.
				returnedVector[i] = Number((uint((pixel & 0x00FF0000) >> 0x10) + uint((pixel & 0x0000FF00) >> 0x08) + uint(pixel & 0x000000FF)) / uint(3));
			}
			// Zwraca jasność piksela. 
			return returnedVector;
		}

		private final function getRGBfromARGB(pixel:uint):uint
		{
			return uint(pixel & 0x00FFFFFF);
		}

		private final function getRed(pixel:uint):uint
		{
			return uint((pixel & 0x00FF0000) >> 0x10); //(pixel & (255 << 16)) >> 16;
		}
	}
}