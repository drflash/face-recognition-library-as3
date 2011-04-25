package com.oskarwicha.images.FaceRecognition
{

	/**
	 * Interfejs dostarcza metodę do pomiaru odległości miedzy dwoma obiektami <code>FaceVector</code>.
	 * 
	 * @author Oskar Wicha
	 * 
	 * @flowerModelElementId _ToZ8MGglEeCqZchJBDddKw
	 */
	internal interface IDistanceMeasure
	{
		function DistanceBetween(obj1:FeatureVector, obj2:FeatureVector):Number;
	}
}