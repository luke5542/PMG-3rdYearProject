module ridgway.pmgcrawler.player;

import dsfml.graphics;

import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.node;

class Player : CircleShape, Node
{
	mixin NormalNode;

	private
	{
		//SpriteAnimation m_anim;
		AnimationSet m_anim;
		CircleShape m_pulseOverlay;
	}

	//this(const(Texture) tex)
	//{
	//	super(tex);
	//}

	//this(SpriteSheet spriteSheet, SpriteFrameList frameList)
	//{
	//	this(spriteSheet.getTexture());
	//	m_anim = new SpriteAnimation(this, spriteSheet, frameList);
	//	m_anim.repeateMode = RepeateMode.REVERSE;
	//	m_anim.repeateCount = INFINITE;
	//	runAnimation(m_anim);
	//}

	this()
	{
		super(16);
		this.origin = Vector2f(16, 16);
		this.fillColor = Color(208, 176, 255, 100);
		m_pulseOverlay = new CircleShape(16);
		m_pulseOverlay.fillColor = Color(163, 25, 209, 200);

		Time pulseAnimDur = seconds(1.75);
		auto delAnim = new DelegateAnimation(pulseAnimDur, &updatePulseAnim);
		delAnim.repeateMode = RepeateMode.REPEATE;
		delAnim.repeateCount = INFINITE;
		runAnimation(delAnim);
	}

	void updatePulseAnim(double progress)
	{
		if(progress < .75)
		{
			auto tempColor = m_pulseOverlay.fillColor;
			tempColor.a = 200;
			m_pulseOverlay.fillColor = tempColor;

			m_pulseOverlay.radius = this.radius * (progress / .75);
			m_pulseOverlay.origin = Vector2f(m_pulseOverlay.radius, m_pulseOverlay.radius);
		}
		else
		{
			m_pulseOverlay.radius = this.radius;
			m_pulseOverlay.origin = Vector2f(m_pulseOverlay.radius, m_pulseOverlay.radius);
			auto tempProgress = 1 - ((progress - .75) / .25);
			auto tempColor = m_pulseOverlay.fillColor;
			tempColor.a = cast(ubyte)(200 * tempProgress);
			m_pulseOverlay.fillColor = tempColor;

		}
	}

	void update(Time time)
	{
		//TODO find something to update
		updateAnimations(time);
	}

	override void draw(RenderTarget target, RenderStates states)
	{
		super.draw(target, states);
		m_pulseOverlay.position = this.position;
		m_pulseOverlay.draw(target, states);
	}
}