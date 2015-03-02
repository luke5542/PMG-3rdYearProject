module ridgway.pmgcrawler.gui;

import std.stdio;
import std.c.stdlib;
import std.concurrency;
import std.random;
import std.conv;

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


immutable WINDOW_HEIGHT = 800;
immutable WINDOW_WIDTH  = 1200;

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
        m_window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(WINDOW_WIDTH, WINDOW_HEIGHT), "PMG Crawler", Window.Style.DefaultStyle, settings);
        m_window.setFramerateLimit(60);

        m_tileMap = new TileMap();
        if(!m_tileMap.load(TILE_MAP_LOC, Vector2u(32, 32), level, 20, 25, Vector2u(0,0), Vector2u(1,0)))
        {
            writeln("Couldn't load image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);

        m_player = new Player();
        m_player.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
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
                else if(event.type == Event.EventType.MouseButtonReleased)
                {
                    handleMouse(event.mouseButton);
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

    void handleMouse(Event.MouseButtonEvent mouseButton)
    {
        //Do nothing for now...
    }

    void update(ref RenderWindow window, Time time)
    {
        checkKeyboard();

        m_player.update(time);
        m_tileMap.update(time);
    }

    void checkKeyboard()
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
    }

    void draw(ref RenderWindow window)
    {
        window.clear();

        m_tileMap.draw(window);
        window.draw(m_player);

        window.display();
    }

}

class GeneratedMapGUI : TileMapGUI
{

    this(string mapFile)
    {
        //auto settings = ContextSettings();
        //settings.antialiasingLevel = 8;
        //m_window = new RenderWindow(VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);
        //m_window.setFramerateLimit(60);

        m_tileMap = new TileMap();
        if(!m_tileMap.loadFromImage(TILE_MAP_LOC, mapFile, Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
        m_tileMap.focusedTile = m_tileMap.getPlayerStart();
    }

}

class DemoMapGUI : TileMapGUI
{

    private
    {
        MapGenConfig m_config;
        Bot bot;
        TestResults m_results;
    }

    this()
    {
        super();
    }

    this(MapGenConfig config)
    {
        super();

        m_config = config;
        m_config.vConfig.useBots = false;

        beginNewMap();
    }

    void beginNewMap()
    {
        auto genMethod = cast(Generators) uniform!"[]"(Generators.min, Generators.max);
        generateMap(genMethod);

        bot = initBot(cast(shared(TileMap)) m_tileMap, m_config);
    }

    void generateMap(Generators genMethod)
    {
        auto genMap = generateMapImage(genMethod);
        while(!genMap)
        {
            genMap = generateMapImage(genMethod);
        }

        runBotOnMap(genMap);
    }

    void runBotOnMap(Image map)
    {
        m_tileMap = new TileMap();
        if(!m_tileMap.loadFromImage(TILE_MAP_LOC, map, Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);

        debug writeln("Player Start: ", m_tileMap.getPlayerStart());
        m_tileMap.focusedTile = m_tileMap.getPlayerStart();
    }

    Image generateMapImage(Generators genMethod)
    {
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

        m_results = runVerification(m_config, image);
        if(m_results.ranDijkstras && m_results.exitTileDistance > 0)
        {
            return image;
        }
        else
        {
            writeln("Map failed verification...");
            return null;
        }
    }

    override void update(ref RenderWindow window, Time time)
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
        static immutable highlightColor = Color(255, 180, 0, 255);
        static immutable normalColor = Color(255, 255, 255, 255);

        Text m_randBtn;
        Text m_perlinBtn;
        Text m_bspBtn;
        Text m_demoBtn;

        RectangleShape m_background;
        Shader m_shader;
        Time m_shaderTime;

        Font m_font;
        Font m_font2;

        enum State { PLAYING_MAP, MAIN_MENU, RUNNING_DEMO, RUNNING_SINGLE_DEMO, SHOWING_MAP }
        State m_state = State.MAIN_MENU;

        bool m_useBots;

        Image m_currentMap;
        Sprite m_mapSprite;
        Text m_backBtn;
        Text m_playBtn;
        Text m_botBtn;
        Text m_mapStats;

        //Used with the minimap st00fs
        View m_view;
        RenderTexture m_renderTex;
        Sprite m_minimap;
    }

    this(MapGenConfig config)
    {
        m_useBots = config.vConfig.useBots;
        super(config);

        m_player = new Player();
        m_player.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);

        m_background = new RectangleShape(Vector2f(WINDOW_WIDTH, WINDOW_HEIGHT));
        m_background.position = Vector2f(0, 0);
        m_background.origin = Vector2f(0, 0);

        if(Shader.isAvailable())
        {
            m_shader = new Shader();
            if (!m_shader.loadFromFile(SHADER_LOC, Shader.Type.Fragment))
            {
                writeln("Shader failed to load.");
            }
            else
            {
                m_shader.setParameter("resolution", Vector2f(WINDOW_WIDTH, WINDOW_HEIGHT));
                m_shaderTime = seconds(0);
                m_shader.setParameter("time", m_shaderTime.asSeconds());
            }
        }

        m_font = new Font();
        if(!m_font.loadFromFile(TEXT_FONT_LOC))
        {
            writeln("Failed to load font file! Exiting...");
            exit(1);
        }
        m_font2 = new Font();
        if(!m_font2.loadFromFile(TEXT_FONT2_LOC))
        {
            writeln("Failed to load font2 file! Exiting...");
            exit(1);
        }

        m_randBtn = new Text("Random Map", m_font, 80);
        m_randBtn.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2 - 200);
        m_randBtn.origin = Vector2f(m_randBtn.getLocalBounds().width/2,
                                    m_randBtn.getLocalBounds().height/2);

        m_perlinBtn = new Text("Perlin Map", m_font, 80);
        m_perlinBtn.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2 - 100);
        m_perlinBtn.origin = Vector2f(m_randBtn.getLocalBounds().width/2,
                                    m_randBtn.getLocalBounds().height/2);

        m_bspBtn = new Text("BSP Map", m_font, 80);
        m_bspBtn.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
        m_bspBtn.origin = Vector2f(m_randBtn.getLocalBounds().width/2,
                                    m_randBtn.getLocalBounds().height/2);

        m_demoBtn = new Text("Demo Mode", m_font, 80);
        m_demoBtn.position = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2 + 100);
        m_demoBtn.origin = Vector2f(m_randBtn.getLocalBounds().width/2,
                                    m_randBtn.getLocalBounds().height/2);

        m_view = new View();
        m_view.center = Vector2f(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
        m_view.size = Vector2f(800, 800);
        m_view.zoom(4);

        m_renderTex = new RenderTexture();
        if(!m_renderTex.create(200, 200))
        {
            writeln("Failed to create render texture. Exiting...");
            exit(1);
        }
        m_renderTex.smooth = true;
        m_renderTex.view = m_view;

        m_minimap = new Sprite();
        m_minimap.position = Vector2f(WINDOW_WIDTH-250, 50);
    }

    void runPlayableMap()
    {
        m_tileMap = new TileMap();
        if(!m_tileMap.loadFromImage(TILE_MAP_LOC, m_currentMap, Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        m_tileMap.focusedLocation = Vector2i(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
        m_tileMap.focusedTile = m_tileMap.getPlayerStart();

        m_state = State.PLAYING_MAP;
    }

    override void beginNewMap()
    {
        //Make this do nothing, now. The functionality will get
        //replaced in another location/user flow.
    }

    override void botReachedMapEnd()
    {
        writeln("Bot Results: ", bot.getResults());

        if(m_state == State.RUNNING_DEMO)
        {
            super.beginNewMap();
        }
        else if(m_state == State.RUNNING_SINGLE_DEMO)
        {
            m_state = State.MAIN_MENU;
        }
    }

    void personReachedMapEnd()
    {
        if(m_state == State.PLAYING_MAP)
        {
            m_state = State.MAIN_MENU;
        }
    }

    override void update(ref RenderWindow window, Time time)
    {
        auto mouseLoc = Mouse.getPosition(window);
        final switch(m_state)
        {
            case State.PLAYING_MAP:
                if(m_tileMap.focusedTile == m_tileMap.getPlayerEnd())
                {
                    personReachedMapEnd();
                }

                checkKeyboard();
                m_player.update(time);
                m_tileMap.update(time);
                break;

            case State.RUNNING_SINGLE_DEMO:
            case State.RUNNING_DEMO:
                super.update(window, time);
                break;

            case State.SHOWING_MAP:
                if(m_playBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_playBtn.setColor(highlightColor);
                }
                else
                {
                    m_playBtn.setColor(normalColor);
                }
                if(m_backBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_backBtn.setColor(highlightColor);
                }
                else
                {
                    m_backBtn.setColor(normalColor);
                }
                if(m_botBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_botBtn.setColor(highlightColor);
                }
                else
                {
                    m_botBtn.setColor(normalColor);
                }

                m_shaderTime += time;
                m_shader.setParameter("time", m_shaderTime.asSeconds());
                break;

            case State.MAIN_MENU:
                if(m_randBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_randBtn.setColor(highlightColor);
                }
                else
                {
                    m_randBtn.setColor(normalColor);
                }
                if(m_perlinBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_perlinBtn.setColor(highlightColor);
                }
                else
                {
                    m_perlinBtn.setColor(normalColor);
                }
                if(m_bspBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_bspBtn.setColor(highlightColor);
                }
                else
                {
                    m_bspBtn.setColor(normalColor);
                }
                if(m_demoBtn.getGlobalBounds().contains(mouseLoc))
                {
                    m_demoBtn.setColor(highlightColor);
                }
                else
                {
                    m_demoBtn.setColor(normalColor);
                }

                m_shaderTime += time;
                m_shader.setParameter("time", m_shaderTime.asSeconds());
                break;
        }
    }

    override void handleMouse(Event.MouseButtonEvent mouseButton)
    {
        if(mouseButton.button == Mouse.Button.Left)
        {
            auto mouseLoc = Mouse.getPosition(m_window);
            if(m_state == State.MAIN_MENU)
            {
                if(m_randBtn.getGlobalBounds().contains(mouseLoc))
                {
                    showRandomMap();
                }
                else if(m_perlinBtn.getGlobalBounds().contains(mouseLoc))
                {
                    showMap(Generators.PERLIN);
                }
                else if(m_bspBtn.getGlobalBounds().contains(mouseLoc))
                {
                    showMap(Generators.BSP);
                }
                else if(m_demoBtn.getGlobalBounds().contains(mouseLoc))
                {
                    super.beginNewMap();
                    m_state = State.RUNNING_DEMO;
                }
            }
            else if(m_state == State.SHOWING_MAP)
            {
                if(m_playBtn.getGlobalBounds().contains(mouseLoc))
                {
                    runPlayableMap();
                }
                else if(m_backBtn.getGlobalBounds.contains(mouseLoc))
                {
                    m_state = State.MAIN_MENU;
                }
                else if(m_botBtn.getGlobalBounds().contains(mouseLoc))
                {
                    runBotOnMap(m_currentMap);
                    bot = initBot(cast(shared(TileMap)) m_tileMap, m_config);
                    m_state = State.RUNNING_SINGLE_DEMO;
                }
            }
        }
    }

    void showRandomMap()
    {
        auto genMethod = cast(Generators) uniform!"[]"(Generators.min, Generators.max);
        showMap(genMethod);
    }

    void showMap(Generators genMethod)
    {
        auto genMap = generateMapImage(genMethod);
        while(!genMap)
        {
            genMap = generateMapImage(genMethod);
        }

        Texture tex = new Texture();
        if(!tex.loadFromImage(genMap))
        {
            writeln("Failed to make texture from generated image...");
        }
        m_currentMap = genMap;
        m_mapSprite = new Sprite(tex);
        auto width = m_currentMap.getSize().x;
        m_mapSprite.origin = Vector2f(width/2, width/2);
        m_mapSprite.scale = Vector2f(400/width, 400/width);
        m_mapSprite.position = Vector2f(WINDOW_WIDTH/2 - 100, WINDOW_HEIGHT/2);


        m_playBtn = new Text("Play", m_font, 60);
        m_playBtn.position = Vector2f(WINDOW_WIDTH/2 - 150, WINDOW_HEIGHT/2 + 250);
        m_playBtn.origin = Vector2f(m_playBtn.getLocalBounds().width/2,
                                    m_playBtn.getLocalBounds().height/2);

        m_backBtn = new Text("Back", m_font, 50);
        m_backBtn.position = Vector2f(WINDOW_WIDTH/2 - 250, 50);
        m_backBtn.origin = Vector2f(m_playBtn.getLocalBounds().width/2,
                                    m_playBtn.getLocalBounds().height/2);

        m_botBtn = new Text("Bot", m_font, 60);
        m_botBtn.position = Vector2f(WINDOW_WIDTH/2 + 150, WINDOW_HEIGHT/2 + 250);
        m_botBtn.origin = Vector2f(m_botBtn.getLocalBounds().width/2,
                                    m_botBtn.getLocalBounds().height/2);

        m_mapStats = new Text(to!(dstring)(m_results.toString()), m_font2, 20);
        m_mapStats.position = Vector2f(WINDOW_WIDTH/2 + 100, WINDOW_HEIGHT/2);
        m_mapStats.origin = Vector2f(0, m_mapStats.getLocalBounds().height/2);

        m_state = State.SHOWING_MAP;
    }

    override void draw(ref RenderWindow window)
    {
        window.clear();

        final switch(m_state)
        {
            case State.PLAYING_MAP:
            case State.RUNNING_SINGLE_DEMO:
            case State.RUNNING_DEMO:
                m_tileMap.draw(m_window);
                window.draw(m_player);

                m_renderTex.clear(Color(100, 100, 100));
                m_tileMap.draw(m_renderTex);
                m_renderTex.draw(m_player);
                m_renderTex.display();

                m_minimap.setTexture(m_renderTex.getTexture());
                window.draw(m_minimap);
                break;
            case State.SHOWING_MAP:
                if(Shader.isAvailable())
                {
                    RenderStates states = RenderStates.Default;
                    states.shader = m_shader;
                    window.draw(m_background, states);
                }

                window.draw(m_mapSprite);
                window.draw(m_playBtn);
                window.draw(m_botBtn);
                window.draw(m_backBtn);
                window.draw(m_mapStats);
                break;
            case State.MAIN_MENU:
                if(Shader.isAvailable())
                {
                    RenderStates states = RenderStates.Default;
                    states.shader = m_shader;
                    window.draw(m_background, states);
                }

                window.draw(m_randBtn);
                window.draw(m_bspBtn);
                window.draw(m_perlinBtn);
                window.draw(m_demoBtn);
                break;
        }

        window.display();
    }
}
