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
    public class Maths
    {
        
           /** sqrt(a^2 + b^2) without under/overflow. **/

           public static function hypot(a:Number, b:Number):Number {
              var r:Number;
              if (Math.abs(a) > Math.abs(b)) {
                 r = b/a;
                 r = Math.abs(a)*Math.sqrt(1+r*r);
              } else if (b != 0) {
                 r = a/b;
                 r = Math.abs(b)*Math.sqrt(1+r*r);
              } else {
                 r = 0.0;
              }
              return r;
           }  
        /**
        * Creates a zeroed out 2D array
        */ 
        public static function make2DArray( m:int, n:int ):Array{
    		var arr:Array = new Array(m);
    		for( var i:int=0; i<m; i++ ){
    			arr[i] = new Array(n);
    			for( var j:int = 0; j<n; j++ ){
    				arr[i][j] = 0.0;
    			}
    		}
    		return arr;  
        }
        
        public static function make1DArray( m:int ):Array{
            var arr:Array = new Array(m);
            for( var i:int=0; i<m; i++ ){
    			arr[i] = 0.0;
    		}
    		return arr;
        }

    }
}