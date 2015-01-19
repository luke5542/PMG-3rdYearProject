module ridgway.pmgcrawler.verification.verification;

import std.stdio;
import std.file;

import dsfml.graphics;

import ridgway.pmgcrawler.verification.dijkstras;
import ridgway.pmgcrawler.mapconfig;
import ridgway.pmgcrawler.map;

struct TestResults
{
    bool ranDijkstras = false;
    float percentageReachableTiles = 0;
    int numWalkableTiles = -1;
    int numNonWalkableTiles = -1;
    int furthestTileDistance = -1;
    int exitTileDistance = -1;
}

void printResults(TestResults results, File file)
{
    if(results.ranDijkstras)
    {
        file.writeln("\tDijkstras:");
        file.writeln("\t\t", results.percentageReachableTiles, "% reachable tiles");
        file.writeln("\t\t", results.numWalkableTiles, " walkable tiles");
        file.writeln("\t\t", results.numNonWalkableTiles, " nonwalkable tiles");
        file.writeln("\t\t", results.furthestTileDistance, " to furthest tile");
        file.writeln("\t\t", results.exitTileDistance, " to exit tile");
    }
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

    return results;
}
