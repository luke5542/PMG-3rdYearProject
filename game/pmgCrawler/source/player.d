module ridgway.pmgcrawler.player;

import dsfml.graphics;

import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.node;

immutable CHARACTER_SIZE = 13;

class Player : CircleShape, Node
{
    mixin NormalNode;

    private
    {
        //SpriteAnimation m_anim;
        AnimationSet m_anim;
        CircleShape m_pulseOverlay;
    }

    this()
    {
        super(CHARACTER_SIZE);
        this.origin = Vector2f(CHARACTER_SIZE, CHARACTER_SIZE);
        this.fillColor = Color(208, 176, 255, 100);
        m_pulseOverlay = new CircleShape(CHARACTER_SIZE);
        m_pulseOverlay.fillColor = Color(163, 25, 209, 200);

        Duration pulseAnimDur = msecs(1_750);
        auto delAnim = new DelegateAnimation(pulseAnimDur, &updatePulseAnim);
        delAnim.repeatMode = RepeatMode.REPEAT;
        delAnim.repeatCount = INFINITE;
        runAnimation(delAnim);
    }

    void updatePulseAnim(double progress)
    {
        if(progress < .75)
        {
            auto tempColor = m_pulseOverlay.fillColor;
            tempColor.a = 200;
            m_pulseOverlay.fillColor = tempColor;
            m_pulseOverlay.scale = this.scale;

            m_pulseOverlay.radius = this.radius * (progress / .75);
            m_pulseOverlay.origin = Vector2f(m_pulseOverlay.radius, m_pulseOverlay.radius);
        }
        else
        {
            m_pulseOverlay.radius = this.radius;
            m_pulseOverlay.scale = this.scale;
            m_pulseOverlay.origin = Vector2f(m_pulseOverlay.radius, m_pulseOverlay.radius);
            
            auto tempProgress = 1 - ((progress - .75) / .25);
            auto tempColor = m_pulseOverlay.fillColor;
            tempColor.a = cast(ubyte)(200 * tempProgress);
            m_pulseOverlay.fillColor = tempColor;

        }
    }

    void update(Duration time)
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
