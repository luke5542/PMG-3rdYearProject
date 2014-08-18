module ridgway.pmgcrawler.node;

import dsfml.system;

import ridgway.pmgcrawler.animation;

interface Node
{
	void runAnimation(Animation anim);
	void updateAnimations(Time time);
}

mixin template NormalNode
{
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
		foreach(anim; m_animations)
		{
			anim.update(time);
		}
	}

}

