module ridgway.pmgcrawler.animation;

import dsfml.system;
import dsfml.graphics;

class Animation
{
	private
	{
		Time m_duration;
	}

	this(Time duration)
	{
		m_duration = duration;
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	abstract void update(float progress);

	final void update(Time time)
	{
		//TODO finish this
	}
}

class TransformAnimation : Animation
{
	private
	{
		Transformable m_transformable;
	}

	this(Transformable transformable, Time duration)
	{
		super(duration);
		m_transformable = transformable;
	}
}