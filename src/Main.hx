package;

import app.App;
import flash.Lib;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import haxe.Timer;
import haxe.ds.ObjectMap;

class Main
{
	static var _app:App;
	
	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		_app = new App();
		Lib.current.addChild(_app);
		
		_app.start();
		Lib.current.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
	}
	
	static function handleEnterFrame(e:Event):Void
	{
		_app.update();
	}
}