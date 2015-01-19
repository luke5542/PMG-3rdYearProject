module ridgway.pmgcrawler.verification.bots;

import std.concurrency;
import std.conv;
import std.random;
import std.stdio;

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

void runBotThread(shared TileMap map)
{
    auto bot = new RandomBot(map);
    bool done = false;
    while(!done)
    {
        auto move = bot.makeNextMove();
        try
        {
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
          done = true;
        }
    }
}
