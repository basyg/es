package es;

import ds.Arr;
import es.Entity;
import haxe.macro.Expr.ExprOf;

typedef EMT = EntityMacroTools;

class Entity extends EntityComponents
{
	public function new()
	{
		
	}
	
	macro public function setComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>, component:ExprOf<T>):ExprOf<Entity>
	{
		var field = EMT.makeComponentField(type);
		
		var listFields = EMT.getAllComponentListFields().filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EMT.makeComponentListNoField);
		var listExprs = listFields.map(EMT.makeComponentListExpr);
		
		var updateListExprs = [
			for (i in 0...listExprs.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				var listExpr = listExprs[i];
				
				var componentFields = EMT.parseComponentFieldsFromComponentListField(listField);
				componentFields.remove(field);
				
				var expr = macro entity.$listNoField = $listExpr.push(entity);
				if (componentFields.length > 0)
				{
					var hasComponentsExpr = EMT.makeHasComponentsExprFromFields(macro entity, componentFields);
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
			var entity:Entity = $that;
			var component = $component;
			Assert.assert(component != null, 'Component for adding is not null');
			
			if (entity.$field == null) $b{updateListExprs};
			
			entity.$field = component;
			entity;
        };
	}
	
	macro public function removeComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T>
	{
		var field = EMT.makeComponentField(type);
		
		var listFields = EMT.getAllComponentListFields().filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EMT.makeComponentListNoField);
		var listExprs = listFields.map(EMT.makeComponentListExpr);
		
		var updateListExprs = [
			for (i in 0...listExprs.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				var listExpr = listExprs[i];
				
				var listFields = EMT.parseComponentFieldsFromComponentListField(listField);
				listFields.remove(field);
				
				var expr0 = macro var no = $that.$listNoField;
				var expr = macro
				{
					var list:Arr<Entity> = $listExpr;
					list.spliceByLast(no);
					if (no < list.length)
					{
						list[no].$listNoField = no;
					}
					$that.$listNoField = -1;
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
			var component = $that.$field;
			Assert.assert(component != null, 'Component for removing is not null');
			
			$b{updateListExprs};
			
			$that.$field = null;
			$that;
        };
	}
	
	macro public function getComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Null<T>>
	{
		var field = EMT.makeComponentField(type);
        return macro $that.$field;
	}
        
    macro public function hasComponents(that:ExprOf<Entity>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		types.push(type);
		var fields = types.map(EMT.makeComponentField);
		return macro
		{
			var entity:Entity = $that;
			${EMT.makeHasComponentsExprFromFields(macro entity, fields)};
		};
    }
	
	static macro public function getEntitiesWithComponents(type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<ConstArr<Entity>>
	{
		types.push(type);
		var list = EMT.makeComponentListExpr(EMT.makeComponentListField(types));
		return macro new ConstArr<Entity>($list);
	}
}