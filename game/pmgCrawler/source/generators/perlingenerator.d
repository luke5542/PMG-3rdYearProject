module ridgway.pmgcrawler.generators.perlingenerator;

import std.stdio;
import std.random;
import dsfml.graphics;

void generatePerlin(string outputFile, int size)
{
	writeln("Map size:", size);
	writeln("Save file: ", outputFile);

	PerlinGenerator pGen = new PerlinGenerator(size, size);
	Image image = pGen.generateImage();
	if(image)
	{
		image.saveToFile(outputFile);
	}
	else
	{
		writeln("Failed to generate an image.");
	}
}

class PerlinGenerator
{
	private
	{
		int m_noiseWidth;
		int m_noiseHeight;

		double[] noise;
	}

	this(int width, int height)
	{
		m_noiseWidth = width;
		m_noiseHeight = height;
	}

	Image generateImage()
	{
		generateNoise();

		Image image = new Image();
		if(!image.create(m_noiseWidth, m_noiseHeight, Color.Black))
		{
			return null;
		}

		foreach(i; 0..m_noiseWidth)
		{
			foreach(j; 0..m_noiseHeight)
			{
				image.setPixel(i, j, getPixelColor(i, j));
			}
		}

		return image;
	}

private:

	void generateNoise()
	{
		noise = new double[m_noiseWidth * m_noiseHeight];

		foreach(w; 0..m_noiseWidth)
		{
			foreach(h; 0..m_noiseHeight)
			{
				noise[w * m_noiseWidth + h] = uniform(0.0, 1.0);
			}
		}
	}

	Color getPixelColor(double x, double y)
	{

		double turbulence = getTurbulence(x, y, 32);
		if(turbulence > (.5 * 255))
		{
			turbulence = 255;
		}
		else
		{
			turbulence = 0;
		}
		ubyte value = cast(ubyte) (turbulence);

		return Color(value, value, value, 255);
	}

	double getNoiseValue(double x, double y)
	{
		double fracX = x - cast(int)(x);
		double fracY = y - cast(int)(y);

		int x1 = (cast(int)(x) + m_noiseWidth) % m_noiseWidth;
		int y1 = (cast(int)(y) + m_noiseHeight) % m_noiseHeight;

		int x2 = (cast(int)(x) + m_noiseWidth - 1) % m_noiseWidth;
		int y2 = (cast(int)(y) + m_noiseHeight - 1) % m_noiseHeight;

		//Bilinear interpolation
		double value = 0.0;
		value += fracX * fracY * noise[x1 * m_noiseWidth + y1];
		value += fracX * (1 - fracY) * noise[x1 * m_noiseWidth + y2];
		value += (1 - fracX) * fracY * noise[x2 * m_noiseWidth + y1];
		value += (1 - fracX) * (1 - fracY) * noise[x2 * m_noiseWidth + y2];

		return value;
	}

	double getTurbulence(double x, double y, double size)
	{
		double val = 0.0;
		double initSize = size;

		while(size >= 1)
		{
			val += getNoiseValue(x / size, y / size) * size;
			size /= 2.0;
		}

		return 128 * val / initSize;
	}

}