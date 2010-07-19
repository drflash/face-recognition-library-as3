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

package com.karthik.math.lingalg {
/** Cholesky Decomposition.
   <P>
   For a symmetric, positive definite matrix A, the Cholesky decomposition
   is an lower triangular matrix L so that A = L*L'.
   <P>
   If the matrix is not symmetric or positive definite, the constructor
   returns a partial decomposition and sets an internal flag that may
   be queried by the isSPD() method.
   */

public class CholeskyDecomposition {

/* ------------------------
   Class variables
 * ------------------------ */

   /** Array for internal storage of decomposition.
   @serial internal array storage.
   */
   private var L:Array;

   /** Row and column dimension (square matrix).
   @serial matrix dimension.
   */
   private var n:int;

   /** Symmetric and positive definite flag.
   @serial is symmetric and positive definite flag.
   */
   private var isspd:Boolean;

/* ------------------------
   Constructor
 * ------------------------ */

   /** Cholesky algorithm for symmetric and positive definite matrix.
   @param  A   Square, symmetric matrix.
   @return     Structure to access L and isspd flag.
   */

   public function CholeskyDecomposition(Arg:KMatrix) {


     // Initialize.
      var A:Array = Arg.getArray();
      n = Arg.getRowDimension();
      L = Maths.make2DArray(n,n);
      isspd = (Arg.getColumnDimension() == n);
      // Main loop.
      var k:int=0;
      for (var j:int= 0; j < n; j++) {
         var Lrowj:Array= L[j];
         var d:Number= 0.0;
         for (k= 0; k < j; k++) {
            var Lrowk:Array= L[k];
            var s:Number= 0.0;
            for (var i:int= 0; i < k; i++) {
               s += Lrowk[i]*Lrowj[i];
            }
            Lrowj[k] = s = (A[j][k] - s)/L[k][k];
            d = d + s*s;
            isspd = isspd && (A[k][j] == A[j][k]); 
         }
         d = A[j][j] - d;
         isspd = isspd && (d > 0.0);
         L[j][j] = Math.sqrt(Math.max(d,0.0));
         for (k= j+1; k < n; k++) {
            L[j][k] = 0.0;
         }
      }
   }

/* ------------------------
   Temporary, experimental code.
 * ------------------------ *\

   \** Right Triangular Cholesky Decomposition.
   <P>
   For a symmetric, positive definite matrix A, the Right Cholesky
   decomposition is an upper triangular matrix R so that A = R'*R.
   This constructor computes R with the Fortran inspired column oriented
   algorithm used in LINPACK and MATLAB.  In Java, we suspect a row oriented,
   lower triangular decomposition is faster.  We have temporarily included
   this constructor here until timing experiments confirm this suspicion.
   *\

   \** Array for internal storage of right triangular decomposition. **\
   private transient double[][] R;

   \** Cholesky algorithm for symmetric and positive definite matrix.
   @param  A           Square, symmetric matrix.
   @param  rightflag   Actual value ignored.
   @return             Structure to access R and isspd flag.
   *\

   public CholeskyDecomposition (Matrix Arg, int rightflag) {
      // Initialize.
      double[][] A = Arg.getArray();
      n = Arg.getColumnDimension();
      R = new double[n][n];
      isspd = (Arg.getColumnDimension() == n);
      // Main loop.
      for (int j = 0; j < n; j++) {
         double d = 0.0;
         for (int k = 0; k < j; k++) {
            double s = A[k][j];
            for (int i = 0; i < k; i++) {
               s = s - R[i][k]*R[i][j];
            }
            R[k][j] = s = s/R[k][k];
            d = d + s*s;
            isspd = isspd & (A[k][j] == A[j][k]); 
         }
         d = A[j][j] - d;
         isspd = isspd & (d > 0.0);
         R[j][j] = Math.sqrt(Math.max(d,0.0));
         for (int k = j+1; k < n; k++) {
            R[k][j] = 0.0;
         }
      }
   }

   \** Return upper triangular factor.
   @return     R
   *\

   public Matrix getR () {
      return new Matrix(R,n,n);
   }

\* ------------------------
   End of temporary code.
 * ------------------------ */

/* ------------------------
   Public Methods
 * ------------------------ */

   /** Is the matrix symmetric and positive definite?
   @return     true if A is symmetric and positive definite.
   */

   public function isSPD():Boolean {
      return isspd;
   }

   /** Return triangular factor.
   @return     L
   */

   public function getL():KMatrix {
      return KMatrix.makeUsingArray(L,n,n);//new Matrix(L,n,n);
   }

   /** Solve A*X = B
   @param  B   A Matrix with as many rows as A and any number of columns.
   @return     X so that L*L'*X = B
   @exception  IllegalArgumentException  Matrix row dimensions must agree.
   @exception  RuntimeException  Matrix is not symmetric positive definite.
   */

   public function solve(B:KMatrix):KMatrix {
      if (B.getRowDimension() != n) {
         throw new Error("Matrix row dimensions must agree.");
      }
      if (!isspd) {
         throw new Error("Matrix is not symmetric positive definite.");
      }

      // Copy right hand side.
      var X:Array = B.getArrayCopy();
      var nx:int= B.getColumnDimension();
      var k:int=0;
      var j:int=0;
      var i:int=0;

	      // Solve L*Y = B;
	      for (k= 0; k < n; k++) {
	        for (j= 0; j < nx; j++) {
	           for (i= 0; i < k ; i++) {
	               X[k][j] -= X[i][j]*L[k][i];
	           }
	           X[k][j] /= L[k][k];
	        }
	      }
	
	      // Solve L'*X = Y;
	      for (k= n-1; k >= 0; k--) {
	        for (j= 0; j < nx; j++) {
	           for (i= k+1; i < n ; i++) {
	               X[k][j] -= X[i][j]*L[i][k];
	           }
	           X[k][j] /= L[k][k];
	        }
	      }
      
      
      return KMatrix.makeUsingArray(X,n,nx);
   }
}
}