package com.oskarwicha.images.FaceRecognition
{
	/**
	 * @flowerModelElementId _V7jsUPQwEeG4_d92CzHtyg
	 */
	internal class DiPair
	{
		public function DiPair(distance:Number = 0.0, featureVector:FeatureVector = null)
		{
			this.dist = distance;
			this.fVec = featureVector;
		}
		
		public var dist:Number;
		public var fVec:FeatureVector;
		
		// Służy do porównaniea dwóch obiektów klasy "diPair"
		public static function compare(arg0:DiPair, arg1:DiPair):int
		{
			return int(int(arg0.dist) - int(arg1.dist));
		}
	}
}