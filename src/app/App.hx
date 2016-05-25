package app;

import app.components.Angle;
import app.components.Position;
import app.components.Speed;
import es.EntitySystem;
import flash.display.Sprite;
import haxe.Timer;

class App extends Sprite
{
	var es:EntitySystem = new EntitySystem();
	
	public function new()
	{
		super();
	}
	
	public function start():Void
	{
		for (i in 0...50000) 
		{
			var e = es.createEntity();
			e.setComponent(Speed, new Speed());
		}
		for (i in 0...50000) 
		{
			var e = es.createEntity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
		}
		{
			var e = es.createEntity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
		}
		{
			var e = es.createEntity();
			e.setComponent(Position, new Position());
		}
		
		var e = es.createEntity();
		e.setComponent(Angle, new Angle());
		
		Timer.measure(remove);
		Timer.measure(removeStatic);
		//remove();
		
		trace(es.getEntitiesWithComponents(Speed, Angle, Position).length);
		trace(es.getEntitiesWithComponents(Speed, Position).length);
		trace(es.getEntitiesWithComponents(Speed).length);
		trace(es.getEntitiesWithComponents(Position).length);
	}
	
	function remove()
	{
		for (e in es.getEntities()) 
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
		for (e in es.getEntitiesWithComponents(Position, Speed)) 
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