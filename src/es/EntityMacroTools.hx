package es;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

class EntityMacroTools
{
	#if macro
	
	public static function makeComponentField<T>(type:ExprOf<Class<T>>):String
	{
		var typeName = switch (type.expr)
		{
			case EConst(CIdent(typeName)): typeName;
			default: throw '"${new Printer().printExpr(type)}" isn\'t a class';
		}
		var complexType = Context.toComplexType(Context.getType(typeName));
		return '__' + StringTools.replace(new Printer().printComplexType(complexType), '.', '_');
	}
	
	public static function makeComponentListField(types:Array<ExprOf<Class<Dynamic>>>):String
	{
		var names = removeRepeatsAndSort(types.map(makeComponentField));
		return names.join('') + '__list';
	}
	
	public static function makeComponentListNoField(listField:String):String
	{
		return listField + 'No';
	}
	
	public static function makeComponentListExpr(listField:String):Expr
	{
		return macro es.EntityComponents.$listField;
	}
	
	static var __allComponentListFields:Null<Array<String>> = null;
	public static function getAllComponentListFields():Array<String>
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
		return __allComponentListFields.copy();
	}
	
	static var __parsedComponentFieldsFromComponentListField:Map<String, Array<String>> = new Map();
	public static function parseComponentFieldsFromComponentListField(listField:String):Array<String>
	{
		if (!__parsedComponentFieldsFromComponentListField.exists(listField))
		{
			var fields = listField.split('__')
				.filter(function(field) return field != '')
				.map(function(field) return '__' + field);
			if (fields.pop() != '__list')
			{
				throw 'Suffix "__list" is not found in listField';
			}
			__parsedComponentFieldsFromComponentListField.set(listField, fields);
		}
		return __parsedComponentFieldsFromComponentListField.get(listField).copy();
	}
	
	public static function makeHasComponentsExprFromFields(entity:ExprOf<Entity>, fields:Array<String>):ExprOf<Bool>
	{
		var conditions = fields.map(function(field)
		{
			return macro $entity.$field != null;
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
	
	public static function removeRepeatsAndSort(strings:Array<String>):Array<String>
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