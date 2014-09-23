module ridgway.pmgcrawler.node;

import std.algorithm;

import dsfml.system;

import ridgway.pmgcrawler.animation;

interface Node
{
	void runAnimation(Animation anim);
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
		Animation[] m_animations;
	}

	/// Add the animation to the queue
	void runAnimation(Animation anim)
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

		if(m_animations.length == 1 && itemsToRemove.length == 1)
		{
			m_animations.length = 0;
		}
		else if(itemsToRemove.length > 0 && m_animations.length > 0)
		{
			debug writeln("Removing animation indices: ", itemsToRemove);

			//Remove all the items designated for removal...
			m_animations = remove(m_animations, itemsToRemove);
		}

	}

}

