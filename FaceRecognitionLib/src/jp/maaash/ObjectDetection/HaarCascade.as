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
	import flash.geom.Rectangle;
	
	/**
	 * @flowerModelElementId _V-iu4PQwEeG4_d92CzHtyg
	 */
	internal class HaarCascade
	{
		public  var base_window_w   :int;
		public  var base_window_h   :int;
		public  var inv_window_area :Number;
		/**
		 * @flowerModelElementId _WCW34vQwEeG4_d92CzHtyg
		 */
		public  var targetImage		:TargetImage;
		
		protected var _scale        :Number = 0.0;
		/**
		 * @flowerModelElementId _WCYtEfQwEeG4_d92CzHtyg
		 */
		protected var _firstTree	:FeatureTree;
		
		public function HaarCascade()
		{
			init();
		}
		
		protected function init():void
		{
			
		}
		
		internal function set scale(s:Number):void
		{
			if( s == _scale ){ return; }
			_scale = s;
			// update rect's width, height, weight
			var feature:FeatureBase;
			inv_window_area = 1.0 / ( base_window_w * base_window_h * s * s );
			
			var tree:FeatureTree = _firstTree;
			while ( tree != null )
			{
				feature = tree.firstFeature;
				while( feature != null )
				{
					feature.setScaleAndWeight( s, inv_window_area );
					feature = feature.next;
				}
				tree = tree.next;
			}
		}
		
		internal function run( r:Rectangle ):int
		{
			//logger("[runHaarClassifierCascade] c:",c,x,y,w,h);
			var x:uint = r.x;
			var y:uint = r.y; 
			var w:uint = r.width;
			var h:uint = r.height;
			
			var mean:Number                 = targetImage.getSum(x, y, w, h) * inv_window_area;
			var variance_norm_factor:Number = targetImage.getSum2(x, y, w, h)* inv_window_area - mean * mean;
			
			if( variance_norm_factor >= 0.0 )
				variance_norm_factor = Math.sqrt(variance_norm_factor);
			else 
				variance_norm_factor = 1.0;
			
			var feature:FeatureBase;
			var val:Number	 = 0.0;
			var st_th:Number = 0.0;
			var tree:FeatureTree = _firstTree;

			while ( tree )
			{
				feature    = tree.firstFeature
				val        = 0.0;
				st_th      = tree.stageThreshold;
				
				while ( feature )
				{
					// Ternary operation causes coersion and makes slower. 
					if (feature.getSum( targetImage, x, y ) < Number(feature.threshold * variance_norm_factor))
						val += feature.leftVal;
					else
						val += feature.rightVal;
					
					if( val <= st_th )
						feature = feature.next;
					else // left_val, right_val are always plus
						break;
				}
				
				if( val >= st_th )
					tree = tree.next;
				else
					return 0;
			}
			return 1;
		}
	}
}