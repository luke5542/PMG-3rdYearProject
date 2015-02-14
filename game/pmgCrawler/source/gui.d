module ridgway.pmgcrawler.gui;

import std.stdio;
import std.c.stdlib;
import std.concurrency;
import std.random;

import core.time;

import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.mapconfig;
import ridgway.pmgcrawler.constants;
import ridgway.pmgcrawler.player;
import ridgway.pmgcrawler.spritesheet;
import ridgway.pmgcrawler.verification.bots;
import ridgway.pmgcrawler.verification.verification;
import ridgway.pmgcrawler.generators.generator;
import ridgway.pmgcrawler.generators.bspgenerator;
import ridgway.pmgcrawler.generators.perlingenerator;


class TileMapGUI
{

    private
    {

        RenderWindow m_window;

        //TileMap lifeMap;
        TileMap m_tileMap;

        static const(int[]) level =
        [
            3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ];

        Player m_player;

        bool m_paused;
    }

    this()
    {
        auto settings = ContextSettings();
        settings.antialiasingLevel = 8;
        m_window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);
        m_window.setFramerateLimit(60);

        m_tileMap = new TileMap();
        if(!m_tileMap.load(TILE_MAP_LOC, Vector2u(32, 32), level, 20, 25, Vector2u(0,0), Vector2u(1,0)))
        {
            writeln("Couldn't load image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(400, 300);

        m_player = new Player();
        m_player.position = Vector2f(400, 300);
    }

    void run()
    {
        //For event polling...
        Event event;

        Clock clock = new Clock();

        while (m_window.isOpen())
        {
            // check all the m_window's events that were triggered since the last iteration of the loop
            while(m_window.pollEvent(event))
            {
                // "close requested" event: we close the m_window
                if(event.type == Event.EventType.Closed)
                {
                    m_window.close();
                }
                else if(event.type == Event.EventType.KeyPressed)
                {

                    if(event.key.code == Keyboard.Key.Escape)
                    {
                        exit(0);
                    }
                    if(event.key.code == Keyboard.Key.Space)
                    {
                        m_paused = !m_paused;
                    }
                }
            }

            Time time = clock.getElapsedTime();
            clock.restart();
            if(!m_paused)
            {
                update(m_window, time);
            }
            draw(m_window);
        }
    }

    void update(ref RenderWindow m_window, Time time)
    {
        if(Keyboard.isKeyPressed(Keyboard.Key.Down))
        {
            m_tileMap.makeMove(Move.DOWN);
        }
        else if(Keyboard.isKeyPressed(Keyboard.Key.Up))
        {
            m_tileMap.makeMove(Move.UP);
        }
        else if(Keyboard.isKeyPressed(Keyboard.Key.Left))
        {
            m_tileMap.makeMove(Move.LEFT);
        }
        else if(Keyboard.isKeyPressed(Keyboard.Key.Right))
        {
            m_tileMap.makeMove(Move.RIGHT);
        }

        m_player.update(time);
        m_tileMap.update(time);
    }

    void draw(ref RenderWindow m_window)
    {
        m_window.clear();

        m_tileMap.draw(m_window);
        m_window.draw(m_player);

        m_window.display();
    }

}

class GeneratedMapGUI : TileMapGUI
{

    this(string mapFile)
    {
        auto settings = ContextSettings();
        settings.antialiasingLevel = 8;
        m_window = new RenderWindow(VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);
        m_window.setFramerateLimit(60);

        m_tileMap = new TileMap();
        if(!m_tileMap.loadFromImage(TILE_MAP_LOC, mapFile, Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(400, 300);
        m_tileMap.focusedTile = m_tileMap.getPlayerStart();

        m_player = new Player();
        m_player.position = Vector2f(400, 300);
    }

}

class DemoMapGUI : TileMapGUI
{

    private
    {
        MapGenConfig m_config;
        Bot bot;
    }

    this(MapGenConfig config)
    {
        auto settings = ContextSettings();
        settings.antialiasingLevel = 8;
        m_window = new RenderWindow(VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);
        m_window.setFramerateLimit(60);

        m_player = new Player();
        m_player.position = Vector2f(400, 300);

        m_config = config;
        m_config.vConfig.useBots = false;

        beginNewMap();
    }

    void beginNewMap()
    {
        generateMap();
        bot = initBot(cast(shared(TileMap)) m_tileMap, m_config);
    }

    void generateMap()
    {
        auto genMap = generateMapImage();
        while(!genMap)
        {
            genMap = generateMapImage();
        }

        m_tileMap = new TileMap();
        if(!m_tileMap.loadFromImage(TILE_MAP_LOC, genMap, Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(400, 300);

        debug writeln("Player Start: ", m_tileMap.getPlayerStart());
        m_tileMap.focusedTile = m_tileMap.getPlayerStart();
    }

    Image generateMapImage()
    {
        auto genMethod = cast(Generators) uniform!"[]"(Generators.min, Generators.max);
        Image image;
        final switch(genMethod)
        {
            case Generators.PERLIN:
                debug writeln("Generating Perlin Map");
                image = generatePerlin(m_config);
                break;
            case Generators.BSP:
                debug writeln("Generating BSP Map");
                image = generateBSP(m_config);
                break;
        }

        auto results = runVerification(m_config, image);
        if(results.ranDijkstras && results.exitTileDistance > 0)
        {
            return image;
        }
        else
        {
            writeln("Map failed verification...");
            return null;
        }
    }

    override void update(ref RenderWindow m_window, Time time)
    {
        if(m_tileMap.canMove)
        {
            if(m_tileMap.focusedTile == m_tileMap.getPlayerEnd)
            {
                botReachedMapEnd();
            }
            else
            {
                m_tileMap.makeMove(bot.makeNextMove());

                auto colors = bot.getTileColors();
                foreach(x; 0 .. colors.length)
                {
                    foreach(y; 0 .. colors[x].length)
                    {
                        m_tileMap.setTileColor(Vector2u(cast(uint) x, cast(uint) y), colors[x][y]);
                    }
                }
            }
        }

        m_player.update(time);
        m_tileMap.update(time);
    }

    void botReachedMapEnd()
    {
        //We are done, and can exit...
        writeln("Bot Results: ", bot.getResults());
        beginNewMap();
    }

}

class FullDemoGUI : DemoMapGUI
{
    private
    {
        alias highlightColor = Color(0, 0, 255, 255);
        alias normalColor = Color(255, 255, 255, 255);

        Text m_randBtn;
        Text m_perlinBtn;
        Text m_bspBtn;
        Text m_demoBtn;

        Font m_font;

        enum State { PLAYING_MAP, MAIN_MENU }
        State m_state;
    }

    this(MapGenConfig config)
    {
        super(config);

        m_font = new Font();
        font.loadFromFile(TEXT_FONT_LOC);

        m_randBtn = new Text("Random", m_font);
    }

    override void beginNewMap()
    {
        //Make this do nothing, now. The functionality will get
        //replaced in another location/user flow.
    }

    override void update(ref RenderWindow window, Time time)
    {
        final switch(m_state)
        {
            case PLAYING_MAP:
                super.update(window, time);
                break;
            case MAIN_MENU:
                auto mouseLoc = Mouse.getPosition(mouse);
                if(m_randBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_randBtn.setColor(highlightColor);
                }
                else
                {
                    m_randBtn.setColor(normalColor);
                }
                break;
        }
    }

    void draw(ref RenderWindow m_window)
    {
        m_window.clear();

        final switch(m_state)
        {
            case PLAYING_MAP:
                m_tileMap.draw(m_window);
                m_window.draw(m_player);
                break;
            case MAIN_MENU:
                m_window.draw(m_randBtn);
                break;
        }

        m_window.display();
    }
}
