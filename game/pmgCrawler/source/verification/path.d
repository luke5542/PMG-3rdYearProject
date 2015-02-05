module ridgway.pmgcrawler.verification.path;

import std.container;

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
}
