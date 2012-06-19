package com.pranavh.as3d.stl
{
	import com.pranavh.as3d.stl.framework.Facet;
	import com.pranavh.as3d.stl.framework.Normal;
	import com.pranavh.as3d.stl.framework.Solid;
	import com.pranavh.as3d.stl.framework.Vertex;
	
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	

	public class STLReader
	{
		public function STLReader()
		{
		}
		
		public var scale:Number=1;
		
		private var solid:RegExp=/solid (.*)/i;
		private var facet:RegExp=/facet (?:normal ([\d\.E\+]+) ([\d\.E\+]+) ([\d\.E\+]+)){0,1}/i;
		private var vertex:RegExp=/vertex(?:\s+)([\-\dE\.\+]+) ([\-\d\.E\+]+) ([\-\d\.E\+]+)/i;
		
		/*
		solid ascii
		facet 
		outer loop
		vertex  0 1 0
		vertex  -1 1 1
		vertex  1 1 1
		endloop
		endfacet
		facet normal 0 0 1
		outer loop
		vertex  0 1 0
		vertex  1 1 1
		vertex  1 1 -1
		endloop
		endfacet
		*/
		
		public var data:Solid;
		
		public function parseASCII(b:String):void {
			var lineArray:Array=toLines(b);
			
			var activeFacet:Facet;
			for each(var line:String in lineArray) {
				line=StringUtil.trim(line);
				switch (line.substr(0, 5)) {
					case "solid":
						data=new Solid();
						var a:Array=solid.exec(line);
						if(a && a.length==2) {
							data.name=a[1];
						}
						break;
					case "facet":
						/*activeFacet=new Facet();
						var n:Array=facet.exec(line);
						if(n && n.length==4) {
							activeFacet.normal=new Normal(n[1], n[2], n[3]);
						}*/
						break;
					case "verte":
						var v:Array=vertex.exec(line);
						if(v && v.length==4) {
							data.addVertex(v[1]*scale, v[2]*scale, v[3]*scale);
							//var vx:Vertex=new Vertex(v[1], v[2], v[3]);
							//activeFacet.vertices.push(vx);
						} else {
							throw new Error("Invalid vertex specification. A vertex must have 3 coordinates");
						}
						break;
					case "endfa":
						/*activeFacet.normalize();
						data.facets.push(activeFacet);*/
						break;
					case "endso":
						//data.normalize();
						break;
					default:
						break;
				}
			}
		}
		
		public function parseBinary(b:ByteArray):void {
			var header:String=b.readUTFBytes(80);
			var iter:uint=b.readUnsignedInt();
			data=new Solid();
			//for(var i:int=0; i<iter; i++) {
			while(b.bytesAvailable > 0) {
				var f:Facet=new Facet();
				f.normal=new Normal(b.readFloat(), b.readFloat(), b.readFloat());
				//f.vertices.push(new Vertex(b.readFloat(), b.readFloat(), b.readFloat()));
				//f.vertices.push(new Vertex(b.readFloat(), b.readFloat(), b.readFloat()));
				//f.vertices.push(new Vertex(b.readFloat(), b.readFloat(), b.readFloat()));
				
				data.addVertex(b.readFloat()*scale, b.readFloat()*scale, b.readFloat()*scale);
				data.addVertex(b.readFloat()*scale, b.readFloat()*scale, b.readFloat()*scale);
				data.addVertex(b.readFloat()*scale, b.readFloat()*scale, b.readFloat()*scale);
				
				var abc:int=b.readShort();
				if(abc != 0) {
					throw new Error("Invalid binary file");
				}
			}
		}
		
		public function parse(data:ByteArray):void {
			var s:String=data.readUTFBytes(data.bytesAvailable);
			data.position=0;
			if(s.indexOf("solid") >= 0 && s.indexOf("endsolid") >= 0) {
				parseASCII(s);
			} else {
				parseBinary(data);
			}
		}
		
		public function toLines(s:String):Array {
			var b:Array=s.split("\n");
			return b;
		}
	}
}