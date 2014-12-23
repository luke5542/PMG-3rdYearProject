module ridgway.pmgcrawler.generators.bspgenerator;

import std.stdio;
import std.random;
import std.math;

import dsfml.graphics;

import ridgway.pmgcrawler.generateImage.perlingenerator;

void generateBSP(string outputFile, int size)
{
	writeln("Map size:", size);
	writeln("Save file: ", outputFile);

	Image image;

	BSPGenerator bGen = new BSPGenerator(size, size, threshold, smoothEdges);
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