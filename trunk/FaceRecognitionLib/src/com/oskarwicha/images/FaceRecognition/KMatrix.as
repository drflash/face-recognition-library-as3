/*
   Project: Karthik's Matrix Library
   Copyright 2009 Karthik Tharavaad
   http://blog.kpicturebooth.com
   karthik_tharavaad@yahoo.com
	
   Converted from Arrays to Vectors and several functions added and removed
   by Oskar Wicha

 * Direct port from Jama: http://math.nist.gov/javanumerics/jama/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

package com.oskarwicha.images.FaceRecognition
{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	/**
	   Jama = Java Matrix class.
	   <P>
	   The Java Matrix Class provides the fundamental operations of numerical
	   linear algebra.  Various constructors create Matrices from two dimensional
	   arrays of double precision floating point numbers.  Various "gets" and
	   "sets" provide access to submatrices and matrix elements.  Several methods
	   implement basic matrix arithmetic, including matrix addition and
	   multiplication, matrix norms, and element-by-element array operations.
	   Methods for reading and printing matrices are also included.  All the
	   operations in this version of the Matrix Class involve real matrices.
	   Complex matrices may be handled in a future version.
	   <P>
	   Five fundamental matrix decompositions, which consist of pairs or triples
	   of matrices, permutation vectors, and the like, produce results in five
	   decomposition classes.  These decompositions are accessed by the Matrix
	   class to compute solutions of simultaneous linear equations, determinants,
	   inverses and other matrix functions.  The five decompositions are:
	   <P><UL>
	   <LI>Eigenvalue Decomposition of both symmetric and nonsymmetric square matrices.
	   </UL>
	   <DL>
	   <P>
	   </DL>
	
	   @author The MathWorks, Inc. and the National Institute of Standards and Technology.
	   @version 5 August 1998
	 */
	public class KMatrix
	{
		
		/* ------------------------
		   Class variables
		 * ------------------------ */
		
		/** Vector for internal storage of elements.
		 */
		protected var A:Vector.<Vector.<Number>>;
		
		/** Row and column dimensions.
		   @serial row dimension.
		   @serial column dimension.
		 */
		protected var m:int;
		
		protected var n:int;
		
		/* ------------------------
		   Constructors
		 * ------------------------ */
		
		/** Construct an m-by-n matrix of zeros.
		   @param m    Number of rows.
		   @param n    Number of colums.
		 */
		public final function KMatrix(m:int, n:int):void
		{
			this.m = m;
			this.n = n;
			A = Maths.make2DVector(m, n);
		}
		
		/** Construct a matrix from a 2-D Vector.<Number>.
		 @param A    Two-dimensional vector of doubles.
		 @exception  IllegalArgumentException All rows must have the same length
		 @see        #constructWithCopy
		 */
		
		public static function makeFromVector(A:Vector.<Vector.<Number>>):KMatrix
		{
			var m:int = A.length;
			var n:uint = A[0].length;
			var matr:KMatrix = new KMatrix(m, n);
			var X:Vector.<Vector.<Number>> = matr.getVector(); 
			
			var i:uint = m;
			while (i--)
			{
				if (A[i].length != n)
				{
					throw new Error("All rows must have the same length.");
				}else 
				{
					X[i] = A[i];
				}
			}
			return matr;
		}
		
		/** Construct a matrix quickly without checking arguments.
		 @param A    Two-dimensional array of doubles.
		 @param m    Number of rows.
		 @param n    Number of colums.
		 */
		
		public static function makeUsingVector(A:Vector.<Vector.<Number>>, m:int, n:int):KMatrix
		{
			var matr:KMatrix = new KMatrix(m, n);
			matr.setVector(A);
			return matr;
		}
		
		public final function setVector(A:Vector.<Vector.<Number>>):void
		{
			this.A = A;
		}
		
		/** Construct a matrix from a one-dimensional packed vector
		 @param vals One-dimensional vector of doubles, packed by columns (ala Fortran).
		 @param m    Number of rows.
		 @exception  IllegalArgumentException Array length must be a multiple of m.
		 */
		
		public static function makeFromColumnPackedVector(vals:Vector.<Number>, m:uint):KMatrix
		{
			var n:uint = (m != 0 ? vals.length / m : 0);
			if (uint(m * n) != vals.length)
			{
				throw new Error("Vector length must be a multiple of m.");
			}
			
			var matr:KMatrix = new KMatrix(m, n);
			var A:Vector.<Vector.<Number>> = matr.getVector();
			var Ai:Vector.<Number>;
			var i:int = m;
			var j:int;
			while (i--)
			{
				Ai = A[i];
				j = n;
				while (j--)
					Ai[j] = vals[uint(i + (j * m))];
				
				A[i] = Ai;
			}
			return matr;
		}
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/** Make a deep copy of a matrix
		 */
		
		public final function copy():KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Vector.<Vector.<Number>> = X.getVector();
			for (var i:uint = 0; i < m; ++i)
			{
				for (var j:uint = 0; j < n; ++j)
				{
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/** Clone the Matrix object.
		 */
		
		public final function clone():Object
		{
			return this.copy();
		}
		
		/** Access the internal two-dimensional array.
		   @return     Pointer to the two-dimensional array of matrix elements.
		 */
		
		public final function getVector():Vector.<Vector.<Number>>
		{
			return A;
		}
		
		/** Get row dimension.
		   @return     m, the number of rows.
		 */
		
		public final function getRowDimension():int
		{
			return m;
		}
		
		/** Get column dimension.
		   @return     n, the number of columns.
		 */
		
		public final function getColumnDimension():int
		{
			return n;
		}
		
		/** Get a single element.
		   @param i    Row index.
		   @param j    Column index.
		   @return     A(i,j)
		   @exception  ArrayIndexOutOfBoundsException
		 */
		
		public final function get(i:uint, j:uint):Number
		{
			return A[i][j];
		}
		
		/** Get a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param j0   Initial column index
		   @param j1   Final column index
		   @return     A(i0:i1,j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function getMatrixWithRange(i0:uint, i1:uint, j0:uint, j1:uint):KMatrix
		{
			var X:KMatrix = new KMatrix(uint(i1 - i0 + 1), uint(j1 - j0 + 1));
			var B:Vector.<Vector.<Number>> = X.getVector();
			var Ai:Vector.<Number>;
			var Bi_i0:Vector.<Number>;
			for (var i:uint = i0; i <= i1; ++i)
			{
				Ai = A[i];
				Bi_i0 = B[uint(i - i0)];
				for (var j:uint = j0; j <= j1; ++j)
				{
					Bi_i0[uint(j - j0)] = Ai[j];
				}
			}
			return X;
		}
		
		/** Get matrix row
		   @param i   Row index
		   @return     A(i,0:lenght-1)
		*/
		public function getRow(i:uint):KMatrix
		{
			var X:KMatrix = new KMatrix(1, this.n);
			X.getVector()[0] = A[i];
			
			return X;
		}
		
		/** Get a submatrix.
		   @param r    Array of row indices.
		   @param c    Array of column indices.
		   @return     A(r(:),c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		/*public function getMatrixWithIndex(r:Array, c:Array):KMatrix
		{
			var X:KMatrix = new KMatrix(r.length, c.length);
			var B:Array = X.getArray();
			for (var i:int = 0; i < r.length; i++)
			{
				for (var j:int = 0; j < c.length; j++)
				{
					B[i][j] = A[r[i]][c[j]];
				}
			}
			return X;
		}*/
		
		/** Get a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param c    Array of column indices.
		   @return     A(i0:i1,c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		/*public function getMatrixWithRowRangeColumnIndex(i0:int,
			i1:int, c:Array):KMatrix
		{
			var X:KMatrix = new KMatrix(i1 - i0 + 1, c.length);
			var B:Array = X.getArray();
			for (var i:int = i0; i <= i1; i++)
			{
				for (var j:int = 0; j < c.length; j++)
				{
					B[i - i0][j] = A[i][c[j]];
				}
			}
			return X;
		}*/
		
		/** Get a submatrix.
		   @param r    Array of row indices.
		   @param i0   Initial column index
		   @param i1   Final column index
		   @return     A(r(:),j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		/*public function getMatrixWithRowIndexColumnRange(r:Array,
			j0:int, j1:int):KMatrix
		{
			var X:KMatrix = new KMatrix(r.length, j1 - j0 + 1);
			var B:Array = X.getArray();
			for (var i:int = 0; i < r.length; i++)
			{
				for (var j:int = j0; j <= j1; j++)
				{
					B[i][j - j0] = A[r[i]][j];
				}
			}
			return X;
		}*/
		
		/** Set a single element.
		   @param i    Row index.
		   @param j    Column index.
		   @param s    A(i,j).
		   @exception  ArrayIndexOutOfBoundsException
		 */
		
		public function set(i:uint, j:uint, s:Number):void
		{
			A[i][j] = s;
		}
		
		/** Set a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param j0   Initial column index
		   @param j1   Final column index
		   @param X    A(i0:i1,j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function setMatrixWithRange(i0:int, i1:int, j0:int, j1:int, X:KMatrix):void
		{
			var Ai:Vector.<Number>;
			for (var i:int = i0; i <= i1; ++i)
			{
				var i_i0:int = int(i - i0);
				Ai = A[i];
				for (var j:int = j0; j <= j1; ++j)
					Ai[j] = X.get(i_i0, int(j - j0));
				
				A[i] = Ai;
			}
		}
		
		/** Matrix transpose.
		   @return    A'
		 */
		
		public function transpose():KMatrix
		{
			var X:KMatrix = new KMatrix(n, m);
			var C:Vector.<Vector.<Number>> = X.getVector();
			var Ai:Vector.<Number>;
			for (var i:uint = 0; i < m; ++i)
			{
				Ai = A[i];
				for (var j:uint = 0; j < n; ++j)
					C[j][i] = Ai[j];
			}
			
			return X;
		}
		
		/** Frobenius norm
		   @return    sqrt of sum of squares of all elements.
		 */
		
		public function normF():Number
		{
			var f:Number = 0;
			for (var i:uint = 0; i < m; ++i)
				for (var j:uint = 0; j < n; ++j)
					f = Maths.hypot(f, A[i][j]);

			return f;
		}
			
		/** A = A + B
		   @param B    another matrix
		   @return     A + B
		 */
		
		public function plusEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var Ai:Vector.<Number>;
			var BAi:Vector.<Number>;
			for (var i:uint = 0; i < m; ++i)
			{
				Ai = A[i];
				BAi = B.A[i];
				for (var j:uint = 0; j < n; ++j)
				{
					Ai[j] += BAi[j];
				}
				A[i] = Ai;
			}
			return this;
		}
		
		/** C = A - B
		   @param B    another matrix
		   @return     A - B
		 */
		
		public function minus(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var X:KMatrix = new KMatrix(m, n);
			var C:Vector.<Vector.<Number>> = X.getVector();
			var Ci:Vector.<Number>;
			var Ai:Vector.<Number>;
			var BAi:Vector.<Number>;
			for (var i:uint = 0; i < m; ++i)
			{
				Ci = C[i];
				Ai = A[i];
				BAi = B.A[i];
				for (var j:uint = 0; j < n; ++j)
				{
					Ci[j] = Ai[j] - BAi[j];
				}
				C[i] = Ci;
			}
			return X;
		}
		
		/** Multiply a matrix by a scalar, C = s*A
		   @param s    scalar
		   @return     s*A
		 */
		
		public function timesScalar(s:Number):KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Vector.<Vector.<Number>> = X.getVector();
			var Ci:Vector.<Number>;
			var Ai:Vector.<Number>;
			for (var i:uint = 0; i < m; ++i)
			{	
				Ci = C[i];
				Ai = A[i];
				for (var j:uint = 0; j < n; ++j)
				{
					Ci[j] = s * Ai[j];
				}
				C[i] = Ci;
			}
			return X;
		}
		
		/** Multiply a matrix by a scalar in place, A = s*A
		   @param s    scalar
		   @return     replace A by s*A
		 */
		
		public function timesEquals(s:Number):KMatrix
		{
			var Ai:Vector.<Number>;
			for (var i:uint = 0; i < m; ++i)
			{
				Ai = A[i];
				for (var j:uint = 0; j < n; ++j)
				{
					Ai[j] *= s;
				}
				A[i] = Ai;
			}
			return this;
		}
		
		/** Linear algebraic matrix multiplication, A * B
		 @param B    another matrix
		 @return     Matrix product, A * B
		 @exception  IllegalArgumentException Matrix inner dimensions must agree.
		 *
		 * @author Oskar Wicha
		 */
		
		public final function timesOld(B:KMatrix):KMatrix
		{
			if (B.m != this.n)
			{
				throw new Error("Matrix inner dimensions must agree.");
			}
			var bn:int = B.n;
			var an:int = this.n;
			var X:KMatrix = new KMatrix(this.m, bn);
			// trace("X wymiary "+m+" na "+ B.n);
			var C:Vector.<Vector.<Number>> = X.getVector();
			//var start:Number = flash.utils.getTimer();
			
			var AVec:Vector.<Vector.<Number>> = this.A;
			var BVec:Vector.<Vector.<Number>> = B.A;
			
			var Bcolj:Vector.<Number> =   new Vector.<Number>(an, true);
			var Arowi:Vector.<Number> = new Vector.<Number>(an, true);
			var j:int = bn, i:int, k:int, s:Number;
			
			var t:Number = 0;
			
			while (--j > -1)
			{
				k = an;
				while (--k > -1)
					Bcolj[k] = BVec[k][j];
				
				i = m;
				while (--i > -1)
				{
					Arowi = AVec[i];
					s = 0.0;
					k = an;
					while (--k > -1)
						s = (Arowi[k] * Bcolj[k]) + s;
					//t += getMilliseconds()-start;
					C[i][j] = Number(s);
				}
			}
			X.setVector(C);
			//if ((getMilliseconds() - start) > 5)
			//Alert.show("Mnozenie macierzy trawalo = " + (getMilliseconds() - start).toString() + " ms");
			//trace("Mnozenie macierzy trawalo = "+(getMilliseconds()-start).toString()+" ms");
			
			//if(t>300){Alert.show(t.toString()+" ms");}
			return X;
		}
		
		
		/** Linear algebraic matrix multiplication, A * B
		   @param B    another matrix
		   @return     Matrix product, A * B
		   @exception  IllegalArgumentException Matrix inner dimensions must agree.
		 *
		 * @author Oskar Wicha
		 */
		
		public function times(B:KMatrix):KMatrix
		{
			//var start:Number = flash.utils.getTimer(); //debug
			if (B.m != this.n)
			{
				throw new Error("Matrix inner dimensions must agree.");
			}
			var bn:uint = B.n;
			var an:uint = this.n;
			var X:KMatrix = new KMatrix(this.m, bn);
			//trace("B wymiary "+B.n+" na "+ B.m);
			//trace("this.A wymiary "+this.n+" na "+ this.m);
			var C:Vector.<Vector.<Number>> = X.getVector();
			var AVec:Vector.<Vector.<Number>> =	this.A;
			AVec.fixed = true;
			var BVecTrans:Vector.<Vector.<Number>> = B.transpose().A;
			BVecTrans.fixed = true;
			var Bcolj:Vector.<Number>;
			
			var Arowi:Vector.<Number>;
			var s:Number;
			
			if(this.m >= 10)
			{
				var Arowi2:Vector.<Number>;
				var Arowi3:Vector.<Number>;
				var Arowi4:Vector.<Number>;
				var Arowi5:Vector.<Number>;
				var Arowi6:Vector.<Number>;
				var Arowi7:Vector.<Number>;
				var Arowi8:Vector.<Number>;
				var Arowi9:Vector.<Number>;
				var Arowi10:Vector.<Number>;
				
				var s2:Number, s3:Number, s4:Number, s5:Number, s6:Number;
				var s7:Number, s8:Number, s9:Number, s10:Number;
				
				var Bcoljk:Number;
			}
			var m_minus_1:uint = uint(m - 1);
			var i:uint;
			var k:uint;
			
			var j:uint = bn;
			while (j--)
			{
				Bcolj = BVecTrans[j];
				// jesli pozostaly do obliczen wiecej niz 10 wierszy z tablicy this.A
				// to wykona sie petla szybsza o 20% od petli wykorzystujacej jeden wiersz
				// w wewnetrznej petli
				i = uint(m - 1);
				while (9 < i)
				{
					
					Arowi = AVec[i];
					Arowi2 = AVec[uint(i-1)];
					Arowi3 = AVec[uint(i-2)];
					Arowi4 = AVec[uint(i-3)];
					Arowi5 = AVec[uint(i-4)];
					Arowi6 = AVec[uint(i-5)];
					Arowi7 = AVec[uint(i-6)];
					Arowi8 = AVec[uint(i-7)];
					Arowi9 = AVec[uint(i-8)];
					Arowi10 = AVec[uint(i-9)];
					
					s = 0.0;
					s2 = 0.0;
					s3 = 0.0;
					s4 = 0.0;
					s5 = 0.0;
					s6 = 0.0;
					s7 = 0.0;
					s8 = 0.0;
					s9 = 0.0;	
					s10 = 0.0;
					
					k = an;
					while (k--)
					{
						Bcoljk = Bcolj[k];
						s += Arowi[k] * Bcoljk;
						s2 += Arowi2[k] * Bcoljk;
						s3 += Arowi3[k] * Bcoljk;
						s4 += Arowi4[k] * Bcoljk;
						s5 += Arowi5[k] * Bcoljk;
						s6 += Arowi6[k] * Bcoljk;
						s7 += Arowi7[k] * Bcoljk;
						s8 += Arowi8[k] * Bcoljk;
						s9 += Arowi9[k] * Bcoljk;
						s10 += Arowi10[k] * Bcoljk;
					}
					C[i][j] = s;
					C[uint(i-1)][j] = s2;
					C[uint(i-2)][j] = s3;
					C[uint(i-3)][j] = s4;
					C[uint(i-4)][j] = s5;
					C[uint(i-5)][j] = s6;
					C[uint(i-6)][j] = s7;
					C[uint(i-7)][j] = s8;
					C[uint(i-8)][j] = s9;
					C[uint(i-9)][j] = s10;

					i -= 10;
				}
				// jesli pozostaly do obliczen mniej niz 10 wierszy z tablicy this.A
				// jesli liczba wierszy w tablicy this.A byla podzielna przez 10 to ta
				// petla sie nigdy nie wykona
				while (i--)
				{
					Arowi = AVec[i];
					s = 0.0;
					k = an;
					while (k--)
						s += Arowi[k] * Bcolj[k];

					C[i][j] = s;
				}
			}
			X.setVector(C);
			//trace("Matrix multiplication done in = " + (flash.utils.getTimer() - start).toString() + " ms");
			return X;
		}
		
		/** Eigenvalue Decomposition
		   @return     EigenvalueDecomposition
		   @see EigenvalueDecomposition
		 */
		
		public function eig():EigenvalueDecomposition
		{
			return new EigenvalueDecomposition(this);
		}
		
		/** Generate identity matrix
		   @param m    Number of rows.
		   @param n    Number of colums.
		   @return     An m-by-n matrix with ones on the diagonal and zeros elsewhere.
		 */
		
		/*public static function identity(m:int, n:int):KMatrix
		{
			var A:KMatrix = new KMatrix(m, n);
			var X:Array = A.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					X[i][j] = (i == j ? 1.0 : 0.0);
				}
			}
			return A;
		}8/
		
		/*
		 *
		 * Extensions to the Matrix class made by me to make life easier
		 *
		 * */

		/**
		 * Get rows of a matrix
		 * @param args the indices corresponding to the row numbers
		 * @return A(args, 0:end)
		 * @exception ArrayIndexOutOfBoundsException Submatrix indices
		 */
		/*public function getRows(... args):KMatrix
		{
			var X:KMatrix = new KMatrix(args.length, n);
			var B:Array = X.getArray();
			for (var i:int = 0; i < args.length; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					B[i][j] = A[args[i]][j];
				}
			}
			return X;
		}*/
		
		/**
		 * Get columns of a matrix
		 * @param args the indices corresponding to the row numbers
		 * @return A(args, 0:end)
		 * @exception ArrayIndexOutOfBoundsException Submatrix indices
		 */
		/*public function getColumns(... args):KMatrix
		{
			var X:KMatrix = new KMatrix(m, args.length);
			var B:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < args.length; j++)
				{
					B[i][j] = A[i][args[j]];
				}
			}
			return X;
		}*/
		
		/** prints this matrix */
		public function toString():String
		{
			var output:String = "";
			for (var i:uint = 0; i < m; i++)
			{
				for (var j:uint = 0; j < n; j++)
				{
					output += A[i][j] + "\t";
				}
				output = output.substring(0, output.length - 1);
				output += "\n";
			}
			return output.substring(0, output.length - 1);
		}
		
		/* ------------------------
		   Private Methods
		 * ------------------------ */
		
		/** Check if size(A) == size(B) **/
		
		private function checkMatrixDimensions(B:KMatrix):void
		{
			if (B.m != m || B.n != n)
			{
				throw new Error("Matrix dimensions must agree.");
			}
		}
	}
}
