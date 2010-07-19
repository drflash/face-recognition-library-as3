package com.oskarwicha.images.FaceRecognition
{
	
	/**
	 * Klasa ta zawiera : </br>
	 * Tablica <code>featureVector</code> za faktycznymi danymi wektora
	 * Obiekt klasy <code>Face</code> z użyciem którego
	 * obrazu twarzy zostają generowane dane w
	 * <code>featureVector</code>.
	 * Liczbe stałoprzecinkową z klasyfikacją wektora .
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class FeatureVector
	{
		
		[ArrayElementType("Number")]
		private var featureVector:Array;
		
		private var classification:int;
		
		private var face:Face;
		
		/**
		 * Konstruktor
		 *
		 */
		public function FeatureVector()
		{
			//puste
		}
		
		/**
		 * Liczba stałoprzecinkowa identyfikująca wektor.
		 *
		 * @return Klasyfikacja wektora
		 *
		 */
		public function getClassification():int
		{
			return classification;
		}
		
		/**
		 * Ustawia klasyfikacje wektora.
		 *
		 * @param classification Klasyfikacja wektora.
		 *
		 */
		public function setClassification(classification:int):void
		{
			this.classification = classification;
		}
		
		/**
		 * Tablica z danymi numerycznymi tworzącymi ten wektor.
		 *
		 * @return Tablica z obiektami typu <code>Number</code>.
		 *
		 */
		public function getFeatureVector():Array
		{
			return featureVector;
		}
		
		/**
		 * Ustawia tablice z danymi numerycznymi tworzącymi ten
		 * wektor.
		 *
		 * @param featureVector Tablica z obiektami typu
		 * <code>Number</code>.
		 *
		 */
		public function setFeatureVector(featureVector:Array):void
		{
			this.featureVector = featureVector;
		}
		
		/**
		 * Obiekt klasy <code>Face</code> używany do obliczenia
		 * faktycznych danch tego wektora.
		 *
		 * @return Obiekt zawierający twarz przechowywaną w tym
		 * obiekcie <code>FeatureVector<code>.
		 *
		 */
		public function getFace():Face
		{
			return face;
		}
		
		/**
		 * Ustawia biekt klasy <code>Face</code> używany do
		 * obliczenia faktycznych danch tego wektora.
		 *
		 * @param face
		 *
		 */
		public function setFace(face:Face):void
		{
			this.face = face;
		}
	}
}