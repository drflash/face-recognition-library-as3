/*
   Project: Karthik's Matrix Library
   Copyright 2009 Karthik Tharavaad
   http://blog.kpicturebooth.com
   karthik_tharavaad@yahoo.com
	
   Converted from Arrays to Vectors and several functions added by Oskar Wicha

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
	
	//import mx.controls.Alert;
	
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
		
		/** Array for internal storage of elements.
		   @serial internal array storage.
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
			
			var i:int = m;
			while (i--)
			{
				if (uint(A[i].length) != n)
					throw new Error("All rows must have the same length.");
				
				X[i] = A[i];
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
		
		public function setVector(A:Vector.<Vector.<Number>>):void
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
			
			var i:int = m;
			var j:int;
			while (i--)
			{
				j = n;
				while (j--)
					A[i][j] = vals[int(i + int(j * m))];
			}
			return matr;
		}
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/** Make a deep copy of a matrix
		 */
		
		public function copy():KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Vector.<Vector.<Number>> = X.getVector();
			for (var i:int = 0; i < m; ++i)
			{
				for (var j:int = 0; j < n; ++j)
				{
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/** Clone the Matrix object.
		 */
		
		public function clone():Object
		{
			return this.copy();
		}
		
		/** Access the internal two-dimensional array.
		   @return     Pointer to the two-dimensional array of matrix elements.
		 */
		
		public function getVector():Vector.<Vector.<Number>>
		{
			return A;
		}
		
		/** Get row dimension.
		   @return     m, the number of rows.
		 */
		
		public function getRowDimension():int
		{
			return m;
		}
		
		/** Get column dimension.
		   @return     n, the number of columns.
		 */
		
		public function getColumnDimension():int
		{
			return n;
		}
		
		/** Get a single element.
		   @param i    Row index.
		   @param j    Column index.
		   @return     A(i,j)
		   @exception  ArrayIndexOutOfBoundsException
		 */
		
		public function get(i:int, j:int):Number
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
		
		public function getMatrixWithRange(i0:int, i1:int, j0:int, j1:int):KMatrix
		{
			var X:KMatrix = new KMatrix(int(i1 - i0 + 1), int(j1 - j0 + 1));
			var B:Vector.<Vector.<Number>> = X.getVector();
			for (var i:int = i0; i <= i1; ++i)
			{
				for (var j:int = j0; j <= j1; ++j)
				{
					B[int(i - i0)][int(j - j0)] = A[i][j];
				}
			}
			return X;
		}
		
		/** Get matrix row
		   @param i   Row index
		   @return     A(i,0:lenght-1)
		*/
		public function getRow(i:int):KMatrix
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
		
		public function set(i:int, j:int, s:Number):void
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
			for (var i:int = i0; i <= i1; i++)
			{
				for (var j:int = j0; j <= j1; j++)
				{
					A[i][j] = X.get(int(i - i0), int(j - j0));
				}
			}
		}
		
		/** Matrix transpose.
		   @return    A'
		 */
		
		public function transpose():KMatrix
		{
			var X:KMatrix = new KMatrix(n, m);
			var C:Vector.<Vector.<Number>> = X.getVector();
			for (var i:int = 0; i < m; ++i)
			{
				for (var j:int = 0; j < n; ++j)
				{
					C[j][i] = A[i][j];
				}
			}
			return X;
		}
		
		/** Frobenius norm
		   @return    sqrt of sum of squares of all elements.
		 */
		
		public function normF():Number
		{
			var f:Number = 0;
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					f = Maths.hypot(f, A[i][j]);
				}
			}
			return f;
		}
			
		/** A = A + B
		   @param B    another matrix
		   @return     A + B
		 */
		
		public function plusEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = A[i][j] + B.A[i][j];
				}
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
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j] - B.A[i][j];
				}
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
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = s * A[i][j];
				}
			}
			return X;
		}
		
		/** Multiply a matrix by a scalar in place, A = s*A
		   @param s    scalar
		   @return     replace A by s*A
		 */
		
		public function timesEquals(s:Number):KMatrix
		{
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = s * A[i][j];
				}
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
		
		public final function times(B:KMatrix):KMatrix
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
			//var start:Number = getMilliseconds();
			
			var AVec:Vector.<Vector.<Number>> =	this.A;
			var BVec:Vector.<Vector.<Number>> =	B.A;
			
			var Bcolj:Vector.<Number> =	new Vector.<Number>(an, true);
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
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
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
		
		private function getMilliseconds():Number
		{
			return (new Date()).getTime();
		}
	
	}
}
