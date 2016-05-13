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
		
		var e = new Entity();
		e.setComponent(Angle, new Angle());
		_entities.push(e);
		
		//remove();
	}
	
	function remove()
	{
		for (e in _entities) 
		{
			e.removeComponent(Angle);
			e.removeComponent(Position);
		}
	}
	
	public function update():Void 
	{
		//Entity.iterateWithComponents(updatePosition, Position);
		for (i in 0...50) 
		{
			Entity.iterateWithComponents(updatePosition, Speed, Angle, Position);
		}
		
		
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
	
	static var f = 0;
	
	inline function updatePosition(e:Entity):Void
	{
		//var position = e.getComponent(Position);
		//position.x++;
		//position.y++;
	}
}