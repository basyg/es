package ds;

import haxe.macro.Expr.ExprOf;

#if macro

extern class Vector<T> implements ArrayAccess<T> {

	var length : Int;
	var fixed : Bool;

	function new( ?length : UInt, ?fixed : Bool ) : Void;
	function concat( ?a : Vector<T> ) : Vector<T>;
	function join( sep : String ) : String;
	function pop() : Null<T>;
	function push(x : T) : Int;
	function reverse() : Void;
	function shift() : Null<T>;
	function unshift( x : T ) : Void;
	function slice( ?pos : Int, ?end : Int ) : Vector<T>;
	function sort( f : T -> T -> Int ) : Void;
	function splice( pos : Int, len : Int ) : Vector<T>;
	function toString() : String;
	function indexOf( x : T, ?from : Int ) : Int;
	function lastIndexOf( x : T, ?from : Int ) : Int;

	public inline static function ofArray<T>( v : Array<T> ) : Vector<T> {
		return untyped __vector__(v);
	}

	public inline static function convert<T,U>( v : Vector<T> ) : Vector<U> {
		return untyped __vector__(v);
	}

}

typedef ArrArray<T> = Vector<T>;

#else

typedef ArrArray<T> = flash.Vector<T>;

#end

abstract Arr<T>(ArrArray<T>) from ArrArray<T>
{
	public var length(get, set):Int;
	
	public inline function new(?length:UInt, ?fixed:Bool)
	{
		this = new ArrArray<T>(length, fixed);
	}
		
	@:arrayAccess
	public inline function get(no:Int):T
	{
		return this[no];
	}
	
	@:arrayAccess
	public inline function set(no:Int, item:T):Void
	{
		this[no] = item;
	}
		
	public inline function iterator():ArrIterator<T>
	{
		return new ArrIterator(this, 0);
	}
	
	public inline function push(item:T):Int
	{
		var l = this.length;
		this[l] = item;
		return l;
	}
	
	public inline function pop(item:T):T
	{
		return this[this.length-- - 1];
	}
	
	public inline function indexOf(item:T):Int
	{
		var result = -1;
		var i = 0;
		var l = this.length;
		while (i < l)
		{
			if (item == this[i++])
			{
				result = i - 1;
				break;
			}
		}
		return result;
	}
	
	public inline function lastIndexOf(item:T):Int
	{
		var result = -1;
		var i = this.length - 1;
		while (i > 0)
		{
			if (item == this[i--])
			{
				result = i + 1;
				break;
			}
		}
		return result;
	}
	
	public inline function has(item:T):Bool
	{
		return indexOf(item) >= 0;
	}
	
	public inline function remove(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			splice(i);
		}
		return isFinded;
	}
	
	public inline function removeByLast(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			spliceByLast(i);
		}
		return isFinded;
	}
	
	public inline function splice(i:Int, isFillByLast:Bool = false):Void
	{
		var newLength = this.length - 1;
		while (i < newLength)
		{
			this[i] = this[i + 1];
			i++;
		}
		this.length = newLength;
	}
	
	public inline function spliceByLast(i:Int, isFillByLast:Bool = false):Void
	{
		var newLength = this.length - 1;
		this[i] = this[newLength];
		this.length = newLength;
	}
	
	inline function get_length():Int
	{
		return this.length;
	}
	
	inline function set_length(length:Int):Int
	{
		return this.length = length;
	}
}

class ArrIterator<T>
{
	public inline function new(arr:ConstArr<T>, no:Int)
	{
		_arr = arr;
		_no = no;
	}
	
	public inline function hasNext():Bool
	{
		return _no < _arr.length;
	}
	
	public inline function next():T
	{
		return _arr[_no++];
	}
	
	var _arr:ConstArr<T>;
	var _no:Int;
}

@:forward(length, iterator)
abstract ConstArr<T>(Arr<T>) from Arr<T>
{
	public inline function new(arr:Arr<T>)
	{
		this = arr;
	}
	
	@:arrayAccess public inline function get(no:Int):T
	{
		return this[no];
	}
}