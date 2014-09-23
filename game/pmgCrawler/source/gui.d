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
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ];

        Player m_player;
    }

    this()
    {
        window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(800,600), "PMG Crawler");
        window.setFramerateLimit(3);

        debug writeln("Loading tile map");
        //tileMap = new TileMap(Vector2i(60, 60));
        tileMap = new TileMap();
        if(!tileMap.load(TILE_MAP_LOC, Vector2u(32, 32), level, 20, 20))
        {
            writeln("Couldn't load image...");
            exit(1);
        }

        tileMap.focusedTile = Vector2u(10, 10);
        tileMap.focusedLocation = Vector2i(400, 300);

        //Load the necessary data for use with the Player's animations, and textures.
        auto sheet = new SpriteSheet();
		sheet.loadFromFile("assets/acid_splosion.json");

		auto frameList = SpriteFrameList();
		frameList.loadFromFile("assets/acid_splosion_sprite_frames.json");

        m_player = new Player(sheet, frameList);
        m_player.position = Vector2f(400, 300);
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
                	if(event.key.code == Keyboard.Key.Down)
                	{
                		writeln("Down arrow key pressed.");
                		tileMap.focusedTile = tileMap.focusedTile + Vector2u(0, 1);
                	}
                	else if(event.key.code == Keyboard.Key.Up)
                	{
                		writeln("Up arrow key pressed.");
                		tileMap.focusedTile = tileMap.focusedTile +  Vector2u(0, -1);
                	}
                	else if(event.key.code == Keyboard.Key.Left)
                	{
                		writeln("Left arror key pressed.");
                		tileMap.focusedTile = tileMap.focusedTile +  Vector2u(-1, 0);
                	}
                	else if(event.key.code == Keyboard.Key.Right)
                	{
                		writeln("Right arrow key pressed.");
                		tileMap.focusedTile = tileMap.focusedTile +  Vector2u(1, 0);
                	}
                	else if(event.key.code == Keyboard.Key.Escape)
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