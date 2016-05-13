package es;

import ds.Arr;
import es.Entity;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.ExprTools;
import haxe.macro.Printer;

class Entity extends ComponentList
{
	public function new()
	{
		
	}
	
	macro public function setComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>, component:ExprOf<T>):ExprOf<Entity>
	{
		var list = makeComponentListExpr(makeComponentListName(type));
		var field = makeComponentFieldName(type);
		var fieldListNo = makeComponentFieldListNoName(type);
        return macro
		{
			var component = $component;
			Assert.assert(component != null, 'Addable component is not null');
			
			if ($that.$field == null)
			{
				var list:Arr<Entity> = $list;
				$that.$fieldListNo = list.push($that);
			}
			
			$that.$field = component;
			$that;
        }
	}
	
	macro public function removeComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T>
	{
		var list = makeComponentListExpr(makeComponentListName(type));
		var field = makeComponentFieldName(type);
		var fieldListNo = makeComponentFieldListNoName(type);
        return macro
		{
			var component = $that.$field;
			Assert.assert(component != null, 'Removable component is not null');
			
			var list:Arr<Entity> = $list;
			var no = $that.$fieldListNo;
			list.spliceByLast(no);
			if (no < list.length)
			{
				var last = list[no];
				last.$fieldListNo = no;
			}
			
			$that.$fieldListNo = -1;
			$that.$field = null;
			component;
        }
	}
	
	macro public function getComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Null<T>>
	{
		var field = makeComponentFieldName(type);
        return macro $that.$field;
	}
        
    macro public function hasComponents(that:ExprOf<Entity>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		types.push(type);
		return makeHasComponents(that, types);
    }
	
	static macro public function iterateWithComponents(handler:Expr, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Void>
	{
		types.push(type);
		if (types.length == 1) {
			var list = makeComponentListExpr(makeComponentListName(type));
			var field = makeComponentFieldName(type);
			return macro
			{
				var list:Arr<Entity> = $list;
				for (entity in list) 
				{
					$handler(entity);
				}
			}
		}
		
		var hasComponents = makeHasComponents(macro entity, types);
		var listsNames = types.map(makeComponentListName);
		var lists = removeRepeatsAndSort(listsNames).map(makeComponentListExpr);
		var firstList = lists.shift();
		var listExprs = lists.map(function(list)
		{
			return macro
			if ($list.length < shortestList.length)
			{
				shortestList = $list;
			}
		});
		var m = macro
		{
			var shortestList = $firstList;
			$b { listExprs };
			for (entity in shortestList) 
			{
				if ($hasComponents)
				{
					$handler(entity);
				}
			}
			shortestList;
		}
		trace(ExprTools.toString(m));
		return m;
	}
	
	#if macro
	
	static function removeRepeatsAndSort(strings:Array<String>):Array<String>
	{
		var map = new Map();
		for (string in strings)
		{
			map[string] = string;
		}
		strings = Lambda.array(map);
		strings.sort(function(a, b) return a > b ? 1 : a < b ? -1 : 0);
		return strings;
	}
	
	static function makeHasComponents(that:ExprOf<Entity>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		var conditions = types.map(function(type)
		{
			var field = makeComponentFieldName(type);
			return macro $that.$field != null;
		});
		
		if (conditions.length == 1) {
			return conditions[0];
		}
		
		var and = conditions.pop();
		for (condition in conditions) 
		{
			and = macro $and && $condition;
		}
		return and;
	}
	
	static function makeComponentFieldName(type:ExprOf<Class<Dynamic>>):String
	{
		var typeName = switch (type.expr)
		{
			case EConst(CIdent(typeName)): typeName;
			default: throw '"${new Printer().printExpr(type)}" isn\'t a class';
		}
		var complexType = Context.toComplexType(Context.getType(typeName));
		return '__' + StringTools.replace(new Printer().printComplexType(complexType), '.', '_');
	}
	
	static function makeComponentFieldListNoName(type:ExprOf<Class<Dynamic>>):String
	{
		return makeComponentFieldName(type) + '_listNo';
	}
	
	static function makeComponentListName(type:ExprOf<Class<Dynamic>>):String
	{
		return makeComponentFieldName(type) + '_list';
	}
	
	static function makeComponentListExpr(listName:String):Expr
	{
		return macro es.ComponentList.$listName;
	}
	
	#end
}