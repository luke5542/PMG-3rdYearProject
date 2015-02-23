module ridgway.pmgcrawler.verification.svm.trainer;

import std.stdio;
import std.process;
import std.file;
import std.algorithm;
import std.conv;
import std.math;
import std.string;

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
        version(Windows)
        {
            string command = getcwd() ~ "/" ~ config.vConfig.classifierFile ~ ".exe" ~ " "
                             ~ getcwd() ~ "/" ~ dataFile ~ " "
                             ~ getcwd() ~ "/" ~ config.vConfig.modelFile ~ " "
                             ~ getcwd() ~ "/" ~ outputDir ~ "classifyResults";
        }
        else
        {
            string command = getcwd() ~ "/" ~ config.vConfig.classifierFile ~ " "
                             ~ getcwd() ~ "/" ~ dataFile ~ " "
                             ~ getcwd() ~ "/" ~ config.vConfig.modelFile ~ " "
                             ~ getcwd() ~ "/" ~ outputDir ~ "classifyResults";
        }
        debug writeln("Running command: ", command);
        auto classify = executeShell(command);

        if(classify.status != 0)
        {
            writeln("Error with classification:");
            writeln(classify.output);
        }
    }
}

void parseClassificationResults(string outputDir, TestResults[] results)
{
    string fileName = getcwd() ~ "/" ~ outputDir ~ "classifyResults";

    string contents = readText(fileName);
    int i = 0;
    auto split = splitter(contents, "\n");
    foreach(line; split)
    {
        if(line.length > 0)
        {
            results[i].order = cast(int) round(to!float(chomp(line)));
            i++;
        }
    }
}
