module ridgway.pmgcrawler.verification.ray;

import dsfml.graphics;

struct Ray
{
    Vector2f m_start;
    Vector2f m_direction;

    this(Vector2f start, Vector2f dir)
    {
        m_start = start;
        m_direction = dir;
        normalize();
    }

    void normalize()
    {
        double len = sqrt(cast(double)((m_direction.x * m_direction.x) + (m_direction.y * m_direction.y)));

        m_direction.x = m_direction.x / len;
        m_direction.y = m_direction.y / len;
    }

    Vector2f nextLocation(float dist)
    {
        m_start = m_start + (m_direction * dist);
        return m_start;
    }
}
