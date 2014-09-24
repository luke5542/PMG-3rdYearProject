module ridgway.pmgcrawler.player;

import dsfml.graphics;

import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.node;

class Player : Sprite, Node
{
	mixin NormalNode;

	private
	{
		SpriteAnimation m_anim;
	}

	this(const(Texture) tex)
	{
		super(tex);
	}

	this(SpriteSheet spriteSheet, SpriteFrameList frameList)
	{
		this(spriteSheet.getTexture());
		m_anim = new SpriteAnimation(this, spriteSheet, frameList);
		m_anim.repeateMode = RepeateMode.REPEATE;
		m_anim.repeateCount = INFINITE;
		runAnimation(m_anim);
	}

	void update(Time time)
	{
		//TODO find something to update
		updateAnimations(time);
	}

	override void draw(RenderTarget target, RenderStates states)
	{
		super.draw(target, states);
	}
}