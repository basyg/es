package es;
import ds.Arr;

class ComponentList
{
	#if !macro
	@:noCompletion public var __app_components_Position:app.components.Position = null;
	@:noCompletion public var __app_components_Speed:app.components.Speed = null;
	@:noCompletion public var __app_components_Angle:app.components.Angle = null;
	
	@:noCompletion public var __app_components_Angle__app_components_Position__app_components_Speed__listNo:Int = -1;
	@:noCompletion static public var __app_components_Angle__app_components_Position__app_components_Speed__list:Arr<Entity> = new Arr();
	
	@:noCompletion public var __app_components_Speed__listNo:Int = -1;
	@:noCompletion static public var __app_components_Speed__list:Arr<Entity> = new Arr();
	
	@:noCompletion public var __app_components_Position__app_components_Speed__listNo:Int = -1;
	@:noCompletion static public var __app_components_Position__app_components_Speed__list:Arr<Entity> = new Arr();
	
	@:noCompletion public var __app_components_Position__listNo:Int = -1;
	@:noCompletion static public var __app_components_Position__list:Arr<Entity> = new Arr();
	#end
}