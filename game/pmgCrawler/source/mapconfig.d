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
	if("perlin" in configJSON)
	{
		auto perlin = configJSON["perlin"];
		if(perlin.type == JSON_TYPE.OBJECT)
		{
			if("size" in perlin && perlin["size"].type == JSON_TYPE.INTEGER)
			{
				config.pConfig.size = cast(int) perlin["size"].integer;
			}
			if("threed" in perlin && perlin["threed"].type == JSON_TYPE.TRUE || perlin["threed"].type == JSON_TYPE.FALSE)
			{
				config.pConfig.isThreeD = perlin["threed"].type == JSON_TYPE.TRUE;
			}
			if("thresh" in perlin && perlin["thresh"].type == JSON_TYPE.INTEGER)
			{
				config.pConfig.threshold = cast(uint) perlin["thresh"].integer;
			}
			if("smooth" in perlin && perlin["smooth"].type == JSON_TYPE.TRUE || perlin["smooth"].type == JSON_TYPE.FALSE)
			{
				config.pConfig.smooth = perlin["smooth"].type == JSON_TYPE.TRUE;
			}
		}
	}

	if("bsp" in configJSON)
	{
		auto bsp = configJSON["bsp"];
		if(bsp.type == JSON_TYPE.OBJECT)
		{
			if("size" in bsp && bsp["size"].type == JSON_TYPE.INTEGER)
			{
				config.bspConfig.size = cast(int) bsp["size"].integer;
			}
			if("min-room-height" in bsp && bsp["min-room-height"].type == JSON_TYPE.INTEGER)
			{
				config.bspConfig.minRoomHeight = cast(int) bsp["min-room-height"].integer;
			}
			if("min-room-width" in bsp && bsp["min-room-width"].type == JSON_TYPE.INTEGER)
			{
				config.bspConfig.minRoomWidth = cast(int) bsp["min-room-width"].integer;
			}
			if("min-area-ratio" in bsp && bsp["min-area-ratio"].type == JSON_TYPE.FLOAT)
			{
				config.bspConfig.minAreaRatio = bsp["min-area-ratio"].floating;
			}
		}
	}

	if("verification" in configJSON)
	{
		auto verif = configJSON["verification"];
		if(verif.type == JSON_TYPE.OBJECT)
		{
			if("dijkstras" in verif && verif["dijkstras"].type == JSON_TYPE.TRUE || verif["dijkstras"].type == JSON_TYPE.FALSE)
			{
				config.vConfig.dijkstras = verif["dijkstras"].type == JSON_TYPE.TRUE;
			}
			if("randomBot" in verif && verif["randomBot"].type == JSON_TYPE.TRUE || verif["randomBot"].type == JSON_TYPE.FALSE)
			{
				config.vConfig.randomBot = verif["randomBot"].type == JSON_TYPE.TRUE;
			}
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
		uint threshold = 120;
		bool smooth = true;
	}

	PerlinConfig pConfig;

	private struct BSPConfig
	{
		int size = 128;
		int minRoomHeight = 7;
		int minRoomWidth = 7;
		float minAreaRatio = 1.0;
	}

	BSPConfig bspConfig;

	private struct VerificationConfig
	{
		bool dijkstras = true;
		bool randomBot = false;
	}

	VerificationConfig vConfig;
}