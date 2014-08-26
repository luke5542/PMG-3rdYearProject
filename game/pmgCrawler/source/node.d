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

	private
	{
		Animation[] m_animations;
	}

	/// Add the animation to the queue
	void runAnimation(Animation anim)
	{
		m_animations ~= anim;
	}

	void updateAnimations(Time time)
	{
		ulong[] itemsToRemove;
		foreach(i, anim; m_animations)
		{
			if(anim.isRunning())
			{
				anim.update(time);
			}
			else
			{
				itemsToRemove ~= i;
			}
		}

		//Remove all the items designated for removal...
		foreach(i; itemsToRemove)
		{
			remove!(SwapStrategy.unstable)(m_animations, i);
		}
	}

}

