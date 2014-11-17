module ridgway.pmgcrawler.main;

import std.stdio;
import std.conv;

import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.constants;
import ridgway.pmgcrawler.gui;
import ridgway.pmgcrawler.generators.perlingenerator;

class LifeGUI
{

	private
	{
		RenderWindow window;

        //TileMap lifeMap;
        VertexTileMap lifeMap;

        static const(bool[]) level =
        [
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            true, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false,
            true, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false,
            true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
            true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
        ];
	}

	this()
	{
		window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(800,600), "PMG Crawler");//, Window.Style.None);
		window.setFramerateLimit(3);

        //lifeMap = new TileMap(Vector2i(60, 60));
        lifeMap = new VertexTileMap();
        lifeMap.load(Vector2u(10, 10), level, 17, 17);
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
            }

            Time time = clock.getElapsedTime();
            clock.restart();
            update(window, time);
            draw(window);
        }
	}

    void update(ref RenderWindow window, Time time)
    {
        //writeln("updating...");

        int numNeighborsAlive;
        for(int w = 1; w < lifeMap.getWidth()-1; ++w)
        {
            for(int h = 1; h < lifeMap.getHeight()-1; ++h)
            {
                numNeighborsAlive = 0;
                if(lifeMap.getIsAlive(w-1, h-1))//Top Left
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w-1, h))//Mid Left
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w-1, h+1))//Bottom Left
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w, h-1))//Top Mid
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w, h+1))//Bottom Mid
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w+1, h-1))//Top Right
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w+1, h))//Mid Right
                {
                    numNeighborsAlive++;
                }
                if(lifeMap.getIsAlive(w+1, h+1))//Bottom Right
                {
                    numNeighborsAlive++;
                }
                /*if(lifeMap.getIsAlive(w, h))
                {
                    numNeighborsAlive++;
                }*/

                if(numNeighborsAlive == 3
                    || (numNeighborsAlive == 2 && lifeMap.getIsAlive(w, h)))
                {
                    lifeMap.setIsStillAlive(w, h, true);
                }
                else
                {
                    lifeMap.setIsStillAlive(w, h, false);
                }

                //lifeMap.updateLifeState(w, h);
            }
        }

        updateLifeStates();
    }

    void updateLifeStates() {
        writeln("updating life states...");

        for(int w = 1; w < lifeMap.getWidth() - 1; w++)
        {
            for(int h = 1; h < lifeMap.getHeight() - 1; h++)
            {
                lifeMap.updateLifeState(w, h);
            }
        }
    }

    void draw(ref RenderWindow window)
    {
        window.clear();

        lifeMap.draw(window);

        window.display();
    }

}

void main(string[] args)
{
    version(unittest)
    {
        writeln("Empty main for unittests...");
    }
    else
    {
        if(args.length > 1)
        {
            switch(args[1])
            {
                case "-h":
                    writeln(helpMessage);
                    break;

                case "-perlin":
                    debug writeln("Generating map.");
                    string saveFile = args[2];
                    int size = to!int(args[3]);
                    bool threshold = to!bool(args[4]);
                    bool use3D = to!bool(args[5]);
                    generatePerlin(saveFile, size, threshold, use3D);
                    break;

                default:
                    //Just run the default game setup...
                    debug writeln("Staring GUI...");
                    TileMapGUI gui = new TileMapGUI();
                    gui.run();
                    break;
            }
        }
        else
        {
            debug writeln("Staring GUI...");
            TileMapGUI gui = new TileMapGUI();
            gui.run();
        }
        
    }
}


unittest
{

	writeln("Testing the PMG Crawler game.");

	assert(1 == 1);

}

immutable string helpMessage = r"This program is designed to generate map levels and allow you to play them.

Usage
-----

<empty>:
  just play the game with the default map.

-h:
  display this help message

-perlin <output file> <size>:
  generate a map, of given size, via perlin noise, and save to the given file.";