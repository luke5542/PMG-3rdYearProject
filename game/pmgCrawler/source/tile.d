module ridgway.pmgcrawler.tile;

import std.stdio;

import dsfml.graphics.sprite;
import dsfml.graphics.color;
import dsfml.graphics.rectangleshape;
import dsfml.system.vector2;

class ColoredTile : RectangleShape
{
    private
    {
        bool mIsAlive;
        bool mIsStillAlive;

    }

    this(Vector2f size, bool alive = false)
    {
        super(size);

        mIsAlive = alive;
        mIsStillAlive = !alive;
        updateFillColor();
    }

    @property
    {
        bool isAlive(bool alive)
        {
            mIsAlive = alive;
            updateFillColor();
            return mIsAlive;
        }

        bool isAlive() const
        {
            return mIsAlive;
        }
    }


    @property
    {
        bool isStillAlive(bool alive)
        {
            mIsStillAlive = alive;
            return mIsStillAlive;
        }

        bool isStillAlive() const
        {
            return mIsStillAlive;
        }
    }


    void updateFillColor()
    {
        if(mIsAlive)
        {
            fillColor = Color.Black;
            writeln("updating fill color to black");
        }
        else
        {
            fillColor = Color.White;
        }
    }

}