module ridgway.pmgcrawler.spritesheet;

import dsfml.graphics;

class SpriteSheet
{
	private
	{
		Texture m_sheet;
		IntRect[] m_spriteRects;
	}

	this()
	{
		//TODO something...
	}

	void loadFromFile(const(string) file)
	{
		//TODO do something for this...
	}

	Texture getTexture()
	{
		return m_sheet;
	}

	IntRect getSpriteRect(const(uint) sprite)
	{
		return m_spriteRects[sprite];
	}
}