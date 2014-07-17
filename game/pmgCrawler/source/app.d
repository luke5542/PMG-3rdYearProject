module ridgway.pmgcrawler.main;

import std.stdio;
import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import ridgway.pmgcrawler.map;

class GUI
{

	private
	{
		RenderWindow window;

        //TileMap lifeMap;
        VertexTileMap lifeMap;

        const(bool) level[] =
        [
            false, false, false, false, false, false, true, true, true, true, true, true, true, true, true, true,
            false, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false,
            true, true, false, false, false, false, false, false, true, true, true, true, true, true, true, true,
            false, true, false, false, false, false, true, true, true, false, true, true, true, false, false, false,
            false, true, true, false, true, true, true, false, false, false, true, true, true, false, false, false,
            false, false, true, false, true, false, false, false, false, false, true, true, true, true, false, false,
            false, false, true, false, true, false, false, false, false, false, true, true, true, true, true, true,
            false, false, true, false, true, false, false, false, false, false, false, false, true, true, true, true,
        ];
	}

	this()
	{
		window = new RenderWindow(/*VideoMode.getDesktopMode()*/VideoMode(800,800), "PMG Crawler");//, Window.Style.None);
		window.setFramerateLimit(10);

        //lifeMap = new TileMap(Vector2i(60, 60));
        lifeMap = new VertexTileMap();
        lifeMap.load(Vector2u(32, 32), level, 16, 8);
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
            //update(window, time);
            draw(window);
        }
	}

    //void update(ref RenderWindow window, Time time)
    //{
    //    //writeln("updating...");

    //    int numNeighborsAlive = 0;
    //    for(int w = 1; w < lifeMap.getWidth() - 1; w++)
    //    {
    //        for(int h = 1; h < lifeMap.getHeight() - 1; h++)
    //        {
    //            if(lifeMap.getIsAlive(w-1, h-1))//Top Left
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w-1, h))//Mid Left
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w-1, h+1))//Bottom Left
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w, h-1))//Top Mid
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w, h+1))//Bottom Mid
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w+1, h-1))//Top Right
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w+1, h))//Mid Right
    //            {
    //                numNeighborsAlive++;
    //            }
    //            if(lifeMap.getIsAlive(w+1, h+1))//Bottom Right
    //            {
    //                numNeighborsAlive++;
    //            }

    //            if(lifeMap.getIsAlive(w, h))
    //            {
    //                if(numNeighborsAlive < 2)
    //                {
    //                    lifeMap.setIsStillAlive(w, h, false);
    //                }
    //                else if(numNeighborsAlive > 3)
    //                {
    //                    lifeMap.setIsStillAlive(w, h, false);
    //                }
    //                else
    //                {
    //                    lifeMap.setIsStillAlive(w, h, true);
    //                }
    //            }
    //            else
    //            {
    //                if(numNeighborsAlive == 3)
    //                {
    //                    lifeMap.setIsStillAlive(w, h, true);
    //                }
    //                else
    //                {
    //                    lifeMap.setIsStillAlive(w, h, false);
    //                }
    //            }
    //        }
    //    }

    //    for(int w = 1; w < lifeMap.getWidth() - 1; w++)
    //    {
    //        for(int h = 1; h < lifeMap.getHeight() - 1; h++)
    //        {
    //            lifeMap.updateLifeState(w, h);
    //        }
    //    }

    void draw(ref RenderWindow window)
    {
        window.clear();

        lifeMap.draw(window);

        window.display();
    }

}

void main()
{
	writeln("Staring GUI...");
    GUI gui = new GUI();
    gui.run();
}


unittest
{

	writeln("Testing the PMG Crawler game.");

	assert(1 == 1);

}