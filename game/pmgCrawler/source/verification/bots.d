module ridgway.pmgcrawler.verification.bots;

import std.concurrency;
import std.conv;
import std.random;
import std.stdio;
import std.math;

import dsfml.graphics;

import ridgway.pmgcrawler.map;

//To be used as the message that will stop the execution of the bot.
struct Exit {}

//To be used exclusively as a message passed to this thread to retrieve the Move
struct GetMove {}

//This class represents the nodes for the internal map for the bots.
class BotMapNode
{
    BotMapNode m_parent;
    bool m_isWalkable;
    bool m_hasSeen;
    bool m_isGoal;
    Vector2u m_location;

    this(Vector2u location, bool isWalkable)
    {
        m_location = location;
        m_isWalkable = isWalkable;
    }

    override bool opEquals(Object other)
    {
        return (cast(BotMapNode) other) && m_location == (cast(BotMapNode) other).m_location;
    }

    /*override int opCmp(Object other)
    {
        auto otherDN = cast(BotMapNode) other;
        return m_distance - otherDN.m_distance;
    }*/

    override string toString()
    {
        return "Location - " ~ to!string(m_location)
                ~ ", Walkable - " ~ to!string(m_isWalkable)
                ~ ", Seen - " ~ to!string(m_hasSeen);
    }
}

class Bot
{
    private
    {
        BotMapNode[][] m_nodes;
        Vector2u m_location;
    }

    this(shared TileMap map)
    {
        auto size = map.getSize();
        m_nodes = new BotMapNode[][size.x];
        foreach(x; 0..size.x)
        {
            m_nodes[x] = new BotMapNode[size.y];
            foreach(y; 0..size.y)
            {
                m_nodes[x][y] = new BotMapNode(Vector2u(x, y), map.isWalkable(Vector2u(x, y)));
            }
        }

        m_location = map.getPlayerStart();
        auto end = map.getPlayerEnd();
        m_nodes[end.x][end.y].m_isGoal = true;
    }

    Vector2u getLocation()
    {
        return m_location;
    }

    abstract Move makeNextMove();

private:

    void applyMove(Move m)
    {
        final switch(m)
        {
            case Move.UP:
                m_location += Vector2u(0, -1);
                break;

            case Move.DOWN:
                m_location += Vector2u(0, 1);
                break;

            case Move.LEFT:
                m_location += Vector2u(-1, 0);
                break;

            case Move.RIGHT:
                m_location += Vector2u(1, 0);
                break;
        }
    }
}

class RandomBot : Bot
{
    this(shared TileMap map)
    {
        super(map);
    }

    override Move makeNextMove()
    {
        auto moves = getValidMoves();
        if(moves.length > 0)
        {
            Move m = moves[uniform(0, moves.length)];
            applyMove(m);
            return m;
        }
        else
        {
            return Move.min;
        }

    }

    Move[] getValidMoves()
    {
        Move[] moves;
        if(m_location.y + 1 < m_nodes[m_location.x].length && m_nodes[m_location.x][m_location.y + 1].m_isWalkable)
        {
            moves ~= Move.DOWN;
        }
        if(m_location.y - 1 >= 0 && m_nodes[m_location.x][m_location.y - 1].m_isWalkable)
        {
            moves ~= Move.UP;
        }
        if(m_location.x - 1 >= 0 && m_nodes[m_location.x - 1][m_location.y].m_isWalkable)
        {
            moves ~= Move.LEFT;
        }
        if(m_location.x + 1 < m_nodes.length && m_nodes[m_location.x + 1][m_location.y].m_isWalkable)
        {
            moves ~= Move.RIGHT;
        }

        return moves;
    }
}

class AStarMapNode
{
    BotMapNode m_mapNode;
    AStarMapNode m_parent;
    int m_distance;
    int m_distanceTo;
    bool m_visited = false;

    this(BotMapNode node, Vector2f goal)
    {
        m_mapNode = node;
        m_distanceTo = distanceTo(goal);
    }

    int distanceTo(AStarMapNode other)
    {
        return distanceTo(other.m_mapNode.m_location);
    }

    int distanceTo(Vector2f other)
    {
        auto dist = m_mapNode.m_location - other;
        return abs(dist.x) + abs(dist.y);
    }

    override int opCmp(Object other)
    {
        auto otherASN = cast(AStarMapNode) other;
        return (m_distance + m_distanceTo) - (otherASN.m_distance + otherASN,m_distanceTo);
    }
}

class AStarBot : Bot
{
    Vector2f m_endLocation;
    AStarMapNode[][] m_asNodes;

    this(shared TileMap map)
    {
        super(map);
        m_endLocation = map.getPlayerEnd();
    }

    override Move makeNextMove()
    {
        auto move = getAStarMove(m_endLocation);
        applyMove(m);

        updateVisibleNodes();

        return move;
    }

    void updateVisibleNodes()
    {

    }

    void initASMap(Vector2f goal)
    {
        m_asNodes = new AStarMapNode[][nodes.length];
        foreach(x; 0..size.x)
        {
            m_asNodes[x] = new AStarMapNode[size.y];
            foreach(y; 0..size.y)
            {
                m_asNodes[x][y] = new AStarMapNode(m_nodes[x][y], goal);
            }
        }
    }

    Move getAStarMove(Vector2f goal)
    {
        initASMap();
        AStarMapNode[] unvisitedNodes;

        auto root = nodes[m_location.x][m_location.y];
        root.m_distance = 0;
        unvisitedNodes ~= root;

        while(unvisitedNodes.length > 0)
        {
            auto currentNode = unvisitedNodes[$-1];
            currentNode.m_visited = true;
            unvisitedNodes = unvisitedNodes[0 .. $-1];

            if(currentNode.m_mapNode.m_location == goal)
            {
                //TODO we have found our goal... yay...
            }

            int distance = currentNode.m_distance + 1;
            auto neighbors = getNeighbors(m_asNodes, currentNode.m_location.x, currentNode.m_location.y);
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

        return Move.min;
    }

    AStarMapNode[] getNeighbors(AStarMapNode[][] nodes, int x, int y)
    {
        AStarMapNode[] neighbors;
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
}

void runBotThread(shared TileMap map)
{
    auto bot = new RandomBot(map);
    bool done = false;
    while(!done)
    {
        try
        {
            auto move = bot.makeNextMove();
            receive((Exit message) {
                        writeln("Stopping Bot");
                        done = true;
                    },
                    (GetMove message) {
                        ownerTid.send(move);
                    });
        }
        catch(OwnerTerminated exc)
        {
            //Do same as the Exit message
            debug writeln("Exiting bot thread due to parental thread termination.");
            debug stdout.flush();
            done = true;
        }
        catch(Exception e)
        {
            debug writeln("Exiting bot thread due to exception: ", e);
            debug stdout.flush();
            done = true;
        }
    }
}
