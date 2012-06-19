package com.pranavh.as3d.stl.framework
{
	
	

	public class Line
	{
		public function Line(i:Number=0, j:Number=0, k:Number=0)
		{
			this.i=i;
			this.j=j;
			this.k=k;
		}
		
		public var i:Number, j:Number, k:Number;
		
		public function get slope():Slope {
			var s:Slope=new Slope();
			s.theta = Math.tan(j / i);
			s.phi = Math.tan(k / i);
			return s;
		}
		
		public static function constructFromPoints(x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2:Number):Line {
			var l:Line=new Line((x2-x1), (y2-y2), (z2-z1));
			return l; 
		}
		
		public static function constructFromVertices(l1:Vertex, l2:Vertex):Line {
			return constructFromPoints(l1.x, l1.y, l1.z, l2.x, l2.y, l2.z);
		}
		
		public static function constructFromAngles(x:Number, y:Number, z:Number, theta:Number, phi:Number):Line {
			var i:Number, j:Number, k:Number;
			i=1;
			j=Math.tan(theta);
			k=Math.tan(phi);
			var l:Line=new Line(i, j, k);
			return l;
		}
		
		public static function minus(l1:Line, l2:Line):Line {
			var l:Line=new Line((l1.i-l2.i), (l1.j-l2.j), (l1.k-l2.k));
			return l;
		}
		
		public static function crossProduct(a:Line, b:Line):Normal {
			/*
			i	j	k
			i1	j1	k1
			i2	j2	k2
			*/
			
			var i:Number = a.j * b.k - a.k * b.j;
			var j:Number = a.k * b.i - a.i * b.k;
			var k:Number = a.i * b.j - a.j * b.i;
			var n:Normal=new Normal(i, j, k);
			return n;
		}
	}
}