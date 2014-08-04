module ridgway.pmgcrawler.player;

import dsfml.graphics;

import ridgway.pmgcrawler.spritesheet;

class Player : Sprite
{

	private
	{
		SpriteSheet m_sheet;
	}

	this(SpriteSheet spriteSheet)
	{
		m_sheet = spriteSheet;
	}

	override void draw(RenderTarget target, RenderStates states)
	{
		setTexture(m_sheet.getTexture());
		textureRect = m_sheet.getSpriteRect(0);
		super.draw(target, states);
	}
}