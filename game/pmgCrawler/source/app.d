module ridgway.pmgcrawler.main;

import std.stdio;
import std.conv;
import std.getopt;

import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.constants;
import ridgway.pmgcrawler.gui;
import ridgway.pmgcrawler.generators.perlingenerator;
import ridgway.pmgcrawler.generators.bspgenerator;

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
        import dunit;
        dunit_main(args);
    }
    else
    {
        bool isHelp = false;
        string perlinOutput, bspOutput;
        uint size;
        uint thresh;
        bool use3D = false;
        uint smooth;
        string mapFile;
        uint minRoomWidth, minRoomHeight;

        try
        {
            getopt(args,
                    "help|h", &isHelp,
                    "poutput", &perlinOutput,
                    "bspoutput", &bspOutput,
                    "thresh", &thresh,
                    "threed", &use3D,
                    "size", &size,
                    "smooth", &smooth,
                    "map", &mapFile,
                    "min-room-height|mrh", &minRoomHeight,
                    "min-room-width|mrw", &minRoomWidth);

            if(isHelp)
            {
                writeln(helpMessage);
            }
            else if(perlinOutput && size > 0)
            {
                debug writeln("Generating map.");
                generatePerlin(perlinOutput, size, thresh, use3D, smooth);
            }
            else if(bspOutput && size > 0)
            {
                if(minRoomHeight == 0)
                {
                    minRoomHeight = 10;
                }
                if(minRoomWidth == 0)
                {
                    minRoomWidth = 10;
                }

                debug writeln("Generating map.");
                generateBSP(bspOutput, size, minRoomWidth, minRoomHeight);
            }
            else
            {
                debug writeln("Staring GUI...");
                if(mapFile)
                {
                    GeneratedMapGUI gui = new GeneratedMapGUI(mapFile);
                    gui.run();
                }
                else
                {
                    TileMapGUI gui = new TileMapGUI();
                    gui.run();
                }
            }
        }
        catch(GetOptException goe)
        {
            writeln(goe.msg, "\n ");
            writeln(helpMessage);
        }
        
    }
}

immutable string helpMessage =
r"This program is designed to generate map levels and allow you to play them.

Usage
-----

<empty> --map=<file name>:
  just play the game with the default map, or the specified image output map.

-h --help:
  Display this help message

--poutput=<output file> --size=<size> --threed=<bool> --thresh=<bool> --smooth<bool>:
  Generate a map, of given size, via perlin noise, and save to the given file.
  This also takes the optional arguments to threshold the result image,
  use 3D perlin noise, and/or smoothing the image.

--bspoutput=<output file> --size=<size> --min-room-height|mrh=<int> -- min-room-width|mrw=<int>:
  Generate a map via Binary Space Partitioning and save it to the given file.
  The optional settings for minimum room height/width allow for custom sizing.
  The default is 10 for each.";