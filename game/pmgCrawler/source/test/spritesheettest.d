module test.spritesheettest;

import dunit;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.interpolator;
import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.animation;

class SpriteSheetTest
{
	mixin UnitTest;

	SpriteSheet sheet;

	@Before
	void setupSpriteSheet()
	{
		sheet = new SpriteSheet();
	}

	@Test
	void testSpriteSheet()
	{
		assertTrue(sheet.loadFromFile("assets/tiles_spritesheet.json"));
		assertEquals(sheet.getSpriteRect("ground-empty.png"), IntRect(2, 2, 32, 32));
	}
}

class SpriteFrameListTest
{
	mixin UnitTest;

	SpriteFrameList frameList;

	@Before
	void setupSpriteFrameList()
	{
		frameList = SpriteFrameList();
		frameList.loadFromFile("assets/player_sprite_frames.json");
	}

	@Test
	void testSpriteFrameList()
	{
		assertEquals(frameList.getDuration(), 400);
		assertEquals(frameList.getFrame(50), "sprite1");
		assertEquals(frameList.getFrame(100), "sprite1");
		assertEquals(frameList.getFrame(101), "sprite2");
		assertEquals(frameList.getFrame(250), "sprite3");
		assertEquals(frameList.getFrame(350), "sprite4");
	}
}