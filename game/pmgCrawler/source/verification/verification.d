module ridgway.pmgcrawler.verification.verification;

import std.stdio;
import std.file;
import std.json;
import std.string;
import std.algorithm;

import dsfml.graphics;

import ridgway.pmgcrawler.verification.dijkstras;
import ridgway.pmgcrawler.verification.bots;
import ridgway.pmgcrawler.mapconfig;
import ridgway.pmgcrawler.map;

struct TestResults
{
    string name;

    float percentageReachableTiles = 0;
    int numWalkableTiles = -1;
    int numNonWalkableTiles = -1;
    int furthestTileDistance = -1;
    int exitTileDistance = -1;
    bool ranDijkstras = false;

    //This is used for the ranking and classificaiton
    uint order;

    struct BotResults
    {
        int numTilesSeen;
        int numMoves;
        int numGoals; // Lower Move:Goal ratio is better.
    }

    BotResults botResults;

    JSONValue toJSON()
    {
        JSONValue[string] vals;
        vals["name"] = JSONValue().str(name);

        JSONValue[string] dijkstras;
        dijkstras["percentReachable"] = JSONValue().floating(percentageReachableTiles);
        dijkstras["walkable"] = JSONValue().integer(numWalkableTiles);
        dijkstras["nonwalkable"] = JSONValue().integer(numNonWalkableTiles);
        dijkstras["furthestDistance"] = JSONValue().integer(furthestTileDistance);
        dijkstras["exitDistance"] = JSONValue().integer(exitTileDistance);
        vals["dijkstras"] = JSONValue(dijkstras);

        JSONValue[string] bots;
        bots["tilesSeen"] = JSONValue().integer(botResults.numTilesSeen);
        bots["movesMade"] = JSONValue().integer(botResults.numMoves);
        bots["goalsChosen"] = JSONValue().integer(botResults.numGoals);
        vals["bots"] = JSONValue(bots);

        vals["order"] = order;

        return JSONValue(vals);
    }

    string toString()
    {
        return toJSON().toPrettyString();
    }
}

void printResults(TestResults[] results, File file)
{
    JSONValue[] vals;
    foreach(item; results)
    {
        vals ~= item.toJSON();
    }

    auto jsonVal = JSONValue(vals);

    file.writeln(jsonVal.toPrettyString());
}

TestResults[] loadResults(in string file)
{
    TestResults[] results;
    string fileContents = readText(file);
    //Get rid of the first 3 lines...
    fileContents = find(fileContents, '\n')[1..$];
    fileContents = find(fileContents, '\n')[1..$];
    fileContents = find(fileContents, '\n')[1..$];

    string jsonContents = chomp(fileContents);

    JSONValue resultsJSON = parseJSON(jsonContents);

    if(resultsJSON.type == JSON_TYPE.ARRAY)
    {
        foreach(val; resultsJSON.array)
        {
            auto resultItem = TestResults();
            if("dijkstras" in val)
            {
                auto dijkstras = val["dijkstras"];
                if(dijkstras.type == JSON_TYPE.OBJECT)
                {
                    if("percentReachable" in dijkstras && dijkstras["percentReachable"].type == JSON_TYPE.FLOAT)
                    {
                        resultItem.percentageReachableTiles = cast(float) dijkstras["percentReachable"].floating;
                    }
                    if("walkable" in dijkstras && dijkstras["walkable"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.numWalkableTiles = cast(int) dijkstras["walkable"].integer;
                    }
                    if("nonwalkable" in dijkstras && dijkstras["nonwalkable"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.numNonWalkableTiles = cast(int) dijkstras["nonwalkable"].integer;
                    }
                    if("furthestDistance" in dijkstras && dijkstras["furthestDistance"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.furthestTileDistance = cast(int) dijkstras["furthestDistance"].integer;
                    }
                    if("exitDistance" in dijkstras && dijkstras["exitDistance"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.exitTileDistance = cast(int) dijkstras["exitDistance"].integer;
                    }
                }

                auto bots = val["bots"];
                if(bots.type == JSON_TYPE.OBJECT)
                {
                    if("tilesSeen" in bots && bots["tilesSeen"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.botResults.numTilesSeen = cast(int) bots["tilesSeen"].integer;
                    }
                    if("movesMade" in bots && bots["movesMade"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.botResults.numMoves = cast(int) bots["movesMade"].integer;
                    }
                    if("goalsChosen" in bots && bots["goalsChosen"].type == JSON_TYPE.INTEGER)
                    {
                        resultItem.botResults.numGoals = cast(int) bots["goalsChosen"].integer;
                    }
                }

                if("order" in val && val["order"].type == JSON_TYPE.INTEGER)
                {
                    resultItem.order = cast(int) val["order"].integer;
                }
            }
            results ~= resultItem;
        }
    }

    return results;
}

TestResults runVerification(MapGenConfig config, string imageStr)
{
    Image image = new Image();
    if(!image.loadFromFile(imageStr))
    {
        debug writeln("Invalid image file");
        return TestResults();
    }

    return runVerification(config, image);
}

TestResults runVerification(MapGenConfig config, Image image)
{
    TileMap map = new TileMap();
    map.minimalLoadFromImage(image);
    auto results = TestResults();

    if(!map.hasPlayerStart || !map.hasPlayerEnd)
    {
        //Map is invalid...
        debug writeln("Map is missing one of start/end");
        return results;
    }

    if(config.vConfig.dijkstras)
    {
        auto dijkstras = new DijkstrasVerifier(map);
        dijkstras.run(results);
    }

    if(config.vConfig.useBots && results.exitTileDistance > 0)
    {
        results.botResults = testBot(map, config);
    }

    return results;
}
