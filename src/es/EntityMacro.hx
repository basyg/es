package es;

import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr.TypePath;
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.Type.ClassField;
import sys.io.File;

#if macro

class EntityMacro
{
	
	static inline var PREFIX:String = '__';
	static inline var LIST_SUFFIX:String = PREFIX + 'list';
	
	static var _componentFields:Null<Array<String>> = null;
	static var _componentListFields:Null<Array<String>> = null;
	
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
		var componentFields = _componentFields == null ? getComponentFields() : _componentFields;
		if (componentFields.indexOf(componentField) < 0)
		{
			_componentFields.push(componentField);
			_updateFiles(componentFields, getComponentListFields());
		}
	}
	
	public static function updateFilesIfComponentListFieldMissing(listField:String)
	{
		if (_componentListFields == null)
		{
			getComponentFields();
			getComponentListFields();
		}
		if (_componentListFields.indexOf(listField) < 0)
		{
			_componentListFields.push(listField);
			_updateFiles(_componentFields, _componentListFields);
		}
	}
	
	public static function getComponentFields():Array<String>
	{
		if (_componentListFields == null)
		{
			_componentFields = _getInstaceFields(EntityComponents)
				.map(function(field) return field.name)
				.filter(function(field) return field.indexOf(LIST_SUFFIX) < 0);
		}
		return _componentFields.copy();
	}
	
	public static function getComponentListFields():Array<String>
	{
		if (_componentListFields == null)
		{
			_componentListFields = _getInstaceFields(EntitySystemLists)
				.map(function(field) return field.name);
		}
		return _componentListFields.copy();
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
		var packagePath = {
			var fullName = TypeTool.fromType(EntityComponents).getName();
			var lastPointNo = fullName.lastIndexOf('.');
			lastPointNo > 0 ? fullName.substring(0, lastPointNo) : '';
		}
		
		var entityComponentsTypePath = srcPath + StringTools.replace(TypeTool.fromType(EntityComponents).getName(), '.', '/') + '.hx';
		var entityComponentsSource =
			'package $packagePath;\n' +
			'class EntityComponents\n' +
			'{\n';
		for (field in componentFields) 
		{
			var typeName = StringTools.replace(field.substr(PREFIX.length), '_', '.');
			entityComponentsSource += '\t@:noCompletion public var $field:$typeName = null;\n';
		}
		entityComponentsSource += '\n';
		for (listField in componentListFields) 
		{
			var listNoField = makeComponentListNoFieldFromListField(listField);
			entityComponentsSource += '\t@:noCompletion public var $listNoField:Int = -1;\n';
		}
		entityComponentsSource += '}\n';
		
		var entitySystemListsTypePath = srcPath + StringTools.replace(TypeTool.fromType(EntitySystemLists).getName(), '.', '/') + '.hx';
		var entitySystemListsSource =
			'package $packagePath;\n' +
			'class EntitySystemLists\n' +
			'{\n';
		for (listField in componentListFields) 
		{
			var listNoField = makeComponentListNoFieldFromListField(listField);
			entitySystemListsSource += '	@:noCompletion public var $listField:ds.Arr<Entity> = new ds.Arr();\n';
		}
		entitySystemListsSource += '}\n';
		
		File.saveContent(entityComponentsTypePath, entityComponentsSource);
		File.saveContent(entitySystemListsTypePath, entitySystemListsSource);
	}
	
}

private class TypeTool
{
	
	static public function fromTypeExpr(type:ExprOf<Class<Dynamic>>):TypeTool
	{
		var name = new Printer().printTypePath(
			switch (Context.toComplexType(Context.getType(ExprTools.toString(type))))
			{
				case ComplexType.TPath(p): p;
				default: throw 'invalid ExprOf<Class<Dynamic>>';
			}
		);
		return new TypeTool(name);
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