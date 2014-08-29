module ridgway.pmgcrawler.spritesheet;

import std.file;
import std.stdio;
import std.string;
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

	/// This takes the name of the meta data input file and 
	/// grabs the image file's name from the meta data.
	bool loadFromFile(in string metaDataFile)
	{
		//Load the files...
		if (!m_sheet.loadFromFile(imageFile) || !exists(metaDataFile))
            return false;

        string metaData = chomp(readText(metaDataFile));
        JSONValue metaJson = parseJSON(metaData);
        debug writeln("Parsing JSON: " ~ metaJson.toString());

        auto spriteFrames = metaJson["frames"];
        for(val; spriteFrames)
        {
        	
        }

        return true;
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
	sheet.loadFromFile("tiles_spritesheet");
}