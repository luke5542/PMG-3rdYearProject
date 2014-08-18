module ridgway.pmgcrawler.map;

import std.random;
import std.stdio;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.tile;
import ridgway.pmgcrawler.node;

class TileMap : Drawable, Transformable, Node
{
    mixin NormalTransformable;
    mixin NormalNode;

    private
    {
        VertexArray m_vertices;
        Texture m_tileset;
        Vector2u m_size;
        Vector2u m_tileSize;

        /// This is the (x,y) of the focused tile.
        /// This tile is centered on the m_tileCenter location.
        Vector2u m_focusedTile;
    }

    this()
    {
        m_tileset = new Texture();
    }

    bool load(const(string) tileset, Vector2u tileSize, const(int[]) tiles, uint width, uint height)
    {
        // load the tileset texture
        if (!m_tileset.loadFromFile(tileset))
            return false;

        m_size = Vector2u(width, height);
        m_tileSize = tileSize;

        //Initialize the location variables
        this.origin = Vector2f((width * tileSize.x) / 2, (height * tileSize.y) / 2);

        // resize the vertex array to fit the level size
        m_vertices = new VertexArray(PrimitiveType.Quads, width * height * 4);

        debug writeln("Setting tiles...");
        // populate the vertex array, with one quad per tile
        for (uint i = 0; i < width; ++i)
        {
            for (uint j = 0; j < height; ++j)
            {
                // get the current tile number
                int tileNumber = tiles[i + j * width];

                // find its position in the tileset texture
                int tu = tileNumber % (m_tileset.getSize().x / tileSize.x);
                int tv = tileNumber / (m_tileset.getSize().y / tileSize.y);

                // get a reference to the start of the current tile's quad
                uint quad = (i + j * width) * 4;

                // define its 4 corners
                m_vertices[quad + 0].position = Vector2f(i * tileSize.x, j * tileSize.y);
                m_vertices[quad + 1].position = Vector2f((i + 1) * tileSize.x, j * tileSize.y);
                m_vertices[quad + 2].position = Vector2f((i + 1) * tileSize.x, (j + 1) * tileSize.y);
                m_vertices[quad + 3].position = Vector2f(i * tileSize.x, (j + 1) * tileSize.y);

                // define its 4 texture coordinates
                m_vertices[quad + 0].texCoords = Vector2f(tu * tileSize.x, tv * tileSize.y);
                m_vertices[quad + 1].texCoords = Vector2f((tu + 1) * tileSize.x, tv * tileSize.y);
                m_vertices[quad + 2].texCoords = Vector2f((tu + 1) * tileSize.x, (tv + 1) * tileSize.y);
                m_vertices[quad + 3].texCoords = Vector2f(tu * tileSize.x, (tv + 1) * tileSize.y);
            }
        }

        return true;
    }

    /// This sets to currently focused tile in the tile map.
    /// It sets the position for this tile map, so don't manually set the position.
    @property
    {   
        Vector2u focusedTile(Vector2u newFocus)
        {
            if(newFocus.x > m_size.x || newFocus.y > m_size.y)
            {
                m_focusedTile = Vector2u(0, 0);
            }
            else
            {
                m_focusedTile = newFocus;
            }
            this.position = Vector2f((newFocus.x * m_tileSize.x) + (m_tileSize.x / 2),
                                (newFocus.y * m_tileSize.y) + (m_tileSize.y / 2));

            debug writeln("New focused tile: " ~ m_focusedTile.toString());

            return m_focusedTile;
        }

        Vector2u focusedTile() const
        {
            return m_focusedTile;
        }
    }

    /// This returns the tile map's size in units of tiles
    const(Vector2u) getSize()
    {
        return m_size;
    }

    void update(Time time)
    {
        updateAnimations();
    }

    override void draw(RenderTarget target, RenderStates states = RenderStates.Default)
    {
        // apply the transform
        states.transform *= getTransform();

        // apply the tileset texture
        states.texture = m_tileset;

        // draw the vertex array
        target.draw(m_vertices, states);


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