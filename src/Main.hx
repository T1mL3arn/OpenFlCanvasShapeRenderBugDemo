package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.ShapeDebug;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;

/**
 * ...
 * @author
 */

class Main extends Sprite 
{
	var inited:Bool;
	var space:nape.space.Space;
	var debug:ShapeDebug;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		
		space = new Space(Vec2.weak(0, 1000));
		debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
		
		setUp(true);
		
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	function setUp(useCustomGraphic:Bool = false)
	{
		if (!useCustomGraphic)
		{
			addChild(debug.display);
		}
		
		var w = stage.stageWidth;
		var h = stage.stageHeight;
		 
		var floor = new Body(BodyType.STATIC);
		floor.shapes.add(new Polygon(Polygon.rect(50, (h - 50), (w - 100), 1)));
		floor.space = space;
		 
		for (i in 0...16) {
			var box = new Body(BodyType.DYNAMIC);
			box.shapes.add(new Polygon(Polygon.box(16, 32)));
			box.position.setxy((w / 2), ((h - 50) - 32 * (i + 0.5)));
			box.space = space;
			if (useCustomGraphic)
				box.userData.view = getRect_(16, 32);
		}
		 
		var ball = new Body(BodyType.DYNAMIC);
		ball.shapes.add(new Circle(50));
		ball.position.setxy(50, h / 2);
		ball.angularVel = 10;
		ball.space = space;
		if (useCustomGraphic)
			ball.userData.view = getBall_(50);
	}
	
	function getRect_(w:Float, h:Float, c:Int = 0x00FF00):Sprite
	{
		var rect:Sprite = new Sprite();
		rect.graphics.beginFill(0x00FF00, 0.8);
		rect.graphics.drawRect(-w/2, -h/2, w, h);
		this.addChild(rect);
		return rect;
	}
	
	function getBall_(r:Float = 40):Sprite
	{
		var ball = new Sprite();
		ball.graphics.beginFill(0xFF0000);
		ball.graphics.drawCircle(0, 0, r);
		ball.graphics.endFill();
		ball.graphics.lineStyle(1, 0);
		ball.graphics.moveTo( -r/2, 0);
		ball.graphics.lineTo(r/2, 0);
		this.addChild(ball);
		return ball;
	}
	
	function onMouseUp(e:MouseEvent):Void 
	{
		space.clear();
		debug.clear();
		this.removeChildren();
		setUp(false);
		#if html5 untyped console.log('------------------------------------'); #end
	}
	
	function onFrame(e:Event):Void 
	{
		space.step(1 / 60, 10, 10);
		
		debug.clear();
		debug.draw(space);
		debug.flush();
		
		for (body in space.bodies)
		{
			var dObj:DisplayObject = cast body.userData.view;
			if (dObj == null) continue;
			dObj.x = body.position.x;
			dObj.y = body.position.y;
			dObj.rotation = body.rotation * 57.2957795;
		}
		
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
