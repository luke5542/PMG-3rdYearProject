module ridgway.pmgcrawler.player;

import dsfml.graphics;

import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.node;

class Player : Sprite, Node
{
	mixin NormalNode;

	private
	{
		SpriteSheet m_sheet;
	}

	this(SpriteSheet spriteSheet)
	{
		m_sheet = spriteSheet;
	}

	void update(Time time)
	{
		//TODO find something to update
		updateAnimations(time);
	}

	override void draw(RenderTarget target, RenderStates states)
	{
		setTexture(m_sheet.getTexture());
		textureRect = m_sheet.getSpriteRect(0);
		super.draw(target, states);
	}
}