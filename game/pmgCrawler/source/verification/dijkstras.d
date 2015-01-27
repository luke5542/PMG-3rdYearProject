module ridgway.pmgcrawler.verification.dijkstras;

import std.container;
import std.typecons;
import std.conv;
import std.stdio;
import std.algorithm;

import dsfml.graphics;

import ridgway.pmgcrawler.verification.verification;
import ridgway.pmgcrawler.map;

class DijkstraNode
{
    DijkstraNode m_parent;
    int m_distance;
    bool m_visited;
    bool m_isWalkable;
    Vector2u m_location;

    this(Vector2u location, bool isWalkable)
    {
        m_location = location;
        m_isWalkable = isWalkable;
        m_distance = int.max;
        m_visited = false;
    }

    override bool opEquals(Object other)
    {
        return (cast(DijkstraNode) other) && m_location == (cast(DijkstraNode) other).m_location;
    }

    override int opCmp(Object other)
    {
        auto otherDN = cast(DijkstraNode) other;
        return m_distance - otherDN.m_distance;
    }

    override string toString()
    {
        return "Distance - " ~ to!string(m_distance)
            ~ ", Visited - " ~ to!string(m_visited)
            ~ ", Location - " ~ to!string(m_location);
    }
}

class DijkstrasVerifier
{
    private
    {
        int m_numWalkable;
        int m_numReachable;
        int m_score;

        TileMap m_mapToTest;
        DijkstraNode[][] nodes;
    }

    this(TileMap map)
    {
        m_mapToTest = map;
        buildGraph(nodes);
    }

    //Returns whether or not the map is playable,
    //while calculating the various statistics.
    void run(ref TestResults results)
    {
        DijkstraNode[] unvisitedNodes;

        auto root = nodes[m_mapToTest.getPlayerStart().x][m_mapToTest.getPlayerStart().y];
        root.m_distance = 0;
        unvisitedNodes ~= root;

        while(unvisitedNodes.length > 0)
        {
            auto currentNode = unvisitedNodes[$-1];
            currentNode.m_visited = true;
            unvisitedNodes = unvisitedNodes[0 .. $-1];

            int distance = currentNode.m_distance + 1;
            auto neighbors = getNeighbors(nodes, currentNode.m_location.x, currentNode.m_location.y);
            foreach(node; neighbors)
            {
                if(node.m_isWalkable)
                {
                    if(node.m_distance > distance)
                    {
                        node.m_distance = distance;
                        node.m_parent = currentNode;
                    }

                    if(!node.m_visited)
                    {
                        unvisitedNodes ~= node;
                    }
                }
            }
            unvisitedNodes.sort;
        }

        debug writeln("End Node Visited: ", nodes[m_mapToTest.getPlayerEnd.x][m_mapToTest.getPlayerEnd.y]);

        results.ranDijkstras = true;

        auto end = m_mapToTest.getPlayerEnd;
        results.exitTileDistance = nodes[end.x][end.y].m_visited ? nodes[end.x][end.y].m_distance : -1;

        countTiles(nodes, results);
    }

    DijkstraNode[] getNeighbors(DijkstraNode[][] nodes, int x, int y)
    {
        DijkstraNode[] neighbors;
        auto size = m_mapToTest.getSize();
        if(x + 1 < size.x && !nodes[x + 1][y].m_visited)
        {
            neighbors ~= nodes[x + 1][y];
        }
        if(y + 1 < size.y && !nodes[x][y + 1].m_visited)
        {
            neighbors ~= nodes[x][y + 1];
        }
        if(x > 0 && !nodes[x - 1][y].m_visited)
        {
            neighbors ~= nodes[x - 1][y];
        }
        if(y > 0 && !nodes[x][y - 1].m_visited)
        {
            neighbors ~= nodes[x][y - 1];
        }

        return neighbors;
    }

    void countTiles(ref DijkstraNode[][] nodes, ref TestResults results)
    {
        int numReachableTiles = 0;

        results.percentageReachableTiles = 0;
        results.numWalkableTiles = 0;
        results.numNonWalkableTiles = 0;
        results.furthestTileDistance = 0;

        foreach(x; 0 .. nodes.length)
        {
            foreach(y; 0 .. nodes[x].length)
            {
                if(nodes[x][y].m_isWalkable)
                {
                    results.numWalkableTiles++;

                    if(nodes[x][y].m_visited)
                    {
                        numReachableTiles++;
                        if(nodes[x][y].m_distance > results.furthestTileDistance)
                        {
                            results.furthestTileDistance = nodes[x][y].m_distance;
                        }
                    }
                }
                else
                {
                    results.numNonWalkableTiles++;
                }
            }
        }

        results.percentageReachableTiles = numReachableTiles * 100 / results.numWalkableTiles;
    }

    void buildGraph(ref DijkstraNode[][] nodes)
    {
        auto size = m_mapToTest.getSize();
        nodes = new DijkstraNode[][size.x];
        foreach(x; 0..size.x)
        {
            nodes[x] = new DijkstraNode[size.y];
            foreach(y; 0..size.y)
            {
                nodes[x][y] = new DijkstraNode(Vector2u(x, y), m_mapToTest.isWalkable(Vector2u(x, y)));
            }
        }
    }
}
