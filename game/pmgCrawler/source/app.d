module ridgway.pmgcrawler.app;

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


bool isHelp = false;
string perlinOutput, bspOutput, mapFile;
uint size, thresh, smooth;
bool use3D = false, VERBOSE = false, demo = false;
uint minRoomWidth, minRoomHeight;
float minAreaRatio;
string rank, config;
int numBatchGen;

void main(string[] args)
{
    version(unittest)
    {
        import dunit;
        dunit_main(args);
    }
    else
    {
        try
        {
            getopt( args,
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
                    "min-area-ratio|mar", &minAreaRatio,
                    "batch-gen", &numBatchGen,
                    "rank", &rank,
                    "config", &config,
                    "verbose", &VERBOSE,
                    "demo", &demo);

            MapGenConfig configObj;
            if(config)
            {
                configObj = loadConfig(config);
            }
            else
            {
                configObj = MapGenConfig();
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
                    generatePerlin(perlinOutput, configObj);
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
                    generateBSP(bspOutput, configObj);
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

                    generateBSP(bspOutput, size, minRoomWidth, minRoomHeight, minAreaRatio, 1);
                }
            }
            else if(numBatchGen > 0)
            {
                batchGen(configObj);
            }
            else if(rank)
            {
                writeln("Ranking map: ", rank);
                auto results = runVerification(configObj, rank);
                printResults(results, stdout);
            }
            else if(demo)
            {
                auto gui = new DemoMapGUI(configObj);
                gui.run();
            }
            else
            {
                debug writeln("Staring GUI...");
                if(mapFile)
                {
                    auto gui = new GeneratedMapGUI(mapFile);
                    gui.run();
                }
                else
                {
                    auto gui = new TileMapGUI();
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

void batchGen(MapGenConfig configObj)
{
    writeln("Beginning batch generation of ", numBatchGen, " maps.");

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

    //Create the results file so we can store our verification data
    auto resultsFile = File(dateDir ~ "results", "w");
    resultsFile.writeln("VERIFICATION RESULTS");
    resultsFile.writeln("--------------------\n");

    Generators genMethod;
    TestResults results;
    string outputFile;
    foreach(i; 0..numBatchGen)
    {
        genMethod = cast(Generators) uniform!"[]"(Generators.min, Generators.max);
        Image image;
        string title;
        final switch(genMethod)
        {
            case Generators.PERLIN:
                debug writeln("Generating Perlin Map");
                image = generatePerlin(dateDir ~ to!string(i) ~"-perlin" ~ ".png", configObj);

                title = to!string(i) ~ " - Perlin";
                break;
            case Generators.BSP:
                debug writeln("Generating BSP Map");
                image = generateBSP(dateDir ~ to!string(i) ~ "-bsp" ~ ".png", configObj);

                title = to!string(i) ~ " - BSP";
                break;
        }

        results = runVerification(configObj, image);
        results.name = title;

        //Print various output.
        printResults(results, resultsFile);
        if(VERBOSE)
        {
            writeln(title);
            printResults(results, stdout);
        }
    }
    resultsFile.close();
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

--bspoutput=<output file> --config=<file> --size=<size> --min-room-height|mrh=<int> --min-room-width|mrw=<int> --min-area-ratio|mar=<float>:
  Generate a map via Binary Space Partitioning and save it to the given file.
  The optional settings for minimum room height/width allow for custom sizing.
  The default is 10 for each.
  Suppling a config file overrides all other command line arguments.

--rank=<file name> --config=<file>
  This will ouput the map verification values for the given map. The methods to use
  in verifying the map are passed via the config file.

--batch-gen=<number of items> --config=<file>
  This will generate the given number of maps, randomly choosing the map gen algorithm.
  This will save the maps in a directory named with the date and time, and name the maps
  with their respective numbers. Finally, this will verify each of the maps as it generates
  them, and output the results in a log file in the same directory.

--demo --config=<file>
  This will activate demo mode, which generates a map, verifies it with Dijkstra's, and
  then makes a bot play it until it gets to the end, at which point it repeats
  with a newly generated map.



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
      "min-room-width":7,
      "min-area-ratio":1.0,
      "room-gap":2
    },

    "verification":
    {
      "dijkstras":true,
      "useBots":true,
      "botType":"Search"
    }
  }`;
