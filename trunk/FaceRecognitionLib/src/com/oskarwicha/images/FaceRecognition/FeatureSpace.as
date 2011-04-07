package com.oskarwicha.images.FaceRecognition
{

	/**
	 * Przechowyje zbiór m.in. wektorów utworzonych w procesie treningu
	 * tworzących przstrzeń cech (ang. feature space).
	 * Umożliwia m.in. znalezienie najbarzdziej podobnego wektora do zadanego
	 * w zbiorze przechowywanym w tej przestrzeni.
	 *
	 * @author Oskar Wicha
	 *
	 */
	public class FeatureSpace
	{
		/**
		 * Definiuje funkcje używaną do obliczania odległości miedzy
		 * dwoma wektorami.
		 *
		 */
		public static var EUCLIDEAN_DISTANCE:IDistanceMeasure = new EuclideanDistance();

		/**
		 * Konstruktor
		 *
		 */
		public function FeatureSpace()
		{
			featureSpace = new Array();
			classifications = new Array();
		}

		[ArrayElementType("String")]
		/**
		 * Tablica z obiektami <code>String</code>
		 *
		 */
		private var classifications:Array;

		//[ArrayElementType("FeatureVector")]
		/**
		 * Tablica z obiektami <code>FeatureVectors<code>
		 *
		 */
		private var featureSpace:Array;

		/**
		 * Sortuje baze w zależności od odległości wektorów w bazie
		 *  w stosunku do wektora rozpoznawanej twarzy.
		 *
		 * @param measure Obiekt zawierający funkcje do pomiaru
		 * dystansu między wektorami.
		 * @param obj Wektor utworzony dla twarzy poddanej rozpoznawaniu
		 * @return Posorotowana tablica obiektów typu fd_pair
		 */
		public function orderByDistance(measure:IDistanceMeasure, obj:FeatureVector):Array
		{
			var orderedList:Array = new Array();
			if (getFeatureSpaceSize() < 1)
				return null;

			const featureSpaceLength:uint = featureSpace.length;
			var dp:Vector.<di_pair> = new Vector.<di_pair>(featureSpaceLength, true);

			// Dla każdego z wektorów w "featureSpace" tworzy 
			// obiek klasy "di_pair" przechowyjący pare obiektów 
			// (jeden klasy FeatureVector i drugi klasy Number z
			// odpowiadającym dla tego wektora dystansem od
			// wektora twarzy rozpoznawanej).
			for (var i:int = 0; i < featureSpaceLength; ++i)
			{
				dp[i] = new di_pair();
				dp[i].obj = featureSpace[i];
				dp[i].dist = measure.DistanceBetween(obj, featureSpace[i]);
			}

			dp.sort(di_pair_compare);

			for each (var dfp:di_pair in dp)
			{
				var fd:fd_pair = new fd_pair();
				fd.face = dfp.obj.getFace();
				fd.dist = dfp.dist;
				orderedList.push(fd);
					//trace(fd.dist);
			}

			return orderedList;
		}

		/**
		 * Zwraca rozmiar tej prestrzeni cech
		 * (ang. feature space)
		 *
		 * @return rozmiar feature space
		 *
		 */
		internal function getFeatureSpaceSize():int
		{
			return featureSpace.length;
		}

		/**
		 * Dodaje obiekt klasy <code>Face</code>  oraz tablice
		 * zawierającą dane wektora do wewnętrznej bazy tego
		 * obiektu klasy <code>FeatureSpace</code>.
		 *
		 * @param face Obiekt twarzy, który ma zostać dodany
		 * @param featureVector Tablica z danymi wektora, które
		 * zostały utworzone w oparciu o obraz przechowywany w
		 * obiekcie twarzy podanym jako pierwszy parametr.
		 *
		 */
		internal function insertIntoDatabase(face:Face, featureVector:Array):void
		{
			// Prawda jeśli tablica classifications nie zawiera
			// takiego obiektu jak face.classification.
			if (classifications.indexOf(face.classification) == -1)
				classifications.push(face.classification);

			var clas:int = classifications.indexOf(face.classification);
			var obj:FeatureVector = new FeatureVector();
			obj.setClassification(clas);
			obj.setFace(face);
			obj.setFeatureVector(featureVector);

			featureSpace.push(obj);
		}

		/**
		 * Z wraca klasyfikacje (ang. classification) twarzy
		 * poddanej rozpoznawaniu.
		 *
		 * @param measure Obiekt zawierający funkcje do pomiaru
		 * dystansu między wektorami
		 * @param obj Wektor do porównania z baza wektorów
		 * @param nn Ilość najbardziej podobnych twarzy w zbiorze,
		 * z których zbioru klasyfikacji poszukiwana jest ta najczęściej
		 * wystepująca klasyfikacja.
		 * @return Obliczona klasyfikacje (ang. classification) twarzy
		 * poddanej rozpoznawaniu.
		 *
		 */
		internal function knn(measure:IDistanceMeasure, obj:FeatureVector, nn:int):String
		{
			if (getFeatureSpaceSize() < 1)
				return null;

			const featureSpaceLength:uint = featureSpace.length;
			var dp:Vector.<di_pair> = new Vector.<di_pair>(featureSpaceLength, true);

			for (var i:int = 0; i < featureSpaceLength; ++i)
			{
				dp[i] = new di_pair();
				dp[i].obj = featureSpace[i];
				dp[i].dist = measure.DistanceBetween(obj, featureSpace[i]);
			}

			dp.sort(di_pair_compare);

			const classificationsLength:uint = classifications.length;
			var accm:Vector.<uint> = new Vector.<uint>(classificationsLength, true);
			accm.length = classificationsLength;
			accm.fixed = true;
			for (i = 0; i < classificationsLength; ++i)
				accm[i] = 0;

			var max:int = 0;
			var ind:int = 0;
			// Znajduje najczęściej występującą klasyfikacje w zbiorze "nn" 
			// najbardziej podobnych twarzy.
			for (i = 0; i < nn; ++i)
			{
				var c:int = dp[i].obj.getClassification();
				accm[c]++;
				if (accm[c] > max)
				{
					max = accm[c];
					ind = c;
				}
			}

			return classifications[ind];
		}

		// Służy do porównaniea dwóch obiektów klasy "di_pair"
		private function di_pair_compare(arg0:Object, arg1:Object):int
		{
			var a:di_pair = di_pair(arg0);
			var b:di_pair = di_pair(arg1);

			return int(a.dist) - int(b.dist);
		}
	}

}

import com.oskarwicha.images.FaceRecognition.Face;
import com.oskarwicha.images.FaceRecognition.FeatureVector;

/* Klasa pomocnicza  */
class di_pair
{
	public var dist:Number;

	public var obj:FeatureVector;
}
;

/* Klasa pomocnicza  */
class fd_pair
{

	public var dist:Number;
	public var face:Face;
}
;