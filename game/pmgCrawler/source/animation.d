module ridgway.pmgcrawler.animation;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;

class Animation
{
	private
	{
		Time m_duration;
		Time m_progress;
		bool m_isRunning;

		Interpolator m_interpolator;
	}

	this(Time duration)
	{
		m_duration = duration;
		m_interpolator = new LinearInterpolator();
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	abstract void update(double progress);

	/// This takes the delta time since the last update call as the input.
	final void update(Time time)
	{
		if(m_isRunning)
		{
			m_progress = m_progress + time;
			double progress = m_progress.asMilliseconds() / m_duration.asMilliseconds();
			if(progress >= 1)
			{
				progress = 1.0;
				m_isRunning = false;
			}

			// interpolate the current progress value
			progress = m_interpolator.interpolate(progress);

			// send the progress update call to this animation
			update(progress);
		}
	}

	void setInterpolator(Interpolator interpolator)
	{
		if(interpolator)
		{
			m_interpolator = interpolator;
		}
		else if(!m_interpolator)
		{
			m_interpolator = new LinearInterpolator();
		}
	}

	final bool isRunning()
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

	override void update(double progress)
	{
		//TODO finish this...
	}
}