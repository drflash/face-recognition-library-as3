package com.oskarwicha.images.FaceRecognition
{
	import flash.events.ErrorEvent;
	
	import mx.messaging.messages.ErrorMessage;

	/**
	 * @flowerModelElementId _TmCksGglEeCqZchJBDddKw
	 */
	internal final class EuclideanDistance implements IDistanceMeasure
	{
		public function EuclideanDistance()
		{
		}

		/**
		 * Oblicza dystans miądzy dwoma wektorami przechowywanymi
		 * w obiektach klasy <code>FeatureVector</code>.
		 * Funkcja niezbedna w celu implementacji interfejsu
		 * <code>DistanceMeasure</code>.
		 *
		 * @param fv1 Pierwszy z wektorów
		 * @param fv2 Drugi z wektorów
		 * @return Dystans miedzy wektorem <code>fv1</code> a <code>fv2</code>
		 *
		 */
		public function distanceBetween(fv1:FeatureVector, fv2:FeatureVector):Number
		{
			var fv1Vector:Vector.<Number> = fv1.featureVectorData;
			var fv2Vector:Vector.<Number> = fv2.featureVectorData;
			var fv1VectorLength:uint = fv1Vector.length;
			var fv2VectorLength:uint = fv2Vector.length;
			
			if(fv1VectorLength != fv2VectorLength)
				throw new ArgumentError("Both FeatureVectors need to have the same length.");
			
			var num:uint = fv1VectorLength ^ ((fv1VectorLength ^ fv2VectorLength) & ~(int(fv1VectorLength < fv2VectorLength) + 1)); // assigns bigger one
			var fv1fv2diff:Number;
			var dist:Number = 0.0;
			
			for (var i:uint = 0; i < num; ++i)
			{
				fv1fv2diff = fv1Vector[i] - fv2Vector[i];
				dist = dist + (fv1fv2diff * fv1fv2diff);
			}
			//trace("Odległość miedzy wektorami = " + Math.sqrt(dist));

			//the neighbor with the smallest distance also has the 
			//smallest squared distance, so we can save some computation
			//time by returning squared values
			return dist;
		}
	}
}
