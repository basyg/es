package es;

import ds.Arr;
import haxe.Constraints.Function;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Function;
#end

class EntitySystem extends EntitySystemLists
{
	var _entities:Arr<Entity> = new Arr();
	
	public function new()
	{
		
	}
	
	public inline function createEntity():Entity
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
		var listField = EntityMacro.makeComponentListFieldFromTypeExprs(types);
		EntityMacro.updateFilesIfComponentListFieldMissing(listField);
		return macro new ds.Arr.ConstArr($that.$listField);
	}
	
	macro public function iterateComponents(that:ExprOf<EntitySystem>, funcExpr:ExprOf<Function>):ExprOf<Dynamic>
	{
		var func:ExprDef = funcExpr.expr;
		var func:Function = switch(func)
		{
			case ExprDef.EFunction(_, f): f;
			default: throw 'error';
		}
		var typeTools = func.args.map(function(arg:FunctionArg)
		{
			Assert.assert(arg.type != null, 'function has type for argument "${arg.name}"');
			return EntityMacro.TypeTool.fromType(Context.resolveType(arg.type, that.pos));
		});
		var fields = [for (typeTool in typeTools) EntityMacro.makeComponentFieldFromTypeName(typeTool.getName())];
		var listField = EntityMacro.makeComponentListFieldFromComponentFields(fields);
		var argExprs = [for (field in fields) macro entity.$field];
		return macro
		{
			var entitySystem = $that;
			for (entity in entitySystem.$listField)
			{
				$funcExpr($a{argExprs});
			}
		};
	}
}