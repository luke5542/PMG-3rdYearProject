module ridgway.pmgcrawler.animation;

import std.stdio;
import core.time;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;
import ridgway.pmgcrawler.spritesheet;

immutable int INFINITE = -1;

enum RepeatMode
{
	REPEAT,
	REVERSE
}

enum AnimationSetMode
{
	PARALLEL,
	SEQUENTIAL
}

interface Animatable
{
	protected void updateProgress(double progress);
	public void update(Duration deltaDuration);
	public bool isRunning();
}

interface UpdateListener
{
	void onAnimationEnd();
	void onAnimationRepeat();
}

class Animation : Animatable
{
	private
	{
		Duration m_duration;
		Duration m_progress;
		bool m_isRunning;

		Interpolator m_interpolator;

		RepeatMode m_repeatMode;
		int m_repeatCount;
		int m_currentRunCount;

		bool m_isReverse;

		UpdateListener[] m_listeners;
	}

	this(Duration duration)
	{
		m_duration = duration;
		m_interpolator = new LinearInterpolator();
		m_isRunning = true;

		m_repeatMode = RepeatMode.REPEAT;
		m_isReverse = false;
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	protected abstract void updateProgress(double progress);

	/// This takes the delta Duration since the last update call as the input.
	final void update(Duration deltaDuration)
	{
		if(m_isRunning)
		{
			m_progress += deltaDuration;
			double progress = cast(double)(m_progress.total!"usecs") / m_duration.total!"usecs";

			if(progress >= 1.0)
			{
				if(m_repeatCount != 0)
				{
					while(progress >= 1.0)
					{
						progress -= 1.0;
						++m_currentRunCount;
					}

					//Check that we are still in a valid animation frame...
					if(m_repeatCount > 0 && m_repeatCount < m_currentRunCount)
					{
						//We have run out of animation frames, so just leave this at the end animation...
						final switch(m_repeatMode)
						{
							case RepeatMode.REPEAT:
								progress = 1.0;
								break;
							case RepeatMode.REVERSE:
								m_isReverse = m_repeatCount % 2 == 0;
								m_progress = usecs(m_duration.total!"usecs");
								break;
						}
						m_isRunning = false;
						sendOnAnimationEnd();
					}
					else
					{
						//We ARE in a valid animation frame, so update the status accordingly
						final switch(m_repeatMode)
						{
							case RepeatMode.REPEAT:
								m_progress = usecs(m_progress.total!"usecs" % m_duration.total!"usecs");
								break;
							case RepeatMode.REVERSE:
								m_isReverse = m_currentRunCount % 2 == 1;
								m_progress = usecs(m_progress.total!"usecs" % m_duration.total!"usecs");
								progress = cast(double)(m_progress.total!"usecs") / m_duration.total!"usecs";
								break;
						}

						sendOnAnimationRepeat();
					}
				}
				else
				{
					progress = 1.0;
					m_isRunning = false;
					sendOnAnimationEnd();
				}
			}

			progress = m_isReverse ? 1.0 - progress : progress;

			// interpolate the current progress value
			progress = m_interpolator.interpolate(progress);

			// send the progress update call to this animation
			updateProgress(progress);
		}
	}

	void addUpdateListener(UpdateListener listener)
	{
		m_listeners ~= listener;
	}

	void sendOnAnimationEnd()
	{
		foreach(listener; m_listeners)
		{
			listener.onAnimationEnd();
		}
	}

	void sendOnAnimationRepeat()
	{
		foreach(listener; m_listeners)
		{
			listener.onAnimationRepeat();
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

	/// This determines the style of our animation repeat
	@property
	{
		RepeatMode repeatMode(RepeatMode mode)
		{
			m_repeatMode = mode;
			return m_repeatMode;
		}

		RepeatMode repeatMode()
		{
			return m_repeatMode;
		}
	}

	/// If the repeat count is negative, then we repeat infinitely.
	/// Otherwise, we run the animation repeatCount number of Durations.
	@property
	{
		int repeatCount(int count)
		{
			m_repeatCount = count;
			return m_repeatCount;
		}

		int repeatCount()
		{
			return m_repeatCount;
		}
	}
}

class DelegateAnimation : Animation
{
	private
	{
		void delegate(double) m_update;
	}

	this(Duration duration, void delegate(double) update)
	{
		super(duration);
		m_update = update;
	}

	override protected void updateProgress(double progress)
	{
		m_update(progress);
	}

}

/// Base class for animations that act upon a transformable.
class TransformAnimation : Animation
{
	protected
	{
		Transformable m_transformable;
	}

	this(Transformable transformable, Duration duration)
	{
		super(duration);
		m_transformable = transformable;
	}
}

/// Animates the transformable's rotation.
class RotateAnimation : TransformAnimation
{
	protected
	{
		double m_startValue;
		double m_endValue;
	}

	this(Transformable transformable, Duration duration, double startValue, double endValue)
	{
		super(transformable, duration);
		m_startValue = startValue;
		m_endValue = endValue;
	}

	override protected void updateProgress(double progress)
	{
		double newRotation = m_startValue + (m_endValue - m_startValue) * progress;
		m_transformable.rotation = newRotation;
	}

}

/// Base class for animations that require Vector2f-based values.
class VectorTransformAnimation : TransformAnimation
{
	protected
	{
		Vector2f m_startValue;
		Vector2f m_endValue;
	}

	this(Transformable transformable, Duration duration, Vector2f startValue, Vector2f endValue)
	{
		super(transformable, duration);
		m_startValue = startValue;
		m_endValue = endValue;
	}

	Vector2f getUpdatedVector(double progress)
	{
		return (m_startValue + ((m_endValue - m_startValue) * progress));
	}
}

/// Animates the transformable's position
class TranslationAnimation : VectorTransformAnimation
{

	this(Transformable transformable, Duration duration, Vector2f startValue, Vector2f endValue)
	{
		super(transformable, duration, startValue, endValue);
	}

	override protected void updateProgress(double progress)
	{
		m_transformable.position = getUpdatedVector(progress);
	}
}

/// Animates the transformable's scale.
class ScaleAnimation : VectorTransformAnimation
{

	this(Transformable transformable, Duration duration, Vector2f startValue, Vector2f endValue)
	{
		super(transformable, duration, startValue, endValue);
	}

	override protected void updateProgress(double progress)
	{
		m_transformable.scale = getUpdatedVector(progress);
	}
}

/// Base class for animations that act upon a sprite.
class SpriteAnimation : Animation
{
	protected
	{
		Sprite m_sprite;
		SpriteSheet m_spriteSheet;
		SpriteFrameList m_frameList;
	}

	this(Sprite sprite, SpriteSheet spriteSheet, SpriteFrameList frameList)
	{
		super(msecs(cast(int) frameList.getDuration()));
		m_sprite = sprite;
		m_spriteSheet = spriteSheet;
		m_frameList = frameList;
	}

	override protected void updateProgress(double progress)
	{

		string currentTexStr = m_frameList.getFrame(cast(long)(m_frameList.getDuration() * progress));
		//writeln("Setting animation frame: ", currentTexStr, ", for progress: ", progress);
		IntRect currentTexRect = m_spriteSheet.getSpriteRect(currentTexStr);

		m_sprite.textureRect = currentTexRect;
	}
}

///For now, all this class does is run a bunch of animations simultaneously.
class AnimationSet : Animatable
{
	private
	{
		Animation[] m_anims;
		int m_currentAnim;

		AnimationSetMode m_mode;
		bool m_isRunning;
	}

	this(Animation[] anims...)
	{
		m_anims = anims.dup;
		m_mode = AnimationSetMode.PARALLEL;
		m_isRunning = true;
	}

	void setMode(AnimationSetMode mode)
	{
		m_mode = mode;
	}

	//Does nothing because this doesn't need it...
	final void updateProgress(double progress) {};

	final void update(Duration deltaT)
	{
		if(m_isRunning)
		{
			final switch(m_mode)
			{
				case AnimationSetMode.PARALLEL:
					m_isRunning = false;
					foreach(anim; m_anims)
					{
						anim.update(deltaT);
						m_isRunning = anim.isRunning() || m_isRunning;
					}
					break;
				case AnimationSetMode.SEQUENTIAL:
					m_anims[m_currentAnim].update(deltaT);
					if(!m_anims[m_currentAnim].isRunning())
					{
						m_currentAnim++;
						m_isRunning = m_currentAnim < m_anims.length;
					}
					break;
			}
		}
	}

	final bool isRunning()
	{
		return m_isRunning;
	}
}
