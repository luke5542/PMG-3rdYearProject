module ridgway.pmgcrawler.spritesheet;

import std.file;
import std.stdio;
import std.string;
import std.json;
import std.path;

import dsfml.graphics;

class SpriteSheet
{
	private
	{
		Texture m_sheet;
		IntRect[string] m_spriteFrames;
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
        debug writeln("Parsing JSON: ", metaJson);

        auto spriteFrames = metaJson["frames"].array;
        foreach(val; spriteFrames)
        {
        	string name = val["filename"].str;
        	JSONValue rectJson = val["frame"];
        	IntRect rect = IntRect( cast(int) rectJson["x"].integer, cast(int) rectJson["y"].integer,
        						    cast(int) rectJson["w"].integer, cast(int) rectJson["h"].integer);

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

	const(Texture) getTexture()
	{
		return m_sheet;
	}

	const(IntRect) getSpriteRect(const(string) spriteName)
	{
		return m_spriteFrames[spriteName];
	}
}

struct SpriteFrameList
{
	private
	{
		SpriteFrame[] m_frames;
		ulong m_duration;
	}

	bool loadFromFile(in string frameFile)
	{
		//Load the files...
		if (!exists(frameFile))
		{
        	debug writeln("SpriteFrameSet data file, ", frameFile, ", doesn't exist.");
            return false;
		}

        string metaData = chomp(readText(frameFile));
        JSONValue metaJson = parseJSON(metaData);
        debug writeln("Parsing JSON: ", metaJson);

        auto spriteFrames = metaJson["frames"].array;
        foreach(val; spriteFrames)
        {
        	string name = val["spritename"].str;

        	// This is the duration of the frame in milliseconds.
        	long duration = val["duration"].integer;
        	m_duration += duration;

        	m_frames ~= SpriteFrame(name, duration);
        }

        return true;
	}

	const(string) getFrame(in ulong progress)
	{
		ulong progressSum = 0;
		foreach(frame; m_frames)
		{
			if((progress - progressSum) <= frame.duration)
			{
				return frame.spritename;
			}
			progressSum += frame.duration;
		}

		return null;
	}

	const(ulong) getDuration()
	{
		return m_duration;
	}
}

private struct SpriteFrame
{
	public
	{
		const(string) spritename;
		const(ulong) duration;
	}

	this(string name, ulong dur)
	{
		spritename = name;
		duration = dur;
	}
}