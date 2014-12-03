module test;

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
	Time duration;

	RotateAnimation rotateAnim;

	this()
	{
		sprite = new Sprite();
		duration = seconds(2.0);
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

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());


		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 180);
		assertFalse(rotateAnim.isRunning());
	}

	@Test
	void testRepeatInfinite()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REPEAT;
		rotateAnim.repeatCount = INFINITE;

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 45);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(199.0));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());
	}

	@Test
	void testReverseSingle()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REVERSE;
		rotateAnim.repeatCount = 1;

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 0);
		assertFalse(rotateAnim.isRunning());
	}

	@Test
	void testReverseInfinite()
	{
		rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
		rotateAnim.repeatMode = RepeatMode.REVERSE;
		rotateAnim.repeatCount = INFINITE;

		rotateAnim.update(seconds(2.0));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(0.5));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(0.5));
		assertEquals(sprite.rotation, 90);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.0));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 45);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.5));
		assertEquals(sprite.rotation, 180);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 135);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(1.5));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());

		rotateAnim.update(seconds(200.0));
		assertEquals(sprite.rotation, 0);
		assertTrue(rotateAnim.isRunning());
	}
}

/*unittest
{
	import dunit.toolkit;

	auto sprite = new Sprite();
	sprite.rotation = 0;

	Time duration = seconds(2.0);

	writeln("Testing repeating animations.");

	auto rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
	rotateAnim.repeatMode = RepeatMode.REPEAT;
	rotateAnim.repeatCount = 1;

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 135);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());


	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 180);
	assertFalse(rotateAnim.isRunning());
	writeln("Single repeat success.");

	rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
	rotateAnim.repeatMode = RepeatMode.REPEAT;
	rotateAnim.repeatCount = INFINITE;

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 45);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(199.0));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());
	writeln("Infinite repeat success.");

	rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
	rotateAnim.repeatMode = RepeatMode.REVERSE;
	rotateAnim.repeatCount = 1;

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 180);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 0);
	assertFalse(rotateAnim.isRunning());
	writeln("Single reverse success.");

	rotateAnim = new RotateAnimation(sprite, duration, 0, 180);
	rotateAnim.repeatMode = RepeatMode.REVERSE;
	rotateAnim.repeatCount = INFINITE;

	rotateAnim.update(seconds(2.0));
	assertEquals(sprite.rotation, 180);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(0.5));
	assertEquals(sprite.rotation, 135);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(0.5));
	assertEquals(sprite.rotation, 90);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.0));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 45);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.5));
	assertEquals(sprite.rotation, 180);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(.5));
	assertEquals(sprite.rotation, 135);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(1.5));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());

	rotateAnim.update(seconds(200.0));
	assertEquals(sprite.rotation, 0);
	assertTrue(rotateAnim.isRunning());
	writeln("Infinite reverse success.");

	//writeln("Animation repeating tests passed.");
	writeln();
}*/

class DelegateTest
{
	import std.stdio;
	mixin UnitTest;

	Time duration;

	DelegateAnimation delegateAnim;

	string delegateMessage = "External Message";

	this()
	{
		duration = seconds(2.0);
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
		delegateAnim.update(seconds(.5));
		delegateAnim.update(seconds(.5));
		delegateAnim.update(seconds(.5));
		delegateAnim.update(seconds(.5));

		assertFalse(delegateAnim.isRunning());
	}
}

/*unittest
{
	import dunit.toolkit;

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
	//assert(!delAnim.isRunning());
	assertFalse(delAnim.isRunning());

	//writeln("DelegateAnimation tests passed!");
	writeln();
}*/

class RotateTest
{
	mixin UnitTest;

	Sprite sprite;
	Time duration;

	RotateAnimation rotateAnim;

	this()
	{
		sprite = new Sprite();
		duration = seconds(2.0);
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
		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 45);

		rotateAnim.update(seconds(1));
		assertEquals(sprite.rotation, 135);

		rotateAnim.update(seconds(.5));
		assertEquals(sprite.rotation, 180);
		assertFalse(rotateAnim.isRunning());
	}
}

/*unittest
{
	import dunit.toolkit;

	auto sprite = new Sprite();
	sprite.rotation = 0;

	Time duration = seconds(2.0);

	writeln("Testing RotateAnimation...");

	auto rotateAnim = new RotateAnimation(sprite, duration,
		sprite.rotation, 180);

	rotateAnim.update(seconds(.5));
	//assert(sprite.rotation == 45);
	assertEquals(sprite.rotation, 45);

	rotateAnim.update(seconds(1));
	//assert(sprite.rotation == 135);
	assertEquals(sprite.rotation, 135);

	rotateAnim.update(seconds(.5));
	//assert(sprite.rotation == 180);
	//assert(!rotateAnim.isRunning());
	assertEquals(sprite.rotation, 180);
	assertFalse(rotateAnim.isRunning());

	//writeln("Rotation Animation tests passed.");
	writeln();
}*/

class TranslationTest
{
	mixin UnitTest;

	Sprite sprite;
	Time duration;

	TranslationAnimation trasnlateAnim;

	this()
	{
		sprite = new Sprite();
		duration = seconds(2.0);
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
		trasnlateAnim.update(seconds(.5));
		assertEquals(sprite.position, Vector2f(25, 25));

		trasnlateAnim.update(seconds(1));
		assertEquals(sprite.position, Vector2f(75, 75));

		trasnlateAnim.update(seconds(.5));
		assertEquals(sprite.position, Vector2f(100, 100));
		assertFalse(trasnlateAnim.isRunning());
	}
}

/*unittest
{
	import dunit.toolkit;

	writeln("Testing TranslationAnimation...");

	auto sprite = new Sprite();
	sprite.position = Vector2f(0, 0);

	Time duration = seconds(2.0);

	auto trasnlateAnim = new TranslationAnimation(sprite, duration,
		sprite.position, Vector2f(100, 100));

	trasnlateAnim.update(seconds(.5));
	assertEquals(sprite.position, Vector2f(25, 25));

	trasnlateAnim.update(seconds(1));
	assertEquals(sprite.position, Vector2f(75, 75));

	trasnlateAnim.update(seconds(.5));
	assertEquals(sprite.position, Vector2f(100, 100));
	assertFalse(trasnlateAnim.isRunning());

	//writeln("Translation Animation tests passed.");
	writeln();
}*/

class ScaleTest
{
	mixin UnitTest;

	Sprite sprite;
	Time duration;

	ScaleAnimation scaleAnim;

	this()
	{
		sprite = new Sprite();
		duration = seconds(2.0);
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
		scaleAnim.update(seconds(.5));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));

		scaleAnim.update(seconds(1));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));

		scaleAnim.update(seconds(.5));
		assertEquals(sprite.scale, Vector2f(10, 10));
		assertFalse(scaleAnim.isRunning());
	}
}

/*unittest
{
	import dunit.toolkit;

	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time duration = seconds(2.0);

	writeln("Testing ScaleAnimation...");

	auto scaleAnim = new ScaleAnimation(sprite, duration,
		sprite.scale, Vector2f(10, 10));

	scaleAnim.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(2.5, 2.5));

	scaleAnim.update(seconds(1));
	assertEquals(sprite.scale, Vector2f(7.5, 7.5));

	scaleAnim.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(10, 10));
	assertFalse(scaleAnim.isRunning());

	//writeln("Scale Animation tests passed.");
	writeln();
}*/

class AnimationSetTest
{
	mixin UnitTest;

	Sprite sprite;
	Time duration;

	ScaleAnimation scaleAnim;
	TranslationAnimation translateAnim;

	AnimationSet animSet;

	this()
	{
		sprite = new Sprite();
		duration = seconds(2.0);
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

		animSet.update(seconds(.5));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));
		assertEquals(sprite.position, Vector2f(25, 25));

		animSet.update(seconds(1));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));
		assertEquals(sprite.position, Vector2f(75, 75));

		animSet.update(seconds(.5));
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

		animSet.update(seconds(.5));
		assertEquals(sprite.scale, Vector2f(2.5, 2.5));

		animSet.update(seconds(1));
		assertEquals(sprite.scale, Vector2f(7.5, 7.5));

		animSet.update(seconds(.5));
		assertEquals(sprite.scale, Vector2f(10, 10));
		assertFalse(scaleAnim.isRunning());

		//The translation animation should get run now...
		animSet.update(seconds(.5));
		assertEquals(sprite.position, Vector2f(25, 25));

		animSet.update(seconds(1));
		assertEquals(sprite.position, Vector2f(75, 75));

		animSet.update(seconds(.5));
		assertEquals(sprite.position, Vector2f(100, 100));

		assertFalse(translateAnim.isRunning());
		assertFalse(animSet.isRunning());
	}
}

unittest
{
	import std.stdio;

	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time duration = seconds(2.0);

	writeln("Testing Parallel AnimationSet...");
	auto scaleAnim = new ScaleAnimation(sprite, duration,
		sprite.scale, Vector2f(10, 10));

	auto translateAnim = new TranslationAnimation(sprite, duration,
		sprite.position, Vector2f(100, 100));

	auto animSet = new AnimationSet(scaleAnim, translateAnim);

	animSet.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(2.5, 2.5));
	assertEquals(sprite.position, Vector2f(25, 25));

	animSet.update(seconds(1));
	assertEquals(sprite.scale, Vector2f(7.5, 7.5));
	assertEquals(sprite.position, Vector2f(75, 75));

	animSet.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(10, 10));
	assertEquals(sprite.position, Vector2f(100, 100));
	assertFalse(scaleAnim.isRunning());
	assertFalse(translateAnim.isRunning());
	assertFalse(animSet.isRunning());

	//writeln("Parallel AnimationSet tests passed.");
	writeln();
}

unittest
{
	import std.stdio;

	writeln("Testing Sequential AnimationSet...");
	auto sprite = new Sprite();
	sprite.scale = Vector2f(0, 0);

	Time duration = seconds(2.0);

	auto scaleAnim = new ScaleAnimation(sprite, duration,
		sprite.scale, Vector2f(10, 10));

	auto translateAnim = new TranslationAnimation(sprite, duration,
		sprite.position, Vector2f(100, 100));

	auto animSet = new AnimationSet(scaleAnim, translateAnim);
	animSet.setMode(AnimationSetMode.SEQUENTIAL);

	animSet.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(2.5, 2.5));

	animSet.update(seconds(1));
	assertEquals(sprite.scale, Vector2f(7.5, 7.5));

	animSet.update(seconds(.5));
	assertEquals(sprite.scale, Vector2f(10, 10));
	assertFalse(scaleAnim.isRunning());

	//The translation animation should get run now...
	animSet.update(seconds(.5));
	assertEquals(sprite.position, Vector2f(25, 25));

	animSet.update(seconds(1));
	assertEquals(sprite.position, Vector2f(75, 75));

	animSet.update(seconds(.5));
	assertEquals(sprite.position, Vector2f(100, 100));

	assertFalse(translateAnim.isRunning());
	assertFalse(animSet.isRunning());

	//writeln("Sequential AnimationSet tests passed.");
	writeln();
}