module ridgway.pmgcrawler.main;

import std.stdio;
import std.conv;
import std.getopt;
import std.c.stdlib;
import std.random;
import std.path;
import std.file;
import std.algorithm;

import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.constants;
import ridgway.pmgcrawler.gui;
import ridgway.pmgcrawler.generators.generator;
import ridgway.pmgcrawler.generators.perlingenerator;
import ridgway.pmgcrawler.generators.bspgenerator;
import ridgway.pmgcrawler.mapconfig;
import ridgway.pmgcrawler.verification.verification;

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
        string rank;
        string config;
        int batchGen;

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
                    "min-room-width|mrw", &minRoomWidth,
                    "batch-gen", &batchGen,
                    "rank", &rank,
                    "config", &config);

            MapGenConfig configObj;
            if(config)
            {
                configObj = loadConfig(config);
            }

            if(isHelp)
            {
                writeln(helpMessage);
            }
            else if(perlinOutput && (size > 0 || config))
            {
                debug writeln("Generating perlin map.");
                if(config)
                {
                    debug writeln("Using config file: ", config);
                    generatePerlin(perlinOutput,
                                    configObj.pConfig.size,
                                    configObj.pConfig.threshold,
                                    configObj.pConfig.isThreeD,
                                    configObj.pConfig.smooth);
                }
                else
                {
                    generatePerlin(perlinOutput, size, thresh, use3D, smooth);
                }
            }
            else if(bspOutput && (size > 0 || config))
            {
                debug writeln("Generating bsp map.");
                if(config)
                {
                    debug writeln("Using config file: ", config);
                    generateBSP(bspOutput,
                                configObj.bspConfig.size,
                                configObj.bspConfig.minRoomWidth,
                                configObj.bspConfig.minRoomHeight);
                }
                else
                {
                    if(minRoomHeight == 0)
                    {
                        minRoomHeight = 10;
                    }
                    if(minRoomWidth == 0)
                    {
                        minRoomWidth = 10;
                    }

                    generateBSP(bspOutput, size, minRoomWidth, minRoomHeight);
                }
            }
            else if(batchGen > 0 && config)
            {
                writeln("Beginning batch generation of ", batchGen, " maps.");

                //Get the date format and create the necessary directories...
                string date = std.datetime.Clock.currTime.toISOString;
                debug writeln("Using date: ", date);
                string dateDir = "./" ~ date[0 .. $-find(date, ".").length] ~ "/";

                //Copy the config into the directory...
                if(!exists(dateDir))
                {
                    mkdirRecurse(dateDir);
                }
                copy(config, dateDir ~ baseName(config));

                Generators genMethod;
                TestResults results;
                foreach(i; 0..batchGen)
                {
                    genMethod = cast(Generators) uniform(0, Generators.max);
                    Image image;
                    final switch(genMethod)
                    {
                        case Generators.PERLIN:
                            debug writeln("Generating Perlin Map");
                            image = generatePerlin(to!string(i) ~ ".png",
                                        configObj.pConfig.size,
                                        configObj.pConfig.threshold,
                                        configObj.pConfig.isThreeD,
                                        configObj.pConfig.smooth);
                            break;
                        case Generators.BSP:
                            debug writeln("Generating BSP Map");
                            image = generateBSP(to!string(i) ~ ".png",
                                        configObj.bspConfig.size,
                                        configObj.bspConfig.minRoomWidth,
                                        configObj.bspConfig.minRoomHeight);
                            break;
                    }

                    results = fullVerification(image);
                }
            }
            else if(rank)
            {
                writeln("Ranking map: ", rank);
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
`This program is designed to generate map levels and allow you to play them.

Usage
-----

<empty> --map=<file name>:
  just play the game with the default map, or the specified image output map.

-h --help:
  Display this help message

--poutput=<output file> --config=<file> --size=<size> --threed=<bool> --thresh=<bool> --smooth<bool>:
  Generate a map, of given size, via perlin noise, and save to the given file.
  This also takes the optional arguments to threshold the result image,
  use 3D perlin noise, and/or smoothing the image.
  Suppling a config file overrides all other command line arguments.

--bspoutput=<output file> --config=<file> --size=<size> --min-room-height|mrh=<int> --min-room-width|mrw=<int>:
  Generate a map via Binary Space Partitioning and save it to the given file.
  The optional settings for minimum room height/width allow for custom sizing.
  The default is 10 for each.
  Suppling a config file overrides all other command line arguments.

--rank=<file name>
  This will ouput the map verification values for the given map.

--batch-gen=<number of items> --config=<file>
  This will generate the given number of maps, randomly choosing the map gen algorithm.
  This will save the maps in a directory named with the date and time, and name the maps
  with their respective numbers. Finally, this will verify each of the maps as it generates
  them, and output the results in a log file in the same directory.



  The config file specifies the properties to input into the various map generators.
  Below is an example config file's contents (note these are also the defaults):

  {
    "perlin":
    {
      "size":128,
      "threed":false,
      "thresh":true,
      "smooth":true
    },

    "bsp":
    {
      "size":128,
      "min-room-height":7,
      "min-room-width":7
    }
  }`;