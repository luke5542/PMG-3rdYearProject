module ridgway.pmgcrawler.generators.perlingenerator;

import std.stdio;
import std.random;
import std.math;

import dsfml.graphics;

void generatePerlin(string outputFile, int size, bool threshold)
{
	writeln("Map size:", size);
	writeln("Save file: ", outputFile);

	PerlinGenerator_3D pGen = new PerlinGenerator_3D(size, size, size, threshold);
	//PerlinGenerator pGen = new PerlinGenerator(size, size, threshold);
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
		bool m_threshold;

		double[] noise;
	}

	this(int width, int height, bool thresh)
	{
		m_noiseWidth = width;
		m_noiseHeight = height;
		m_threshold = thresh;
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

		double xPeriod = 5;
		double yPeriod = 10;

		double turbPower = 5;
		double turbSize = 8;

		/*double turbulence = x * xPeriod / m_noiseWidth
							+ y * yPeriod / m_noiseHeight
							+ turbPower * getTurbulence(x, y, turbSize) / 256;

		turbulence = 256 * abs(sin(turbulence * 3.14159265));*/
		double turbulence = getTurbulence(x, y, turbSize);
		if(m_threshold)
		{
			if(turbulence > (.40 * 255))
			{
				turbulence = 255;
			}
			else
			{
				turbulence = 0;
			}
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

class PerlinGenerator_3D
{
	private
	{
		int m_noiseWidth;
		int m_noiseHeight;
		int m_noiseDepth;
		bool m_threshold;

		double[] noise;
	}

	this(int width, int height, int depth, bool thresh)
	{
		m_noiseWidth = width;
		m_noiseHeight = height;
		m_noiseDepth = depth;
		m_threshold = thresh;
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
				//foreach(k; 0..m_noiseDepth)
				//{
					image.setPixel(i, j, getPixelColor(i, m_noiseDepth/2, j));
				//}
			}
		}

		return image;
	}

private:

	void generateNoise()
	{
		noise = new double[m_noiseWidth * m_noiseHeight * m_noiseDepth];

		foreach(w; 0..m_noiseWidth)
		{
			foreach(h; 0..m_noiseHeight)
			{
				foreach(d; 0..m_noiseDepth)
				{
					noise[w * m_noiseWidth + h * m_noiseHeight + d] = uniform(0.0, 1.0);
				}
			}
		}
	}

	Color getPixelColor(double x, double y, double z)
	{

		double turbulence = getTurbulence(x, y, z, 32);
		if(m_threshold)
		{
			if(turbulence > (.5 * 255))
			{
				turbulence = 255;
			}
			else
			{
				turbulence = 0;
			}
		}
		ubyte value = cast(ubyte) (turbulence);

		return Color(value, value, value, 255);
	}

	double getNoiseValue(double x, double y, double z)
	{
		double fracX = x - cast(int)(x);
		double fracY = y - cast(int)(y);
		double fracZ = z - cast(int)(z);

		int x1 = (cast(int)(x) + m_noiseWidth) % m_noiseWidth;
		int y1 = (cast(int)(y) + m_noiseHeight) % m_noiseHeight;
		int z1 = (cast(int)(z) + m_noiseDepth) % m_noiseDepth;

		int x2 = (x1 + m_noiseWidth - 1) % m_noiseWidth;
		int y2 = (y1 + m_noiseHeight - 1) % m_noiseHeight;
		int z2 = (z1 + m_noiseDepth - 1) % m_noiseDepth;

		//Bilinear interpolation
		double value = 0.0;
		value += fracX       * fracY       * fracZ * noise[(x1 * m_noiseWidth) + (y1 * m_noiseHeight) + z1];
		value += fracX       * (1 - fracY) * fracZ * noise[(x1 * m_noiseWidth) + (y2 * m_noiseHeight) + z1];
		value += (1 - fracX) * fracY       * fracZ * noise[(x2 * m_noiseWidth) + (y1 * m_noiseHeight) + z1];
		value += (1 - fracX) * (1 - fracY) * fracZ * noise[(x2 * m_noiseWidth) + (y2 * m_noiseHeight) + z1];

		value += fracX       * fracY       * (1 - fracZ) * noise[(x1 * m_noiseWidth) + (y1 * m_noiseHeight) + z2];
		value += fracX       * (1 - fracY) * (1 - fracZ) * noise[(x1 * m_noiseWidth) + (y2 * m_noiseHeight) + z2];
		value += (1 - fracX) * fracY       * (1 - fracZ) * noise[(x2 * m_noiseWidth) + (y1 * m_noiseHeight) + z2];
		value += (1 - fracX) * (1 - fracY) * (1 - fracZ) * noise[(x2 * m_noiseWidth) + (y2 * m_noiseHeight) + z2];

		return value;
	}

	double getTurbulence(double x, double y, double z, double size)
	{
		double val = 0.0;
		double initSize = size;

		while(size >= 1)
		{
			val += getNoiseValue(x / size, y / size, z / size) * size;
			size /= 2.0;
		}

		return 128 * val / initSize;
	}

}