package es;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.Type.ClassField;

class EntityMacro
{
	#if macro
	
	static var _type = EntityMacro;
	
	//public static function getQualifiedEntityComponentsName():String
	//{
		//
	//}
	//
	public static function getQualifiedEntitySystemListsName():String
	{
		
		//Context.onTypeNotFound(function(n) { trace(n); return null; });
		return null;
	}
	
	public static function makeComponentFieldFromTypeExpr<T>(type:ExprOf<Class<T>>):String
	{
		var typeName = ExprTools.toString(type);
		var complexType = Context.toComplexType(Context.getType(typeName));
		return '__' + StringTools.replace(new Printer().printComplexType(complexType), '.', '_');
	}
	
	public static function makeComponentListFieldFromTypeExprs(types:Array<ExprOf<Class<Dynamic>>>):String
	{
		var names = removeRepeatsAndSort(types.map(makeComponentFieldFromTypeExpr));
		return names.join('') + '__list';
	}
	
	public static function makeComponentListNoFieldFromListField(listField:String):String
	{
		return listField + 'No';
	}
	
	static var __allComponentListFields:Null<Array<String>> = null;
	public static function getAllComponentListFields(that:ExprOf<Entity>):Array<String>
	{
		var entitySystemListsType = {
			var typeOfThat = Context.toComplexType(Context.typeof(that));
			Context.getType(new Printer().printComplexType(typeOfThat) + 'SystemLists');
		}
		if (__allComponentListFields == null)
		{
			getQualifiedEntitySystemListsName();
			var staticFields:Array<ClassField> = switch(entitySystemListsType)
			{
				case TInst(_.get().fields.get() => fields, _): fields;
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
		
		if (conditions.length == 1)
		{
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
	
	public static function traceExpr(e)
	{
		trace(ExprTools.toString(e));
		return e;
	}
	
	#end
}