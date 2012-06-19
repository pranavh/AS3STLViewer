package com.pranavh.as3d.stl.framework
{
	public class Normal
	{
		public function Normal(i:Number=0, j:Number=0, k:Number=0)
		{
			this.i=i;
			this.j=j;
			this.k=k;
		}
		
		public var i:Number, j:Number, k:Number;
		//public var direction:int=1;
		
		public function pushToVector(v:Vector.<Number>):uint {
			return v.push(i, j, k);
		}
		
		public function clone():Normal {
			return new Normal(i, j, k);
		}
		
		public static function sameDirection(n1:Normal, n2:Normal):Boolean {
			var r1:Number=n1.i / n2.i;
			var r2:Number=n1.j / n2.j;
			var r3:Number=n1.k / n2.k;
			return (r1==r2==r3);
		}
	}
}