package app;

import app.components.Angle;
import app.components.Position;
import app.components.Speed;
import flash.display.Sprite;
import haxe.Timer;

class App extends Sprite
{
	var system:es2.EntitySystem = new es2.EntitySystem();
	
	public function new()
	{
		super();
	}
	
	public function start():Void
	{
		for (i in 0...50000) 
		{
			var e = system.createEntity();
			e.setComponent(Speed, new Speed());
		}
		for (i in 0...50000) 
		{
			var e = system.createEntity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
		}
		{
			var e = system.createEntity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
		}
		{
			var e = system.createEntity();
			e.setComponent(Position, new Position());
		}
		
		var e = system.createEntity();
		e.setComponent(Angle, new Angle());
		
		Timer.measure(remove);
		Timer.measure(removeStatic);
		//remove();
		
		trace(system.getEntitiesWithComponents(Speed, Angle, Position).length);
		trace(system.getEntitiesWithComponents(Speed, Position).length);
		trace(system.getEntitiesWithComponents(Speed).length);
		trace(system.getEntitiesWithComponents(Position).length);
	}
	
	function remove()
	{
		for (e in system.getEntities()) 
		{
			if (e.hasComponents(Position, Speed))
			{
				e.removeComponent(Position);
				e.removeComponent(Speed);
			}
		}
	}
	
	function removeStatic()
	{
		for (e in system.getEntitiesWithComponents(Position, Speed)) 
		{
			e.removeComponent(Position);
			e.removeComponent(Speed);
		}
	}
	
	public function update():Void 
	{
		//Entity.iterateWithComponents(Position);
		//trace(Entity.getEntitiesWithComponents(Speed, Angle, Position).length);
		//Entity.iterateWithComponents(Speed, Position);
		//Entity.iterateWithComponents(Position);
		
		
		//trace(f);
		//var i = 0;
		//for (e in _entities) 
		//{
			//if (e.hasComponents(Position, Speed, Angle))
			//{
				//i++;
			//}
		//}
	}
}