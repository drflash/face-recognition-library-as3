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
	/**
	 * @flowerModelElementId _WCJcgPQwEeG4_d92CzHtyg
	 */
	internal class Feature3Rects extends FeatureBase 
	{
		/**
		 * @flowerModelElementId _WCJcgvQwEeG4_d92CzHtyg
		 */
		private  var r1 :HaarRect;
		/**
		 * @flowerModelElementId _WCJcg_QwEeG4_d92CzHtyg
		 */
		private  var r2 :HaarRect;
		/**
		 * @flowerModelElementId _WCKDkPQwEeG4_d92CzHtyg
		 */
		private  var r3 :HaarRect;
		
		public function Feature3Rects( _th:Number, _lv:Number, _rv:Number, _r1:Array, _r2:Array, _r3:Array)
		{
			super(_th, _lv, _rv);
			r1 = new HaarRect(_r1);
			r2 = new HaarRect(_r2);
			r3 = new HaarRect(_r3);
		}
		
		internal override function getSum( targetImage:TargetImage, offsetx:int, offsety:int ):Number
		{
			var x		:uint = offsetx + r1.sx;
			var y		:uint = offsety + r1.sy;
			var w		:uint = r1.sw;
			var h		:uint = r1.sh;
			var y_iiw   :uint = y       * targetImage.iiw;
			var yh_iiw  :uint = (y + h) * targetImage.iiw;
			var y_iiwx  :uint = y_iiw   + x;
			var y_iiwxw :uint = y_iiwx  + w;
			var yh_iiwx :uint = yh_iiw  + x;
			var yh_iiwxw:uint = yh_iiwx + w;
			var ii:Vector.<uint> = targetImage.ii;
			
			// Sum for r1
			var sum1:Number = Number(ii[y_iiwx] + ii[yh_iiwxw] - ii[yh_iiwx] - ii[y_iiwxw]);
			
			// Update values for r3
			x = offsetx + r2.sx;
			y = offsety + r2.sy;
			w = r2.sw;
			h = r2.sh;
			y_iiw    = y       * targetImage.iiw;
			yh_iiw   = (y + h) * targetImage.iiw;
			y_iiwx   = y_iiw   + x;
			y_iiwxw  = y_iiwx  + w;
			yh_iiwx  = yh_iiw  + x;
			yh_iiwxw = yh_iiwx + w;
			
			// Sum for r2
			var sum2:Number = Number(ii[y_iiwx] + ii[yh_iiwxw] - ii[yh_iiwx] - ii[y_iiwxw]);
			
			// Update values for r3
			x = offsetx + r3.sx;
			y = offsety + r3.sy;
			w = r3.sw;
			h = r3.sh;
			y_iiw    = y       * targetImage.iiw;
			yh_iiw   = (y + h) * targetImage.iiw;
			y_iiwx   = y_iiw   + x;
			y_iiwxw  = y_iiwx  + w;
			yh_iiwx  = yh_iiw  + x;
			yh_iiwxw = yh_iiwx + w;
			
			// Sum for r3
			var sum3:Number = Number(ii[y_iiwx] + ii[yh_iiwxw] - ii[yh_iiwx] - ii[y_iiwxw]);
			
			return 	sum1 * r1.sWeight +
					sum2 * r2.sWeight +
					sum3 * r3.sWeight;
			/*
			return 	Number(targetImage.getSum( offsetx + r1.sx, offsety + r1.sy, r1.sw, r1.sh )) * r1.sWeight +
			Number(targetImage.getSum( offsetx + r2.sx, offsety + r2.sy, r2.sw, r2.sh )) * r2.sWeight +
			Number(targetImage.getSum( offsetx + r3.sx, offsety + r3.sy, r3.sw, r3.sh )) * r3.sWeight;*/
		}
		
		internal override function setScaleAndWeight(s:Number, w:Number):void
		{
			r3.scale = r2.scale = r1.scale = s;
			r3.scaleWeight = r2.scaleWeight = w;
			r1.sWeight = -( Number(r2.area) * r2.sWeight + Number(r3.area) * r3.sWeight ) / Number(r1.area);
		}
	}
}
