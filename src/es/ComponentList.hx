package es;
import app.components.Position;
import app.components.Speed;
import ds.Arr;

class ComponentList
{
	#if !macro
	@:noCompletion public var __app_components_Position:app.components.Position = null;
	@:noCompletion public var __app_components_Position_listNo:Int = -1;
	@:noCompletion static public var __app_components_Position_list:Arr<Entity> = new Arr();
	
	@:noCompletion public var __app_components_Speed:app.components.Speed = null;
	@:noCompletion public var __app_components_Speed_listNo:Int = -1;
	@:noCompletion static public var __app_components_Speed_list:Arr<Entity> = new Arr();
	
	@:noCompletion public var __app_components_Angle:app.components.Angle = null;
	@:noCompletion public var __app_components_Angle_listNo:Int = -1;
	@:noCompletion static public var __app_components_Angle_list:Arr<Entity> = new Arr();
	#end
}