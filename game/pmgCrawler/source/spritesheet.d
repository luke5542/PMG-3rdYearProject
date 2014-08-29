module ridgway.pmgcrawler.spritesheet;

import std.file;
import std.json;

import dsfml.graphics;

class SpriteSheet
{
	private
	{
		Texture m_sheet;
		IntRect[] m_spriteRects;
	}

	this()
	{
		m_sheet = new Texture();
	}

	/// This assumes that the file name of the meta-data
	/// file and the image both have the same base name.
	/// This also assumes that the files have the extensions
	/// '.png' for the image and '.json' for the meta data
	bool loadFromFile(in string file)
	{
		return loadFromFile(file ~ ".png", file ~ ".json");
	}

	bool loadFromFile(in string imageFile, in string metaDataFile)
	{
		//Load the files...
		if (!m_sheet.loadFromFile(tileset) || !exists(metaDataFile))
            return false;

        string metaData = chomp(readText(metaDataFile));
        JSONValue metaJson = parseJSON(metaData);
        debug writeln("Parsing JSON: " ~ metaJson);
	}

	Texture getTexture()
	{
		return m_sheet;
	}

	IntRect getSpriteRect(const(uint) sprite)
	{
		return m_spriteRects[sprite];
	}
}

unittest
{
	SpriteSheet sheet = new SpriteSheet();
	sheet.loadFromFile("testSpriteSheet");
}