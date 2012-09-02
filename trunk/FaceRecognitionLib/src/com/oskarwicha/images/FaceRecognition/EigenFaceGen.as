package com.oskarwicha.images.FaceRecognition
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	/**
	 * Klasa tworzy eigenfaces z obrazów twarzy.
	 *
	 * @author Oskar Wicha
	 *
	 * @flowerModelElementId _Tlw34GglEeCqZchJBDddKw
	 */
	internal class EigenFaceGen implements IExternalizable
	{
		/**
		 * Konstruktor
		 */
		public function EigenFaceGen()
		{
			//puste
		}

		// Średnia twarz uzywana podczas treningu
		private var __averageFace:KMatrix;

		// Posorotwane wartości uzyskane w procesie treningu.
		private var __eigValues:KMatrix;

		// Posortowane wektory uzyskane w procesie treningu.
		private var __eigVectors:KMatrix;

		// Ilość używanych wektorów.
		private var _numOfEigenVecs:uint = 0;

		// Jesli proces treningu zakonczył się powodzeniem przyjmuje
		// wartość "true".
		private var __trained:Boolean = false;

		/**
		 * Zwraca wartości eigenface dla zdjęcia
		 * twarzy przekazangeo za pomocą parametru <code>pic</code>.
		 * Zwracane wartości używane są w feature space czyli przestrzeni cech.
		 *
		 * @param pic Zdjęcie twarzy
		 * @param number Ilość obliczanych wartości eigen faces.
		 * @return Wartości eigen face jako obiekty typu <code>Number</code>
		 * w tabeli o długości równej wartości parametru <code>number</code>
		 * lub <code>this.getNumEigenVecs</code> w zależności, która z tych
		 * wartości jest mniejsza
		 */
		internal final function getEigenFaces(pic:Picture, number:uint):Vector.<Number>
		{
			if (!pic || !__eigVectors)
				return null;

			// Dostosowuje wartość zmiennej "number" ażeby była równa lub 
			// mniejsza od ilości dostępnych wektorów
			if (number > _numOfEigenVecs)
				number = _numOfEigenVecs;

			var ret:Vector.<Number> = new Vector.<Number>(number, true);
			var pictureVector:Vector.<Number> = pic.getImagePixels();

			// Konwertuje macierz o wymiarach np. 50x50 do 1x2500
			var face:KMatrix = KMatrix.makeFromColumnPackedVector(pictureVector, pictureVector.length);
			var vecs:KMatrix = __eigVectors.getMatrixWithRange(0, uint(__eigVectors.getRowDimension() - 1), 0, uint(number - 1)).transpose();
			var rslt:KMatrix = vecs.times(face);

			return rslt.getColAsVector(0, number);
		}

		/**
		 * Informuje jak wiele eigen vectors (wektorów) zostalo
		 * utworzonych podczas ostatniego procesu treningu.
		 *
		 * @return Liczba wygenereowanych eigen vectors (wektorów)
		 *
		 */
		internal function getNumEigenVecs():uint
		{
			return _numOfEigenVecs;
		}

		/**
		 * Informuje czy obiekt tej klasy
		 * (<code>EigenFaceGen</code>) przeszedł proces treningu.
		 *
		 * @return <code>True</code> jeśli ten obiekt klasy
		 * <code>EigenFaceGen</code> wykonał z powodzeniem proces
		 * treningu
		 *
		 */
		internal function isTrained():Boolean
		{
			return __trained;
		}

		/**
		 *  Rozpoczyna analize treningowego zestawu zdjęć.
		 * 	Potrafi zająć troche czasu.
		 *
		 * @param faces Tablica z obiektami klasy <code>Face</code> uzywanymi do treningu systemu
		 * @param progress Obiekt zarządzający informacjami o postępie treningu
		 */
		internal final function processTrainingSet(faces:Vector.<Face>, progress:ProgressTracker):void
		{
			/**
			 * KROK 1
			 * Wczytanie zdjęć i zapisanie w postaci jednego
			 * wiersza wartości a następnie załadowanie do
			 * dużej macierzy.
			 *
			 */
			progress.advanceProgress("Creating matrix...");
			
			var i:uint = faces.length;
			var dpix:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(i, true);
			
			while (i--)
			{
				var pic:Picture = faces[i].picture;
				// Wykonywane dla każdego zdjęcia twarzy w zestawie.
				dpix[i] = pic.getImagePixels();
			}
			// Tworzy obiekt KMatrix ze zbioru wektorów jednowierszowych zawierających
			// wszystkie obrazy twarzy z testowego zestawu.
			var matrix:KMatrix = KMatrix.makeFromVector(dpix);

			/**
			 * KROK 2
			 * Obliczanie średniej twarzy a następnie odjęcie jej
			 * od każdej z twarzy w zestawie treningowym w celu
			 * obliczenia różnic między twarzami w zestawie
			 * treningowym a średnią twarzą.
			 *
			 */
			progress.advanceProgress("Calculating average face...");
			
			var matrixColumnDimension:int = matrix.getColumnDimension();
			var matrixRowDimension:int = matrix.getRowDimension();
			var amountOfFacesInverted:Number = Number(1.0 / Number(matrix.getRowDimension()));
			
			__averageFace = new KMatrix(1, matrixColumnDimension);
			
			i = matrixRowDimension;
			while (i--)
				__averageFace.plusEquals(matrix.getRow(i));

			// Końcowy etap obliczania średniej twarzy
			// przez pomnożenie przez odwrotność ilości
			// twarzy w zestawie. 
			__averageFace.timesEquals(amountOfFacesInverted);
			var bigAvg:KMatrix = matrix.copyEmpty();
			var bigAvgColumnDimensionMinusOne:int = int(bigAvg.getColumnDimension() - 1);

			i = bigAvg.getRowDimension();
			while (i--)
				bigAvg.setMatrixWithRange(i, i, 0, bigAvgColumnDimensionMinusOne, __averageFace);

			// Oblicza dla każdej twarzy w zestawie różnice 
			// między nią a średnią twarzą.
			var A:KMatrix = matrix.minus(bigAvg);
			A = A.transpose();

			/**
			 * KROK 3
			 * Obliczanie macierzy kowariancji.
			 *
			 */
			progress.advanceProgress("Calculating covariance matrix...");
			var At:KMatrix = A.transpose();
			var L:KMatrix = At.times(A);

			/**
			 * KROK 4
			 * Obliczanie wartości własnych (ang. eigenvalues) i wektorów własnych dla wyliczonej
			 * macierzy kowariancji.
			 *
			 */
			progress.advanceProgress("Calculating eigenvectors...");
			var eigen:EigenvalueDecomposition = L.eig();
			__eigValues = eigen.getD();
			__eigVectors = eigen.getV();

			/**
			 * KROK 5
			 * Sortowanie wektorów/wartości na podstawie wielkości wartości (ang. eigen value)
			 *
			 */
			progress.advanceProgress("Sorting eigenvectors...");

			var eigDVSorted:Vector.<KMatrix> = sortem(__eigValues, __eigVectors);
			__eigValues = eigDVSorted[0];
			__eigVectors = eigDVSorted[1];

			/**
			 * KROK 6
			 * Konwertowanie wektorów dla A'*A do wektorów dla A*A'.
			 *
			 */
			progress.advanceProgress("Converting eigenvectors...");
			//trace("\t A[X][Y]=A[" + A.getColumnDimension() + "][" + A.getRowDimension() + "]");
			//trace("\t eigenVectors[X][Y]=eigenVectors[" + eigVectors.getColumnDimension() + "][" + eigVectors.getRowDimension() + "]");
			__eigVectors = A.times(__eigVectors);
			//trace("eigenVectors[X][Y]=eigenVectors[" + eigVectors.getColumnDimension() + "][" + eigVectors.getRowDimension() + "]");

			/**
			 * KROK 7
			 * Pobieranie wartości (ang. eigen values) z diagonalnej
			 * macierzy oraz normalizowanie ich by były
			 * specyficzne dla cov(A') a nie A*A'.
			 *
			 */
			progress.advanceProgress("Calculating eigenvalues ...");

			var values:Vector.<Number> = __eigValues.getDiag();
			var AColumnsMinusOneInv:Number = 1.0 / Number(A.getColumnDimension() - 1);

			i = values.length;
			while (i--)
				values[i] *= AColumnsMinusOneInv;

			/**
			 * KROK 8
			 * Normalizuje wektory do długości jednostkowej
			 * usuwa wektory odpowiadające bardzo małym wartością.
			 *
			 */
			progress.advanceProgress("Normalizing eigenvectors...");
			_numOfEigenVecs = 0;

			var eigVectorsRowDimension:uint = __eigVectors.getRowDimension();
			var eigVectorsRowDimensionMinusOne:uint = eigVectorsRowDimension - 1;
			var tempKMatrix:KMatrix;
			var invertedNormF:Number;

			i = __eigVectors.getColumnDimension();
			while (i--)
			{
				if (values[i] >= 0.001)
				{
					tempKMatrix = __eigVectors.getCol(i);
					invertedNormF = 1.0 / tempKMatrix.normF();
					tempKMatrix.timesEquals(invertedNormF);
					++_numOfEigenVecs;
				}
				else
				{
					tempKMatrix = new KMatrix(eigVectorsRowDimension, 1);
				}
				__eigVectors.setCol(i, tempKMatrix);
			}
			__eigVectors = __eigVectors.getMatrixWithRange(0, eigVectorsRowDimensionMinusOne, 0, uint(_numOfEigenVecs - 1));
			__trained = true;
			
			progress.advanceProgress("End of training ...", false);
			trace("Created " + _numOfEigenVecs + " eigenVectors"); //test
			trace("Dimensions of eigenVectors: " + __eigVectors.getRowDimension() + " x " + __eigVectors.getColumnDimension()); //test
		}

		/**
		 * Funkcja porównująca dwa obiekty klasy "di_pair" używana
		 * przy sortowaniu tablic. 
		 * 
		 * @private
		 * */
		private function diPair_sort(arg0:diPair, arg1:diPair):int
		{
			var diff:Number = arg0.value - arg1.value;
			return (diff > 0.0) ? -1 : (diff < 0.0) ? 1 : 0;
		}
		
		/**
		 * Sortuje eigen values (wartości) i vectors (wektory) w
		 * porządku malejącym.
		 *
		 * @param D  eigen Values (wartości)
		 * @param V  eigen Vectors (wektory)
		 * @return Posortowane eigen values (wartości) i vectors
		 * (wektory) w porządku malejącym
		 */
		private function sortem(D:KMatrix, V:KMatrix):Vector.<KMatrix>
		{
			var dvec:Vector.<Number> = D.getDiag();
			var dvecIndexed:Vector.<diPair> = new Vector.<diPair>(dvec.length, true);
			var i:int = dvecIndexed.length;
			
			while (i--)
				dvecIndexed[i] = new diPair(i, dvec[i]);

			dvecIndexed.sort(diPair_sort);

			var VColumnDimension:int = V.getColumnDimension();
			var VRowDimension:int = V.getRowDimension();
			var D2:KMatrix = D.copyEmpty();
			var V2:KMatrix = V.copyEmpty();
			var height:int = int(VRowDimension - 1);
			var tmp:KMatrix;
			var tempIndex:int;

			i = dvecIndexed.length;
			while (i--)
			{
				tempIndex = dvecIndexed[i].index;
				D2.set(i, i, D.get(tempIndex, tempIndex));
				tmp = V.getRow(tempIndex);
				V2.setMatrixWithRange(i, i, 0, height, tmp);
			}

			var V3:KMatrix = V.copyEmpty();
			var VRowDimensionMinusOne:int = int(VRowDimension - 1);
			var VColumnDimensionMinusOne:int = int(VColumnDimension - 1);
			var j:int;
			
			i = VRowDimension;
			while (i--)
			{
				j = VColumnDimension;
				
				while (j--)
					V3.set(i, j, V2.get(int(VRowDimensionMinusOne - i), int(VColumnDimensionMinusOne - j)));
			}
			
			return new <KMatrix>[D2, V3];
		}
		
		public function writeExternal(output:IDataOutput):void
		{		
			output.writeUnsignedInt(_numOfEigenVecs);
			output.writeBoolean(__trained);
			output.writeObject(__eigVectors);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			_numOfEigenVecs = input.readUnsignedInt();
			__trained = input.readBoolean();
			__eigVectors = input.readObject() as KMatrix;
		}
	}
}

/* Klasa pomocnicza widoczna tylko dla kodu wewnątrz tego pliku */
class diPair
{
	public var index:int;
	public var value:Number;
	
	public function diPair(_index:int, _value:Number)
	{
		this.index = _index;
		this.value = _value;
	}
}
