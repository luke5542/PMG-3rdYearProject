module ridgway.pmgcrawler.mapconfig;

import std.string;
import std.stdio;
import std.json;
import std.file;

MapGenConfig loadConfig(in string file)
{
	string jsonContents = chomp(readText(file));

	JSONValue configJSON = parseJSON(jsonContents);

	auto config = new MapGenConfig();
	auto perlin = configJSON["perlin"];
	if(perlin.type == JSON_TYPE.OBJECT)
	{
		if(perlin["size"].type == JSON_TYPE.INTEGER)
		{
			config.pConfig.size = cast(int) perlin["size"].integer;
		}
		if(perlin["threed"].type == JSON_TYPE.TRUE || perlin["threed"].type == JSON_TYPE.FALSE)
		{
			config.pConfig.isThreeD = perlin["threed"].type == JSON_TYPE.TRUE;
		}
		if(perlin["thresh"].type == JSON_TYPE.TRUE || perlin["thresh"].type == JSON_TYPE.FALSE)
		{
			config.pConfig.threshold = perlin["thresh"].type == JSON_TYPE.TRUE;
		}
		if(perlin["smooth"].type == JSON_TYPE.TRUE || perlin["smooth"].type == JSON_TYPE.FALSE)
		{
			config.pConfig.smooth = perlin["smooth"].type == JSON_TYPE.TRUE;
		}
	}

	auto bsp = configJSON["bsp"];
	if(bsp.type == JSON_TYPE.OBJECT)
	{
		if(bsp["size"].type == JSON_TYPE.INTEGER)
		{
			config.bspConfig.size = cast(int) bsp["size"].integer;
		}
		if(bsp["min-room-height"].type == JSON_TYPE.INTEGER)
		{
			config.bspConfig.minRoomHeight = cast(int) bsp["min-room-height"].integer;
		}
		if(bsp["min-room-width"].type == JSON_TYPE.INTEGER)
		{
			config.bspConfig.minRoomWidth = cast(int) bsp["min-room-width"].integer;
		}
	}

	return config;
}

class MapGenConfig
{
	private struct PerlinConfig
	{
		int size = 128;
		bool isThreeD = false;
		bool threshold = true;
		bool smooth = true;
	}

	PerlinConfig pConfig;

	private struct BSPConfig
	{
		int size = 128;
		int minRoomHeight = 7;
		int minRoomWidth = 7;
	}

	BSPConfig bspConfig;
}