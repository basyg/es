package es;
import ds.Arr;

class EntitySystemLists
{
	#if !macro
	@:noCompletion public var __app_components_Angle__app_components_Position__app_components_Speed__list:Arr<Entity> = new Arr();
	@:noCompletion public var __app_components_Position__app_components_Speed__list:Arr<Entity> = new Arr();
	@:noCompletion public var __app_components_Position__list:Arr<Entity> = new Arr();
	@:noCompletion public var __app_components_Speed__list:Arr<Entity> = new Arr();
	#end
	
}