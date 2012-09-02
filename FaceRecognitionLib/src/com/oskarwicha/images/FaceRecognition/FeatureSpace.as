package com.oskarwicha.images.FaceRecognition
{
	import flash.net.registerClassAlias;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	/**
	 * Przechowyje zbiór m.in. wektorów utworzonych w procesie treningu
	 * tworzących przstrzeń cech (ang. feature space).
	 * Umożliwia m.in. znalezienie najbarzdziej podobnego wektora do zadanego
	 * w zbiorze przechowywanym w tej przestrzeni.
	 *
	 * @author Oskar Wicha
	 *
	 * @flowerModelElementId _TpbP4GglEeCqZchJBDddKw
	 */
	public class FeatureSpace implements IExternalizable
	{
		/**
		 * Definiuje funkcje używaną do obliczania odległości miedzy
		 * dwoma wektorami.
		 * 
		 * @flowerModelElementId _V8ti4PQwEeG4_d92CzHtyg
		 */
		public static var EUCLIDEAN_DISTANCE:IDistanceMeasure = new EuclideanDistance();

		/**
		 * Konstruktor
		 *
		 */
		public function FeatureSpace()
		{
			registerClassAlias("FeatureVector", FeatureVector);
			__featureSpace = new Vector.<FeatureVector>();
			__classifications = new Vector.<String>();
		}

		/**
		 * Wektor z obiektami <code>String</code>
		 *
		 */
		private var __classifications:Vector.<String>;

		/**
		 * Wektor z obiektami <code>FeatureVectors<code>
		 * 
		 * @flowerModelElementId _V8ti5fQwEeG4_d92CzHtyg
		 */
		private var __featureSpace:Vector.<FeatureVector>;
		
		/**
		 * Sortuje baze w zależności od odległości wektorów w bazie
		 * w stosunku do wektora rozpoznawanej twarzy.
		 *
		 * @param measure Obiekt zawierający funkcje do pomiaru
		 * dystansu między wektorami.
		 * @param obj Wektor utworzony dla twarzy poddanej rozpoznawaniu
		 * @return Posorotowany wektor obiektów typu <code>FdPair</code>
		 */
		internal function orderByDistance(measure:IDistanceMeasure, fv:FeatureVector):Vector.<FdPair>
		{
			/*if(!isItCorrectFeatureVectorsLength(fv.featureVectorData.length))
				throw new Error("Error: Incorrect value of fv.featureVectorData.length." +
					" All vectors in FeatureSpace need to have equal lengths");*/
			
			var orderedList:Vector.<FdPair> = new Vector.<FdPair>();
			if (this.size < 1)
				return null;

			var featureSpaceLength:uint = __featureSpace.length;
			var dp:Vector.<DiPair> = new Vector.<DiPair>(featureSpaceLength, true);
			var dpi:DiPair;

			// Dla każdego z wektorów w "featureSpace" tworzy 
			// obiek klasy "DiPair" przechowyjący pare obiektów 
			// (jeden klasy FeatureVector i drugi klasy Number z
			// odpowiadającym dla tego wektora dystansem od
			// wektora twarzy rozpoznawanej).
			for (var i:uint = 0; i < featureSpaceLength; ++i)
			{
				dp[i] = dpi = new DiPair();
				dpi.dist = measure.distanceBetween(fv, dpi.fVec = __featureSpace[i]);
			}

			dp.sort(DiPair.compare);

			i = featureSpaceLength;
			while (i--)
			{
				var fd:FdPair = orderedList[i] = new FdPair();
				dpi = dp[i];
				fd.face = dpi.fVec.face;
				fd.dist = dpi.dist;
			    //trace(fd.dist + " -  " + fd.face.classification);
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
		internal function get size():uint
		{
			return __featureSpace.length;
		}
		
		private function isItCorrectFeatureVectorsLength(length:uint):Boolean
		{
			if(__featureSpace.length)
				return __featureSpace[0].featureVectorData.length == length;
			else
				return true;
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
		internal final function insertIntoDatabase(face:Face, featureVector:Vector.<Number>):void
		{
			/*if(!isItCorrectFeatureVectorsLength(featureVector.length))
				throw new Error("Error: Incorrect value of featureVector.length." +
					" All vectors in FeatureSpace need to have equal lengths");*/
			
			// Prawda jeśli tablica classifications nie zawiera
			// takiego obiektu jak face.classification.
			if (__classifications.indexOf(face.classification) == -1)
				__classifications[__classifications.length] = face.classification;

			var clas:int = __classifications.indexOf(face.classification);
			var obj:FeatureVector = new FeatureVector();
			obj.featureVectorData = featureVector;
			obj.classification = clas;
			obj.face = face;
			__featureSpace[__featureSpace.length] = obj;
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
		internal final function knn(measure:IDistanceMeasure, obj:FeatureVector, nn:uint, distTreshold:Number):DiPair
		{
			if (!__featureSpace.length)
				return null;
			
			/*if(!isItCorrectFeatureVectorsLength(obj.featureVectorData.length))
				throw new Error("Error: Incorrect value of obj.featureVectorData.length." +
					" All vectors in FeatureSpace need to have equal lengths");*/
			
			var featureSpaceLength:uint = __featureSpace.length;
			var dp:Vector.<DiPair> = new Vector.<DiPair>(featureSpaceLength, true);
			var dpi:DiPair;
			
			for (var i:int = 0; i < featureSpaceLength; ++i)
			{
				dp[i] = dpi = new DiPair();
				dpi.fVec = __featureSpace[i];
				dpi.dist = measure.distanceBetween(obj, dpi.fVec);
			}

			dp.sort(DiPair.compare);

			var classificationsLength:uint = __classifications.length;
			var accm:Vector.<uint> = new Vector.<uint>(classificationsLength, true);
			var max:uint = 0;
			var ind:int = -1;
			var closest:uint;
			
			if(nn > featureSpaceLength) 
				nn = featureSpaceLength;
			
			// Znajduje najczęściej występującą klasyfikacje w zbiorze "nn" 
			// najbardziej podobnych twarzy.
			for (i = nn-1; i >= 0; --i)
			{
				dpi = dp[i];
				
				if(dpi.dist > distTreshold)
					continue;
				
				var c:uint = dpi.fVec.classification;
				
				if (++accm[c] > max)
				{
					max = accm[ind = c];
					closest = i;
				}
			}
			
			if(ind != -1)
				return dp[closest];
			else
				return null;
		}
		
		// IExtensible implementation
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(__classifications);
			output.writeObject(__featureSpace);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			__classifications = Vector.<String>(input.readObject());
			__featureSpace = Vector.<FeatureVector>(input.readObject());
		}
	}
}