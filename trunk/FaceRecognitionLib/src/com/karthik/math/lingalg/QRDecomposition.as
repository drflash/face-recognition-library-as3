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

/** QR Decomposition.
<P>
   For an m-by-n matrix A with m >= n, the QR decomposition is an m-by-n
   orthogonal matrix Q and an n-by-n upper triangular matrix R so that
   A = Q*R.
<P>
   The QR decompostion always exists, even if the matrix does not have
   full rank, so the constructor will never fail.  The primary use of the
   QR decomposition is in the least squares solution of nonsquare systems
   of simultaneous linear equations.  This will fail if isFullRank()
   returns false.
*/

public class QRDecomposition {

/* ------------------------
   Class variables
 * ------------------------ */

   /** Array for internal storage of decomposition.
   @serial internal array storage.
   */
   private var QR:Array;

   /** Row and column dimensions.
   @serial column dimension.
   @serial row dimension.
   */
   private var m:int, n:int;

   /** Array for internal storage of diagonal of R.
   @serial diagonal of R.
   */
   private var Rdiag:Array;

/* ------------------------
   Constructor
 * ------------------------ */

   /** QR Decomposition, computed by Householder reflections.
   @param A    Rectangular matrix
   @return     Structure to access R and the Householder vectors and compute Q.
   */

   public function QRDecomposition(A:KMatrix) {
      // Initialize.
      QR = A.getArrayCopy();
      m = A.getRowDimension();
      n = A.getColumnDimension();
      Rdiag =  Maths.make1DArray(n);//new double[n];
      var i:int=0;
      var j:int=0;
      var k:int=0;
      // Main loop.
      for ( k= 0; k < n; k++) {
         // Compute 2-norm of k-th column without under/overflow.
         var nrm:Number= 0;
         for ( i= k; i < m; i++) {
            nrm = Maths.hypot(nrm,QR[i][k]);
         }

         if (nrm != 0.0) {
            // Form k-th Householder vector.
            if (QR[k][k] < 0) {
               nrm = -nrm;
            }
            for ( i= k; i < m; i++) {
               QR[i][k] /= nrm;
            }
            QR[k][k] += 1.0;

            // Apply transformation to remaining columns.
            for ( j= k+1; j < n; j++) {
               var s:Number= 0.0; 
               for ( i= k; i < m; i++) {
                  s += QR[i][k]*QR[i][j];
               }
               s = -s/QR[k][k];
               for ( i= k; i < m; i++) {
                  QR[i][j] += s*QR[i][k];
               }
            }
         }
         Rdiag[k] = -nrm;
      }
   }

/* ------------------------
   Public Methods
 * ------------------------ */

   /** Is the matrix full rank?
   @return     true if R, and hence A, has full rank.
   */

   public function isFullRank():Boolean {
       var j:int;
      for ( j= 0; j < n; j++) {
         if (Rdiag[j] == 0)
            return false;
      }
      return true;
   }

   /** Return the Householder vectors
   @return     Lower trapezoidal matrix whose columns define the reflections
   */

   public function getH():KMatrix {
       var i:int=0;
       var j:int=0;
      var X:KMatrix= new KMatrix(m,n);
      var H:Array = X.getArray();
      for ( i= 0; i < m; i++) {
         for ( j= 0; j < n; j++) {
            if (i >= j) {
               H[i][j] = QR[i][j];
            } else {
               H[i][j] = 0.0;
            }
         }
      }
      return X;
   }

   /** Return the upper triangular factor
   @return     R
   */

   public function getR():KMatrix {
       var i:int=0;
       var j:int=0;
      var X:KMatrix= new KMatrix(n,n);
      var R:Array = X.getArray();
      for ( i= 0; i < n; i++) {
         for ( j= 0; j < n; j++) {
            if (i < j) {
               R[i][j] = QR[i][j];
            } else if (i == j) {
               R[i][j] = Rdiag[i];
            } else {
               R[i][j] = 0.0;
            }
         }
      }
      return X;
   }

   /** Generate and return the (economy-sized) orthogonal factor
   @return     Q
   */

   public function getQ():KMatrix {
       var i:int=0;
       var j:int=0;
       var k:int=0;
      var X:KMatrix= new KMatrix(m,n);
      var Q:Array = X.getArray();
      for ( k= n-1; k >= 0; k--) {
         for ( i= 0; i < m; i++) {
            Q[i][k] = 0.0;
         }
         Q[k][k] = 1.0;
         for ( j= k; j < n; j++) {
            if (QR[k][k] != 0) {
               var s:Number= 0.0;
               for ( i= k; i < m; i++) {
                  s += QR[i][k]*Q[i][j];
               }
               s = -s/QR[k][k];
               for ( i= k; i < m; i++) {
                  Q[i][j] += s*QR[i][k];
               }
            }
         }
      }
      return X;
   }

   /** Least squares solution of A*X = B
   @param B    A Matrix with as many rows as A and any number of columns.
   @return     X that minimizes the two norm of Q*R*X-B.
   @exception  IllegalArgumentException  Matrix row dimensions must agree.
   @exception  RuntimeException  Matrix is rank deficient.
   */

   public function solve(B:KMatrix):KMatrix {
       var i:int=0;
       var j:int=0;
       var k:int=0;
      if (B.getRowDimension() != m) {
         throw new Error("Matrix row dimensions must agree.");
      }
      if (!this.isFullRank()) {
         throw new Error("Matrix is rank deficient.");
      }
      
      // Copy right hand side
      var nx:int= B.getColumnDimension();
      var X:Array = B.getArrayCopy();

      // Compute Y = transpose(Q)*B
      for ( k= 0; k < n; k++) {
         for ( j= 0; j < nx; j++) {
            var s:Number= 0.0; 
            for ( i= k; i < m; i++) {
               s += QR[i][k]*X[i][j];
            }
            s = -s/QR[k][k];
            for ( i= k; i < m; i++) {
               X[i][j] += s*QR[i][k];
            }
         }
      }
      // Solve R*X = Y;
      for ( k= n-1; k >= 0; k--) {
         for ( j= 0; j < nx; j++) {
            X[k][j] /= Rdiag[k];
         }
         for ( i= 0; i < k; i++) {
            for ( j= 0; j < nx; j++) {
               X[i][j] -= X[k][j]*QR[i][k];
            }
         }
      }
      return (KMatrix.makeUsingArray(X,n,nx).getMatrixWithRange(0,n-1,0,nx-1));
   }
}
}