module ridgway.pmgcrawler.node;

import std.algorithm;

import dsfml.system;

import ridgway.pmgcrawler.animation;

interface Node
{
	void runAnimation(Animatable anim);
	void updateAnimations(Time time);
	void update(Time time);
}

mixin template NormalNode()
{
	import ridgway.pmgcrawler.animation;
	import std.algorithm;
	debug import std.stdio;

	private
	{
		Animatable[] m_animations;
	}

	/// Add the animation to the queue
	void runAnimation(Animatable anim)
	{
		m_animations ~= anim;
	}

	/// Update the currently running animations.
	void updateAnimations(Time time)
	{
		int[] itemsToRemove;
		foreach(i, anim; m_animations)
		{
			if(anim.isRunning())
			{
				anim.update(time);
			}
			else
			{
				itemsToRemove ~= cast(int) i;
			}
		}

		//if(itemsToRemove.length == m_animations.length)
		//{
		//	m_animations.length = 0;
		//}
		//else if(itemsToRemove.length > 0 && m_animations.length > 0)
		//{
		//	debug writeln("Removing animation indices: ", itemsToRemove);

		//	//Remove all the items designated for removal...
		//	m_animations = remove(m_animations, itemsToRemove);
		//}

		foreach(index; itemsToRemove)
		{
			removeAtUnstable(m_animations, index);
		}

	}

	private static void removeAtUnstable(T)(ref T[] arr, size_t index)
	{
	    if(index >= arr.length)
	    {
	    	writeln("YA DOOF, index(", index, ") >= arr.length(", arr.length, ")");
	    }
	    else
	    {
	    	if(index != arr.length - 1)
	    	{
	    		arr[index] = arr[$-1];
	    	}
    		arr = arr[0 .. $-1];

	    }
	}

}

