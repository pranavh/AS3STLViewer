package com.pranavh.as3d.stl.framework
{
	public class Solid
	{
		public function Solid()
		{
		}
		
		public var name:String="";
		public var vertices:Vector.<Number>=new Vector.<Number>();
		public var indices:Vector.<uint>=new Vector.<uint>();
		
		private var map:Object={};
		public function addVertex(x:Number, y:Number, z:Number):void {
			var key:String=x + "," + y + "," + z;
			if(map[key] == null) {
				var insertionPoint:uint=vertices.length;
				vertices.push(x, y, z);
				var index:uint=insertionPoint / 3;
				indices.push(index);
				map[key]=index;
			} else {
				indices.push(map[key]);
			}
		}
		
	}
}