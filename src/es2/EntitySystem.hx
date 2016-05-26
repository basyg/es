package es2;

import ds.Arr;
import haxe.macro.Expr.ExprOf;

private typedef EM = EntityMacro;

class EntitySystem extends EntitySystemLists
{
	var _entities:Arr<Entity> = new Arr();
	
	public function new()
	{
		
	}
	
	public function createEntity():Entity
	{
		var entity = new Entity(this);
		_entities.push(entity);
		return entity;
	}
	
	public inline function getEntities():ConstArr<Entity>
	{
		return _entities;
	}
	
	macro public function getEntitiesWithComponents(that:ExprOf<EntitySystem>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<ConstArr<Entity>>
	{
		types.push(type);
		var listField = EM.makeComponentListFieldFromTypeExprs(types);
		return macro new ds.Arr.ConstArr($that.$listField);
	}
}