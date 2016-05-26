package es2;

import haxe.macro.Expr.ExprOf;

private typedef EM = EntityMacro;

class Entity extends EntityComponents
{
	public var entitySystem(default, null):EntitySystem;
	
	public function new(entitySystem:EntitySystem)
	{
		this.entitySystem = entitySystem;
	}
	
	macro public function setComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>, component:ExprOf<T>):ExprOf<Entity>
	{
		var field = EM.makeComponentFieldFromTypeExpr(type);
		
		var listFields = EM.getAllComponentListFields(that).filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EM.makeComponentListNoFieldFromListField);
		
		var updateListExprs = [
			for (i in 0...listFields.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				
				var componentFields = EM.parseComponentFieldsFromComponentListField(listField);
				componentFields.remove(field);
				
				var expr = macro entity.$listNoField = entitySystem.$listField.push(entity);
				if (componentFields.length > 0)
				{
					var hasComponentsExpr = EM.makeHasComponentsExprFromFields(macro entity, componentFields);
					expr = macro if ($hasComponentsExpr)
					{
						$expr;
					}
				}
				expr;
			}
		];
		
        return macro
		{
			var entity = $that;
			var component = $component;
			var entitySystem = entity.entitySystem;
			Assert.assert(component != null, 'Component for adding is not null');
			
			if (entity.$field == null) $b{updateListExprs};
			
			entity.$field = component;
			entity;
        };
	}
	
	macro public function removeComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T>
	{
		var field = EM.makeComponentFieldFromTypeExpr(type);
		
		var listFields = EM.getAllComponentListFields(that).filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EM.makeComponentListNoFieldFromListField);
		
		var updateListExprs = [
			for (i in 0...listFields.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				
				var listFields = EM.parseComponentFieldsFromComponentListField(listField);
				listFields.remove(field);
				
				var expr0 = macro var no = entity.$listNoField;
				var expr = macro
				{
					var list = entitySystem.$listField;
					list.spliceByLast(no);
					if (no < list.length)
					{
						list[no].$listNoField = no;
					}
					entity.$listNoField = -1;
				}
				if (listFields.length > 0)
				{
					expr = macro if (no >= 0) $expr;
				}
				expr = macro
				{
					$expr0;
					$expr;
				}
			}
		];
		
        return macro
		{
			var entity = $that;
			var component = $that.$field;
			var entitySystem = entity.entitySystem;
			Assert.assert(component != null, 'Component for removing is not null');
			
			$b{updateListExprs};
			
			entity.$field = null;
			entity;
        };
	}
	
	macro public function getComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Null<T>>
	{
		var field = EM.makeComponentFieldFromTypeExpr(type);
        return macro $that.$field;
	}
        
    macro public function hasComponents(that:ExprOf<Entity>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		types.push(type);
		var fields = types.map(EM.makeComponentFieldFromTypeExpr);
		return macro
		{
			var entity = $that;
			${EM.makeHasComponentsExprFromFields(macro entity, fields)};
		};
    }
}