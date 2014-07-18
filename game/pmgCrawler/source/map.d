module ridgway.pmgcrawler.map;

import std.random;

import dsfml.system;
import dsfml.graphics;

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

class VertexTileMap : Drawable, Transformable
{
    mixin NormalTransformable;

    private
    {
        VertexArray m_vertices;
        bool[] m_tiles;
        bool[] m_stillAlive;
        uint m_width, m_height;
    }

    this()
    {
    }

    void load(Vector2u tileSize, const(bool[]) tiles, uint width, uint height)
    {
        m_tiles = new bool[tiles.length];
        m_tiles[] = tiles;
        m_stillAlive = new bool[tiles.length];
        m_stillAlive[] = tiles;
        m_width = width;
        m_height = height;

        // resize the vertex array to fit the level size
        m_vertices = new VertexArray(PrimitiveType.Quads, width * height * 4);

        // populate the vertex array, with one quad per tile
        for (uint i = 0; i < width; ++i)
        {
            for (uint j = 0; j < height; ++j)
            {
                // get the current tile number
                bool tileNumber = m_tiles[i + j * width];

                // get a pointer to the current tile's quad
                uint quad = (i + j * width) * 4;

                // define its 4 corners
                m_vertices[quad + 0].position = Vector2f(i * tileSize.x, j * tileSize.y);
                m_vertices[quad + 1].position = Vector2f((i + 1) * tileSize.x, j * tileSize.y);
                m_vertices[quad + 2].position = Vector2f((i + 1) * tileSize.x, (j + 1) * tileSize.y);
                m_vertices[quad + 3].position = Vector2f(i * tileSize.x, (j + 1) * tileSize.y);

                if(tileNumber) // white
                {
                    // define its 4 texture coordinates
                    m_vertices[quad + 0].color = Color.White;
                    m_vertices[quad + 1].color = Color.White;
                    m_vertices[quad + 2].color = Color.White;
                    m_vertices[quad + 3].color = Color.White;
                }
                else
                {
                    // define its 4 texture coordinates
                    m_vertices[quad + 0].color = Color.Black;
                    m_vertices[quad + 1].color = Color.Black;
                    m_vertices[quad + 2].color = Color.Black;
                    m_vertices[quad + 3].color = Color.Black;
                
                }
            }
        }
    }

    const(uint) getHeight()
    {
        return m_height;
    }

    const(uint) getWidth()
    {
        return m_width;
    }

    const(bool) getIsAlive(uint x, uint y)
    {
        return m_tiles[x + y * m_width];
    }

    void setIsAlive(uint x, uint y, bool alive)
    {
        m_tiles[x + y * m_width] = alive;
    }

    void setIsStillAlive(uint x, uint y, bool alive)
    {
        m_stillAlive[x + y * m_width] = alive;
    }

    void updateLifeState(uint x, uint y)
    {
        bool isAlive = m_tiles[x + y * m_width] = m_stillAlive[x + y * m_width];
        uint quad = (x + y * m_width) * 4;

        if(isAlive) // white
        {
            // define its 4 texture coordinates
            m_vertices[quad + 0].color = Color.White;
            m_vertices[quad + 1].color = Color.White;
            m_vertices[quad + 2].color = Color.White;
            m_vertices[quad + 3].color = Color.White;
        }
        else
        {
            // define its 4 texture coordinates
            m_vertices[quad + 0].color = Color.Black;
            m_vertices[quad + 1].color = Color.Black;
            m_vertices[quad + 2].color = Color.Black;
            m_vertices[quad + 3].color = Color.Black;
        
        }
    }

    override void draw(RenderTarget target, RenderStates states = RenderStates.Default)
    {
        // apply the transform
        states.transform *= getTransform();

        // draw the vertex array
        target.draw(m_vertices, states);
    }
}