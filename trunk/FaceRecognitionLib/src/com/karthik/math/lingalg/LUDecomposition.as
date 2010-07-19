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

package com.karthik.math.lingalg{
/** LU Decomposition.
   <P>
   For an m-by-n matrix A with m >= n, the LU decomposition is an m-by-n
   unit lower triangular matrix L, an n-by-n upper triangular matrix U,
   and a permutation vector piv of length m so that A(piv,:) = L*U.
   If m < n, then L is m-by-m and U is m-by-n.
   <P>
   The LU decompostion with pivoting always exists, even if the matrix is
   singular, so the constructor will never fail.  The primary use of the
   LU decomposition is in the solution of square systems of simultaneous
   linear equations.  This will fail if isNonsingular() returns false.
   */

public class LUDecomposition {

/* ------------------------
   Class variables
 * ------------------------ */

   /** Array for internal storage of decomposition.
   @serial internal array storage.
   */
   private var LU:Array;

   /** Row and column dimensions, and pivot sign.
   @serial column dimension.
   @serial row dimension.
   @serial pivot sign.
   */
   private var m:int;
   private var n:int; 
   private var pivsign:int; 

   /** Internal storage of pivot vector.
   @serial pivot vector.
   */
   private var piv:Array;

/* ------------------------
   Constructor
 * ------------------------ */

   /** LU Decomposition
   @param  A   Rectangular matrix
   @return     Structure to access L, U and piv.
   */

   public function LUDecomposition(A:KMatrix) {

   // Use a "left-looking", dot-product, Crout/Doolittle algorithm.

      LU = A.getArrayCopy();
      m = A.getRowDimension();
      n = A.getColumnDimension();
      
      var i:int=0;
      var k:int=0;
      piv = Maths.make1DArray(m);;
      for (i= 0; i < m; i++) {
         piv[i] = i;
      }
      pivsign = 1;
      var LUrowi:Array;
      var LUcolj:Array= Maths.make1DArray(m);;
    
      // Outer loop.

      for (var j:int= 0; j < n; j++) {

         // Make a copy of the j-th column to localize references.

         for (i= 0; i < m; i++) {
            LUcolj[i] = LU[i][j];
         }

         // Apply previous transformations.

         for (i= 0; i < m; i++) {
            LUrowi = LU[i];

            // Most of the time is spent in the following dot product.

            var kmax:int= Math.min(i,j);
            var s:Number= 0.0;
            for (k= 0; k < kmax; k++) {
               s += LUrowi[k]*LUcolj[k];
            }

            LUrowi[j] = LUcolj[i] -= s;
         }
   
         // Find pivot and exchange if necessary.

         var p:int= j;
         for (i= j+1; i < m; i++) {
            if (Math.abs(LUcolj[i]) > Math.abs(LUcolj[p])) {
               p = i;
            }
         }
         if (p != j) {
            for (k= 0; k < n; k++) {
               var t:Number= LU[p][k]; LU[p][k] = LU[j][k]; LU[j][k] = t;
            }
            k= piv[p]; piv[p] = piv[j]; piv[j] = k;
            pivsign = -pivsign;
         }

         // Compute multipliers.
         
         if (j < m && LU[j][j] != 0.0) {
            for (i= j+1; i < m; i++) {
               LU[i][j] /= LU[j][j];
            }
         }
      }
   }

/* ------------------------
   Temporary, experimental code.
   ------------------------ *\

   \** LU Decomposition, computed by Gaussian elimination.
   <P>
   This constructor computes L and U with the "daxpy"-based elimination
   algorithm used in LINPACK and MATLAB.  In Java, we suspect the dot-product,
   Crout algorithm will be faster.  We have temporarily included this
   constructor until timing experiments confirm this suspicion.
   <P>
   @param  A             Rectangular matrix
   @param  linpackflag   Use Gaussian elimination.  Actual value ignored.
   @return               Structure to access L, U and piv.
   *\

   public LUDecomposition (Matrix A, int linpackflag) {
      // Initialize.
      LU = A.getArrayCopy();
      m = A.getRowDimension();
      n = A.getColumnDimension();
      piv = new int[m];
      for (int i = 0; i < m; i++) {
         piv[i] = i;
      }
      pivsign = 1;
      // Main loop.
      for (int k = 0; k < n; k++) {
         // Find pivot.
         int p = k;
         for (int i = k+1; i < m; i++) {
            if (Math.abs(LU[i][k]) > Math.abs(LU[p][k])) {
               p = i;
            }
         }
         // Exchange if necessary.
         if (p != k) {
            for (int j = 0; j < n; j++) {
               double t = LU[p][j]; LU[p][j] = LU[k][j]; LU[k][j] = t;
            }
            int t = piv[p]; piv[p] = piv[k]; piv[k] = t;
            pivsign = -pivsign;
         }
         // Compute multipliers and eliminate k-th column.
         if (LU[k][k] != 0.0) {
            for (int i = k+1; i < m; i++) {
               LU[i][k] /= LU[k][k];
               for (int j = k+1; j < n; j++) {
                  LU[i][j] -= LU[i][k]*LU[k][j];
               }
            }
         }
      }
   }

\* ------------------------
   End of temporary code.
 * ------------------------ */

/* ------------------------
   Public Methods
 * ------------------------ */

   /** Is the matrix nonsingular?
   @return     true if U, and hence A, is nonsingular.
   */

   public function isNonsingular():Boolean {
      for (var j:int= 0; j < n; j++) {
         if (LU[j][j] == 0)
            return false;
      }
      return true;
   }

   /** Return lower triangular factor
   @return     L
   */

   public function getL():KMatrix {
      var X:KMatrix= new KMatrix(m,n);
      var L:Array = X.getArray();
      for (var i:int= 0; i < m; i++) {
         for (var j:int= 0; j < n; j++) {
            if (i > j) {
               L[i][j] = LU[i][j];
            } else if (i == j) {
               L[i][j] = 1.0;
            } else {
               L[i][j] = 0.0;
            }
         }
      }
      return X;
   }

   /** Return upper triangular factor
   @return     U
   */

   public function getU():KMatrix {
      var X:KMatrix= new KMatrix(n,n);
      var U:Array = X.getArray();
      for (var i:int= 0; i < n; i++) {
         for (var j:int= 0; j < n; j++) {
            if (i <= j) {
               U[i][j] = LU[i][j];
            } else {
               U[i][j] = 0.0;
            }
         }
      }
      return X;
   }

   /** Return pivot permutation vector
   @return     piv
   */

   public function getPivot ():Array {
      var p:Array= Maths.make1DArray(m);
      for (var i:int= 0; i < m; i++) {
         p[i] = piv[i];
      }
      return p;
   }

   /** Return pivot permutation vector as a one-dimensional double array
   @return     (double) piv
   */

   public function getDoublePivot ():Array {
      var vals:Array= Maths.make1DArray(m);
      for (var i:int= 0; i < m; i++) {
         vals[i] = piv[i];
      }
      return vals;
   }

   /** Determinant
   @return     det(A)
   @exception  IllegalArgumentException  Matrix must be square
   */

   public function det():Number {
      if (m != n) {
         throw new Error("Matrix must be square.");
      }
      var d:Number= Number(pivsign);
      for (var j:int= 0; j < n; j++) {
         d *= LU[j][j];
      }
      return d;
   }

   /** Solve A*X = B
   @param  B   A Matrix with as many rows as A and any number of columns.
   @return     X so that L*U*X = B(piv,:)
   @exception  IllegalArgumentException Matrix row dimensions must agree.
   @exception  RuntimeException  Matrix is singular.
   */

   public function solve(B:KMatrix):KMatrix {
      var i:int=0;
      var k:int=0;
      var j:int=0;
      if (B.getRowDimension() != m) {
         throw new Error("Matrix row dimensions must agree.");
      }
      if (!this.isNonsingular()) {
         throw new Error("Matrix is singular.");
      }

      // Copy right hand side with pivoting
      var nx:int= B.getColumnDimension();
      var Xmat:KMatrix= B.getMatrixWithRowIndexColumnRange(piv,0,nx-1); // B.getMatrix(piv,0,nx-1);
      var X:Array = Xmat.getArray();

      // Solve L*Y = B(piv,:)
      for (k= 0; k < n; k++) {
         for (i= k+1; i < n; i++) {
            for (j= 0; j < nx; j++) {
               X[i][j] -= X[k][j]*LU[i][k];
            }
         }
      }
      // Solve U*X = Y;
      for (k= n-1; k >= 0; k--) {
         for (j= 0; j < nx; j++) {
            X[k][j] /= LU[k][k];
         }
         for (i= 0; i < k; i++) {
            for (j= 0; j < nx; j++) {
               X[i][j] -= X[k][j]*LU[i][k];
            }
         }
      }
      return Xmat;
   }
}
}