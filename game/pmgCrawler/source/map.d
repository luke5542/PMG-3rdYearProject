module ridgway.pmgcrawler.map;

import std.random;

import dsfml.graphics.sprite;
import dsfml.system.vector2;
import dsfml.graphics.renderwindow;

import ridgway.pmgcrawler.tile;

/*class MapData
{

	private
	{
		char[][] tileTypes;
	}

	this(int x, int y)
	{
		tileTypes = new char[x][y];
	}

}*/

class TileMap
{
	private
	{
		ColoredTile[][] m_tiles;

        Vector2i m_size;

        int m_tileSize;
	}

    this(Vector2i size, int tileSize = 10)
    {
        m_tileSize = tileSize;
        m_size = size;

        m_tiles = new ColoredTile[][](m_size.x, m_size.y);
        //m_tiles.length = m_size.y;

        foreach(uint h, ColoredTile[] h_tiles; m_tiles)
        {
            //h_tiles.length = m_size.x;
            foreach(uint w, ColoredTile w_tile; h_tiles)
            {
                m_tiles[w][h] = new ColoredTile(Vector2f(m_tileSize, m_tileSize), uniform!(ushort)()%4 == 1);
                m_tiles[w][h].position = Vector2f(m_tileSize*w, m_tileSize*h);
            }
        }
    }

    const(uint) getHeight()
    {
        return m_size.y;
    }

    const(uint) getWidth()
    {
        return m_size.x;
    }

    bool getIsAlive(uint x, uint y)
    {
        return m_tiles[x][y].isAlive;
    }

    void setIsAlive(uint x, uint y, bool alive)
    {
        m_tiles[x][y].isAlive = alive;
    }

    void setIsStillAlive(uint x, uint y, bool alive)
    {
        m_tiles[x][y].isStillAlive = alive;
    }

    void updateLifeState(uint x, uint y)
    {
        m_tiles[x][y].isAlive = m_tiles[x][y].isStillAlive;
    }

    void draw(ref RenderWindow window)
    {
        foreach(ColoredTile[] h_tiles; m_tiles)
        {
            foreach(ColoredTile w_tile; h_tiles)
            {
                window.draw(w_tile);
            }
        }
    }
}