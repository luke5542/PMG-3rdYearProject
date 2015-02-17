module ridgway.pmgcrawler.verification.svm.trainer;

import std.stdio;
import std.process;
import std.file;

import ridgway.pmgcrawler.verification.verification;
import ridgway.pmgcrawler.mapconfig;

immutable BSP = 1;
immutable PERLIN = 2;

void saveDataFile(in string fileLoc, TestResults[] data)
{
    auto resultsFile = File(fileLoc, "w");
    foreach(item; data)
    {
        resultsFile.writeln(item.order, " ",
                            "qid:", 1, " ",
                            "1:", item.percentageReachableTiles, " ",
                            "2:", item.numWalkableTiles, " ",
                            "3:", item.numNonWalkableTiles, " ",
                            "4:", item.furthestTileDistance, " ",
                            "5:", item.exitTileDistance, " ",
                            "6:", item.botResults.numTilesSeen, " ",
                            "7:", item.botResults.numMoves, " ",
                            "8:", item.botResults.numGoals);
    }
}

void classifyData(MapGenConfig config, string dataFile, string outputDir)
{
    if(config.vConfig.classify)
    {
        string command = getcwd() ~"/"~ config.vConfig.classifierFile ~ " "
                         ~ getcwd() ~"/"~ dataFile ~ " "
                         ~ getcwd() ~"/"~ config.vConfig.modelFile ~ " "
                         ~ getcwd() ~"/"~ outputDir ~ "classifyResults";
        //writeln("Running command: ", command);
        auto classify = executeShell(command);

        if(classify.status != 0)
        {
            writeln("Error with classification:");
            writeln(classify.output);
        }
    }
}
