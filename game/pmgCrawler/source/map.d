module ridgway.pmgcrawler.map;

import std.random;
import std.stdio;
import std.math;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.tile;
import ridgway.pmgcrawler.node;
import ridgway.pmgcrawler.constants;

immutable ENTRANCE = 30;
immutable EXIT = 42;

enum Move { UP, DOWN, LEFT, RIGHT }

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

        Vector2i m_tileCenter;

        //The start and end locations for the player.
        Vector2u m_playerStart, m_playerEnd;
        bool m_hasStart, m_hasEnd;

        const(int)[] m_tiles;

        bool m_canMove;
    }

    this()
    {
        m_tileset = new Texture();
        m_tileCenter = Vector2i();
        m_focusedTile = Vector2u();
        m_tileSize = Vector2u();

        m_hasEnd = false;
        m_hasStart = false;
        m_canMove = true;
    }



    bool minimalLoadFromImage(in string mapImage)
    {
        Image image = new Image();
        if(!image.loadFromFile(mapImage))
        {
            return false;
        }

        minimalLoadFromImage(image);

        return true;
    }

    void minimalLoadFromImage(Image image)
    {
        const(ubyte[]) pixelArray = image.getPixelArray();
        int[] tiles = new int[pixelArray.length / 4];
        Vector2u start, end;
        int size = cast(int) sqrt(pixelArray.length / 4.0);

        debug writeln("loadFromImage() Size: ", size);

        for(int i = 0; i < pixelArray.length; i += 4)
        {
            if(pixelArray[i] == pixelArray[i+1])
            {
                //Deal with being either BLACK or WHITE
                if(pixelArray[i] == 255)
                {
                    //Pixel is WHITE
                    tiles[i/4] = 0;
                }
                else
                {
                    //Pixel is BLACK
                    tiles[i/4] = 1;
                }
            }
            else if(pixelArray[i] == 255)
            {
                //Deal with being RED
                int index = i/4;
                tiles[index] = EXIT;

                debug writeln("Red Index: ", index,
                                " Loc: (", index%size,
                                ",", (index/size),
                                ")");

                end = Vector2u(index%size, (index/size));
                m_hasEnd = true;
            }
            else
            {
                //Deal with being GREEN
                int index = i/4;
                tiles[index] = ENTRANCE;

                debug writeln("Green Index: ", index,
                                " Loc: (", index%size,
                                ",", (index/size),
                                ")");

                start = Vector2u(index%size, (index/size));
                m_hasStart = true;
            }
        }

        m_size = Vector2u(size, size);
        m_tiles = tiles;
        m_playerEnd = end;
        m_playerStart = start;
    }

    // This assumes that the input image is a square image.
    bool loadFromImage(in string tileset, in string mapImage, Vector2u tileSize)
    {
        if(minimalLoadFromImage(mapImage))
        {
            return load(tileset, tileSize, m_tiles, m_size.x, m_size.y, m_playerStart, m_playerEnd);
        }
        else
        {
            return false;
        }
    }

    // This assumes that the input image is a square image.
    bool loadFromImage(in string tileset, Image mapImage, Vector2u tileSize)
    {
        minimalLoadFromImage(mapImage);
        return load(tileset, tileSize, m_tiles, m_size.x, m_size.y, m_playerStart, m_playerEnd);
    }

    bool load(const(string) tileset, Vector2u tileSize, const(int[]) tiles,
                uint width, uint height, Vector2u playerStart, Vector2u playerEnd)
    {
        m_playerEnd = playerEnd;
        m_playerStart = playerStart;

        // load the tileset texture
        if (!m_tileset.loadFromFile(tileset))
            return false;

        m_size = Vector2u(width, height);
        m_tileSize = tileSize;
        m_tiles = tiles;

        //Initialize the location variables
        this.origin = Vector2f(0, 0);//Vector2f((width * tileSize.x) / 2, (height * tileSize.y) / 2);

        // resize the vertex array to fit the level size
        m_vertices = new VertexArray(PrimitiveType.Quads, width * height * 4);

        debug writeln("Setting tiles...");
        // populate the vertex array, with one quad per tile
        for (uint i = 0; i < width; ++i)
        {
            for (uint j = 0; j < height; ++j)
            {
                // get the current tile number
                int tileNumber = m_tiles[i + j * width];

                if(tileNumber == EXIT || tileNumber == ENTRANCE)
                {
                    tileNumber = 0;
                }

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

        updateFocusLocation();

        return true;
    }

    /// This sets to currently focused tile in the tile map.
    /// It sets the position for this tile map, so don't manually set the position.
    @property
    {
        Vector2u focusedTile(Vector2u newFocus)
        {
            if(newFocus.x >= m_size.x || newFocus.y >= m_size.y)
            {
                //m_focusedTile = Vector2u(0, 0);
                writeln("Focused Tile Error: Trying to exceed tile size! " ~ newFocus.toString());
            }
            else
            {
                m_focusedTile = newFocus;
            }

            debug writeln("New focused tile: " ~ m_focusedTile.toString());
            updateFocusLocation();

            return m_focusedTile;
        }

        Vector2u focusedTile() const
        {
            return m_focusedTile;
        }
    }

    /// This sets the current location for the focused tile.
    /// It sets the position for this tile map, so don't manually set the position.
    @property
    {
        Vector2i focusedLocation(Vector2i newCenter)
        {
            m_tileCenter = newCenter;

            debug writeln("New focused location: " ~ m_tileCenter.toString());
            updateFocusLocation();

            return m_tileCenter;
        }

        Vector2i focusedLocation() const
        {
            return m_tileCenter;
        }
    }

    bool isWalkable(Vector2u tile) shared
    {
        if(tile.x >= m_size.x || tile.y >= m_size.y )
        {
            //m_focusedTile = Vector2u(0, 0);
            writeln("Error: Trying to exceed tile size! ", tile);
            return false;
        }

        int tileNum = m_tiles[tile.x + tile.y * m_size.x];

        //TODO improve this to work with any 'walkable' tiles...
        return tileNum == 0 || tileNum == EXIT || tileNum == ENTRANCE;
    }

    bool isWalkable(Vector2u tile)
    {
        if(tile.x >= m_size.x || tile.y >= m_size.y )
        {
            //m_focusedTile = Vector2u(0, 0);
            writeln("Error: Trying to exceed tile size! ", tile);
            return false;
        }

        int tileNum = m_tiles[tile.x + tile.y * m_size.x];

        //TODO improve this to work with any 'walkable' tiles...
        return tileNum == 0 || tileNum == EXIT || tileNum == ENTRANCE;
    }

    bool canMove()
    {
        return m_canMove;
    }

    void makeMove(Move m)
    {
        final switch(m)
        {
            case Move.UP:
                makeMove(Vector2u(0, -1));
                break;

            case Move.DOWN:
                makeMove(Vector2u(0, 1));
                break;

            case Move.LEFT:
                makeMove(Vector2u(-1, 0));
                break;

            case Move.RIGHT:
                makeMove(Vector2u(1, 0));
                break;
        }
    }

    const(bool) hasPlayerStart()
    {
        return m_hasStart;
    }

    const(bool) hasPlayerEnd()
    {
        return m_hasEnd;
    }

    const(Vector2u) getPlayerStart()
    {
        return m_playerStart;
    }

    const(Vector2u) getPlayerEnd()
    {
        return m_playerEnd;
    }

    const(Vector2u) getPlayerStart() shared
    {
        return m_playerStart;
    }

    const(Vector2u) getPlayerEnd() shared
    {
        return m_playerEnd;
    }

    /// This returns the tile map's size in units of tiles
    const(Vector2u) getSize() shared
    {
        return m_size;
    }
    const(Vector2u) getSize()
    {
        return m_size;
    }

    void update(Time time)
    {
        updateAnimations(time);
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

private:

    void updateFocusLocation()
    {
        this.position = Vector2f(m_tileCenter.x - cast(float)(m_focusedTile.x * m_tileSize.x) - (m_tileSize.x / 2),
                                 m_tileCenter.y - cast(float)(m_focusedTile.y * m_tileSize.y) - (m_tileSize.y / 2));

        debug writeln("New location: " ~ position.toString());
    }

    void animateFocusLocation()
    {
        auto nextLocation = Vector2f(m_tileCenter.x - cast(float)(m_focusedTile.x * m_tileSize.x) - (m_tileSize.x / 2),
                                     m_tileCenter.y - cast(float)(m_focusedTile.y * m_tileSize.y) - (m_tileSize.y / 2));

        auto trasnlateAnim = new TranslationAnimation(this, milliseconds(100), this.position, nextLocation);
        trasnlateAnim.addUpdateListener(new MapAnimUpdateListener);
        runAnimation(trasnlateAnim);

        debug writeln("New location: ", position);
    }

    void makeMove(Vector2u direction)
    {
        if(m_canMove)
        {
            m_canMove = false;

            auto nextTile = m_focusedTile + direction;
            if(isWalkable(nextTile))
            {
                m_focusedTile = nextTile;
                debug writeln("New focused location: ", m_tileCenter);
                animateFocusLocation();
            }
            else
            {
                m_canMove = true;
            }
        }
    }

    class MapAnimUpdateListener : UpdateListener
    {
        void onAnimationEnd()
        {
            //just reset the canMove status
            m_canMove = true;
        }

        void onAnimationRepeat()
        {
            //Do nothing, this shouldn't get called
            writeln("This is getting called.... STOP IT!!!");
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
