module ridgway.pmgcrawler.verification.path;

import std.container;

import dsfml.graphics;

import ridgway.pmgcrawler.map;

struct Path
{
    private
    {
        DList!Move m_moves;
    }

    bool hasMove()
    {
        return !m_moves.empty;
    }

    //Adds item to the list
    void push(Move m)
    {
        m_moves.insertFront(m);
    }

    //Removes and returns the next move to make along this path.
    Move pop()
    {
        auto m = m_moves.front();
        m_moves.removeFront();
        return m;
    }

    void drawPath(TileMap map, Vector2u location)
    {
        Vector2u curLoc = location;
        foreach(move; m_moves)
        {
            final switch(move)
            {
                case Move.UP:
                    curLoc = curLoc + Vector2u(0, -1);
                    break;

                case Move.DOWN:
                    curLoc = curLoc + Vector2u(0, 1);
                    break;

                case Move.LEFT:
                    curLoc = curLoc + Vector2u(-1, 0);
                    break;

                case Move.RIGHT:
                    curLoc = curLoc + Vector2u(1, 0);
                    break;
            }

            //Set that location as red...
            map.setTileColor(curLoc, Color.Red);
        }
    }
}
