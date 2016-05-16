package app;
import app.components.Angle;
import app.components.Position;
import app.components.Speed;
import ds.Arr;
import es.Entity;
import flash.display.Sprite;

class App extends Sprite
{
	var _entities:Arr<Entity> = new Arr();
	
	public function new()
	{
		super();
	}
	
	public function start():Void
	{
		//for (i in 0...10000) 
		{
			var e = new Entity();
			e.setComponent(Speed, new Speed());
			
			_entities.push(e);
		}
		//for (i in 0...10000) 
		{
			var e = new Entity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
			_entities.push(e);
		}
		{
			var e = new Entity();
			e.setComponent(Position, new Position());
			e.setComponent(Speed, new Speed());
			_entities.push(e);
		}
		{
			var e = new Entity();
			e.setComponent(Position, new Position());
			_entities.push(e);
		}
		
		var e = new Entity();
		e.setComponent(Angle, new Angle());
		_entities.push(e);
		
		//remove();
		
		trace(Entity.getEntitiesWithComponents(Speed, Angle, Position).length);
		trace(Entity.getEntitiesWithComponents(Speed, Position).length);
		trace(Entity.getEntitiesWithComponents(Speed).length);
		trace(Entity.getEntitiesWithComponents(Position).length);
	}
	
	function remove()
	{
		for (e in _entities) 
		{
			if (e.hasComponents(Position))
			{
				e.removeComponent(Position);
			}
			//e.removeComponent(Position);
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