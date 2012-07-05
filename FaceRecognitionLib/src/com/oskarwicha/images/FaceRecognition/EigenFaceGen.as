package com.oskarwicha.images.FaceRecognition
{
	import mx.controls.Alert;

	/**
	 * Klasa tworzy eigenfaces z obrazów twarzy.
	 *
	 * @author Oskar Wicha
	 *
	 * @flowerModelElementId _Tlw34GglEeCqZchJBDddKw
	 */
	internal class EigenFaceGen
	{
		/**
		 * Konstruktor
		 */
		public function EigenFaceGen()
		{
			//puste
		}

		// Średnia twarz uzywana podczas treningu
		private var averageFace:KMatrix;

		// Posorotwane wartości uzyskane w procesie treningu.
		private var eigValues:KMatrix;

		// Posortowane wektory uzyskane w procesie treningu.
		private var eigVectors:KMatrix;

		// Ilość używanych wektorów.
		private var numOfEigenVecs:int = 0;

		// Jesli proces treningu zakonczył się powodzeniem przyjmuje
		// wartość "true".
		private var trained:Boolean = false;

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
		internal final function getEigenFaces(pic:Picture, number:int):Vector.<Number>
		{
			if (!pic || !eigVectors)
				return null;

			// Dostosowuje wartość zmiennej "number" ażeby była równa lub 
			// mniejsza od ilości dostępnych wektorów
			if (number > numOfEigenVecs)
				number = numOfEigenVecs;

			var ret:Vector.<Number> = new Vector.<Number>(number, true);
			var pictureVector:Vector.<Number> = pic.getImagePixels();

			// Konwertuje macierz o wymiarach np. 50x50 do 1x2500
			var face:KMatrix = KMatrix.makeFromColumnPackedVector(pictureVector, pictureVector.length);
			var Vecs:KMatrix = eigVectors.getMatrixWithRange(0, int(eigVectors.getRowDimension() - 1), 0, int(number - 1)).transpose();

			var rslt:KMatrix = Vecs.times(face);

			var i:int = number;
			while (i--)
				ret[i] = rslt.get(i, 0);

			return ret;
		}

		/**
		 * Informuje jak wiele eigen vectors (wektorów) zostalo
		 * utworzonych podczas ostatniego procesu treningu.
		 *
		 * @return Liczba wygenereowanych eigen vectors (wektorów)
		 *
		 */
		internal function getNumEigenVecs():int
		{
			return numOfEigenVecs;
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
			return trained;
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
			progress.advanceProgress("Konstrułowanie macierzy ...");

			var dpix:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(faces.length, true);

			var i:int = faces.length;
			while (i--)
			{
				// Wykonywane dla każdego zdjęcia twarzy w zestawie.
				dpix[i] = faces[i].picture.getImagePixels();
			}
			// Tworzy wektor z wektorów jednowierszowych zawierających
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
			progress.advanceProgress("Obliczanie średniej twarzy...");
			var matrixColumnDimension:int = matrix.getColumnDimension();
			averageFace = new KMatrix(1, matrixColumnDimension);

			var matrixRowDimension:int = matrix.getRowDimension();
			i = matrixRowDimension;
			while (i--)
				averageFace.plusEquals(matrix.getRow(i));

			var amountOfFacesInverted:Number = Number(1 / matrix.getRowDimension());

			// Końcowy etap obliczania średniej twarzy
			// przez pomnożenie przez odwrotność ilości
			// twarzy w zestawie. 
			averageFace.timesEquals(amountOfFacesInverted);
			var bigAvg:KMatrix = new KMatrix(matrix.getRowDimension(), matrix.getColumnDimension());

			var bigAvgColumnDimensionMinusOne:int = int(bigAvg.getColumnDimension() - 1);
			i = bigAvg.getRowDimension();
			while (i--)
				bigAvg.setMatrixWithRange(i, i, 0, bigAvgColumnDimensionMinusOne, averageFace);

			// Oblicza dla każdej twarzy w zestawie różnice 
			// między nią a średnią twarzą.
			var A:KMatrix = matrix.minus(bigAvg).transpose();

			/**
			 * KROK 3
			 * Obliczanie macierzy kowariancji.
			 *
			 */
			progress.advanceProgress("Obliczanie macierzy kowariancji...");
			var At:KMatrix = A.transpose();
			var L:KMatrix = At.times(A);

			/**
			 * KROK 4
			 * Obliczanie wartości własnych (ang. eigenvalues) i wektorów własnych dla wyliczonej
			 * macierzy kowariancji.
			 *
			 */
			progress.advanceProgress("Obliczanie eigenvectors...");
			var eigen:EigenvalueDecomposition = L.eig();
			eigValues = eigen.getD();
			eigVectors = eigen.getV();

			/**
			 * KROK 5
			 * Sortowanie wektorów/wartości na podstawie wielkości wartości (ang. eigen value)
			 *
			 */
			progress.advanceProgress("Sortowanie eigenvectors...");

			var eigDVSorted:Vector.<KMatrix> = sortem(eigValues, eigVectors);
			eigValues = eigDVSorted[0];
			eigVectors = eigDVSorted[1];

			/**
			 * KROK 6
			 * Konwertowanie wektorów dla A'*A do wektorów dla A*A'.
			 *
			 */
			progress.advanceProgress("Konwertowanie eigenvectors...");
			trace("A[X][Y]=A[" + A.getColumnDimension() + "][" + A.getRowDimension() + "]");
			trace("eigenVectors[X][Y]=eigenVectors[" + eigVectors.getColumnDimension() + "][" + eigVectors.getRowDimension() + "]");
			eigVectors = A.times(eigVectors);
			//trace("eigenVectors[X][Y]=eigenVectors[" + eigVectors.getColumnDimension() + "][" + eigVectors.getRowDimension() + "]");

			/**
			 * KROK 7
			 * Pobieranie wartości (ang. eigen values) z diagonalnej
			 * macierzy oraz normalizowanie ich by były
			 * specyficzne dla cov(A') a nie A*A'.
			 *
			 */
			progress.advanceProgress("Uzyskuje eigenvalues ...");

			var values:Vector.<Number> = diag(eigValues);
			var AColumnDimensionMinusOne:int = int(A.getColumnDimension() - 1);

			i = values.length;
			while (i--)
				values[i] /= AColumnDimensionMinusOne;

			/**
			 * KROK 8
			 * Normalizuje wektory do długości jednostkowej
			 * usuwa wektory odpowiadające bardzo małym wartością.
			 *
			 */
			progress.advanceProgress("Normalizuje eigenvectors...");
			numOfEigenVecs = 0;

			var tmp:KMatrix;
			var eigVectorsRowDimension:uint = eigVectors.getRowDimension();
			var eigVectorsRowDimensionMinusOne:uint = eigVectorsRowDimension - 1;
			var tempKMatrix:KMatrix;

			i = eigVectors.getColumnDimension();
			while (i--)
			{
				if (values[i] >= 0.0001)
				{
					tempKMatrix = eigVectors.getMatrixWithRange(0, eigVectorsRowDimensionMinusOne, i, i);
					tmp = tempKMatrix.timesScalar(1 / tempKMatrix.normF());
					++numOfEigenVecs;
				}
				else
				{
					tmp = new KMatrix(eigVectorsRowDimension, 1);
				}
				eigVectors.setMatrixWithRange(0, eigVectorsRowDimensionMinusOne, i, i, tmp);
			}
			eigVectors = eigVectors.getMatrixWithRange(0, eigVectorsRowDimensionMinusOne, 0, uint(numOfEigenVecs - 1));
			trained = true;

			trace("Uzyskano " + numOfEigenVecs + " eigenVectors"); //test
			trace("Wymiary eigenVectors: " + eigVectors.getRowDimension() + " x " + eigVectors.getColumnDimension()); //test
		}

		/* Funkcja porównująca dwa obiekty klasy "di_pair" używana
		 przy sortowaniu tablic. */
		private function di_pair_sort(arg0:di_pair, arg1:di_pair):int
		{
			var diff:Number = arg0.value - arg1.value;
			return (diff > 0) ? -1 : (diff < 0) ? 1 : 0;
		}

		/**
		 * Zwraca diagonalną macierzy
		 *
		 * @param M Macierz której diagonalna ma zostać zwrócona
		 * @return Tablica z obiektami typu Number zawierająca
		 * wartości diagonalnej
		 */
		private function diag(M:KMatrix):Vector.<Number>
		{
			var i:int = M.getColumnDimension();
			var dvec:Vector.<Number> = new Vector.<Number>(i, true);

			while (i--)
				dvec[i] = M.get(i, i);

			return dvec;
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
			var dvec:Vector.<Number> = diag(D);
			var dvec_indexed:Vector.<di_pair> = new Vector.<di_pair>(dvec.length, true);
			var i:int = dvec_indexed.length;
			while (i--)
			{
				dvec_indexed[i] = new di_pair();
				dvec_indexed[i].index = i;
				dvec_indexed[i].value = dvec[i];
			}

			dvec_indexed.sort(di_pair_sort);

			var VColumnDimension:int = V.getColumnDimension();
			var VRowDimension:int = V.getRowDimension();

			var D2:KMatrix = new KMatrix(D.getRowDimension(), D.getColumnDimension());
			var V2:KMatrix = new KMatrix(VRowDimension, VColumnDimension);

			var height:int = int(VRowDimension - 1);
			var tmp:KMatrix;

			var tempIndex:int;
			i = dvec_indexed.length;
			while (i--)
			{
				tempIndex = dvec_indexed[i].index;
				D2.set(i, i, D.get(tempIndex, tempIndex));
				tmp = V.getRow(tempIndex);
				V2.setMatrixWithRange(i, i, 0, height, tmp);
			}

			var V3:KMatrix = new KMatrix(VRowDimension, VColumnDimension);
			var VRowDimensionMinusOne:int = int(VRowDimension - 1);
			var VColumnDimensionMinusOne:int = int(VColumnDimension - 1);
			var j:int;
			i = VRowDimension;
			while (i--)
			{
				j = VColumnDimension;
				while (j--)
				{
					V3.set(i, j, V2.get(int(VRowDimensionMinusOne - i), int(VColumnDimensionMinusOne - j)));
				}
			}
			var vec:Vector.<KMatrix> = new Vector.<KMatrix>(2, true);
			vec[0] = D2;
			vec[1] = V3;
			return vec;
		}
	}
}

/* Klasa pomocnicza widoczna tylko dla kodu wewnątrz tego pliku */
class di_pair
{
	public var index:int;
	public var value:Number;
}
