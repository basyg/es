package es;

import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Type;
import haxe.macro.Type.ClassField;
import sys.FileSystem;
import sys.io.File;

#if macro

class EntityMacro
{
	
	static inline var PREFIX:String = '__';
	static inline var LIST_SUFFIX:String = PREFIX + 'list';
	
	static var _type = EntityMacro;
	
	public static function makeComponentFieldFromTypeExpr<T>(type:ExprOf<Class<T>>):String
	{
		var typeName = TypeTool.fromTypeExpr(type).getName();
		var componentField = PREFIX + StringTools.replace(typeName, '.', '_');
		return componentField;
	}
	
	public static function makeComponentListFieldFromTypeExprs(types:Array<ExprOf<Class<Dynamic>>>):String
	{
		var componentFields = _removeRepeatsAndSort(types.map(makeComponentFieldFromTypeExpr));
		var listField = componentFields.join('') + LIST_SUFFIX;
		updateFilesIfComponentListFieldMissing(listField);
		return listField;
	}
	
	public static function makeComponentListNoFieldFromListField(listField:String):String
	{
		return listField + 'No';
	}
	
	public static function updateFilesIfComponentFieldMissing(componentField:String)
	{
		if (__componentFields == null)
		{
			getComponentFields();
			getComponentListFields();
		}
		if (__componentFields.indexOf(componentField) < 0)
		{
			__componentFields.push(componentField);
			_updateFiles(__componentFields, __componentListFields);
		}
	}
	
	public static function updateFilesIfComponentListFieldMissing(listField:String)
	{
		if (__componentListFields == null)
		{
			getComponentFields();
			getComponentListFields();
		}
		if (__componentListFields.indexOf(listField) < 0)
		{
			__componentListFields.push(listField);
			_updateFiles(__componentFields, __componentListFields);
		}
	}
	
	static var __componentFields:Null<Array<String>> = null;
	public static function getComponentFields():Array<String>
	{
		if (__componentListFields == null)
		{
			__componentFields = _getInstaceFields(EntityComponents)
				.map(function(field) return field.name)
				.filter(function(field) return field.indexOf(LIST_SUFFIX) < 0);
		}
		return __componentFields.copy();
	}
	
	static var __componentListFields:Null<Array<String>> = null;
	public static function getComponentListFields():Array<String>
	{
		if (__componentListFields == null)
		{
			__componentListFields = _getInstaceFields(EntitySystemLists)
				.map(function(field) return field.name);
		}
		return __componentListFields.copy();
	}
	
	static var __parsedComponentFieldsFromComponentListField:Map<String, Array<String>> = new Map();
	public static function parseComponentFieldsFromComponentListField(listField:String):Array<String>
	{
		if (!__parsedComponentFieldsFromComponentListField.exists(listField))
		{
			var fields = listField.split(PREFIX)
				.filter(function(field) return field.length > 0)
				.map(function(field) return PREFIX + field);
			Assert.assert(fields.pop() == LIST_SUFFIX, 'fields.pop() == LIST_SUFFIX');
			__parsedComponentFieldsFromComponentListField[listField] = fields;
		}
		return __parsedComponentFieldsFromComponentListField.get(listField).copy();
	}
	
	static function _getInstaceFields(type:Class<Dynamic>):Array<ClassField>
	{
		var entitySystemListsType = TypeTool.fromType(type).getType();
		return switch(entitySystemListsType)
		{
			case TInst(_.get().fields.get() => fields, _): fields;
			default: throw 'error';
		}
	}
	
	static function _removeRepeatsAndSort(strings:Array<String>):Array<String>
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
	
	static function _updateFiles(componentFields:Array<String>, componentListFields:Array<String>):Void
	{
		var srcPath = Sys.getCwd() + 'src/';
		
		var entityComponentsTypePath = srcPath + StringTools.replace(TypeTool.fromType(EntityComponents).getName(), '.', '/') + '.hx';
		var entityComponentsSource = 'package es;\nclass EntityComponents\n{\n';
		entityComponentsSource += componentFields
			.map(function(field)
			{
				var typeName = StringTools.replace(field.substr(PREFIX.length), '_', '.');
				return '	@:noCompletion public var $field:$typeName = null;';
			}).join('\n');
		entityComponentsSource += '\n';
		entityComponentsSource += componentListFields
			.map(function(listField)
			{
				var listNoField = makeComponentListNoFieldFromListField(listField);
				return '	@:noCompletion public var $listNoField:Int = -1;';
			}).join('\n');
		entityComponentsSource += '\n}\n';
		File.saveContent(entityComponentsTypePath, entityComponentsSource);
		
		var entitySystemListsTypePath = srcPath + StringTools.replace(TypeTool.fromType(EntitySystemLists).getName(), '.', '/') + '.hx';
		var entitySystemListsSource = 'package es;\nclass EntitySystemLists\n{\n';
		entitySystemListsSource += componentListFields
			.map(function(listField)
			{
				return '	@:noCompletion public var $listField:ds.Arr<Entity> = new ds.Arr();';
			}).join('\n');
		entitySystemListsSource += '\n}\n';
		File.saveContent(entitySystemListsTypePath, entitySystemListsSource);
		
		trace(entitySystemListsSource);
		trace(FileSystem.exists(entitySystemListsTypePath));
	}
	
}

private class TypeTool
{
	
	static public function fromTypeExpr(type:ExprOf<Class<Dynamic>>):TypeTool
	{
		var type = Context.typeof(type);
		return switch (type) 
		{
			case Type.TType(_.toString() => classString, p):
				var leftAngleBracketNo = classString.indexOf('<');
				var rightAngleBracketNo = classString.lastIndexOf('>');
				var name = classString.substring(leftAngleBracketNo + 1, rightAngleBracketNo);
				new TypeTool(name);
			default: throw 'invalid ExprOf<Class<Dynamic>>';
		}
	}
	
	static public function fromType(type:Class<Dynamic>):TypeTool
	{
		Assert.assert(Reflect.hasField(type, '__name__'), 'Reflect.hasField(type, "__name__")');
		var name = Reflect.getProperty(type, '__name__').join('.');
		return new TypeTool(name);
	}
	
	var _name:String;
	var _type:Null<Type> = null;
	var _complexType:Null<ComplexType> = null;
	
	public function new(name:String)
	{
		_name = name;
	}
	
	public function getName():String
	{
		return _name;
	}
	
	public function getType():Type
	{
		return _type == null ? _type = Context.getType(_name) : _type;
	}
	
	public function getComplexType():ComplexType
	{
		return _complexType == null ? Context.toComplexType(getType()) : _complexType;
	}
	
}

#end