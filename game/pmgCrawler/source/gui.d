module ridgway.pmgcrawler.gui;

import std.stdio;
import std.c.stdlib;

import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.constants;
import ridgway.pmgcrawler.player;
import ridgway.pmgcrawler.spritesheet;


class TileMapGUI
{

    private
    {

        RenderWindow window;

        //TileMap lifeMap;
        TileMap tileMap;

        static const(int[]) level =
        [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ];

        Player m_player;
        bool m_canMove;
    }

    this()
    {
    	auto settings = ContextSettings();
    	settings.antialiasingLevel = 8;
        window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);
        //window.setFramerateLimit(3);

        debug writeln("Loading tile map");
        tileMap = new TileMap();
        if(!tileMap.load(TILE_MAP_LOC, Vector2u(32, 32), level, 20, 20, Vector2u(0,0), Vector2u(1,0)))
        {
            writeln("Couldn't load image...");
            exit(1);
        }

        tileMap.focusedLocation = Vector2i(400, 300);

        m_player = new Player();
        m_player.position = Vector2f(400, 300);

        m_canMove = false;
    }

    void run()
    {
        //For event polling...
        Event event;

        Clock clock = new Clock();

        while (window.isOpen())
        {
            // check all the window's events that were triggered since the last iteration of the loop
            while(window.pollEvent(event))
            {
                // "close requested" event: we close the window
                if(event.type == Event.EventType.Closed)
                {
                    window.close();
                }
                else if(event.type == Event.EventType.KeyPressed)
                {
                	
                	if(event.key.code == Keyboard.Key.Escape)
                	{
                		exit(0);
                	}
                }
            }

            Time time = clock.getElapsedTime();
            clock.restart();
            update(window, time);
            draw(window);
        }
    }

    void update(ref RenderWindow window, Time time)
    {
    	if(Keyboard.isKeyPressed(Keyboard.Key.Down))
    	{
    		debug writeln("Down arrow key pressed.");
    		tileMap.moveDown();
    	}
    	else if(Keyboard.isKeyPressed(Keyboard.Key.Up))
    	{
    		debug writeln("Up arrow key pressed.");
    		tileMap.moveUp();
    	}
    	else if(Keyboard.isKeyPressed(Keyboard.Key.Left))
    	{
    		debug writeln("Left arror key pressed.");
    		tileMap.moveLeft();
    	}
    	else if(Keyboard.isKeyPressed(Keyboard.Key.Right))
    	{
    		debug writeln("Right arrow key pressed.");
    		tileMap.moveRight();
    	}

        m_player.update(time);
        tileMap.update(time);
    }

    void draw(ref RenderWindow window)
    {
        window.clear();

        tileMap.draw(window);
        window.draw(m_player);

        window.display();
    }

}

class GeneratedMapGUI : TileMapGUI
{
	private
	{

	}

	this()
    {
    	auto settings = ContextSettings();
    	settings.antialiasingLevel = 8;
        window = new RenderWindow(VideoMode(800,600), "PMG Crawler", Window.Style.DefaultStyle, settings);

        debug writeln("Loading tile map");
        tileMap = new TileMap();
        if(!tileMap.loadFromImage(TILE_MAP_LOC, ASSET_LOC ~ "swag-smooth2.png", Vector2u(32, 32)))
        {
            writeln("Couldn't load tile map image...");
            exit(1);
        }

        tileMap.focusedLocation = Vector2i(400, 300);
        tileMap.focusedTile = tileMap.getPlayerStart();

        m_player = new Player();
        m_player.position = Vector2f(400, 300);

        m_canMove = false;
    }
}