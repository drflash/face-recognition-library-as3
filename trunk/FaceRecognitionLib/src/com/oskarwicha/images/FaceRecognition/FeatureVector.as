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

		/**
		 * Konstruktor
		 *
		 */
		public function FeatureVector()
		{
			//puste
		}

		private var classification:int;

		private var face:Face;

		[ArrayElementType("Number")]
		private var featureVector:Array;

		/**
		 * Liczba stałoprzecinkowa identyfikująca wektor.
		 *
		 * @return Klasyfikacja wektora
		 *
		 */
		internal function getClassification():int
		{
			return classification;
		}

		/**
		 * Obiekt klasy <code>Face</code> używany do obliczenia
		 * faktycznych danch tego wektora.
		 *
		 * @return Obiekt zawierający twarz przechowywaną w tym
		 * obiekcie <code>FeatureVector<code>.
		 *
		 */
		internal function getFace():Face
		{
			return face;
		}

		/**
		 * Tablica z danymi numerycznymi tworzącymi ten wektor.
		 *
		 * @return Tablica z obiektami typu <code>Number</code>.
		 *
		 */
		internal function getFeatureVector():Array
		{
			return featureVector;
		}

		/**
		 * Ustawia klasyfikacje wektora.
		 *
		 * @param classification Klasyfikacja wektora.
		 *
		 */
		internal function setClassification(classification:int):void
		{
			this.classification = classification;
		}

		/**
		 * Ustawia biekt klasy <code>Face</code> używany do
		 * obliczenia faktycznych danch tego wektora.
		 *
		 * @param face
		 *
		 */
		internal function setFace(face:Face):void
		{
			this.face = face;
		}

		/**
		 * Ustawia tablice z danymi numerycznymi tworzącymi ten
		 * wektor.
		 *
		 * @param featureVector Tablica z obiektami typu
		 * <code>Number</code>.
		 *
		 */
		internal function setFeatureVector(featureVector:Array):void
		{
			this.featureVector = featureVector;
		}
	}
}