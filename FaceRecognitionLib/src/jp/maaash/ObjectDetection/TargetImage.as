//
// Project Marilena
// Object Detection in Actionscript3
// based on OpenCV (Open Computer Vision Library) Object Detection
//
// Copyright (C) 2008, Masakazu OHTSUKA (mash), all rights reserved.
// contact o.masakazu(at)gmail.com
//
// additional optimizations by Mario Klingemann / Quasimondo
// contact mario(at)quasimondo.com
//
// additional optimizations by Oskar Wicha / OSCYLOSKOP
// contact oscyloskop(at)gmail.com
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
package jp.maaash.ObjectDetection
{
	import flash.display.BitmapData;
	
	/**
	 * @flowerModelElementId _WC3OMPQwEeG4_d92CzHtyg
	 */
	internal class TargetImage
	{
		public  var ii   :Vector.<uint>;	// IntegralImage
		public  var ii2  :Vector.<uint>;	// IntegralImage of squared pixels
		public  var iiw   :uint;
		public  var iih   :uint;
		public  var width :uint;
		public  var height:uint;

		public function TargetImage( )
		{
		}

		public function set bitmapData(bd:BitmapData):void
		{
			bd.lock();
			
			if( (bd.width + 1) != iiw || (bd.height + 1) != iih )
			{
				ii  = new Vector.<uint>((bd.width + 1) * (bd.height + 1), true);
				ii2 = new Vector.<uint>(ii.length, true);
			}
			
			width  = bd.width;
			height = bd.height;
			
			// build IntegralImages
			// IntegralImage is 1 size larger than image
			// all 0 for the 1st row,column
			iiw = width + 1;
			iih = height + 1;
			
			var singleII  :uint;
			var singleII2 :uint;
			var index     :uint;
			var index2    :uint;
			var ba_index  :uint = 0;
			var pix:uint;
			var sum :uint;
			var sum2:uint;
			var ba:Vector.<uint> = bd.getVector(bd.rect);
						
			for( var i:uint=0; i < iiw; ++i )
			{
				ii2[i] = ii[i] = 0;
			}
			
			for( var j:uint=1; j < iih; ++j )
			{
				sum = sum2 = ii2[ index = uint(j * iiw) ] = ii[ index ] = 0;
				index2 = uint(index-iiw);
				
				for( i=1; i < iiw; ++i )
				{
					pix   = ba[ ba_index++ ];
					pix   = uint((pix & uint(0x00FF0000)) >> uint(0x10)); //(pixel & (255 << 16)) >> 16; // red channel value
					
					sum  += pix;
					sum2 += uint(pix * pix);
					
					++index;
					++index2;
					singleII  = ii[ index2 ];
					singleII += sum;
					
					singleII2  = ii2[ index2 ];
					singleII2 += sum2; 
					
					ii[  index ] = singleII;
					ii2[ index ] = singleII2;
					//singleII  = _ii[int(index-iiw+1)] + _ii[index] - _ii[int(index-iiw)] + pix;
					//singleII2 = _ii2[int(index-iiw+1)] + _ii2[index] - _ii2[int(index-iiw)] + pix*pix;
					//_ii[ ++index ] = singleII;
					//_ii2[ index ]  = singleII2;
					
				}
			}
		}
		
		public function getSum(x:uint, y:uint, w:uint, h:uint):uint
		{
			var y_iiw   :uint = y       * iiw;
			var yh_iiw  :uint = (y + h) * iiw;
			return ii[ y_iiw  + x    ] +
				   ii[ yh_iiw + x + w] -
				   ii[ yh_iiw + x    ] -
				   ii[ y_iiw  + x + w];
		}

		// sum of squared pixel
		public function getSum2(x:uint, y:uint, w:uint, h:uint):uint
		{
			var y_iiw   :uint = y       * iiw;
			var yh_iiw  :uint = (y + h) * iiw;
			return ii2[ y_iiw  + x    ] +
				   ii2[ yh_iiw + x + w] -
				   ii2[ yh_iiw + x    ] -
				   ii2[ y_iiw  + x + w];
		}

		public function getII(x:uint, y:uint):uint
		{
			return ii[ y * iiw + x ];
		}

		public function getII2(x:uint, y:uint):uint
		{
			return ii2[ y * iiw + x ];
		}

	}
}
