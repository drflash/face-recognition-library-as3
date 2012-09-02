package com.oskarwicha.images.FaceRecognition
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

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
	 * @flowerModelElementId _TpndIGglEeCqZchJBDddKw
	 */
	internal class FeatureVector implements IExternalizable
	{
		/**
		 * Konstruktor
		 *
		 */
		public function FeatureVector()
		{
		}

		private var __classification:uint;
		/**
		 * @flowerModelElementId _V82s0vQwEeG4_d92CzHtyg
		 */
		private var __face:Face;
		private var __featureVectorData:Vector.<Number>;

		/**
		 * Liczba stałoprzecinkowa identyfikująca wektor.
		 *
		 * @return Klasyfikacja wektora
		 *
		 */
		internal function get classification():uint
		{
			return __classification;
		}

		/**
		 * Obiekt klasy <code>Face</code> używany do obliczenia
		 * faktycznych danch tego wektora.
		 *
		 * @return Obiekt zawierający twarz przechowywaną w tym
		 * obiekcie <code>FeatureVector<code>.
		 *
		 */
		internal function get face():Face
		{
			return __face;
		}

		/**
		 * Tablica z danymi numerycznymi tworzącymi ten wektor.
		 *
		 * @return Tablica z obiektami typu <code>Number</code>.
		 *
		 */
		internal function get featureVectorData():Vector.<Number>
		{
			return __featureVectorData;
		}

		/**
		 * Ustawia klasyfikacje wektora.
		 *
		 * @param classification Klasyfikacja wektora.
		 *
		 */
		internal function set classification(classification:uint):void
		{
			__classification = classification;
		}

		/**
		 * Ustawia biekt klasy <code>Face</code> używany do
		 * obliczenia faktycznych danch tego wektora.
		 *
		 * @param face
		 *
		 */
		internal function set face(face:Face):void
		{
			__face = face;
		}

		/**
		 * Ustawia tablice z danymi numerycznymi tworzącymi ten
		 * wektor.
		 *
		 * @param featureVector Tablica z obiektami typu
		 * <code>Number</code>.
		 *
		 */
		internal function set featureVectorData(featureVector:Vector.<Number>):void
		{
			__featureVectorData = featureVector;
		}
		
		// IExtensible implementation
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUnsignedInt(__classification);
			output.writeObject(__featureVectorData);
			output.writeObject(__face);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			__classification = input.readUnsignedInt();
			__featureVectorData = Vector.<Number>(input.readObject());
			__face = input.readObject() as Face;
		}
	}
}