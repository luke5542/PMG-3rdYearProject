module ridgway.pmgcrawler.mapconfig;

import std.string;
import std.stdio;
import std.json;
import std.file;
import std.conv;

MapGenConfig loadConfig(in string file)
{
    string jsonContents = chomp(readText(file));

    JSONValue configJSON = parseJSON(jsonContents);

    auto config = MapGenConfig();
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
            if("room-gap" in bsp && bsp["room-gap"].type == JSON_TYPE.INTEGER)
            {
                config.bspConfig.roomGap = cast(int) bsp["room-gap"].integer;
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
            if("useBots" in verif && verif["useBots"].type == JSON_TYPE.TRUE || verif["useBots"].type == JSON_TYPE.FALSE)
            {
                config.vConfig.useBots = verif["useBots"].type == JSON_TYPE.TRUE;
            }
            if("botType" in verif && verif["botType"].type == JSON_TYPE.STRING)
            {
                config.vConfig.bot = to!BotType(verif["botType"].str);
            }
            if("classifier" in verif && verif["classifier"].type == JSON_TYPE.STRING)
            {
                config.vConfig.classifierFile = verif["classifier"].str;
                if("model" in verif && verif["model"].type == JSON_TYPE.STRING)
                {
                    config.vConfig.modelFile = verif["model"].str;
                    config.vConfig.classify = true;
                }
            }
        }
    }

    return config;
}

enum BotType { Random, SpeedRunner, Moron, Search }

struct MapGenConfig
{
    private struct PerlinConfig
    {
        int size = 128;
        uint threshold = 120;
        bool isThreeD = false;
        bool smooth = true;
    }

    PerlinConfig pConfig;

    private struct BSPConfig
    {
        int size = 128;
        int minRoomHeight = 7;
        int minRoomWidth = 7;
        float minAreaRatio = 1.0;
        int roomGap = 1;
    }

    BSPConfig bspConfig;

    private struct VerificationConfig
    {
        BotType bot = BotType.Search;
        bool useBots = false;
        bool dijkstras = true;
        bool classify = false;
        string classifierFile;
        string modelFile;
    }

    VerificationConfig vConfig;
}
