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
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
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
	public class KMatrix implements IExternalizable
	{
		/* ------------------------
		Class variables
		* ------------------------ */
		
		/** Vector for internal storage of elements.
		 */
		protected var A:Vector.<Vector.<Number>>;
		
		/** Row dimensions.
		 @serial row dimension.
		 */
		protected var m:int;
		
		/** Column dimensions.
		 @serial column dimension.
		 */
		protected var n:int;
		
		/* ------------------------
		Constructor
		* ------------------------ */
		
		/** Construct an m-by-n matrix of zeros.
		 @param m    Number of rows.
		 @param n    Number of colums.
		 */
		public final function KMatrix(m:int=3, n:int=3):void
		{
			this.m = m;
			this.n = n;
			A = Maths.make2DVector(m, n);
		}
		
		/** Construct a matrix from a 2D Vector.<Number>.
		 @param A    Two-dimensional vector of doubles.
		 @exception  IllegalArgumentException All rows must have the same length
		 @see        #constructWithCopy
		 */
		
		public static function makeFromVector(A:Vector.<Vector.<Number>>):KMatrix
		{
			var m:int = A.length;
			var n:uint = A[0].length;
			var matr:KMatrix = new KMatrix(m, n);
			var X:Vector.<Vector.<Number>> = matr.A; 
			
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
		 @param A    Two-dimensional Vector of Numbers.
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
			var A:Vector.<Vector.<Number>> = matr.A;
			var Ai:Vector.<Number>;
			var i:uint = m;
			var j:uint;
			
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
		
		/** Makes a deep copy of a matrix
		 */
		
		public final function copy():KMatrix
		{
			var X:KMatrix = new KMatrix(m, n);
			var C:Vector.<Vector.<Number>> = X.A;
			for (var i:uint = 0; i < m; ++i)
			{
				for (var j:uint = 0; j < n; ++j)
				{
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/** Makes empty copy of a matrix
		 */
		
		public final function copyEmpty():KMatrix
		{
			return new KMatrix(m, n);
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
		
		/** Get vector with values on diagonal
		 @return     Diagonal of A
		 */
		
		public final function getDiag():Vector.<Number>
		{
			var i:int = (n < m) ? n : m;
			var dvec:Vector.<Number> = new Vector.<Number>(i, true);
			
			while (i--)
				dvec[i] = A[i][i];
			
			return dvec;
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
			var B:Vector.<Vector.<Number>> = X.A;
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
		public function getRow(row:uint):KMatrix
		{
			var X:KMatrix = new KMatrix(1, this.n);
			X.A[0] = A[row];
			
			return X;
		}
		
		/** Get matrix row as <code>Vector.<Number></code>
		 @param i   Row index
		 @param maxRows	Returns <code>maxCols</code> values in Vector
		 *  if <code>KMatrix</code> has more or the same number of columns
		 *  else all values in row are returned in Vector;
		 @return     A(i,0:((length >= maxCols)? maxCols : length)-1)
		 */
		public function getRowAsVector(row:uint, maxCols:uint = uint.MAX_VALUE):Vector.<Number>
		{
			if(this.n <= maxCols)
			{
				return A[row];
			}
			else
			{
				var col:uint = maxCols;
				var V:Vector.<Number> = new Vector.<Number>(col, true);
				var Arow:Vector.<Number> = A[row];
				
				while(col--)
					V[col] = Arow[col];
				
				return V;
			}
		}
		
		
		/** Get matrix column
		 @param i   Column index
		 @return     A(0:lenght-1,i)
		 */
		public function getCol(col:uint):KMatrix
		{
			var X:KMatrix = new KMatrix(this.m, 1);
			var B:Vector.<Vector.<Number>> = X.A;
			var row:uint = this.m;
			
			while(row--)
				B[row][0] = A[row][col];
			
			return X;
		}
		
		/** Get matrix column as <code>Vector.<Number></code>
		 @param i   Column index
		 @param maxRows	Returns <code>maxRows</code> values in Vector
		 *  if <code>KMatrix</code> has more or the same number of rows
		 *  else all values in column are returned in Vector;
		 @return     A(0:((length >= maxRows)? maxRows : length)-1, i)
		 */
		public function getColAsVector(col:uint, maxRows:uint = uint.MAX_VALUE):Vector.<Number>
		{
			var row:uint = (this.m >= maxRows) ? maxRows : this.m;
			var V:Vector.<Number> = new Vector.<Number>(row, true);
			
			while(row--)
				V[row] = A[row][col];
			
			return V;
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
		
		public function setMatrixWithRange(i0:uint, i1:uint, j0:uint, j1:uint, X:KMatrix):void
		{
			var XA:Vector.<Vector.<Number>> = X.A;
			var XAi_i0:Vector.<Number>;
			var Ai:Vector.<Number>;
			
			if((i1-i0) != X.m-1 || (j1-j0) != X.n-1)
				throw Error("Dimmensions of selected region and matrix X are not the same.");
			
			for (var i:uint = i0; i <= i1; ++i)
			{
				XAi_i0 = XA[uint(i - i0)];
				Ai = A[i];
				
				for (var j:uint = j0; j <= j1; ++j)
					Ai[j] = XAi_i0[uint(j - j0)];
			}
		}
		
		/** Set matrix column
		 @param i   Column index
		 @param X Matrix containing new column values
		 */
		public function setCol(col:uint, X:KMatrix):void
		{
			if(X.m != this.m || X.n != 1)
				return;
			
			var XA:Vector.<Vector.<Number>> = X.A;
			var Ai:Vector.<Number>;
			var XAi:Vector.<Number>;
			
			for (var i:uint = 0; i < m; ++i)
			{
				Ai = A[i];
				XAi = XA[i];
				Ai[col] = XAi[0];
				A[i] = Ai;
			}
		}
		
		/** Matrix transpose.
		 @return    A'
		 */
		
		public function transpose():KMatrix
		{
			var X:KMatrix = new KMatrix(this.n, this.m);
			var C:Vector.<Vector.<Number>> = X.A;
			var Ai:Vector.<Number>;
			var i:uint;
			var j:uint;
			var srcRows:uint = this.m;
			var srcCols:uint = this.n;

			if(!(srcCols % 4))
			{
				// Unrolled version 10% faster
				for (i = 0; i < srcRows; ++i)
				{
					Ai = A[i];
					for (j = 0; j < srcCols;)
					{
						C[j][i] = Ai[j++];
						C[j][i] = Ai[j++];
						C[j][i] = Ai[j++];
						C[j][i] = Ai[j++];
					}
				}
			}
			else
			{
				for (i = 0; i < srcRows; ++i)
				{
					Ai = A[i];
					for (j = 0; j < srcCols; ++j)
						C[j][i] = Ai[j];
				}
			}
			
			return X;
		}
		
		/** Frobenius norm
		 @return    sqrt of sum of squares of all elements.
		 */
		
		public function normF():Number
		{
			var Ai:Vector.<Number>;
			var f:Number = 0.0;
			var i:uint;
			var j:uint;
			
			if(!(this.n % 4))
			{
				// Unrolled version 25% faster
				for (i = 0; i < this.m; ++i)
				{
					Ai = A[i];
					for (j = 0; j < this.n;)
					{
						f = Maths.hypot(f, Ai[j++]);
						f = Maths.hypot(f, Ai[j++]);
						f = Maths.hypot(f, Ai[j++]);
						f = Maths.hypot(f, Ai[j++]);
					}
				}
			}
			else
			{
				for (i = 0; i < this.m; ++i)
				{
					Ai = A[i];
					for (j = 0; j < this.n; ++j)
						f = Maths.hypot(f, Ai[j]);
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
			var Ai:Vector.<Number>;
			var BAi:Vector.<Number>;
			var i:uint;
			var j:uint;
			
			checkMatrixDimensions(B);
			
			if(!(this.n % 4))
			{
				for (i = 0; i < this.m; ++i)
				{
					Ai = A[i];
					BAi = B.A[i];
					for (j = 0; j < this.n;)
					{
						Ai[j] += BAi[j++];
						Ai[j] += BAi[j++];
						Ai[j] += BAi[j++];
						Ai[j] += BAi[j++];
					}
				}
			}
			else
			{
				for (i = 0; i < this.m; ++i)
				{
					Ai = A[i];
					BAi = B.A[i];
					for (j = 0; j < this.n; ++j)
					{
						Ai[j] += BAi[j];
					}
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
			
			var X:KMatrix = new KMatrix(this.m, this.n);
			var C:Vector.<Vector.<Number>> = X.A;
			var Ci:Vector.<Number>;
			var Ai:Vector.<Number>;
			var BAi:Vector.<Number>;
			var i:uint;
			var j:uint;
			
			if(!(this.n % 4))
			{
				// Unrolled				
				for (i = 0; i < m; ++i)
				{
					Ci = C[i];
					Ai = A[i];
					BAi = B.A[i];
					for (j = 0; j < n;)
					{
						Ci[j] = Ai[j] - BAi[j++];
						Ci[j] = Ai[j] - BAi[j++];
						Ci[j] = Ai[j] - BAi[j++];
						Ci[j] = Ai[j] - BAi[j++];
					}
				}
			}
			else
			{
				for (i = 0; i < m; ++i)
				{
					Ci = C[i];
					Ai = A[i];
					BAi = B.A[i];
					for (j = 0; j < n; ++j)
					{
						Ci[j] = Ai[j] - BAi[j];
					}
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
			
			var Ai:Vector.<Number>;
			var BAi:Vector.<Number>;
			
			for (var i:uint = 0; i < m; ++i)
			{
				Ai = A[i];
				BAi = B.A[i];
				for (var j:uint = 0; j < n; ++j)
				{
					Ai[j] -= BAi[j];
				}
				A[i] = Ai;
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
			var C:Vector.<Vector.<Number>> = X.A;
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
			}
			return X;
		}
		
		/** Multiply a matrix by a scalar in place, A = s*A
		 @param s    scalar
		 */
		
		public function timesEquals(s:Number):void
		{
			var Ai:Vector.<Number>;
			var i:uint;
			var j:uint;
			
			if(!(this.n % 4))
			{
				// Unrolled version 30% faster
				for (i = 0; i < m; ++i)
				{
					Ai = A[i];
					for (j = 0; j < n;)
					{
						Ai[j++] *= s;
						Ai[j++] *= s;
						Ai[j++] *= s;
						Ai[j++] *= s;
					}
				}
			}
			else
			{
				for (i = 0; i < m; ++i)
				{
					Ai = A[i];
					for (j = 0; j < n; ++j)
					{
						Ai[j] *= s;
					}
				}
			}
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
			var C:Vector.<Vector.<Number>> = X.A;
			var AVec:Vector.<Vector.<Number>> = this.A;
			var BVec:Vector.<Vector.<Number>> = B.A;
			
			var Bcolj:Vector.<Number> =   new Vector.<Number>(an, true);
			var Arowi:Vector.<Number>= new Vector.<Number>(an, true);
			var j:int = bn, i:int, k:int, s:Number;
			
			if(!(this.n % 4))
			{
				// Unrolled version 35% faster
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
						{
							s = Number(Arowi[k] * Bcolj[k]) + s;
							--k;
							s = Number(Arowi[k] * Bcolj[k]) + s;
							--k;
							s = Number(Arowi[k] * Bcolj[k]) + s;
							--k;
							s = Number(Arowi[k] * Bcolj[k]) + s;
						}
						
						C[i][j] = Number(s);
					}
				}
			}
			else
			{
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
							s = Number(Arowi[k] * Bcolj[k]) + s;
						
						C[i][j] = Number(s);
					}
				}
			}
			X.setVector(C);
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
		
		private final function checkMatrixDimensions(B:KMatrix):void
		{
			if (B.m != m || B.n != n)
			{
				throw new Error("Matrix dimensions must agree.");
			}
		}
		
		// IExtensible implementation
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeInt(m);
			output.writeInt(n);
			output.writeObject(A);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			m = input.readInt();
			n = input.readInt();
			A = Vector.<Vector.<Number>>(input.readObject());
		}
	}
}
