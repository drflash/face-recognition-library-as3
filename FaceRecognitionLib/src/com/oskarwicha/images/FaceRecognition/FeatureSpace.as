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
	public class FeatureSpace implements DistanceMeasure
	{
		/**
		 * Definiuje funkcje używaną do obliczania odległości miedzy
		 * dwoma wektorami.
		 *
		 */
		public static var EUCLIDEAN_DISTANCE:DistanceMeasure =
			DistanceMeasure(new FeatureSpace);
		
		/**
		 * Oblicza dystans miądzy dwoma wektorami przechowywanymi
		 * w obiektach klasy <code>FeatureVector</code>.
		 * Funkcja niezbedna w celu implementacji interfejsu
		 * <code>DistanceMeasure</code>.
		 *
		 * @param fv1 Pierwszy z wektorów
		 * @param fv2 Drugi z wektorów
		 * @return Dystans miedzy wektorem <code>fv1</code> a
		 * <code>fv2</code>
		 *
		 */
		public function DistanceBetween(fv1:FeatureVector,
			fv2:FeatureVector):Number
		{
			var num:int = fv1.getFeatureVector().length;
			num =
				(fv2.getFeatureVector().length > num ? fv2.getFeatureVector().length : num);
			var dist:Number = 0;
			for (var i:int = 0; i < num; i++)
			{
				dist +=
					((fv1.getFeatureVector()[i] - fv2.getFeatureVector()[i]) * (fv1.getFeatureVector()[i] - fv2.getFeatureVector()[i]));
			}
			trace("Odległość miedzy wektorami = " + Math.sqrt(dist));
			return Math.sqrt(dist);
		}
		
		[ArrayElementType("FeatureVector")]
		/**
		 * Tablica z obiektami <code>FeatureVectors<code>
		 *
		 */
		private var featureSpace:Array;
		
		[ArrayElementType("String")]
		/**
		 * Tablica z obiektami <code>String</code>
		 *
		 */
		private var classifications:Array;
		
		/**
		 * Konstruktor
		 *
		 */
		public function FeatureSpace()
		{
			featureSpace = new Array();
			classifications = new Array();
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
		public function insertIntoDatabase(face:Face,
			featureVector:Array):void
		{
			// Prawda jeśli tablica classifications nie zawiera
			// takiego obiektu jak face.classification.
			if (classifications.indexOf(face.classification) == -1)
				classifications.push(face.classification);
			
			var clas:int =
				classifications.indexOf(face.classification);
			var obj:FeatureVector = new FeatureVector();
			obj.setClassification(clas);
			obj.setFace(face);
			obj.setFeatureVector(featureVector);
			
			featureSpace.push(obj);
		}
		
		// Służy do porównaniea dwóch obiektów klasy "di_pair"
		private function di_pair_compare(arg0:Object,
			arg1:Object):int
		{
			var a:di_pair = di_pair(arg0);
			var b:di_pair = di_pair(arg1);
			
			return int(a.dist) - int(b.dist);
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
		public function knn(measure:DistanceMeasure,
			obj:FeatureVector, nn:int):String
		{
			if (getFeatureSpaceSize() < 1)
				return null;
			var ret:String = "";
			
			var dp:Array = new Array(featureSpace.length);
			
			for (var i:int = 0; i < featureSpace.length; i++)
			{
				dp[i] = new di_pair();
				dp[i].obj = featureSpace[i];
				dp[i].dist =
					measure.DistanceBetween(obj, featureSpace[i]);
			}
			
			dp.sort(di_pair_compare);
			
			var accm:Array = new Array(classifications.length);
			for (i = 0; i < classifications.length; i++)
				accm[i] = 0;
			
			var max:int = 0;
			var ind:int = 0;
			// Znajduje najczęściej występującą klasyfikacje w zbiorze "nn" 
			// najbardziej podobnych twarzy.
			for (i = 0; i < nn; i++)
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
		
		/**
		 * Sortuje baze w zależności od odległości wektorów w bazie
		 *  w stosunku do wektora rozpoznawanej twarzy.
		 *
		 * @param measure Obiekt zawierający funkcje do pomiaru
		 * dystansu między wektorami.
		 * @param obj Wektor utworzony dla twarzy poddanej rozpoznawaniu
		 * @return Posorotowana tablica obiektów typu fd_pair
		 */
		public function orderByDistance(measure:DistanceMeasure,
			obj:FeatureVector):Array
		{
			var orderedList:Array = new Array();
			if (getFeatureSpaceSize() < 1)
				return null;
			
			var dp:Array = new Array(featureSpace.length);
			
			// Dla każdego z wektorów w "featureSpace" tworzy 
			// obiek klasy "di_pair" przechowyjący pare obiektów 
			// (jeden klasy FeatureVector i drugi klasy Number z
			// odpowiadającym dla tego wektora dystansem od
			// wektora twarzy rozpoznawanej).
			for (var i:int = 0; i < featureSpace.length; i++)
			{
				dp[i] = new di_pair();
				dp[i].obj = featureSpace[i];
				dp[i].dist =
					measure.DistanceBetween(obj, featureSpace[i]);
			}
			
			dp.sort(di_pair_compare);
			
			for each (var dfp:di_pair in dp)
			{
				var fd:fd_pair = new fd_pair();
				fd.face = dfp.obj.getFace();
				fd.dist = dfp.dist;
				orderedList.push(fd);
			}
			
			return orderedList.toArray(new fd_pair[0]);
		}
		
		/**
		 * Zwraca rozmiar tej prestrzeni cech
		 * (ang. feature space)
		 *
		 * @return rozmiar feature space
		 *
		 */
		public function getFeatureSpaceSize():int
		{
			return featureSpace.length;
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
	public var face:Face;
	
	public var dist:Number;
}
;