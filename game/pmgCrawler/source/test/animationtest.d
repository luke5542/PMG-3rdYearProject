module test.animationtest;

import dunit;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;
import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.animation;

class RepeatTest
{
	mixin UnitTest;

	Sprite sprite;
	Duration duration;

	RotateAnimation rotateAnim;

	this()
	{
		sprite = new Sprite();
		duration = msecs(2000);
	}

	@Before
	void setupAnimation()
	{
		sprite.rotation = 0;
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
	}

	@Test
	void testRepeatSingle()
	{
		rotateAnim.repeatMode = RepeatMode.REPEAT;
		rotateAnim.repeatCount = 1;

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());


		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 180);
		assertFalse(rotateAnim.isRunning());
	}

	@Test
	void testRepeatInfinite()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REPEAT;
		rotateAnim.repeatCount = INFINITE;

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 45);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(199_000));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());
	}

	@Test
	void testReverseSingle()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REVERSE;
		rotateAnim.repeatCount = 1;

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 0);
		assertFalse(rotateAnim.isRunning());
	}

	@Test
	void testReverseInfinite()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REVERSE;
		rotateAnim.repeatCount = INFINITE;

		rotateAnim.update(msecs(2000));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 45);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1500));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(1500));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(msecs(200_000));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());
	}
}

class DelegateTest
{
	import std.stdio;
	mixin UnitTest;

	Duration duration;

	DelegateAnimation delegateAnim;

	string delegateMessage = "External Message";

	this()
	{
		duration = msecs(2000);
	}

	@Before
	void setupDelegateFunction()
	{
		delegateAnim = new DelegateAnimation(duration, &someFunc);
	}

	void someFunc(double progress) {
		debug writeln("Yes, can access: ", delegateMessage,
				", with progress: ", progress);
	}

	@Test
	void testDelegateAnimation()
	{
		delegateAnim.update(msecs(500));
		delegateAnim.update(msecs(500));
		delegateAnim.update(msecs(500));
		delegateAnim.update(msecs(500));

		assertFalse(delegateAnim.isRunning());
	}
}

class RotateTest
{
	mixin UnitTest;

	Sprite sprite;
	Duration duration;

	RotateAnimation rotateAnim;

	this()
	{
		sprite = new Sprite();
		duration = msecs(2000);
	}

	@Before
	void setupRotate()
	{
		sprite.rotation = 0;
		rotateAnim = new RotateAnimation(sprite, duration, sprite.rotation, 180);
	}

	@Test
	void testRotateAnimation()
	{
		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 45);

		rotateAnim.update(msecs(1000));
		assertEquals(sprite.rotation, 135);

		rotateAnim.update(msecs(500));
		assertEquals(sprite.rotation, 180);
		assertFalse(rotateAnim.isRunning());
	}
}

class TranslationTest
{
	mixin UnitTest;

	Sprite sprite;
	Duration duration;

	TranslationAnimation trasnlateAnim;

	this()
	{
		sprite = new Sprite();
		duration = msecs(2000);
	}

	@Before
	void setupTranslation()
	{
		sprite.position = Vector2f(0, 0);
		trasnlateAnim = new TranslationAnimation(sprite, duration,
						sprite.position, Vector2f(100, 100));
	}

	@Test
	void testRotateAnimation()
	{
		trasnlateAnim.update(msecs(500));
		assertEquals(sprite.position, Vector2f(25, 25));

		trasnlateAnim.update(msecs(1000));
		assertEquals(sprite.position, Vector2f(75, 75));

		trasnlateAnim.update(msecs(500));
		assertEquals(sprite.position, Vector2f(100, 100));
		assertFalse(trasnlateAnim.isRunning());
	}
}

class ScaleTest
{
	mixin UnitTest;

	Sprite sprite;
	Duration duration;

	ScaleAnimation scaleAnim;

	this()
	{
		sprite = new Sprite();
		duration = msecs(2000);
	}

	@Before
	void setupScaleAnimation()
	{
		sprite.scale = Vector2f(0, 0);
		scaleAnim = new ScaleAnimation(sprite, duration, sprite.scale, Vector2f(10, 10));
	}

	@Test
	void testScaleAnimation()
	{
		scaleAnim.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));

		scaleAnim.update(msecs(1000));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));

		scaleAnim.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(10, 10));
		assertFalse(scaleAnim.isRunning());
	}
}

class AnimationSetTest
{
	mixin UnitTest;

	Sprite sprite;
	Duration duration;

	ScaleAnimation scaleAnim;
	TranslationAnimation translateAnim;

	AnimationSet animSet;

	this()
	{
		sprite = new Sprite();
		duration = msecs(2000);
	}

	@Before
	void setupAnimationSet()
	{

		sprite.scale = Vector2f(0, 0);
		sprite.position = Vector2f(0, 0);

		scaleAnim = new ScaleAnimation(sprite, duration,
					sprite.scale, Vector2f(10, 10));

		translateAnim = new TranslationAnimation(sprite, duration,
						sprite.position, Vector2f(100, 100));

		animSet = new AnimationSet(scaleAnim, translateAnim);
	}

	@Test
	void testParallelAnimationSet()
	{
		animSet.setMode(AnimationSetMode.PARALLEL);

		animSet.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));
		assertEquals(sprite.position, Vector2f(25, 25));

		animSet.update(msecs(1000));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));
		assertEquals(sprite.position, Vector2f(75, 75));

		animSet.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(10, 10));
		assertEquals(sprite.position, Vector2f(100, 100));
		assertFalse(scaleAnim.isRunning());
		assertFalse(translateAnim.isRunning());
		assertFalse(animSet.isRunning());
	}

	@Test
	void testSequentialAnimationSet()
	{
		animSet.setMode(AnimationSetMode.SEQUENTIAL);

		animSet.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));

		animSet.update(msecs(1000));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));

		animSet.update(msecs(500));
		assertEquals(sprite.scale, Vector2f(10, 10));
		assertFalse(scaleAnim.isRunning());

		//The translation animation should get run now...
		animSet.update(msecs(500));
		assertEquals(sprite.position, Vector2f(25, 25));

		animSet.update(msecs(1000));
		assertEquals(sprite.position, Vector2f(75, 75));

		animSet.update(msecs(500));
		assertEquals(sprite.position, Vector2f(100, 100));

		assertFalse(translateAnim.isRunning());
		assertFalse(animSet.isRunning());
	}
}
