/*
  Project: Karthik's Matrix Library
  Copyright 2009 Karthik Tharavaad
  http://blog.kpicturebooth.com
  karthik_tharavaad@yahoo.com

  Several functions added by Oskar Wicha

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

	public class Maths
	{
		/**
		 * Computes and returns an absolute value.
		 *
		 * @param value The number whose absolute value is returned.
		 * @return The absolute value of the specified parameter.
		 */
		public static function abs(value:Number):Number
		{
			//return value < 0.0 ? -value : value;
			return value * (1.0 - (int(value < 0.0) << 1));
		}

		/** sqrt(a^2 + b^2) without under/overflow. **/

		public static function hypot(a:Number, b:Number):Number
		{
			var r:Number;
			var abs_a:Number = (a * (1.0 - (int(a < 0.0) << 1))); // Maths.abs(a)
			var abs_b:Number = (b * (1.0 - (int(b < 0.0) << 1))); // Maths.abs(b)
			
			if ( abs_b < abs_a )
			{
				r = b / a;
				return abs_a * Math.sqrt(1.0 + r * r);
			}
			else if (b != 0.0)
			{
				r = a / b;
				return abs_b * Math.sqrt(1.0 + r * r);
			}
			else
			{
				return 0.0;
			}
		}

		public static function make1DVector(m:uint):Vector.<Number>
		{
			//var vec:Vector.<Number> = new Vector.<Number>(m, true);
			/*for (var i:int = 0; i < m; ++i)
			{
				vec[i] = 0.0;
			}*/
			return new Vector.<Number>(m, true);
		}

		/**
		* Creates a zeroed out 2D Vector
		*/
		public static function make2DVector(m:uint, n:uint):Vector.<Vector.<Number>>
		{
			var vec:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(m, true);
			var i:uint = 0;
			
			if(!(m % 4))
			{
				// Unrolled version
				while (i < m)
				{
					vec[i++] = new Vector.<Number>(n, true);
					vec[i++] = new Vector.<Number>(n, true);
					vec[i++] = new Vector.<Number>(n, true);
					vec[i++] = new Vector.<Number>(n, true);
				}
			}
			else
			{
				while (i < m)
				{
					vec[i++] = new Vector.<Number>(n, true);
				}
			}
			return vec;
		}

		/**
		 * Normalizes a denormal IEEE-754 double-precision floating-point number.
		 *
		 * <p>This code has been tested on Mac OS X, Windows and Linux.</p>
		 *
		 * @param value A denormal IEEE-754 double-precision floating-point number.
		 *
		 * @see http://wiki.joa-ebert.com/index.php/Avoiding_Denormals
		 */
		public static function normalize(value:Number):Number
		{
			return value + 1e-18 - 1e-18;
		}
	}
}