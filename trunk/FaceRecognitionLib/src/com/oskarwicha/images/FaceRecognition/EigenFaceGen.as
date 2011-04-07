package com.oskarwicha.images.FaceRecognition
{
	import com.karthik.math.lingalg.EigenvalueDecomposition;
	import com.karthik.math.lingalg.KMatrix;

	/**
	 * Klasa tworzy eigenfaces z obrazów twarzy.
	 *
	 * @author Oskar Wicha
	 *
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
		internal function getEigenFaces(pic:Picture, number:int):Array
		{
			if (!pic || !eigVectors)
				return null;
			// Dostosowuje wartość zmiennej "number" ażeby była równa lub 
			// mniejsza od ilości dostępnych wektorów
			if (number > numOfEigenVecs)
				number = numOfEigenVecs;

			//[ArrayElementType("Number")]
			var ret:Array = new Array(number);
			var pictureArray:Array = pic.getImagePixels();
			// Konwertuje macierz o wymiarach np. 50x50 do 1x2500
			var face:KMatrix = KMatrix.makeFromColumnPacked(pictureArray, pictureArray.length);
			var Vecs:KMatrix = eigVectors.getMatrixWithRange(0, eigVectors.getRowDimension() - 1, 0, number - 1).transpose();

			var rslt:KMatrix = Vecs.times(face);

			for (var i:int = 0; i < number; i++)
			{
				ret[i] = rslt.get(i, 0) as Number;
			}

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
		internal function processTrainingSet(faces:Array, progress:ProgressTracker):void
		{
			/**
			 * KROK 1
			 * Wczytanie zdjęć i zapisanie w postaci jednego
			 * wiersza wartości a następnie załadowanie do
			 * dużej macierzy.
			 *
			 */
			progress.advanceProgress("Konstrułowanie macierzy ...");
			var dpix:Array = new Array(faces.length);
			var dpixLength:uint = dpix.length;
			for (var i:uint = 0; i < dpixLength; i++)
			{
				dpix[i] = new Array(faces[i].picture.getImagePixels().length);
			}

			var facesLength:uint = faces.length;
			for (i = 0; i < facesLength; i++)
			{
				// Wykonywane dla każdego zdjęcia twarzy w zestawie.
				var pixels:Array = faces[i].picture.getImagePixels();

				var pixelsLength:int = pixels.length;
				for (var j:int = 0; j < pixelsLength; j++)
				{
					dpix[i][j] = pixels[j];
				}
			}
			// Tworzy macierz z tablic jednowierszowych zawierających
			// wszystkie obrazy twarzy z testowego zestawu.
			var matrix:KMatrix = KMatrix.makeFromArray(dpix);

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
			for (i = 0; i < matrixRowDimension; i++)
			{
				averageFace.plusEquals(matrix.getMatrixWithRange(i, i, 0, matrixColumnDimension - 1));
			}
			var amountOfFacesInverted:Number = (1.0 / matrix.getRowDimension()) as Number;
			// Końcowy etap obliczania średniej twarzy
			// przez pomnożenie przez odwrotność ilości
			// twarzy w zestawie. 
			averageFace.timesEquals(amountOfFacesInverted);
			var bigAvg:KMatrix = new KMatrix(matrix.getRowDimension(), matrix.getColumnDimension());
			var bigAvgRowDimension:int = bigAvg.getRowDimension();
			for (i = 0; i < bigAvgRowDimension; i++)
			{
				bigAvg.setMatrixWithRange(i, i, 0, bigAvg.getColumnDimension() - 1, averageFace);
			}
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

			//[ArrayElementType("KMatrix")]
			var eigDVSorted:Array = sortem(eigValues, eigVectors);
			eigValues = eigDVSorted[0];
			eigVectors = eigDVSorted[1];

			/**
			 * KROK 6
			 * Konwertowanie wektorów dla A'*A do wektorów dla A*A'.
			 *
			 */
			progress.advanceProgress("Konwertowanie eigenvectors...");
			//trace("A[X][Y]=A[" + A.getColumnDimension() + "][" + A.getRowDimension() + "]");
			//trace("eigenVectors[X][Y]=eigenVectors[" + eigVectors.getColumnDimension() + "][" + eigVectors.getRowDimension() + "]");
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

			//[ArrayElementType("Number")]
			var values:Array = diag(eigValues);

			var valuesLength:int = values.length;
			var AColumnDimensionMinusOne:int = A.getColumnDimension() - 1;
			for (i = 0; i < valuesLength; ++i)
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
			var eigVectorsColumnDimenstion:int = eigVectors.getColumnDimension();
			for (i = 0; i < eigVectorsColumnDimenstion; ++i)
			{

				if (values[i] < 0.0001)
				{
					tmp = new KMatrix(eigVectors.getRowDimension(), 1);
				}
				else
				{
					tmp = eigVectors.getMatrixWithRange(0, int(eigVectors.getRowDimension() - 1), i, i).timesScalar(1 / eigVectors.getMatrixWithRange(0, int(eigVectors.getRowDimension() - 1), i, i).normF());
					numOfEigenVecs++;
				}
				eigVectors.setMatrixWithRange(0, eigVectors.getRowDimension() - 1, i, i, tmp);
			}
			eigVectors = eigVectors.getMatrixWithRange(0, eigVectors.getRowDimension() - 1, 0, numOfEigenVecs - 1);

			trained = true;

			trace("Uzyskano " + numOfEigenVecs + " eigenVectors");
			trace("Wymiary eigenVectors: " + eigVectors.getRowDimension() + " x " + eigVectors.getColumnDimension());
		}

		/* Funkcja porównująca dwa obiekty klasy "di_pair" używana
		 przy sortowaniu tablic. */
		private function di_pair_sort(arg0:Object, arg1:Object):int
		{
			var lt:di_pair = arg0 as di_pair;
			var rt:di_pair = arg1 as di_pair;
			var dif:Number = (lt.value - rt.value);
			if (dif > 0)
				return -1;
			if (dif < 0)
				return 1;
			else
				return 0;
		}

		/**
		 * Zwraca diagonalną macierzy
		 *
		 * @param M Macierz której diagonalna ma zostać zwrócona
		 * @return Tablica z obiektami typu Number zawierająca
		 * wartości diagonalnej
		 */
		private function diag(M:KMatrix):Array
		{
			var dvec:Array = new Array(M.getColumnDimension());
			for (var i:int = 0; i < M.getColumnDimension(); i++)
			{
				dvec[i] = M.get(i, i);
			}
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
		private function sortem(D:KMatrix, V:KMatrix):Array
		{
			var dvec:Array = diag(D);

			var dvec_indexed:Array = new Array(dvec.length);
			for (var i:int = 0; i < dvec_indexed.length; i++)
			{
				dvec_indexed[i] = new di_pair();
				dvec_indexed[i].index = i;
				dvec_indexed[i].value = dvec[i];
			}

			dvec_indexed.sort(di_pair_sort);

			var D2:KMatrix = new KMatrix(D.getRowDimension(), D.getColumnDimension());
			var V2:KMatrix = new KMatrix(V.getRowDimension(), V.getColumnDimension());

			for (i = 0; i < dvec_indexed.length; i++)
			{
				D2.set(i, i, D.get(dvec_indexed[i].index, dvec_indexed[i].index));
				var height:int = V.getRowDimension() - 1;
				var tmp:KMatrix = V.getMatrixWithRange(dvec_indexed[i].index, dvec_indexed[i].index, 0, height);
				V2.setMatrixWithRange(i, i, 0, height, tmp);
			}

			var V3:KMatrix = new KMatrix(V.getRowDimension(), V.getColumnDimension());
			for (i = 0; i < V3.getRowDimension(); i++)
			{
				for (var j:int = 0; j < V3.getColumnDimension(); j++)
				{
					V3.set(i, j, V2.get(V3.getRowDimension() - i - 1, V3.getColumnDimension() - j - 1));
				}
			}
			var arr:Array = new Array();
			arr.push(D2);
			arr.push(V3);
			return arr;
		}
	}
}

/* Klasa pomocnicza widoczna tylko dla kodu wewnątrz tego pliku */
class di_pair
{

	public var index:int;
	public var value:Number;
}