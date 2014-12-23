module ridgway.pmgcrawler.generators.bspgenerator;

import std.stdio;
import std.random;
import std.math;

import dsfml.graphics;

import ridgway.pmgcrawler.generators.generators;

void generateBSP(string outputFile, int size)
{
	writeln("Map size:", size);
	writeln("Save file: ", outputFile);

	Image image;

	BSPGenerator bGen = new BSPGenerator(size, size, size/8, size/8);
	image = bGen.generateImage();
	
	if(image)
	{
		image.saveToFile(outputFile);
	}
	else
	{
		writeln("Failed to generate an image.");
	}
}

class BSPGenerator : Generator
{

	private
	{
		uint m_noiseWidth;
		uint m_noiseHeight;
		uint m_minRoomWidth;
		uint m_minRoomHeight;

		double[] noise;
	}

	this(uint width, uint height, uint minRoomWidth, uint minRoomHeight)
	{
		m_noiseWidth = width;
		m_noiseHeight = height;
		m_minRoomWidth = minRoomWidth;
		m_minRoomHeight = minRoomHeight;
	}

	Image generateImage()
	{
		auto image = new Image();
		if(!image.create(m_noiseWidth, m_noiseHeight, Color.Black))
		{
			return null;
		}

		bsp(image, true, true);
	}

	//This method recursively generates a game map through binary space partitioning.
	void bsp(Image image, UIntRect bounds, bool placeStart, bool placeEnd)
	{
		bool smallWidth = bounds.width/2 < minRoomWidth;
		bool smallHeight = bounds.height/2 < minRoomHeight;
		if(smallWidth && smallHeight)
		{
			//Just finish here and make a room
		}
		else if(smallWidth && !smallHeight)
		{
			//Split the room height-ways
		}
		else if(!smallWidth && smallHeight)
		{
			//Split room width-ways
		}
		else
		{
			//Split room in a random orientation.
			ubyte splitDir = uniform(0, 2);
			if(splitDir == 1)
			{
				//Split height-ways
			}
			else
			{
				//Split width-ways
			}
		}
	}

	//This method makes a pathway across a split in the tree.
	void connectRooms()
	{

	}

}