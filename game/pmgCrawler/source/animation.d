module ridgway.pmgcrawler.animation;

import std.stdio;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;
import ridgway.pmgcrawler.spritesheet;

immutable int INFINITE = -1;

enum RepeateMode
{
	REPEATE,
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
	public void update(Time deltaTime);
	public bool isRunning();
}

interface UpdateListener
{
	void onAnimationEnd();
	void onAnimationRepeate();
}

class Animation : Animatable
{
	private
	{
		Time m_duration;
		Time m_progress;
		bool m_isRunning;

		Interpolator m_interpolator;

		RepeateMode m_repeateMode;
		int m_repeateCount;
		int m_currentRunCount;

		bool m_isReverse;

		UpdateListener[] m_listeners;
	}

	this(Time duration)
	{
		m_duration = duration;
		m_interpolator = new LinearInterpolator();
		m_isRunning = true;

		m_repeateMode = RepeateMode.REPEATE;
		m_isReverse = false;
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	protected abstract void updateProgress(double progress);

	/// This takes the delta time since the last update call as the input.
	final void update(Time deltaTime)
	{
		if(m_isRunning)
		{
			m_progress += deltaTime;
			double progress = cast(double)(m_progress.asMicroseconds()) / m_duration.asMicroseconds();

			if(progress >= 1.0)
			{
				if(m_repeateCount != 0)
				{
					while(progress >= 1.0)
					{
						progress -= 1.0;
						++m_currentRunCount;
					}

					//Check that we are still in a valid animation frame...
					if(m_repeateCount > 0 && m_repeateCount < m_currentRunCount)
					{
						//We have run out of animation frames, so just leave this at the end animation...
						final switch(m_repeateMode)
						{
							case RepeateMode.REPEATE:
								progress = 1.0;
								break;
							case RepeateMode.REVERSE:
								m_isReverse = m_repeateCount % 2 == 0;
								m_progress = microseconds(m_duration.asMicroseconds());
								break;
						}
						m_isRunning = false;
						sendOnAnimationEnd();
					}
					else
					{
						//We ARE in a valid animation frame, so update the status accordingly
						final switch(m_repeateMode)
						{
							case RepeateMode.REPEATE:
								m_progress = microseconds(m_progress.asMicroseconds() % m_duration.asMicroseconds());
								break;
							case RepeateMode.REVERSE:
								m_isReverse = m_currentRunCount % 2 == 1;
								m_progress = microseconds(m_progress.asMicroseconds() % m_duration.asMicroseconds());
								progress = cast(double)(m_progress.asMicroseconds()) / m_duration.asMicroseconds();
								break;
						}

						sendOnAnimationRepeate();
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

	void sendOnAnimationRepeate()
	{
		foreach(listener; m_listeners)
		{
			listener.onAnimationRepeate();
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

	/// This determines the style of our animation repeate
	@property
	{
		RepeateMode repeateMode(RepeateMode mode)
		{
			m_repeateMode = mode;
			return m_repeateMode;
		}

		RepeateMode repeateMode()
		{
			return m_repeateMode;
		}
	}

	/// If the repeate count is negative, then we repeate infinitely.
	/// Otherwise, we run the animation repeateCount number of times.
	@property
	{
		int repeateCount(int count)
		{
			m_repeateCount = count;
			return m_repeateCount;
		}

		int repeateCount()
		{
			return m_repeateCount;
		}
	}
}

class DelegateAnimation : Animation
{
	private
	{
		void delegate(double) m_update;
	}

	this(Time duration, void delegate(double) update)
	{
		super(duration);
		m_update = update;
	}

	override protected void updateProgress(double progress)
	{
		m_update(progress);
	}

}

unittest
{
	writeln("Testing DelegateAnimation...");

	string helloWorld = "Hello World!";
	void someFunc(double progress) { writeln("Yes, can access: ", helloWorld,
									 ", with progress: ", progress); }

	auto dur = seconds(2);

	auto delAnim = new DelegateAnimation(dur, &someFunc);
	delAnim.update(seconds(.5));
	delAnim.update(seconds(.5));
	delAnim.update(seconds(.5));
	delAnim.update(seconds(.5));
	assert(!delAnim.isRunning());

	writeln("DelegateAnimation tests passed!");
	writeln();
}

/// Base class for animations that act upon a transformable.
class TransformAnimation : Animation
{
	protected
	{
		Transformable m_transformable;
	}

	this(Transformable transformable, Time duration)
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

	this(Transformable transformable, Time duration, double startValue, double endValue)
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

unittest
{
	auto sprite = new Sprite();
	sprite.rotation = 0;

	Time transDuration = seconds(2.0);

	writeln("Testing RotateAnimation...");

	auto rotateAnim = new RotateAnimation(sprite, transDuration,
		sprite.rotation, 180);

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 45);

	rotateAnim.update(seconds(1));
	assert(sprite.rotation == 135);

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 180);
	assert(!rotateAnim.isRunning());

	writeln("Rotation Animation tests passed.");
	writeln();
}

unittest
{	
	auto sprite = new Sprite();
	sprite.rotation = 0;

	Time transDuration = seconds(2.0);

	writeln("Testing repeating animations.");

	auto rotateAnim = new RotateAnimation(sprite, transDuration, 0, 180);
	rotateAnim.repeateMode = RepeateMode.REPEATE;
	rotateAnim.repeateCount = 1;

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 135);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());


	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 180);
	assert(!rotateAnim.isRunning());
	writeln("Single repeate success.");

	rotateAnim = new RotateAnimation(sprite, transDuration, 0, 180);
	rotateAnim.repeateMode = RepeateMode.REPEATE;
	rotateAnim.repeateCount = INFINITE;

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 45);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(199.0));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());
	writeln("Infinite repeate success.");

	rotateAnim = new RotateAnimation(sprite, transDuration, 0, 180);
	rotateAnim.repeateMode = RepeateMode.REVERSE;
	rotateAnim.repeateCount = 1;

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 180);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 0);
	assert(!rotateAnim.isRunning());
	writeln("Single reverse success.");

	rotateAnim = new RotateAnimation(sprite, transDuration, 0, 180);
	rotateAnim.repeateMode = RepeateMode.REVERSE;
	rotateAnim.repeateCount = INFINITE;

	rotateAnim.update(seconds(2.0));
	assert(sprite.rotation == 180);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(0.5));
	assert(sprite.rotation == 135);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(0.5));
	assert(sprite.rotation == 90);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 45);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.5));
	assert(sprite.rotation == 180);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assert(sprite.rotation == 135);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.5));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());

	rotateAnim.update(seconds(200.0));
	assert(sprite.rotation == 0);
	assert(rotateAnim.isRunning());
	writeln("Infinite reverse success.");

	writeln("Animation repeating tests passed.");
	writeln();
}

/// Base class for animations that require Vector2f-based values.
class VectorTransformAnimation : TransformAnimation
{
	protected
	{
		Vector2f m_startValue;
		Vector2f m_endValue;
	}

	this(Transformable transformable, Time duration, Vector2f startValue, Vector2f endValue)
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

	this(Transformable transformable, Time duration, Vector2f startValue, Vector2f endValue)
	{
		super(transformable, duration, startValue, endValue);
	}

	override protected void updateProgress(double progress)
	{
		m_transformable.position = getUpdatedVector(progress);
	}
}

unittest
{
	import std.stdio;
	writeln("Testing TranslationAnimation...");

	auto sprite = new Sprite();
	sprite.position = Vector2f(0, 0);

	Time transDuration = seconds(2.0);

	auto trasnlateAnim = new TranslationAnimation(sprite, transDuration,
		sprite.position, Vector2f(100, 100));

	trasnlateAnim.update(seconds(.5));
	assert(sprite.position == Vector2f(25, 25));

	trasnlateAnim.update(seconds(1));
	assert(sprite.position == Vector2f(75, 75));

	trasnlateAnim.update(seconds(.5));
	assert(sprite.position == Vector2f(100, 100));
	assert(!trasnlateAnim.isRunning());

	writeln("Translation Animation tests passed.");
	writeln();
}

/// Animates the transformable's scale.
class ScaleAnimation : VectorTransformAnimation
{

	this(Transformable transformable, Time duration, Vector2f startValue, Vector2f endValue)
	{
		super(transformable, duration, startValue, endValue);
	}

	override protected void updateProgress(double progress)
	{
		m_transformable.scale = getUpdatedVector(progress);
	}
}

unittest
{
	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time transDuration = seconds(2.0);

	writeln("Testing ScaleAnimation...");

	auto scaleAnim = new ScaleAnimation(sprite, transDuration,
		sprite.scale, Vector2f(10, 10));

	scaleAnim.update(seconds(.5));
	assert(sprite.scale == Vector2f(2.5, 2.5));

	scaleAnim.update(seconds(1));
	assert(sprite.scale == Vector2f(7.5, 7.5));

	scaleAnim.update(seconds(.5));
	assert(sprite.scale == Vector2f(10, 10));
	assert(!scaleAnim.isRunning());

	writeln("Scale Animation tests passed.");
	writeln();
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
		super(milliseconds(cast(int) frameList.getDuration()));
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
		m_anims = anims;
		m_mode = AnimationSetMode.PARALLEL;
		m_isRunning = true;
	}

	void setMode(AnimationSetMode mode)
	{
		m_mode = mode;
	}

	//Does nothing because this doesn't need it...
	final void updateProgress(double progress) {};

	final void update(Time deltaT)
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

unittest
{
	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time transDuration = seconds(2.0);

	writeln("Testing Parallel AnimationSet...");
	auto scaleAnim = new ScaleAnimation(sprite, transDuration,
		sprite.scale, Vector2f(10, 10));

	auto translateAnim = new TranslationAnimation(sprite, transDuration,
		sprite.position, Vector2f(100, 100));

	auto animSet = new AnimationSet(scaleAnim, translateAnim);

	animSet.update(seconds(.5));
	assert(sprite.scale == Vector2f(2.5, 2.5));
	assert(sprite.position == Vector2f(25, 25));

	animSet.update(seconds(1));
	assert(sprite.scale == Vector2f(7.5, 7.5));
	assert(sprite.position == Vector2f(75, 75));

	animSet.update(seconds(.5));
	assert(sprite.scale == Vector2f(10, 10));
	assert(sprite.position == Vector2f(100, 100));
	assert(!scaleAnim.isRunning());
	assert(!translateAnim.isRunning());
	assert(!animSet.isRunning());

	writeln("Parallel AnimationSet tests passed.");
	writeln();
}

unittest
{
	writeln("Testing Sequential AnimationSet...");
	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time transDuration = seconds(2.0);

	auto scaleAnim = new ScaleAnimation(sprite, transDuration,
		sprite.scale, Vector2f(10, 10));

	auto translateAnim = new TranslationAnimation(sprite, transDuration,
		sprite.position, Vector2f(100, 100));

	auto animSet = new AnimationSet(scaleAnim, translateAnim);
	animSet.setMode(AnimationSetMode.SEQUENTIAL);

	animSet.update(seconds(.5));
	assert(sprite.scale == Vector2f(2.5, 2.5));

	animSet.update(seconds(1));
	assert(sprite.scale == Vector2f(7.5, 7.5));

	animSet.update(seconds(.5));
	assert(sprite.scale == Vector2f(10, 10));
	assert(!scaleAnim.isRunning());

	//The translation animation should get run now...
	animSet.update(seconds(.5));
	assert(sprite.position == Vector2f(25, 25));

	animSet.update(seconds(1));
	assert(sprite.position == Vector2f(75, 75));

	animSet.update(seconds(.5));
	assert(sprite.position == Vector2f(100, 100));

	assert(!translateAnim.isRunning());
	assert(!animSet.isRunning());

	writeln("Sequential AnimationSet tests passed.");
	writeln();
}
