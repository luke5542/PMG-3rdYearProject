module ridgway.pmgcrawler.spritesheet;

import std.file;
import std.stdio;
import std.string;
import std.json;
import std.path;

import dsfml.graphics;

alias Rect!(long) LongRect;

class SpriteSheet
{
	private
	{
		Texture m_sheet;
		LongRect[string] m_spriteFrames;
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
		if (!exists(metaDataFile))
		{
        	debug writeln("spritesheet meta data file, ", metaDataFile, ", doesn't exist.");
            return false;
		}

		string metaDataDirectory = dirName(metaDataFile);

        string metaData = chomp(readText(metaDataFile));
        JSONValue metaJson = parseJSON(metaData);
        debug writeln("Parsing JSON: ", metaJson.toString());

        auto spriteFrames = metaJson["frames"].array;
        foreach(val; spriteFrames)
        {
        	string name = val["filename"].str;
        	JSONValue rectJson = val["frame"];
        	LongRect rect = LongRect( rectJson["x"].integer, rectJson["y"].integer,
        						    rectJson["w"].integer, rectJson["h"].integer);

        	m_spriteFrames[name] = rect;
        }

        string imageFile = metaDataDirectory ~ "/" ~ metaJson["meta"]["image"].str;
        debug writeln("Loading image file from: ", imageFile);

        if (!m_sheet.loadFromFile(imageFile))
        {
        	debug writeln("Image, ", imageFile, ", not loaded into texture.");
        	return false;
        }

        return true;
	}

	Texture getTexture()
	{
		return m_sheet;
	}

	LongRect getSpriteRect(const(string) spriteName)
	{
		return m_spriteFrames[spriteName];
	}
}

unittest
{
	writeln("Testing SpriteSheets");

	SpriteSheet sheet = new SpriteSheet();
	assert(sheet.loadFromFile("assets/tiles_spritesheet.json"));
	assert(sheet.getSpriteRect("ground-empty.png") == LongRect(2, 2, 32, 32));

	writeln("Sprite Sheet tests passed.");
	writeln();
}