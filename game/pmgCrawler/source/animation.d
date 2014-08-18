module ridgway.pmgcrawler.animation;

import dsfml.system;
import dsfml.graphics;

class Animation
{
	private
	{
		Time m_duration;
		Time m_progress;
		boolean m_isRunning;
	}

	this(Time duration)
	{
		m_duration = duration;
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	abstract void update(double progress);

	/// This takes the delta time since the last update call as the input.
	final void update(Time time)
	{
		m_progress = m_progress + time;
		double progress = m_progress.asMilliseconds() / m_duration.asMilliseconds();

		// send the progress update call to this animation
		update(progress);
	}

	final boolean isRunning()
	{
		return m_isRunning;
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

	void update(double progress)
	{
		//TODO finish this...
	}
}