module ridgway.pmgcrawler.generators.bspgenerator;

import std.stdio;
import std.random;
import std.math;

import dsfml.graphics;

import ridgway.pmgcrawler.generators.generator;
import ridgway.pmgcrawler.mapconfig;

enum SplitDirection { VERTICAL, HORIZONTAL }
immutable SPLIT_PROBABILITY = .1;

Image generateBSP(MapGenConfig config)
{
    return generateBSP("", false, config);
}

Image generateBSP(string outputFile, MapGenConfig config)
{
    return generateBSP(outputFile, true, config);
}

Image generateBSP(string outputFile, bool saveMap, MapGenConfig config)
{
    debug writeln("Using config: size-", config.bspConfig.size,
                    ", minRoomWidth-", config.bspConfig.minRoomWidth,
                    ", minRoomHeight-", config.bspConfig.minRoomHeight);
    return generateBSP(outputFile,
                        saveMap,
                        config.bspConfig.size,
                        config.bspConfig.minRoomWidth,
                        config.bspConfig.minRoomHeight,
                        config.bspConfig.minAreaRatio,
                        config.bspConfig.roomGap);
}

Image generateBSP(string outputFile, int size, uint minRoomWidth,
                    uint minRoomHeight, float minAreaRatio, int roomGap)
{
    return generateBSP(outputFile, true, size, minRoomWidth, minRoomHeight, minAreaRatio, roomGap);
}

Image generateBSP(string outputFile, bool saveImage, int size, uint minRoomWidth,
                    uint minRoomHeight, float minAreaRatio, int roomGap)
{
    writeln("Map size:", size);
    writeln("Save file: ", outputFile);

    Image image;

    BSPGenerator bGen = new BSPGenerator(size, size, minRoomWidth, minRoomHeight, minAreaRatio, roomGap);
    image = bGen.generateImage();

    if(image && saveImage)
    {
        image.saveToFile(outputFile);
    }
    else
    {
        writeln("Failed to generate an image.");
    }

    return image;
}

class BSPGenerator : Generator
{

    private
    {
        int m_width;
        int m_height;
        int m_minRoomWidth;
        int m_minRoomHeight;

        float m_minAreaRatio;

        immutable int ROOM_GAP;
    }

    this(int width, int height, int minRoomWidth, int minRoomHeight,
            float minAreaRatio, int roomGap)
    {
        m_width = width;
        m_height = height;
        m_minRoomWidth = minRoomWidth;
        m_minRoomHeight = minRoomHeight;

        m_minAreaRatio = minAreaRatio;

        ROOM_GAP = roomGap;
    }

    Image generateImage()
    {
        auto image = new Image();
        image.create(m_width, m_height, Color.Black);

        bsp(image, IntRect(0, 0, image.getSize.x, image.getSize.y), true, true);

        return image;
    }

    //This method recursively generates a game map through binary space partitioning.
    void bsp(Image image, IntRect bounds, bool placeStart, bool placeEnd)
    {
        bool smallWidth = (bounds.width - (m_minRoomWidth * m_minAreaRatio) - 4*ROOM_GAP) <= m_minRoomWidth;
        bool smallHeight = (bounds.height - (m_minRoomHeight * m_minAreaRatio) - 4*ROOM_GAP) <= m_minRoomHeight;
        if(smallWidth && smallHeight)
        {
            //Just finish here and make a room

            //Randomize the room size...
            int offsetHeight = bounds.height - m_minRoomHeight - 2*ROOM_GAP;
            int offsetWidth = bounds.width - m_minRoomWidth - 2*ROOM_GAP;

            int height = m_minRoomHeight + uniform!"[]"(0, offsetHeight);
            int width = m_minRoomWidth + uniform!"[]"(0, offsetWidth);

            //Make sure that there WILL be some overlap with another room,
            //by moving this one closer to the center.
            int widthUnderflow = bounds.width - 2*ROOM_GAP - width - m_minRoomWidth;
            int left;
            if(widthUnderflow > 0)
            {
                left = bounds.left + uniform!"[]"(ROOM_GAP + widthUnderflow, bounds.width - width);
            }
            else
            {
                left = bounds.left + uniform!"[]"(ROOM_GAP, bounds.width - width);
            }

            //Make sure that there WILL be some overlap with another room,
            //by moving this one closer to the center.
            int heightUnderflow = bounds.height - 2*ROOM_GAP - height - m_minRoomHeight;
            int top;
            if(heightUnderflow > 0)
            {
                top = bounds.top + uniform!"[]"(ROOM_GAP + heightUnderflow, bounds.height - height);
            }
            else
            {
                top = bounds.top + uniform!"[]"(ROOM_GAP, bounds.height - height);
            }

            //Prepare to set the start/end locations, if needed.
            Vector2u startLoc, endLoc;
            if(placeStart)
            {
                startLoc = Vector2u(uniform(left + 1, left + width - 1),
                                    uniform(top + 1, top + height - 1));
                //debug writeln("Start calculated at (", startLoc.x, ",", startLoc.y, ")");
            }
            if(placeEnd)
            {
                endLoc   = Vector2u(uniform(left + 1, left + width - 1),
                                    uniform(top + 1, top + height - 1));
                //debug writeln("End calculated at (", endLoc.x, ",", endLoc.y, ")");
            }

            //Set the pixel colors for the room. For now, just keep it simple.
            foreach(y; top .. top + height)
            {
                foreach(x; left .. left + width)
                {
                    if(x >= bounds.left + bounds.width || y >= bounds.top + bounds.height)
                    {
                        debug writeln("Bounds exceeded!! YA DOOF!! (", x, ",", y, ")");
                    }
                    if(placeStart && startLoc == Vector2u(x, y))
                    {
                        image.setPixel(x, y, StartColor);
                        debug writeln("Placed start at (", x, ",", y, ")");
                    }
                    else if(placeEnd && endLoc == Vector2u(x, y))
                    {
                        image.setPixel(x, y, EndColor);
                        debug writeln("Placed end at (", x, ",", y, ")");
                    }
                    else
                    {
                        image.setPixel(x, y, Color.Blue);
                    }
                }
            }
        }
        else if(smallWidth && !smallHeight)
        {
            //Split the room height-ways
            float splitChance = uniform(0.0, 1.0);
            if(splitChance > SPLIT_PROBABILITY)
            {
                splitHeight(image, bounds, placeStart, placeEnd);
            }
        }
        else if(!smallWidth && smallHeight)
        {
            //Split room width-ways
            float splitChance = uniform(0.0, 1.0);
            if(splitChance > SPLIT_PROBABILITY)
            {
                splitWidth(image, bounds, placeStart, placeEnd);
            }
        }
        else
        {
            //Split room in a random orientation.
            int splitDir = uniform(0, 2);
            if(splitDir == SplitDirection.VERTICAL)
            {
                //Split height-ways
                splitHeight(image, bounds, placeStart, placeEnd);
            }
            else
            {
                //Split width-ways
                splitWidth(image, bounds, placeStart, placeEnd);
            }
        }
    }

    void splitHeight(Image image, IntRect bounds, bool placeStart, bool placeEnd)
    {
        int maxOffset = bounds.height - m_minRoomHeight*2 - 4*ROOM_GAP;
        int randOffset = uniform!"[]"(0, maxOffset);
        int height = m_minRoomHeight + randOffset + 2*ROOM_GAP;

        IntRect topRect = IntRect(bounds.left, bounds.top,
                                    bounds.width, height);
        bsp(image, topRect, placeStart, false);

        IntRect bottomRect = IntRect(bounds.left, bounds.top + height,
                                    bounds.width, bounds.height - height);
        bsp(image, bottomRect, false, placeEnd);

        connectRooms(image, SplitDirection.VERTICAL, topRect, bottomRect);
    }

    void splitWidth(Image image, IntRect bounds, bool placeStart, bool placeEnd)
    {
        int maxOffset = bounds.width - m_minRoomWidth*2 - 4*ROOM_GAP;
        int randOffset = uniform!"[]"(0, maxOffset);
        int width = m_minRoomWidth + randOffset + 2*ROOM_GAP;

        IntRect leftRect = IntRect(bounds.left, bounds.top,
                                    width, bounds.height);
        bsp(image, leftRect, placeStart, false);

        IntRect rightRect = IntRect(bounds.left + width, bounds.top,
                                    bounds.width - width, bounds.height);
        bsp(image, rightRect, false, placeEnd);

        connectRooms(image, SplitDirection.HORIZONTAL, leftRect, rightRect);
    }

    //This method makes a pathway across a split in the tree.
    void connectRooms(Image image, SplitDirection dir, IntRect sideOne, IntRect sideTwo)
    {
        final switch(dir)
        {
            case SplitDirection.VERTICAL:
                //Search for where there's common white on either side of the split
                Vector2u[int] edgesTop, edgesBottom;
                foreach(x; sideOne.left .. sideOne.left + sideOne.width)
                {
                    foreach(y; sideOne.top .. sideOne.top + sideOne.height)
                    {
                        if((image.getPixel(x, y) == Color.Blue || image.getPixel(x, y) == Color.White)
                            && (!(x in edgesTop) || edgesTop[x].y < y))
                        {
                            edgesTop[x] = Vector2u(x, y);
                        }
                    }
                }
                foreach(x; sideTwo.left .. sideTwo.left + sideTwo.width)
                {
                    foreach(y; sideTwo.top .. sideTwo.top + sideTwo.height)
                    {
                        if((image.getPixel(x, y) == Color.Blue || image.getPixel(x, y) == Color.White)
                            && (!(x in edgesBottom) || edgesBottom[x].y > y))
                        {
                            edgesBottom[x] = Vector2u(x, y);
                        }
                    }
                }

                //Use the pairs of items, where they exist...
                Vector2u[int] similarEdges;
                foreach(x1, vec1; edgesTop)
                {
                    foreach(x2, vec2; edgesBottom)
                    {
                        if(x2 == x1)
                        {
                            similarEdges[x1] = Vector2u(vec1.y, vec2.y);
                        }
                    }
                }

                if(similarEdges.keys.length == 0)
                {
                    writeln("No similar edges in VERTICAL split.");
                    stdout.flush();
                }
                else
                {
                    //Draw the line between them...
                    int randKey = similarEdges.keys[uniform(0, similarEdges.keys.length)];
                    Vector2u yCoords = similarEdges[randKey];
                    foreach(y; yCoords.x .. yCoords.y)
                    {
                        if(image.getPixel(randKey, y) == Color.Black)
                        {
                            image.setPixel(randKey, y, Color.White);
                        }
                    }
                }

                break;
            case SplitDirection.HORIZONTAL:
            //Search for where there's common white on either side of the split
                Vector2u[int] edgesLeft, edgesRight;
                foreach(x; sideOne.left .. sideOne.left + sideOne.width)
                {
                    foreach(y; sideOne.top .. sideOne.top + sideOne.height)
                    {
                        if((image.getPixel(x, y) == Color.Blue || image.getPixel(x, y) == Color.White)
                            && (!(y in edgesLeft) || edgesLeft[y].x < x))
                        {
                            edgesLeft[y] = Vector2u(x, y);
                        }
                    }
                }
                foreach(x; sideTwo.left .. sideTwo.left + sideTwo.width)
                {
                    foreach(y; sideTwo.top .. sideTwo.top + sideTwo.height)
                    {
                        if((image.getPixel(x, y) == Color.Blue || image.getPixel(x, y) == Color.White)
                            && (!(y in edgesRight) || edgesRight[y].x > x))
                        {
                            edgesRight[y] = Vector2u(x, y);
                        }
                    }
                }

                //Use the pairs of items, where they exist...
                Vector2u[int] similarEdges;
                foreach(y1, vec1; edgesLeft)
                {
                    foreach(y2, vec2; edgesRight)
                    {
                        if(y2 == y1)
                        {
                            similarEdges[y1] = Vector2u(vec1.x, vec2.x);
                        }
                    }
                }

                if(similarEdges.keys.length == 0)
                {
                    writeln("No similar edges in HORIZONTAL split.");
                    stdout.flush();
                }
                else
                {
                    //Draw the line between them
                    int randKey = similarEdges.keys[uniform(0, similarEdges.keys.length)];
                    Vector2u xCoords = similarEdges[randKey];
                    foreach(x; xCoords.x .. xCoords.y)
                    {
                        if(image.getPixel(x, randKey) == Color.Black)
                        {
                            image.setPixel(x, randKey, Color.White);
                        }
                    }
                }
                break;
        }
    }

}
