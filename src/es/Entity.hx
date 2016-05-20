package es;

import ds.Arr;
import es.Entity;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

class Entity extends EntityComponents
{
	public function new()
	{
		
	}
	
	macro public function setComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>, component:ExprOf<T>):ExprOf<Entity>
	{
		var field = makeComponentField(type);
		
		var allListsNames = getAllComponentListFields();
		var listsNames = allListsNames.filter(function(list) return list.indexOf(field) >= 0);
		var lists = listsNames.map(makeComponentListExpr);
		
		var listNoFields = listsNames.map(makeComponentListNoField);
		
		var listExprs = [for (i in 0...lists.length) 
		{
			var listNoField = listNoFields[i];
			var listName = listsNames[i];
			var list = lists[i];
			
			var listFields = parseComponentFieldsFromComponentListField(listName, field);
			
			var expr = macro
			{
				var list:Arr<Entity> = $list;
				$that.$listNoField = list.push($that);
			}
			if (listFields.length > 0)
			{
				var hasComponents = makeHasComponentsFromFields(that, listFields);
				expr = macro if ($hasComponents) $expr;
			}
			expr;
		}];
		
        var m = macro
		{
			var component = $component;
			Assert.assert(component != null, 'Component for adding is not null');
			
			if ($that.$field == null) $b{listExprs};
			
			$that.$field = component;
			$that;
        }
		trace(ExprTools.toString(m));
		return m;
	}
	
	macro public function removeComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T>
	{
		var field = makeComponentField(type);
		
		var allListsNames = getAllComponentListFields();
		var listsNames = allListsNames.filter(function(list) return list.indexOf(field) >= 0);
		var lists = listsNames.map(makeComponentListExpr);
		
		var listNoFields = listsNames.map(makeComponentListNoField);
		
		var listExprs = [for (i in 0...lists.length) 
		{
			var listNoField = listNoFields[i];
			var listName = listsNames[i];
			var list = lists[i];
			
			var listFields = parseComponentFieldsFromComponentListField(listName, field);
			
			var expr0 = macro var no = $that.$listNoField;
			var expr = macro
			{
				var list:Arr<Entity> = $list;
				list.spliceByLast(no);
				if (no < list.length)
				{
					var last = list[no];
					last.$listNoField = no;
				}
				$that.$listNoField = -1;
			}
			if (listFields.length > 0)
			{
				expr = macro if (no >= 0) $expr;
			}
			expr = macro {$expr0; $expr;}
		}];
		
        var m = macro
		{
			var component = $that.$field;
			Assert.assert(component != null, 'Component for removing is not null');
			
			$b{listExprs};
			
			$that.$field = null;
			$that;
        }
		trace(ExprTools.toString(m));
		return m;
	}
	
	macro public function getComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Null<T>>
	{
		var field = makeComponentField(type);
        return macro $that.$field;
	}
        
    macro public function hasComponents(that:ExprOf<Entity>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		types.push(type);
		return makeHasComponentsFromTypes(that, types);
    }
	
	static macro public function getEntitiesWithComponents(type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<ConstArr<Entity>>
	{
		types.push(type);
		var list = makeComponentListExpr(makeComponentListField(types));
		var m =  macro new ConstArr<Entity>($list);
		trace(ExprTools.toString(m));
		return m;
	}
	
	#if macro
	
	static var __allComponentListFields:Null<Array<String>> = null;
	
	static function parseComponentFieldsFromComponentListField(listName:String, ?withoutField:String):Array<String>
	{
		var fields = [];
		
		while(true)
		{
			var i = listName.indexOf('__', 2);
			var field = listName.substr(0, i);
			listName = listName.substr(i);
			fields.push(field);
			if (listName == '__list')
			{
				break;
			}
		}
		
		if (withoutField != null)
		{
			var i = fields.indexOf(withoutField);
			if (i >= 0)
			{
				fields.splice(i, 1);
			}
		}
		
		return fields;
	}
	
	static function getAllComponentListFields():Array<String>
	{
		if (__allComponentListFields == null)
		{
			var staticFields:Array<ClassField> = switch(Context.getType('es.EntityComponents'))
			{
				case TInst(_.get().statics.get() => fields, _): fields;
				default: throw 'error';
			}
			__allComponentListFields = staticFields.map(function(field) return field.name);
		}
		return __allComponentListFields;
	}
	
	static function makeHasComponentsFromTypes(that:ExprOf<Entity>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		return makeHasComponentsFromFields(that, types.map(makeComponentField));
	}
	
	static function makeHasComponentsFromFields(that:ExprOf<Entity>, fields:Array<String>):ExprOf<Bool>
	{
		var conditions = fields.map(function(field)
		{
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
	
	static function makeComponentField(type:ExprOf<Class<Dynamic>>):String
	{
		var typeName = switch (type.expr)
		{
			case EConst(CIdent(typeName)): typeName;
			default: throw '"${new Printer().printExpr(type)}" isn\'t a class';
		}
		var complexType = Context.toComplexType(Context.getType(typeName));
		return '__' + StringTools.replace(new Printer().printComplexType(complexType), '.', '_');
	}
	
	static function makeComponentListNoField(listName:String):String
	{
		return listName + 'No';
	}
	
	static function makeComponentListField(types:Array<ExprOf<Class<Dynamic>>>):String
	{
		var names = removeRepeatsAndSort(types.map(makeComponentField));
		return names.join('') + '__list';
	}
	
	static function makeComponentListExpr(listName:String):Expr
	{
		return macro es.EntityComponents.$listName;
	}
	
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
	
	#end
}