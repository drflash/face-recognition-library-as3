/*
   Project: Karthik's Matrix Library
   Copyright 2009 Karthik Tharavaad
   http://blog.kpicturebooth.com
   karthik_tharavaad@yahoo.com

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

package com.karthik.math.lingalg
{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	
	import mx.controls.Alert;
	
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
	   <LI>Cholesky Decomposition of symmetric, positive definite matrices.
	   <LI>LU Decomposition of rectangular matrices.
	   <LI>QR Decomposition of rectangular matrices.
	   <LI>Singular Value Decomposition of rectangular matrices.
	   <LI>Eigenvalue Decomposition of both symmetric and nonsymmetric square matrices.
	   </UL>
	   <DL>
	   <DT><B>Example of use:</B></DT>
	   <P>
	   <DD>Solve a linear system A x = b and compute the residual norm, ||b - A x||.
	   <P><PRE>
	   double[][] vals = {{1.,2.,3},{4.,5.,6.},{7.,8.,10.}};
	   Matrix A = new Matrix(vals);
	   Matrix b = Matrix.random(3,1);
	   Matrix x = A.solve(b);
	   Matrix r = A.times(x).minus(b);
	   double rnorm = r.normInf();
	   </PRE></DD>
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
		protected var A:Array;
		
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
		public function KMatrix(m:int, n:int):void
		{
			this.m = m;
			this.n = n;
			A = Maths.make2DArray(m, n);
		}
		
		/** Construct an m-by-n constant matrix.
		   @param m    Number of rows.
		   @param n    Number of colums.
		   @param s    Fill the matrix with this scalar value.
		 */
		
		public static function makeWithCopy(m:int, n:int,
			s:Array):KMatrix
		{
			var matr:KMatrix = new KMatrix(m, n);
			var A:Array = matr.getArray();
			
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = s;
				}
			}
			return matr;
		}
		
		/** Construct a matrix from a 2-D array.
		   @param A    Two-dimensional array of doubles.
		   @exception  IllegalArgumentException All rows must have the same length
		   @see        #constructWithCopy
		 */
		
		public static function makeFromArray(A:Array):KMatrix
		{
			
			var m:int = A.length;
			var n:int = A[0].length;
			var matr:KMatrix = new KMatrix(m, n);
			var X:Array = matr.getArray();
			for (var i:int = 0; i < m; i++)
			{
				if (A[i].length != n)
				{
					throw new Error("All rows must have the same length.");
				}
				for (var j:int = 0; j < n; j++)
				{
					X[i][j] = A[i][j];
				}
				
			}
			return matr;
		}
		
		/** Construct a matrix from an image, make sure the bitmap is in black and white first before passing to this function otherwise it will only record
		 * the blue channel
		 * @param bmp bitmap to construct matrix from
		 */
		public static function makeFromImage(bmp:BitmapData):KMatrix
		{
			var m:int = bmp.width;
			var n:int = bmp.height;
			var matr:KMatrix = new KMatrix(m, n);
			var A:Array = matr.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = bmp.getPixel(j, i) >> 255;
				}
			}
			return matr;
		}
		
		/** Construct a matrix quickly without checking arguments.
		   @param A    Two-dimensional array of doubles.
		   @param m    Number of rows.
		   @param n    Number of colums.
		 */
		
		public static function makeUsingArray(A:Array, m:int,
			n:int):KMatrix
		{
			var matr:KMatrix = new KMatrix(m, n);
			matr.setArray(A);
			return matr;
		}
		
		public function setArray(A:Array):void
		{
			this.A = A;
		}
		
		/** Construct a matrix from a one-dimensional packed array
		   @param vals One-dimensional array of doubles, packed by columns (ala Fortran).
		   @param m    Number of rows.
		   @exception  IllegalArgumentException Array length must be a multiple of m.
		 */
		
		public static function makeFromColumnPacked(vals:Array,
			m:int):KMatrix
		{
			var n:int = (m != 0 ? vals.length / m : 0);
			if (m * n != vals.length)
			{
				throw new Error("Array length must be a multiple of m.");
			}
			
			var matr:KMatrix = new KMatrix(m, n);
			var A:Array = matr.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = vals[i + j * m];
				}
			}
			return matr;
		}
		
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/** Construct a matrix from a copy of a 2-D array.
		   @param A    Two-dimensional array of doubles.
		   @exception  IllegalArgumentException All rows must have the same length
		 */
		
		public static function constructWithCopy(A:Array):KMatrix
		{
			var m:int = A.length;
			var n:int = A[0].length;
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				if (A[i].length != n)
				{
					throw new Error("All rows must have the same length.");
				}
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/** Make a deep copy of a matrix
		 */
		
		public function copy():KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
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
		
		public function getArray():Array
		{
			return A;
		}
		
		/** Copy the internal two-dimensional array.
		   @return     Two-dimensional array copy of matrix elements.
		 */
		
		public function getArrayCopy():Array
		{
			var C:Array = Maths.make2DArray(m, n);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j];
				}
			}
			return C;
		}
		
		/** Make a one-dimensional column packed copy of the internal array.
		   @return     Matrix elements packed in a one-dimensional array by columns.
		 */
		
		public function getColumnPackedCopy():Array
		{
			var vals:Array = Maths.make1DArray(m * n);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					vals[i + j * m] = A[i][j];
				}
			}
			return vals;
		}
		
		/** Make a one-dimensional row packed copy of the internal array.
		   @return     Matrix elements packed in a one-dimensional array by rows.
		 */
		
		public function getRowPackedCopy():Array
		{
			var vals:Array = Maths.make1DArray(m * n);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					vals[i * n + j] = A[i][j];
				}
			}
			return vals;
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
		
		public function getMatrixWithRange(i0:int, i1:int, j0:int,
			j1:int):KMatrix
		{
			var X:KMatrix = new KMatrix(i1 - i0 + 1, j1 - j0 + 1);
			var B:Array = X.getArray();
			for (var i:int = i0; i <= i1; i++)
			{
				for (var j:int = j0; j <= j1; j++)
				{
					B[i - i0][j - j0] = A[i][j];
				}
			}
			return X;
		}
		
		/** Get a submatrix.
		   @param r    Array of row indices.
		   @param c    Array of column indices.
		   @return     A(r(:),c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function getMatrixWithIndex(r:Array, c:Array):KMatrix
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
		}
		
		/** Get a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param c    Array of column indices.
		   @return     A(i0:i1,c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function getMatrixWithRowRangeColumnIndex(i0:int,
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
		}
		
		/** Get a submatrix.
		   @param r    Array of row indices.
		   @param i0   Initial column index
		   @param i1   Final column index
		   @return     A(r(:),j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function getMatrixWithRowIndexColumnRange(r:Array,
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
		}
		
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
		
		public function setMatrixWithRange(i0:int, i1:int, j0:int,
			j1:int, X:KMatrix):void
		{
			for (var i:int = i0; i <= i1; i++)
			{
				for (var j:int = j0; j <= j1; j++)
				{
					A[i][j] = X.get(i - i0, j - j0);
				}
			}
		}
		
		/** Set a submatrix.
		   @param r    Array of row indices.
		   @param c    Array of column indices.
		   @param X    A(r(:),c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function setMatrixWithIndex(r:Array, c:Array,
			X:KMatrix):void
		{
			for (var i:int = 0; i < r.length; i++)
			{
				for (var j:int = 0; j < c.length; j++)
				{
					A[r[i]][c[j]] = X.get(i, j);
				}
			}
		}
		
		/** Set a submatrix.
		   @param r    Array of row indices.
		   @param j0   Initial column index
		   @param j1   Final column index
		   @param X    A(r(:),j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function setMatrixWithRowIndexColumnRange(r:Array,
			j0:int, j1:int, X:KMatrix):void
		{
			for (var i:int = 0; i < r.length; i++)
			{
				for (var j:int = j0; j <= j1; j++)
				{
					A[r[i]][j] = X.get(i, j - j0);
				}
			}
		}
		
		/** Set a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param c    Array of column indices.
		   @param X    A(i0:i1,c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */
		
		public function setMatrixWithRowRangeColumnIndex(i0:int,
			i1:int, c:Array, X:KMatrix):void
		{
			for (var i:int = i0; i <= i1; i++)
			{
				for (var j:int = 0; j < c.length; j++)
				{
					A[i][c[j]] = X.get(i - i0, j);
				}
			}
		}
		
		/** Matrix transpose.
		   @return    A'
		 */
		
		public function transpose():KMatrix
		{
			var X:KMatrix = new KMatrix(n, m);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; ++i)
			{
				for (var j:int = 0; j < n; ++j)
				{
					C[j][i] = A[i][j];
				}
			}
			return X;
		}
		
		/** One norm
		   @return    maximum column sum.
		 */
		
		public function norm1():Number
		{
			var f:Number = 0;
			for (var j:int = 0; j < n; j++)
			{
				var s:Number = 0;
				for (var i:int = 0; i < m; i++)
				{
					s += Math.abs(A[i][j]);
				}
				f = Math.max(f, s);
			}
			return f;
		}
		
		/** Two norm
		   @return    maximum singular value.
		 */
		
		public function norm2():Number
		{
			return (new SingularValueDecomposition(this).norm2());
		}
		
		/** Infinity norm
		   @return    maximum row sum.
		 */
		
		public function normInf():Number
		{
			var f:Number = 0;
			for (var i:int = 0; i < m; i++)
			{
				var s:Number = 0;
				for (var j:int = 0; j < n; j++)
				{
					s += Math.abs(A[i][j]);
				}
				f = Math.max(f, s);
			}
			return f;
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
		
		/**  Unary minus
		   @return    -A
		 */
		
		public function uminus():KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = -A[i][j];
				}
			}
			return X;
		}
		
		/** C = A + B
		   @param B    another matrix
		   @return     A + B
		 */
		
		public function plus(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j] + B.A[i][j];
				}
			}
			return X;
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
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j] - B.A[i][j];
				}
			}
			return X;
		}
		
		/** A = A - B
		   @param B    another matrix
		   @return     A - B
		 */
		
		public function minusEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = A[i][j] - B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element multiplication, C = A.*B
		   @param B    another matrix
		   @return     A.*B
		 */
		
		public function arrayTimes(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j] * B.A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element multiplication in place, A = A.*B
		   @param B    another matrix
		   @return     A.*B
		 */
		
		public function arrayTimesEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = A[i][j] * B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element right division, C = A./B
		   @param B    another matrix
		   @return     A./B
		 */
		
		public function arrayRightDivide(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = A[i][j] / B.A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element right division in place, A = A./B
		   @param B    another matrix
		   @return     A./B
		 */
		
		public function arrayRightDivideEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = A[i][j] / B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element left division, C = A.\B
		   @param B    another matrix
		   @return     A.\B
		 */
		
		public function arrayLeftDivide(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					C[i][j] = B.A[i][j] / A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element left division in place, A = A.\B
		   @param B    another matrix
		   @return     A.\B
		 */
		
		public function arrayLeftDivideEquals(B:KMatrix):KMatrix
		{
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = B.A[i][j] / A[i][j];
				}
			}
			return this;
		}
		
		/** Multiply a matrix by a scalar, C = s*A
		   @param s    scalar
		   @return     s*A
		 */
		
		public function timesScalar(s:Number):KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Array = X.getArray();
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
		
//		/** Linear algebraic matrix multiplication, A * B
//		   @param B    another matrix
//		   @return     Matrix product, A * B
//		   @exception  IllegalArgumentException Matrix inner dimensions must agree.
//		 */
//		
//		public function timesOld(B:KMatrix):KMatrix
//		{
//			var k:int = 0;
//			if (B.m != n)
//			{
//				throw new Error("Matrix inner dimensions must agree.");
//			}
//			var bn:int = B.n;
//			var X:KMatrix = new KMatrix(m, bn);
//			//trace("X wymiary "+m+" na "+ B.n);
//			var C:Array = X.getArray();
//			var Bcolj:Array = new Array(n); //new double[n];
//			
//			var j:int = 0;
//			var i:int;
//			var Arowi:Array;
//			var s:Number = 0;
//			
//			//test
//			/* var j:int, k:int, s:int;
//			   var xRowsAmount:int = X.getRowDimension();
//			   var xColumnsAmount:int = X.getColumnDimension();
//			   var bRowsAmount:int = B.getRowDimension();
//			   var licznik:Number = 0;
//			   var ba :Array= B.A.concat();
//			   for (j=0;j<xRowsAmount;j++) {
//			   var xaj:Array = (X.A[j] as Array).concat();
//			   var aj:Array =  (A[j] as Array).concat();
//			   for (k=0;k<xColumnsAmount;k++) {
//			   for (s=0;s<bRowsAmount;s++){licznik++;
//			   var bas:Array = (ba[s] as Array).concat();;
//			   xaj[k] += aj[s]*bas[k];
//			   }
//			   }
//			   X.A[j] = xaj.concat();
//			
//			   }
//			 trace(xRowsAmount +"*"+xColumnsAmount+"*"+bRowsAmount+"="+licznik); */
//			//test
//			
//			var start:Number = getMilliseconds();
//			var ba:Array = B.A;
//			var licznik:Number = 0;
//			while (j < bn)
//			{
//				k = 0;
//				while (k < n)
//				{
//					Bcolj[k] = ba[k][j];
//					++k;
//				}
//				for (i = 0; i < m; ++i)
//				{
//					Arowi = A[i];
//					s = 0;
//					
//					for (k = 0; k < n; ++k)
//					{
//						s += Arowi[k] * Bcolj[k];
//						licznik++;
//					}
//					C[i][j] = s; //inverted indexes to use linear acces to memory (litle faster)
//				}
//				++j;
//			}
//			X.setArray(C);
//			if ((getMilliseconds() - start) > 30)
//			{
//				trace("Licznik = " + licznik);
//				Alert.show("Mnozenie macierzy trawalo = " + (getMilliseconds() - start).toString() + " ms");
//			}
//			return X;
//		}
		
		/** Linear algebraic matrix multiplication, A * B
		   @param B    another matrix
		   @return     Matrix product, A * B
		   @exception  IllegalArgumentException Matrix inner dimensions must agree.
		 *
		 * @author Oskar Wicha
		 */
		
		public function times(B:KMatrix):KMatrix
		{
			if (B.m != this.n)
			{
				throw new Error("Matrix inner dimensions must agree.");
			}
			var bn:int = B.n;
			var an:int = this.n;
			var X:KMatrix = new KMatrix(this.m, bn);
			// trace("X wymiary "+m+" na "+ B.n);
			var C:Array = X.getArray();
			//var CVec:Vector.<Vector.<Number>> = create2dVectorOfNumberObjects(m,bn);
			
			var AVec:Vector.<Vector.<Number>> =
				create2dVectorOfNumbersFrom2dArrayOfNumbers(this.A);
			var BVec:Vector.<Vector.<Number>> =
				create2dVectorOfNumbersFrom2dArrayOfNumbers(B.A);
			
			var Bcolj:Vector.<Number> =
				new Vector.<Number>(an, true);
			var Arowi:Vector.<Number>;
			var j:int = 0, i:int, k:int, s:Number = 0;
			
			//var start:Number = getMilliseconds();
			
			while (j < bn)
			{
				k = 0;
				while (k < an)
				{
					Bcolj[k] = BVec[k][j];
					++k;
				}
				
				for (i = 0; i < m; ++i)
				{
					Arowi = Vector.<Number>(AVec[i]);
					Arowi.fixed = true;
					s = 0;
					
					for (k = 0; k < an; ++k)
						s = (Arowi[k] * Bcolj[k]) + s;
					
					C[i][j] = s; //could be something incorect with i or j because vectors have problem sometimes
				}
				++j;
			}
			X.setArray(C);
			//if ((getMilliseconds() - start) > 30)
			//Alert.show("Mnozenie macierzy trawalo = " + (getMilliseconds() - start).toString() + " ms");
			//trace("Mnozenie macierzy trawalo = "+(getMilliseconds()-start).toString()+" ms");
			return X;
		}
		
		private final function create2dVectorOfNumberObjects(m:uint,
			n:uint):Vector.<Vector.<Number>>
		{
			var vector:Vector.<Vector.<Number>> =
				new Vector.<Vector.<Number>>(m, true);
			for (var i:int = 0; i < n; ++i)
				vector[i] = new Vector.<Number>(n, true);
			
			return vector;
		}
		
		private final function copy2dArrayTo2dVectorOfNumberObjects(array2dOfNumbers:Array,
			vector2dOfNumbers:Vector.<Vector.<Number>>):void
		{
			if ((vector2dOfNumbers.length == array2dOfNumbers.length) &&
				(vector2dOfNumbers[0] as Vector.<Number>).length == (array2dOfNumbers[0] as Array).length)
			{
				var m:int = vector2dOfNumbers.length;
				var n:int =
					Vector.<Number>(vector2dOfNumbers[0]).length;
				
				for (var i:int = 0; i < m; ++i)
					for (var j:int = 0; j < n; ++j)
						vector2dOfNumbers[i][j] =
							Number(array2dOfNumbers[i][j]);
				
			}
			else
				throw new Error("Array and Vector dimensions must agree.");
		}
		
		private final function create2dVectorOfNumbersFrom2dArrayOfNumbers(array2dOfNumbers:Array):Vector.<Vector.<Number>>
		{
			const m:int = array2dOfNumbers.length;
			const n:int = (array2dOfNumbers[0] as Array).length;
			var i:int = m;
			var j:int = n;
			
			var vector:Vector.<Vector.<Number>> =
				new Vector.<Vector.<Number>>(m, true);
			
			while (--i > -1)
			{
				vector[i] = new Vector.<Number>(n, true);
				j = n;
				while (--j > -1)
				{
					vector[i][j] = Number(array2dOfNumbers[i][j]);
				}
			}
			return vector;
		}
		
		private function getMilliseconds():Number
		{
			return (new Date()).getTime();
		}
		
		/** LU Decomposition
		   @return     LUDecomposition
		   @see LUDecomposition
		 */
		
		public function lu():LUDecomposition
		{
			return new LUDecomposition(this);
		}
		
		/** QR Decomposition
		   @return     QRDecomposition
		   @see QRDecomposition
		 */
		
		public function qr():QRDecomposition
		{
			return new QRDecomposition(this);
		}
		
		/** Cholesky Decomposition
		   @return     CholeskyDecomposition
		   @see CholeskyDecomposition
		 */
		
		public function chol():CholeskyDecomposition
		{
			return new CholeskyDecomposition(this);
		}
		
		/** Singular Value Decomposition
		   @return     SingularValueDecomposition
		   @see SingularValueDecomposition
		 */
		
		public function svd():SingularValueDecomposition
		{
			return new SingularValueDecomposition(this);
		}
		
		/** Eigenvalue Decomposition
		   @return     EigenvalueDecomposition
		   @see EigenvalueDecomposition
		 */
		
		public function eig():EigenvalueDecomposition
		{
			return new EigenvalueDecomposition(this);
		}
		
		/** Solve A*X = B
		   @param B    right hand side
		   @return     solution if A is square, least squares solution otherwise
		 */
		
		public function solve(B:KMatrix):KMatrix
		{
			return (m == n ? (new LUDecomposition(this)).solve(B) : (new QRDecomposition(this)).solve(B));
		}
		
		/** Solve X*A = B, which is also A'*X' = B'
		   @param B    right hand side
		   @return     solution if A is square, least squares solution otherwise.
		 */
		
		public function solveTranspose(B:KMatrix):KMatrix
		{
			return transpose().solve(B.transpose());
		}
		
		/** Matrix inverse or pseudoinverse
		   @return     inverse(A) if A is square, pseudoinverse otherwise.
		 */
		
		public function inverse():KMatrix
		{
			return solve(identity(m, m));
		}
		
		/** Matrix determinant
		   @return     determinant
		 */
		
		public function det():Number
		{
			return new LUDecomposition(this).det();
		}
		
		/** Matrix rank
		   @return     effective numerical rank, obtained from SVD.
		 */
		
		public function rank():int
		{
			return new SingularValueDecomposition(this).rank();
		}
		
		/** Matrix condition (2 norm)
		   @return     ratio of largest to smallest singular value.
		 */
		
		public function cond():Number
		{
			return new SingularValueDecomposition(this).cond();
		}
		
		/** Matrix trace.
		   @return     sum of the diagonal elements.
		 */
		
		public function traceMatrix():Number
		{
			var t:Number = 0;
			for (var i:int = 0; i < Math.min(m, n); i++)
			{
				t += A[i][i];
			}
			return t;
		}
		
		/** Generate matrix with random elements
		   @param m    Number of rows.
		   @param n    Number of colums.
		   @return     An m-by-n matrix with uniformly distributed random elements.
		 */
		
		public static function random(m:int, n:int):KMatrix
		{
			var A:KMatrix = new KMatrix(m, n);
			var X:Array = A.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					X[i][j] = Math.random();
				}
			}
			return A;
		}
		
		/** Generate identity matrix
		   @param m    Number of rows.
		   @param n    Number of colums.
		   @return     An m-by-n matrix with ones on the diagonal and zeros elsewhere.
		 */
		
		public static function identity(m:int, n:int):KMatrix
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
		}
		
		/*
		 *
		 * Extensions to the Matrix class made by me to make life easier
		 *
		 * */
		
		/** Construct a matrix from a one-dimensional packed array
		   @param vals One-dimensional array of doubles, packed by row (ala Fortran).
		   @param m    Number of rows.
		   @exception  IllegalArgumentException Array length must be a multiple of m.
		 */
		
		public static function makeFromRowPacked(vals:Array,
			m:int):KMatrix
		{
			
			var n:int = (m != 0 ? vals.length / m : 0);
			
			if (m * n != vals.length)
			{
				throw new Error("Array length must be a multiple of m.");
			}
			var matr:KMatrix = new KMatrix(m, n);
			var A:Array = matr.getArray();
			for (var i:int = 0; i < m; i++)
			{
				for (var j:int = 0; j < n; j++)
				{
					A[i][j] = vals[i * n + j];
				}
			}
			return matr;
		}
		
		/**
		 * Get rows of a matrix
		 * @param args the indices corresponding to the row numbers
		 * @return A(args, 0:end)
		 * @exception ArrayIndexOutOfBoundsException Submatrix indices
		 */
		public function getRows(... args):KMatrix
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
		}
		
		/**
		 * Get columns of a matrix
		 * @param args the indices corresponding to the row numbers
		 * @return A(args, 0:end)
		 * @exception ArrayIndexOutOfBoundsException Submatrix indices
		 */
		public function getColumns(... args):KMatrix
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
		}
		
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
	
	}
}
