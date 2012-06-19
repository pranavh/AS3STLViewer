package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
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
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	
	
	[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
	public class STLViewer extends Sprite
	{
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var awayStats:AwayStats;
		private var cameraController:HoverController;
		private var displayMesh:Mesh;
		
		//light objects
		private var pointLight:PointLight;
		private var lightPicker:StaticLightPicker;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		//Reader objects
		private var reader:STLReader;
		private var f:FileReference;
		private var filter:Array;
		
		private var tiltIncrement:Number = 0;
		private var panIncrement:Number = 0;
		private var distanceIncrement:Number = 0;
		public const tiltSpeed:Number = 2;
		public const panSpeed:Number = 2;
		public const distanceSpeed:Number = 2;
		
		/**
		 * Constructor
		 */
		public function STLViewer()
		{
			initEngine();
			initLights();
			initFile();
			initListeners();
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
			//this.solid=reader.data;
			initObject();
		}
		
		private function fSelected(e:Event):void {
			f.removeEventListener(Event.SELECT, fSelected);
			f.addEventListener(Event.COMPLETE, fLoaded);
			f.load();
		}
		
		private function initFile():void {
			f=new FileReference();
			var l:FileFilter=new FileFilter("StereoLithography Files (*.stl)", "*.stl");
			filter=[l];
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new View3D();
			view.antiAlias = 4;
			view.forceMouseMove = true;
			scene = view.scene;
			camera = view.camera;
			addChild(view);
			
			//setup controller to be used on the camera
			cameraController = new HoverController(camera, null, 45, 30, 520, 5);
			
			// show statistics
			awayStats = new AwayStats(view);
			addChild(awayStats);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//create a light for the camera
			pointLight = new PointLight();
			scene.addChild(pointLight);
			// In version 4, you'll need a lightpicker. Materials must then be registered with it (see initObject)
			lightPicker = new StaticLightPicker([pointLight]);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObject():void
		{
			if(displayMesh && scene.contains(displayMesh))
				scene.removeChild(displayMesh);
			
			var solid:Solid=reader.data;
			
			var subGeom:SubGeometry=new SubGeometry();
			subGeom.updateVertexData(solid.vertices);
			subGeom.updateIndexData(solid.indices);
			
			var geometry:Geometry=new Geometry();
			geometry.addSubGeometry(subGeom);
			
			var material:ColorMaterial = new ColorMaterial( 0xFF0000 );
			material.bothSides=true;
			material.lightPicker = lightPicker;
			var mesh:Mesh = new Mesh(geometry, material);
			scene.addChild(mesh);
			
			displayMesh=mesh;
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			cameraController.panAngle += panIncrement;
			cameraController.tiltAngle += tiltIncrement;
			cameraController.distance += distanceIncrement;
			
			pointLight.position = camera.position;
			
			view.render();
		}
		
		/**
		 * Key down listener for camera control
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					tiltIncrement = tiltSpeed;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					tiltIncrement = -tiltSpeed;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					panIncrement = panSpeed;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					panIncrement = -panSpeed;
					break;
				case Keyboard.Z:
					distanceIncrement = distanceSpeed;
					break;
				case Keyboard.X:
					distanceIncrement = -distanceSpeed;
					break;
				case Keyboard.O:
					if(event.shiftKey) {
						browse();
					}
					break;
			}
		}
		
		/**
		 * Key up listener for camera control
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					tiltIncrement = 0;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					panIncrement = 0;
					break;
				case Keyboard.Z:
				case Keyboard.X:
					distanceIncrement = 0;
					break;
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			move = true;
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			trace("Light: " + pointLight.position.toString());
			trace("Camera: " + camera.position.toString());
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			awayStats.x = stage.stageWidth - awayStats.width;
		}
	}
}
