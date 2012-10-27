/*
  Project: Karthik's Matrix Library
  Copyright 2009 Karthik Tharavaad
  http://blog.kpicturebooth.com
  karthik_tharavaad@yahoo.com

  Converte from Arrays to Vectors by Oskar Wicha

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

	/** Eigenvalues and eigenvectors of a real matrix.
	<P>
		If A is symmetric, then A = V*D*V' where the eigenvalue matrix D is
		diagonal and the eigenvector matrix V is orthogonal.
		I.e. A = V.times(D.times(V.transpose())) and
		V.times(V.transpose()) equals the identity matrix.
	<P>
		If A is not symmetric, then the eigenvalue matrix D is block diagonal
		with the real eigenvalues in 1-by-1 blocks and any complex eigenvalues,
		lambda + i*mu, in 2-by-2 blocks, [lambda, mu; -mu, lambda].  The
		columns of V represent the eigenvectors in the sense that A*V = V*D,
		i.e. A.times(V) equals V.times(D).  The matrix V may be badly
		conditioned, or even singular, so the validity of the equation
		A = V*D*inverse(V) depends upon V.cond().
	**/
	internal class EigenvalueDecomposition
	{
		/* ------------------------
		   Constructor
		 * ------------------------ */

		/** Check for symmetry, then construct the eigenvalue decomposition
		@param A    Square matrix
		@return     Structure to access D and V.
		*/
		public function EigenvalueDecomposition(Arg:KMatrix)
		{
			var A:Vector.<Vector.<Number>> = Arg.getVector();
			__n = Arg.getColumnDimension();

			__V = Maths.make2DVector(__n, __n);
			__d = new Vector.<Number>(__n);
			__e = new Vector.<Number>(__n);
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;

			__issymmetric = true;
			for (j = 0; (j < __n) && __issymmetric; ++j)
			{
				for (i = 0; (i < __n) && __issymmetric; ++i)
				{
					__issymmetric = (A[i][j] == A[j][i]);
				}
			}

			if (__issymmetric)
			{
				for (i = 0; i < __n; ++i)
				{
					var Ai:Vector.<Number> = A[i];
					var Vi:Vector.<Number> = __V[i];
					
					for (j = 0; j < __n; ++j)
					{
						Vi[j] = Ai[j];
					}
				}

				// Tridiagonalize.
				tred2();

				// Diagonalize.
				tql2();
			}
			else
			{
				__H = Maths.make2DVector(__n, __n);
				__ort = new Vector.<Number>(__n);

				for (i = 0; i < __n; ++i)
				{
					var Ai2:Vector.<Number> = A[i];
					var Hi:Vector.<Number> = __H[i];
					
					for (j = 0; j < __n; ++j)
					{
						Hi[j] = Ai2[j];
					}
				}

				// Reduce to Hessenberg form.
				orthes();

				// Reduce Hessenberg to real Schur form.
				hqr2();
			}
		}

		/** Vector for internal storage of nonsymmetric Hessenberg form.
		@serial internal storage of nonsymmetric Hessenberg form.
		*/
		private var __H:Vector.<Vector.<Number>>;

		/** Vector for internal storage of eigenvectors.
		@serial internal storage of eigenvectors.
		*/
		private var __V:Vector.<Vector.<Number>>;
		private var __cdivi:Number = 0.0;

		// Complex scalar division.
		private var __cdivr:Number = 0.0;

		/** Vectors for internal storage of eigenvalues.
		@serial internal storage of eigenvalues.
		*/
		private var __d:Vector.<Number>;
		private var __e:Vector.<Number>;

		/** Symmetry flag.
		@serial internal symmetry flag.
		*/
		private var __issymmetric:Boolean;

		/* ------------------------
		   Class variables
		 * ------------------------ */

		/** Row and column dimension (square matrix).
		@serial matrix dimension.
		*/
		private var __n:int;

		/** Working storage for nonsymmetric algorithm.
		@serial working storage for nonsymmetric algorithm.
		*/
		private var __ort:Vector.<Number>;

		/** Return the block diagonal eigenvalue matrix
		@return     D
		*/

		public function getD():KMatrix
		{
			var X:KMatrix = new KMatrix(__n, __n);
			var D:Vector.<Vector.<Number>> = X.getVector();
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			
			for (i = 0; i < __n; ++i)
			{
				var Di:Vector.<Number> = D[i];
				for (j = 0; j < __n; ++j)
				{
					Di[j] = 0.0;
				}
								
				Di[i] = __d[i];
				
				var ei:Number = __e[i];
				if (ei > 0)
				{
					Di[uint(i + 1)] = ei;
				}
				else if (ei < 0)
				{
					Di[uint(i - 1)] = ei;
				}
			}
			return X;
		}

		/** Return the imaginary parts of the eigenvalues
		@return     imag(diag(D))
		*/

		public function getImagEigenvalues():Vector.<Number>
		{
			return __e;
		}

		/** Return the real parts of the eigenvalues
		@return     real(diag(D))
		*/

		public function getRealEigenvalues():Vector.<Number>
		{
			return __d;
		}

		/** Return the eigenvector matrix
		@return     V
		*/

		public function getV():KMatrix
		{
			return KMatrix.makeUsingVector(__V, __n, __n);
		}

		/* ------------------------
		   Public Methods
		 * ------------------------ */

		private function cdiv(xr:Number, xi:Number, yr:Number, yi:Number):void
		{
			var r:Number = 0;
			var d:Number = 0;
			
			if (Maths.abs(yr) > Maths.abs(yi))
			{
				r = yi / yr;
				d = yr + r * yi;
				__cdivr = (xr + r * xi) / d;
				__cdivi = (xi - r * xr) / d;
			}
			else
			{
				r = yr / yi;
				d = yi + r * yr;
				__cdivr = (r * xr + xi) / d;
				__cdivi = (r * xi - xr) / d;
			}
		}


		// Nonsymmetric reduction from Hessenberg to real Schur form.

		private function hqr2():void
		{

			//  This is derived from the Algol procedure hqr2,
			//  by Martin and Wilkinson, Handbook for Auto. Comp.,
			//  Vol.ii-Linear Algebra, and the corresponding
			//  Fortran subroutine in EISPACK.

			// Initialize

			var nn:int = this.__n;
			var n:int = nn - 1;
			var low:int = 0;
			var high:int = nn - 1;
			var eps:Number = Math.pow(2.0, -52.0);
			eps = Maths.normalize(eps);
			var exshift:Number = 0.0;
			var p:Number = 0, q:Number = 0, r:Number = 0, s:Number = 0, z:Number = 0, t:Number, w:Number, x:Number, y:Number;
			var i:uint = 0;
			var j:uint = 0;
			var k:uint = 0;
			var l:uint = 0;
			// Store roots isolated by balanc and compute matrix norm

			var norm:Number = 0.0;
			for (i = 0; i < nn; ++i)
			{
				var Hi:Vector.<Number> = __H[i];
				
				if (i < low || i > high)
				{
					__d[i] = Hi[i];
					__e[i] = 0.0;
				}
				
				j = (i > 1) ? i-1 : 0;
				while (j < nn)
				{
					norm += Maths.abs(Hi[j++]);
				}
			}

			// Outer loop over eigenvalue index

			var iter:int = 0;
			while (n >= low)
			{
				// Look for single small sub-diagonal element
				l = n;
				while (l > low)
				{
					s = Maths.abs(__H[l - 1][l - 1]) + Maths.abs(__H[l][l]);
					if (s == 0.0)
					{
						s = norm;
					}
					
					if (Maths.abs(__H[l][l - 1]) < eps * s)
					{
						break;
					}
					l--;
				}

				// Check for convergence
				// One root found

				if (l == n)
				{
					__d[n] = __H[n][n] += exshift;
					__e[n] = 0.0;
					n--;
					iter = 0;
					// Two roots found
				}
				else if (l == n - 1)
				{
					w = __H[n][n - 1] * __H[n - 1][n];
					p = (__H[n - 1][n - 1] - __H[n][n]) / 2.0;
					q = p * p + w;
					z = Math.sqrt(Maths.abs(q));
					x = __H[n][n] += exshift;
					__H[n - 1][n - 1] += exshift;

					// Real pair

					if (q >= 0)
					{
						if (p >= 0)
						{
							z = p + z;
						}
						else
						{
							z = p - z;
						}
						__d[n - 1] = x + z;
						__d[n] = __d[n - 1];
						if (z != 0.0)
						{
							__d[n] = x - w / z;
						}
						__e[n - 1] = 0.0;
						__e[n] = 0.0;
						x = __H[n][n - 1];
						s = Maths.abs(x) + Maths.abs(z);
						p = x / s;
						q = z / s;
						r = Maths.hypot(p, q); //Math.sqrt(p * p + q * q);
						p = p / r;
						q = q / r;

						// Row modification
						var Hn1:Vector.<Number> = __H[n-1];
						var Hn:Vector.<Number> = __H[n];
						for (j = n - 1; j < nn; ++j)
						{
							z = Hn1[j];
							Hn1[j] = q * z + p * Hn[j];
							Hn[j] = q * Hn[j] - p * z;
						}
						
						// Column modification

						for (i = 0; i <= n; ++i)
						{
							Hi = __H[i];
							z = Hi[n - 1];
							Hi[n - 1] = q * z + p * Hi[n];
							Hi[n] = q * Hi[n] - p * z;
						}

						// Accumulate transformations

						for (i = low; i <= high; ++i)
						{
							var Vi:Vector.<Number> = __V[i];
							z = Vi[n - 1];
							Vi[n - 1] = q * z + p * Vi[n];
							Vi[n] = q * Vi[n] - p * z;
						}

							// Complex pair

					}
					else
					{
						__d[n - 1] = x + p;
						__d[n] = x + p;
						__e[n - 1] = z;
						__e[n] = -z;
					}
					n = n - 2;
					iter = 0;

					// No convergence yet

				}
				else
				{

					// Form shift

					x = __H[n][n];
					y = 0.0;
					w = 0.0;
					if (l < n)
					{
						y = __H[n - 1][n - 1];
						w = __H[n][n - 1] * __H[n - 1][n];
					}

					// Wilkinson's original ad hoc shift

					if (iter == 10)
					{
						exshift += x;
						for (i = low; i <= n; i++)
						{
							__H[i][i] -= x;
						}
						s = Maths.abs(__H[n][n - 1]) + Maths.abs(__H[n - 1][n - 2]);
						x = y = 0.75 * s;
						w = -0.4375 * s * s;
					}

					// MATLAB's new ad hoc shift

					if (iter == 30)
					{
						s = (y - x) / 2.0;
						s = s * s + w;
						if (s > 0)
						{
							s = Math.sqrt(s);
							if (y < x)
							{
								s = -s;
							}
							s = x - w / ((y - x) / 2.0 + s);
							for (i = low; i <= n; i++)
							{
								__H[i][i] -= s;
							}
							exshift += s;
							x = y = w = 0.964;
						}
					}

					iter = iter + 1; // (Could check iteration count here.)

					// Look for two consecutive small sub-diagonal elements

					var m:int = n - 2;
					while (m >= l)
					{
						z = __H[m][m];
						r = x - z;
						s = y - z;
						p = (r * s - w) / __H[m + 1][m] + __H[m][m + 1];
						q = __H[m + 1][m + 1] - z - r - s;
						r = __H[m + 2][m + 1];
						s = Maths.abs(p) + Maths.abs(q) + Maths.abs(r);
						p = p / s;
						q = q / s;
						r = r / s;
						if (m == l)
						{
							break;
						}
						if (Maths.abs(__H[m][m - 1]) * (Maths.abs(q) + Maths.abs(r)) < eps * (Maths.abs(p) * (Maths.abs(__H[m - 1][m - 1]) + Maths.abs(z) + Maths.abs(__H[m + 1][m + 1]))))
						{
							break;
						}
						m--;
					}

					for (i = m + 2; i <= n; i++)
					{
						__H[i][i - 2] = 0.0;
						if (i > m + 2)
						{
							__H[i][i - 3] = 0.0;
						}
					}

					// Double QR step involving rows l:n and columns m:n

					for (k = m; k <= n - 1; k++)
					{
						var notlast:Boolean = (k != n - 1);
						if (k != m)
						{
							p = __H[k][k - 1];
							q = __H[k + 1][k - 1];
							r = (notlast ? __H[k + 2][k - 1] : 0.0);
							x = Maths.abs(p) + Maths.abs(q) + Maths.abs(r);
							if (x != 0.0)
							{
								p = p / x;
								q = q / x;
								r = r / x;
							}
						}
						if (x == 0.0)
						{
							break;
						}
						s = Math.sqrt(p * p + q * q + r * r);
						if (p < 0)
						{
							s = -s;
						}
						if (s != 0)
						{
							if (k != m)
							{
								__H[k][k - 1] = -s * x;
							}
							else if (l != m)
							{
								__H[k][k - 1] = -__H[k][k - 1];
							}
							p = p + s;
							x = p / s;
							y = q / s;
							z = r / s;
							q = q / p;
							r = r / p;

							// Row modification

							for (j = k; j < nn; j++)
							{
								p = __H[k][j] + q * __H[k + 1][j];
								if (notlast)
								{
									p = p + r * __H[k + 2][j];
									__H[k + 2][j] = __H[k + 2][j] - p * z;
								}
								__H[k][j] = __H[k][j] - p * x;
								__H[k + 1][j] = __H[k + 1][j] - p * y;
							}

							// Column modification

							for (i = 0; i <= Math.min(n, k + 3); i++)
							{
								p = x * __H[i][k] + y * __H[i][k + 1];
								if (notlast)
								{
									p = p + z * __H[i][k + 2];
									__H[i][k + 2] = __H[i][k + 2] - p * r;
								}
								__H[i][k] = __H[i][k] - p;
								__H[i][k + 1] = __H[i][k + 1] - p * q;
							}

							// Accumulate transformations

							for (i = low; i <= high; i++)
							{
								p = x * __V[i][k] + y * __V[i][k + 1];
								if (notlast)
								{
									p = p + z * __V[i][k + 2];
									__V[i][k + 2] = __V[i][k + 2] - p * r;
								}
								__V[i][k] = __V[i][k] - p;
								__V[i][k + 1] = __V[i][k + 1] - p * q;
							}
						} // (s != 0)
					} // k loop
				} // check convergence
			} // while (n >= low)

			// Backsubstitute to find vectors of upper triangular form

			if (norm == 0.0)
			{
				return;
			}

			for (n = nn - 1; n >= 0; n--)
			{
				p = __d[n];
				q = __e[n];

				// Real vector

				if (q == 0)
				{
					l = n;
					__H[n][n] = 1.0;
					for (i = n - 1; i >= 0; i--)
					{
						w = __H[i][i] - p;
						r = 0.0;
						for (j = l; j <= n; j++)
						{
							r = r + __H[i][j] * __H[j][n];
						}
						if (__e[i] < 0.0)
						{
							z = w;
							s = r;
						}
						else
						{
							l = i;
							if (__e[i] == 0.0)
							{
								if (w != 0.0)
								{
									__H[i][n] = -r / w;
								}
								else
								{
									__H[i][n] = -r / (eps * norm);
								}

									// Solve real equations

							}
							else
							{
								x = __H[i][i + 1];
								y = __H[i + 1][i];
								q = (__d[i] - p) * (__d[i] - p) + __e[i] * __e[i];
								t = (x * s - z * r) / q;
								__H[i][n] = t;
								if (Maths.abs(x) > Maths.abs(z))
								{
									__H[i + 1][n] = (-r - w * t) / x;
								}
								else
								{
									__H[i + 1][n] = (-s - y * t) / z;
								}
							}

							// Overflow control

							t = Maths.abs(__H[i][n]);
							if ((eps * t) * t > 1)
							{
								for (j = i; j <= n; j++)
								{
									__H[j][n] /= t; // __H[j][n] / t;
								}
							}
						}
					}

						// Complex vector

				}
				else if (q < 0)
				{
					l = n - 1;

					// Last vector component imaginary so matrix is triangular

					if (Maths.abs(__H[n][n - 1]) > Maths.abs(__H[n - 1][n]))
					{
						__H[n - 1][n - 1] = q / __H[n][n - 1];
						__H[n - 1][n] = -(__H[n][n] - p) / __H[n][n - 1];
					}
					else
					{
						cdiv(0.0, -__H[n - 1][n], __H[n - 1][n - 1] - p, q);
						__H[n - 1][n - 1] = __cdivr;
						__H[n - 1][n] = __cdivi;
					}
					__H[n][n - 1] = 0.0;
					__H[n][n] = 1.0;
					for (i = n - 2; i >= 0; i--)
					{
						var ra:Number, sa:Number, vr:Number, vi:Number;
						ra = 0.0;
						sa = 0.0;
						for (j = l; j <= n; j++)
						{
							ra = ra + __H[i][j] * __H[j][n - 1];
							sa = sa + __H[i][j] * __H[j][n];
						}
						w = __H[i][i] - p;

						if (__e[i] < 0.0)
						{
							z = w;
							r = ra;
							s = sa;
						}
						else
						{
							l = i;
							if (__e[i] == 0)
							{
								cdiv(-ra, -sa, w, q);
								__H[i][n - 1] = __cdivr;
								__H[i][n] = __cdivi;
							}
							else
							{

								// Solve complex equations

								x = __H[i][i + 1];
								y = __H[i + 1][i];
								vr = (__d[i] - p) * (__d[i] - p) + __e[i] * __e[i] - q * q;
								vi = (__d[i] - p) * 2.0 * q;
								if (vr == 0.0 && vi == 0.0)
								{
									vr = eps * norm * (Maths.abs(w) + Maths.abs(q) + Maths.abs(x) + Maths.abs(y) + Maths.abs(z));
								}
								cdiv(x * r - z * ra + q * sa, x * s - z * sa - q * ra, vr, vi);
								__H[i][n - 1] = __cdivr;
								__H[i][n] = __cdivi;
								if (Maths.abs(x) > (Maths.abs(z) + Maths.abs(q)))
								{
									__H[i + 1][n - 1] = (-ra - w * __H[i][n - 1] + q * __H[i][n]) / x;
									__H[i + 1][n] = (-sa - w * __H[i][n] - q * __H[i][n - 1]) / x;
								}
								else
								{
									cdiv(-r - y * __H[i][n - 1], -s - y * __H[i][n], z, q);
									__H[i + 1][n - 1] = __cdivr;
									__H[i + 1][n] = __cdivi;
								}
							}

							// Overflow control

							t = Math.max(Maths.abs(__H[i][n - 1]), Maths.abs(__H[i][n]));
							if ((eps * t) * t > 1)
							{
								for (j = i; j <= n; j++)
								{
									__H[j][n - 1] = __H[j][n - 1] / t;
									__H[j][n] = __H[j][n] / t;
								}
							}
						}
					}
				}
			}

			// Vectors of isolated roots

			for (i = 0; i < nn; i++)
			{
				if (i < low || i > high)
				{
					Vi = __V[i];
					Hi = __H[i];
					for (j = i; j < nn; j++)
					{
						Vi[j] = Hi[j];
					}
				}
			}

			// Back transformation to get eigenvectors of original matrix

			for (j = nn - 1; j >= low; j--)
			{
				var maxK:int = (j < high)? j : high;
				for (i = low; i <= high; ++i)
				{
					Vi = __V[i];
					z = 0.0;
					for (k = low; k <= maxK; ++k)
					{
						z += Vi[k] * __H[k][j];
					}
					Vi[j] = z;
				}
				__V[high] = Vi;
			}
		}

		// Nonsymmetric reduction to Hessenberg form.

		private function orthes():void
		{

			//  This is derived from the Algol procedures orthes and ortran,
			//  by Martin and Wilkinson, Handbook for Auto. Comp.,
			//  Vol.ii-Linear Algebra, and the corresponding
			//  Fortran subroutines in EISPACK.

			var low:int = 0;
			var high:int = __n - 1;
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			var f:Number = 0;
			var g:Number = 0;
			var m:int = 0;

			for (m = low + 1; m <= high - 1; ++m)
			{
				// Scale column.

				var scale:Number = 0.0;
				for (i = m; i <= high; ++i)
				{
					scale += Maths.abs(__H[i][m - 1]);
				}
				if (scale != 0.0)
				{
					// Compute Householder transformation.

					var h:Number = 0.0;
					for (i = high; i >= m; i--)
					{
						__ort[i] = __H[i][m - 1] / scale;
						h += __ort[i] * __ort[i];
					}
					g = Math.sqrt(h);
					if (__ort[m] > 0)
					{
						g = -g;
					}
					h = h - __ort[m] * g;
					__ort[m] = __ort[m] - g;

					// Apply Householder similarity transformation
					// H = (I-u*u'/h)*H*(I-u*u')/h)
					
					for (j = m; j < __n; j++)
					{
						f = 0.0;
						for (i = high; i >= m; i--)
						{
							f += __ort[i] * __H[i][j];
						}
						f = f / h;
						for (i = m; i <= high; i++)
						{
							__H[i][j] -= f * __ort[i];
						}
					}

					for (i = 0; i <= high; i++)
					{
						var Hi:Vector.<Number> = __H[i];
						f = 0.0;
						for (j = high; j >= m; j--)
						{
							f += __ort[j] * Hi[j];
						}
						f = f / h;
						for (j = m; j <= high; j++)
						{
							Hi[j] -= f * __ort[j];
						}
						__H[i] = Hi;
					}
					__ort[m] = scale * __ort[m];
					__H[m][m - 1] = scale * g;
				}
			}

			// Accumulate transformations (Algol's ortran).

			for (i = 0; i < __n; i++)
			{
				var Vi:Vector.<Number> = __V[i];
				for (j = 0; j < __n; j++)
				{
					Vi[j] = (i == j ? 1.0 : 0.0);
				}
				__V[i] =Vi;
			}

			for (m = high - 1; m >= low + 1; m--)
			{
				if (__H[m][m - 1] != 0.0)
				{
					for (i = m + 1; i <= high; ++i)
					{
						__ort[i] = __H[i][m - 1];
					}
					for (j = m; j <= high; ++j)
					{
						g = 0.0;
						for (i = m; i <= high; ++i)
						{
							g += __ort[i] * __V[i][j];
						}
						// Double division avoids possible underflow
						g = (g / __ort[m]) / __H[m][m - 1];
						for (i = m; i <= high; ++i)
						{
							__V[i][j] += g * __ort[i];
						}
					}
				}
			}
		}

		// Symmetric tridiagonal QL algorithm.

		private function tql2():void
		{

			//  This is derived from the Algol procedures tql2, by
			//  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
			//  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
			//  Fortran subroutine in EISPACK.
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			var p:Number = 0;
			for (i = 1; i < __n; ++i)
			{
				__e[uint(i - 1)] = __e[i];
			}
			__e[__n - 1] = 0.0;

			var f:Number = 0.0;
			var tst1:Number = 0.0;
			var eps:Number = Math.pow(2.0, -52.0);
			for (var l:int = 0; l < __n; l++)
			{

				// Find small subdiagonal element

				tst1 = Math.max(tst1, Maths.abs(__d[l]) + Maths.abs(__e[l]));
				var m:int = l;
				while (m < __n)
				{
					if (Maths.abs(__e[m]) <= eps * tst1)
					{
						break;
					}
					m++;
				}

				// If m == l, d[l] is an eigenvalue,
				// otherwise, iterate.

				if (m > l)
				{
					var iter:int = 0;
					do
					{
						++iter; // (Could check iteration count here.)

						// Compute implicit shift

						var g:Number = __d[l];
						p = (__d[l + 1] - g) / (2.0 * __e[l]);
						var r:Number = Maths.hypot(p, 1.0);
						if (p < 0)
						{
							r = -r;
						}
						__d[l] = __e[l] / (p + r);
						__d[l + 1] = __e[l] * (p + r);
						var dl1:Number = __d[l + 1];
						var h:Number = g - __d[l];
						for (i = l + 2; i < __n; i++)
						{
							__d[i] -= h;
						}
						f = f + h;

						// Implicit QL transformation.

						p = __d[m];
						var c:Number = 1.0;
						var c2:Number = c;
						var c3:Number = c;
						var el1:Number = __e[l + 1];
						var s:Number = 0.0;
						var s2:Number = 0.0;
						for (i = m - 1; i >= l; i--)
						{
							c3 = c2;
							c2 = c;
							s2 = s;
							g = c * __e[i];
							h = c * p;
							r = Maths.hypot(p, __e[i]);
							__e[i + 1] = s * r;
							s = __e[i] / r;
							c = p / r;
							p = c * __d[i] - s * g;
							__d[i + 1] = h + s * (c * g + s * __d[i]);

							// Accumulate transformation.

							for (k = 0; k < __n; k++)
							{
								h = __V[k][i + 1];
								__V[k][i + 1] = s * __V[k][i] + c * h;
								__V[k][i] = c * __V[k][i] - s * h;
							}
						}
						p = -s * s2 * c3 * el1 * __e[l] / dl1;
						__e[l] = s * p;
						__d[l] = c * p;

							// Check for convergence.

					} while (Maths.abs(__e[l]) > eps * tst1);
				}
				__d[l] = __d[l] + f;
				__e[l] = 0.0;
			}

			// Sort eigenvalues and corresponding vectors.

			for (i = 0; i < __n - 1; i++)
			{
				k = i;
				p = __d[i];
				for (j = i + 1; j < __n; j++)
				{
					if (__d[j] < p)
					{
						k = j;
						p = __d[j];
					}
				}
				if (k != i)
				{
					__d[k] = __d[i];
					__d[i] = p;
					for (j = 0; j < __n; j++)
					{
						var Vj:Vector.<Number> = __V[j];
						p = Vj[i];
						Vj[i] = Vj[k];
						Vj[k] = p;
					}
				}
			}
		}

		/* ------------------------
		   Private Methods
		 * ------------------------ */

		// Symmetric Householder reduction to tridiagonal form.

		private function tred2():void
		{

			//  This is derived from the Algol procedures tred2 by
			//  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
			//  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
			//  Fortran subroutine in EISPACK.
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			var h:Number = 0;
			var g:Number = 0;
			for (j = 0; j < __n; j++)
			{
				__d[j] = __V[__n - 1][j];
			}

			// Householder reduction to tridiagonal form.

			for (i = __n - 1; i > 0; i--)
			{

				// Scale to avoid under/overflow.

				var scale:Number = 0.0;
				h = 0.0;
				for (k = 0; k < i; k++)
				{
					scale = scale + Maths.abs(__d[k]);
				}
				if (scale == 0.0)
				{
					__e[i] = __d[i - 1];
					for (j = 0; j < i; j++)
					{
						__d[j] = __V[i - 1][j];
						__V[i][j] = 0.0;
						__V[j][i] = 0.0;
					}
				}
				else
				{

					// Generate Householder vector.

					for (k = 0; k < i; k++)
					{
						__d[k] /= scale;
						h += __d[k] * __d[k];
					}
					var f:Number = __d[i - 1];
					g = Math.sqrt(h);
					if (f > 0)
					{
						g = -g;
					}
					__e[i] = scale * g;
					h = h - f * g;
					__d[i - 1] = f - g;
					for (j = 0; j < i; j++)
					{
						__e[j] = 0.0;
					}

					// Apply similarity transformation to remaining columns.

					for (j = 0; j < i; j++)
					{
						f = __d[j];
						__V[j][i] = f;
						g = __e[j] + __V[j][j] * f;
						for (k = j + 1; k <= i - 1; k++)
						{
							g += __V[k][j] * __d[k];
							__e[k] += __V[k][j] * f;
						}
						__e[j] = g;
					}
					f = 0.0;
					for (j = 0; j < i; j++)
					{
						__e[j] /= h;
						f += __e[j] * __d[j];
					}
					var hh:Number = f / (h + h);
					for (j = 0; j < i; j++)
					{
						__e[j] -= hh * __d[j];
					}
					for (j = 0; j < i; j++)
					{
						f = __d[j];
						g = __e[j];
						for (k = j; k <= i - 1; ++k)
						{
							__V[k][j] -= (f * __e[k] + g * __d[k]);
						}
						__d[j] = __V[i - 1][j];
						__V[i][j] = 0.0;
					}
				}
				__d[i] = h;
			}

			// Accumulate transformations.

			for (i = 0; i < __n - 1; i++)
			{
				__V[__n - 1][i] = __V[i][i];
				__V[i][i] = 1.0;
				h = __d[i + 1];
				if (h != 0.0)
				{
					for (k = 0; k <= i; k++)
					{
						__d[k] = __V[k][i + 1] / h;
					}
					for (j = 0; j <= i; j++)
					{
						g = 0.0;
						for (k = 0; k <= i; k++)
						{
							g += __V[k][i + 1] * __V[k][j];
						}
						for (k = 0; k <= i; k++)
						{
							__V[k][j] -= g * __d[k];
						}
					}
				}
				for (k = 0; k <= i; k++)
				{
					__V[k][i + 1] = 0.0;
				}
			}
			for (j = 0; j < __n; j++)
			{
				__d[j] = __V[__n - 1][j];
				__V[__n - 1][j] = 0.0;
			}
			__V[__n - 1][__n - 1] = 1.0;
			__e[0] = 0.0;
		}
	}
}
