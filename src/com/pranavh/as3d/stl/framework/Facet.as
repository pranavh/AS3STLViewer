package com.pranavh.as3d.stl.framework
{
	import flash.geom.Vector3D;

	public class Facet
	{
		public function Facet()
		{
			vertices=new Vector.<Vertex>();
			//normal=new Normal();
		}
		
		public var vertices:Vector.<Vertex>;
		public var normal:Normal;
		
		private var v:Vector.<Number>;
		public function get vertexData():Vector.<Number> {
			return v;
		}
		
		public function normalize():void {
			if(vertices.length != 3) {
				throw new Error("A facet must have exactly 3 vertices");
			}
			/*var n:Normal=Vertex.getNormal(vertices[0], vertices[1], vertices[2]);
			if(normal) {
				if(!Normal.sameDirection(normal, n)) {
					throw new Error("Invalid normal supplied");
				}
			} else {
				normal=n;
			}*/
			
			v=new Vector.<Number>();
			for each(var vx:Vertex in vertices) {
				v.push(vx.x, vx.y, vx.z);
			}
		}
	}
}