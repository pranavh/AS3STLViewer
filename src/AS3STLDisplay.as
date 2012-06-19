package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	
	import com.pranavh.as3d.stl.STLReader;
	import com.pranavh.as3d.stl.framework.Solid;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	
	import mx.events.FlexEvent;

	[SWF(backgroundColor="#aaaaaa", frameRate="60", width="1024", height="768")]
	public class AS3STLDisplay extends Sprite
	{
		
		public function AS3STLDisplay()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color=0xaaaaaa;
			
			f=new FileReference();
			var l:FileFilter=new FileFilter("StereoLithography Files (*.stl)", "*.stl");
			filter=[l];
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public var solid:Solid
		
		private var axes:Trident
		private var cam:Camera3D;
		private var camControl:HoverController;
		private var f:FileReference;
		private var filter:Array;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lightPicker:StaticLightPicker;
		private var m:Boolean;
		
		private var material:ColorMaterial;
		private var mesh:Mesh;
		
		//navigation variables
		private var move:Boolean = false;
		
		//light objects
		private var pointLight:PointLight;
		private var oppositeLight:PointLight;
		private var directionalLight:DirectionalLight;
		private var lights:Array;
		
		private var reader:STLReader;
		
		//engine variables
		private var scene:Scene3D;
		private var view:View3D;
		
		public function render():void {
			cam=new Camera3D();
			cam.x=0;
			cam.y=0;
			cam.z=200;
			
			camControl=new HoverController(cam, null, 45, 30, 520, 5); 
			
			view=new View3D();
			view.camera=cam;
			view.antiAlias = 4;
			view.backgroundColor=0x9D9DDB;
			scene=view.scene;
			addChild(view);
			
			initLights();
			
			axes=new Trident(100);
			view.scene.addChild(axes);
			
			var sg:SubGeometry=new SubGeometry();
			sg.updateVertexData(solid.vertices);
			sg.updateIndexData(solid.indices);
			//sg.updateVertexNormalData(solid.normalData);
			
			var geom:Geometry=new Geometry();
			geom.addSubGeometry(sg);
			
			//var geom:CubeGeometry=new CubeGeometry();
			
			
			
			
			material=new ColorMaterial(0xcc2222);
			material.bothSides=true
			material.lightPicker=lightPicker;
			
			mesh=new Mesh(geom, material);
			view.scene.addChild(mesh);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function browse():void
		{
			f.addEventListener(Event.SELECT, fSelected);
			f.browse(filter);
		}
		
		private function fLoaded(e:Event):void {
			f.removeEventListener(Event.COMPLETE, fLoaded);
			reader=new STLReader();
			reader.parse(f.data);
			this.solid=reader.data;
			render();
		}
		
		private function fSelected(e:Event):void {
			f.removeEventListener(Event.SELECT, fSelected);
			f.addEventListener(Event.COMPLETE, fLoaded);
			f.load();
		}
		
		private function initLights():void
		{
			//create a light for the camera
			pointLight = new PointLight();
			scene.addChild(pointLight);
			// In version 4, you'll need a lightpicker. Materials must then be registered with it (see initObject)
			lightPicker = new StaticLightPicker([pointLight]);
		}
		
		private function onEnterFrame(event:Event):void {
			if(m) {
				camControl.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camControl.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
				//pointLight.position=cam.position;
			}
			
			view.render();
			//removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			var ra:Number=20;
			var x:int=1;
			var r:Boolean=true;
			switch(e.keyCode) {
				case Keyboard.O:
					if(e.ctrlKey) {
						browse();
					}
					r=false;
					break;
				case Keyboard.W:
					cam.moveUp(10);
					break;
				case Keyboard.S:
					cam.moveDown(10);
					break;
				case Keyboard.A:
					cam.moveLeft(10);
					break;
				case Keyboard.D:
					cam.moveRight(10);
					break;
				case Keyboard.HOME:
					break;
				case Keyboard.UP:
					cam.moveForward(10);
					break;
				case Keyboard.DOWN:
					cam.moveBackward(10);
					break;
				case Keyboard.LEFT:
					x=-1;
				case Keyboard.RIGHT:
					//cam.yaw(ra * x);
					//cam.rotate(new Vector3D(0,100,0)., ra*x);
					break;
				default:
					r=false;
					break;
			}
			if(r)
				view.render();
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			m=true;
			lastPanAngle = camControl.panAngle;
			lastTiltAngle = camControl.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			m=false;
		}
	}
}