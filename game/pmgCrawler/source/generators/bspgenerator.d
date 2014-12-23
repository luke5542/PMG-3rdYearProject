module ridgway.pmgcrawler.generators.bspgenerator;

import std.stdio;
import std.random;
import std.math;

import dsfml.graphics;

import ridgway.pmgcrawler.generators.generator;

enum SplitDirection { VERTICAL, HORIZONTAL }

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

		bsp(image, UIntRect(0, 0, image.getSize.x, image.getSize.y), true, true);

		return image;
	}

	//This method recursively generates a game map through binary space partitioning.
	void bsp(Image image, UIntRect bounds, bool placeStart, bool placeEnd)
	{
		bool smallWidth = (bounds.width/2 - 4) < m_minRoomWidth;
		bool smallHeight = (bounds.height/2 - 4) < m_minRoomHeight;
		if(smallWidth && smallHeight)
		{
			//Just finish here and make a room
		}
		else if(smallWidth && !smallHeight)
		{
			//Split the room height-ways
			splitHeight(image, bounds, placeStart, placeEnd);
		}
		else if(!smallWidth && smallHeight)
		{
			//Split room width-ways
			splitWidth(image, bounds, placeStart, placeEnd);
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

	void splitHeight(Image image, UIntRect bounds, bool placeStart, bool placeEnd)
	{
		uint maxOffset = bounds.height - m_minRoomHeight*2 - 4;
		uint randOffset = uniform(0, maxOffset);
		uint height = m_minRoomHeight + randOffset;

		UIntRect topRect = UIntRect(bounds.left, bounds.top,
									bounds.width, height);
		bsp(image, topRect, placeStart, false);

		UIntRect bottomRect = UIntRect(bounds.left, bounds.top + height,
									bounds.width, bounds.height - height);
		bsp(image, bottomRect, false, placeEnd);

		connectRooms(image, SplitDirection.VERTICAL, topRect, bottomRect);
	}

	void splitWidth(Image image, UIntRect bounds, bool placeStart, bool placeEnd)
	{
		uint maxOffset = bounds.width - m_minRoomWidth*2 - 4;
		uint randOffset = uniform(0, maxOffset);
		uint width = m_minRoomHeight + randOffset;

		UIntRect leftRect = UIntRect(bounds.left, bounds.top,
									width, bounds.height);
		bsp(image, leftRect, placeStart, false);

		UIntRect rightRect = UIntRect(bounds.left + width, bounds.top,
									bounds.width - width, bounds.height);
		bsp(image, rightRect, false, placeEnd);

		connectRooms(image, SplitDirection.HORIZONTAL, leftRect, rightRect);
	}

	//This method makes a pathway across a split in the tree.
	void connectRooms(Image image, SplitDirection dir, UIntRect sideOne, UIntRect sideTwo)
	{
		final switch(dir)
		{
			case SplitDirection.VERTICAL:
				break;
			case SplitDirection.HORIZONTAL:
				break;
		}
	}

}