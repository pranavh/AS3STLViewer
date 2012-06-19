package com.pranavh.as3d.stl.framework
{
	public class Vertex
	{
		public function Vertex(x:Number, y:Number, z:Number)
		{
			this.x=x;
			this.y=y;
			this.z=z;
		}
		
		public var x:Number, y:Number, z:Number;
		
		public function pushToVector(v:Vector.<Number>):uint {
			return v.push(x, y, z);
		}
		
		public function clone():Vertex {
			return new Vertex(x, y, z);
		}
		
		public static function getNormal(v1:Vertex, v2:Vertex, v3:Vertex):Normal {
			var l1:Line=Line.constructFromVertices(v1, v2);
			var l2:Line=Line.constructFromVertices(v1, v3);
			return Line.crossProduct(l1, l2);
		}
	}
}