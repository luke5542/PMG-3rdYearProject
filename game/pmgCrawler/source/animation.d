module ridgway.pmgcrawler.animation;

import std.stdio;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;
import ridgway.pmgcrawler.spritesheet;

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
		m_isRunning = true;
	}

	/// This is called with the value (0-1) of the
	/// amount that this animation has completed by. TODO: word better
	protected abstract void updateProgress(double progress);

	/// This takes the delta time since the last update call as the input.
	public final void update(Time deltaTime)
	{
		if(m_isRunning)
		{

			m_progress += deltaTime;
			double progress = cast(double)(m_progress.asMicroseconds()) / m_duration.asMicroseconds();
			if(progress >= 1)
			{
				progress = 1.0;
				m_isRunning = false;
			}

			// interpolate the current progress value
			progress = m_interpolator.interpolate(progress);

			// send the progress update call to this animation
			updateProgress(progress);
		}
	}

	public void setInterpolator(Interpolator interpolator)
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

	public final bool isRunning()
	{
		return m_isRunning;
	}
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

	this(Sprite sprite, Time duration, SpriteSheet spriteSheet, SpriteFrameList frameList)
	{
		super(duration);
		m_sprite = sprite;
		m_spriteSheet = spriteSheet;
		m_frameList = frameList;
	}

	override protected void updateProgress(double progress)
	{
		string currentTexStr = m_frameList.getFrame(cast(long)(m_frameList.getDuration() * progress));
		IntRect currentTexRect = m_spriteSheet.getSpriteRect(currentTexStr);

		m_sprite.textureRect = currentTexRect;
	}
}

