module ridgway.pmgcrawler.verification.bots;

import std.concurrency;
import std.conv;
import std.random;
import std.stdio;
import std.math;
import std.typecons;

import dsfml.graphics;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.mapconfig;
import ridgway.pmgcrawler.verification.path;

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
    bool m_isReachable = false;
    bool m_isEdge = false;
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
        Vector2u m_sizeOfMap;
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

        m_sizeOfMap = map.getSize();

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
                if(m_location.y > 0)
                    m_location += Vector2u(0, -1);
                break;

            case Move.DOWN:
                if(m_location.y < m_sizeOfMap.y - 1)
                    m_location += Vector2u(0, 1);
                break;

            case Move.LEFT:
                if(m_location.x > 0)
                    m_location += Vector2u(-1, 0);
                break;

            case Move.RIGHT:
                if(m_location.x < m_sizeOfMap.x - 1)
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
    int m_distance = int.max;
    float m_distanceTo;
    bool m_visited = false;
    Move m_moveToHere;

    this(BotMapNode node, Vector2u goal)
    {
        m_mapNode = node;
        m_distanceTo = distanceTo(this.m_mapNode.m_location, goal);
    }

    override int opCmp(Object other)
    {
        auto otherASN = cast(AStarMapNode) other;
        return cast(int) ((otherASN.m_distance + otherASN.m_distanceTo) - (m_distance + m_distanceTo));
    }
}

float distanceTo(AStarMapNode first, AStarMapNode second)
{
    return distanceTo(first.m_mapNode.m_location, second.m_mapNode.m_location);
}

float distanceTo(Vector2u first, Vector2u second)
{
    auto dist = first - second;
    return abs(dist.x) + abs(dist.y);//sqrt(cast(float) dist.x * dist.x) + sqrt(cast(float) dist.y * dist.y);//
}

class AStarBot : Bot
{
    Vector2u m_endLocation;
    AStarMapNode[][] m_asNodes;
    bool m_useHasSeen = false;
    Path m_path;
    bool m_generatePath = true;

    this(shared TileMap map)
    {
        super(map);
        m_endLocation = map.getPlayerEnd();
    }

    override Move makeNextMove()
    {
        
        auto move = getAStarMove(m_endLocation);
        applyMove(move);

        debug writeln("making move ", move);

        return move;
    }

    void initASMap(Vector2u goal)
    {
        m_asNodes = new AStarMapNode[][m_nodes.length];
        foreach(x; 0..m_nodes.length)
        {
            m_asNodes[x] = new AStarMapNode[m_nodes[x].length];
            foreach(y; 0..m_nodes[x].length)
            {
                m_asNodes[x][y] = new AStarMapNode(m_nodes[x][y], goal);
            }
        }
    }

    Move getAStarMove(Vector2u goal)
    {
        initASMap(goal);
        AStarMapNode[] unvisitedNodes;

        auto root = m_asNodes[m_location.x][m_location.y];
        root.m_distance = 0;
        root.m_parent = null;
        unvisitedNodes ~= root;

        while(unvisitedNodes.length > 0)
        {
            auto currentNode = unvisitedNodes[$-1];
            currentNode.m_visited = true;
            unvisitedNodes = unvisitedNodes[0 .. $-1];

            if(currentNode.m_mapNode.m_location == goal)
            {
                //we have found our goal... yay...
                return getMoveFromNode(currentNode);
            }

            int distance = currentNode.m_distance + 1;
            auto neighbors = getNeighbors(m_asNodes, currentNode.m_mapNode.m_location.x,
                                            currentNode.m_mapNode.m_location.y, distance);
            foreach(node; neighbors)
            {
                if(node.m_mapNode.m_isWalkable)
                {
                    node.m_distance = distance;
                    node.m_parent = currentNode;

                    if(!node.m_visited && (!m_useHasSeen || node.m_mapNode.m_hasSeen))
                    {
                        unvisitedNodes ~= node;
                    }
                }
            }
            unvisitedNodes.sort;
        }

        debug writeln("No move found...");

        return Move.min;
    }

    Move getMoveFromNode(AStarMapNode currentNode)
    {
        //Get us to the penultimate node...
        while(currentNode !is null && currentNode.m_parent !is null
                && currentNode.m_parent.m_parent !is null)
        {
            currentNode = currentNode.m_parent;
        }

        return currentNode.m_moveToHere;
    }

    AStarMapNode[] getNeighbors(AStarMapNode[][] nodes, int x, int y, int distance)
    {
        AStarMapNode[] neighbors;
        if(x + 1 < m_sizeOfMap.x && !nodes[x + 1][y].m_visited && nodes[x + 1][y].m_distance > distance)
        {
            nodes[x + 1][y].m_moveToHere = Move.RIGHT;
            neighbors ~= nodes[x + 1][y];
        }
        if(y + 1 < m_sizeOfMap.y && !nodes[x][y + 1].m_visited && nodes[x][y + 1].m_distance > distance)
        {
            nodes[x][y + 1].m_moveToHere = Move.DOWN;
            neighbors ~= nodes[x][y + 1];
        }
        if(x > 0 && !nodes[x - 1][y].m_visited && nodes[x - 1][y].m_distance > distance)
        {
            nodes[x - 1][y].m_moveToHere = Move.LEFT;
            neighbors ~= nodes[x - 1][y];
        }
        if(y > 0 && !nodes[x][y - 1].m_visited && nodes[x][y - 1].m_distance > distance)
        {
            nodes[x][y - 1].m_moveToHere = Move.UP;
            neighbors ~= nodes[x][y - 1];
        }

        return neighbors;
    }

}

class BlindBot : AStarBot
{

    private static immutable VISION_RADIUS = 10;

    Vector2u m_endGoal;

    this(shared TileMap map)
    {
        super(map);
        //m_useHasSeen = true;
        m_endGoal = m_endLocation;
        setReachability(m_nodes, m_location);
        updateHasSeen();
    }

    override Move makeNextMove()
    {
        //Selecting the current goal before doing other things...
        debug writeln("Finding goal...");
        setCurrentGoal();
        debug writeln("Goal set to: ", m_endLocation);
        debug writeln("Running A* search...");
        auto move = super.makeNextMove();

        updateHasSeen();

        return move;
    }

    void setCurrentGoal()
    {
        //Start by seeing if we can get to the exit, which takes priority
        if(m_nodes[m_endGoal.x][m_endGoal.y].m_hasSeen)
        {
            m_endLocation = m_endGoal;
            return;
        }

        //If we don't know where the exit is, we go to a random choice
        //of all of the closest unseen and walkable tiles...
        BotMapNode nearestNodes;
        float closestDistance = float.max;
        float curDist;
        foreach(x; 0 .. m_sizeOfMap.x)
        {
            foreach(y; 0 .. m_sizeOfMap.y)
            {
                if(!m_nodes[x][y].m_hasSeen && m_nodes[x][y].m_isReachable)
                {
                    curDist = distanceTo(m_nodes[x][y].m_location, m_location);

                    if(nearestNodes is null)//.length == 0)
                    {
                        nearestNodes = m_nodes[x][y];
                        closestDistance = curDist;

                    }
                    else if(curDist < closestDistance)
                    {
                        //nearestNodes.length = 0;
                        nearestNodes = m_nodes[x][y];
                        closestDistance = curDist;
                    }
                    else if(curDist == closestDistance)
                    {
                        nearestNodes = m_nodes[x][y];
                    }
                }
            }
        }

        //debug writeln("Number of nearest nodes: ", nearestNodes.length);
        m_endLocation = nearestNodes.m_location;//[uniform(0, nearestNodes.length)].m_location;

    }

    void updateHasSeen()
    {
        int minX = ((cast(int) m_location.x) - VISION_RADIUS) <= 0
                    ? 0 : ((cast(int) m_location.x) - VISION_RADIUS);
        int maxX = ((cast(int) m_location.x) + VISION_RADIUS) >= m_sizeOfMap.x
                    ? m_sizeOfMap.x : ((cast(int) m_location.x) + VISION_RADIUS);

        int minY = ((cast(int) m_location.y) - VISION_RADIUS) <= 0
                    ? 0 : ((cast(int) m_location.y) - VISION_RADIUS);
        int maxY = ((cast(int) m_location.y) + VISION_RADIUS) >= m_sizeOfMap.y
                    ? m_sizeOfMap.y : ((cast(int) m_location.y) + VISION_RADIUS);

        foreach(x; minX .. maxX)
        {
            foreach(y; minY .. maxY)
            {
                m_nodes[x][y].m_hasSeen = true;
            }
        }
    }

    // override AStarMapNode[] getNeighbors(AStarMapNode[][] nodes, int x, int y, int distance)
    // {
    //     auto neighbors = super.getNeighbors(nodes, x, y, distance);
    //     AStarMapNode[] seenNeighbors;
    //
    //     foreach(node; neighbors)
    //     {
    //         if(node.m_mapNode.m_hasSeen)
    //         {
    //             seenNeighbors ~= node;
    //         }
    //     }
    //
    //     debug writeln("num neighbors: ", seenNeighbors.length);
    //
    //     return seenNeighbors;
    // }
}

class BetterBlindBot : AStarBot
{

    private static immutable VISION_RADIUS = 10;

    Vector2u m_endGoal;
    bool m_goalFound = true;

    this(shared TileMap map)
    {
        super(map);
        //m_useHasSeen = true;
        m_endGoal = m_endLocation;
        //setReachability(m_nodes, m_location);
        updateHasSeen();
    }

    override Move makeNextMove()
    {
        //Selecting the current goal before doing other things...
        debug writeln("Finding goal...");
        if(m_goalFound)
        {
            setCurrentGoal();
        }
        debug writeln("Goal set to: ", m_endLocation);
        debug writeln("Running A* search...");
        auto move = super.makeNextMove();

        updateHasSeen();

        writeln("Bot at location: ", m_location);

        return move;
    }

    void setCurrentGoal()
    {
        //Start by seeing if we can get to the exit, which takes priority
        if(m_nodes[m_endGoal.x][m_endGoal.y].m_hasSeen)
        {
            m_endLocation = m_endGoal;
            return;
        }

        // Grab the goal as the nearest tile that is:
        // walkable, has been seen, and is an edge.
        // If we don't know where the exit is, we go to a random choice
        // of all of the closest unseen and walkable tiles...
        BotMapNode nearestNodes;
        float closestDistance = float.max;
        float curDist;
        foreach(x; 0 .. m_sizeOfMap.x)
        {
            foreach(y; 0 .. m_sizeOfMap.y)
            {
                if(m_nodes[x][y].m_isWalkable && !m_nodes[x][y].m_hasSeen && hasWalkableEdgeNeighbor(x, y))
                {
                    curDist = distanceTo(m_nodes[x][y].m_location, m_location);

                    if(nearestNodes is null)
                    {
                        nearestNodes = m_nodes[x][y];
                        closestDistance = curDist;

                    }
                    else if(curDist < closestDistance)
                    {
                        nearestNodes = m_nodes[x][y];
                        closestDistance = curDist;
                    }
                    else if(curDist == closestDistance)
                    {
                        nearestNodes = m_nodes[x][y];
                    }
                }
            }
        }

        m_endLocation = nearestNodes.m_location;
        m_goalFound = false;
    }

    bool hasWalkableEdgeNeighbor(int x, int y)
    {
        if(x - 1 >= 0 && m_nodes[x - 1][y].m_isEdge && m_nodes[x - 1][y].m_isWalkable)
        {
            return true;
        }
        if(x + 1 < m_sizeOfMap.x && m_nodes[x + 1][y].m_isEdge && m_nodes[x + 1][y].m_isWalkable)
        {
            return true;
        }
        if(y - 1 >= 0 && m_nodes[x][y - 1].m_isEdge && m_nodes[x][y - 1].m_isWalkable)
        {
            return true;
        }
        if(y + 1 < m_sizeOfMap.y && m_nodes[x][y + 1].m_isEdge && m_nodes[x][y + 1].m_isWalkable)
        {
            return true;
        }

        return false;
    }

    void updateHasSeen()
    {
        // Step 1: implement Ray Tracing over the area...
        int minX = ((cast(int) m_location.x) - VISION_RADIUS) <= 0
                    ? 0 : ((cast(int) m_location.x) - VISION_RADIUS);
        int maxX = ((cast(int) m_location.x) + VISION_RADIUS) >= m_sizeOfMap.x
                    ? m_sizeOfMap.x : ((cast(int) m_location.x) + VISION_RADIUS);

        int minY = ((cast(int) m_location.y) - VISION_RADIUS) <= 0
                    ? 0 : ((cast(int) m_location.y) - VISION_RADIUS);
        int maxY = ((cast(int) m_location.y) + VISION_RADIUS) >= m_sizeOfMap.y
                    ? m_sizeOfMap.y : ((cast(int) m_location.y) + VISION_RADIUS);

        //Get all walls in the area
        Tuple!(Vector2f, FloatRect)[] walls;
        foreach(x; minX .. maxX)
        {
            foreach(y; minY .. maxY)
            {
                if(!m_nodes[x][y].m_isWalkable)
                {
                    walls ~= Tuple!(Vector2f, FloatRect)(Vector2f(x, y), FloatRect(x - .5, y - .5, 1, 1));
                }
            }
        }

        auto floatLoc = Vector2f(m_location.x, m_location.y);
        foreach(x; minX .. maxX)
        {
            foreach(y; minY .. maxY)
            {
                bool wallIntersects = false;
                foreach(rect; walls)
                {
                    auto floatNodeLoc = Vector2f(m_nodes[x][y].m_location.x, m_nodes[x][y].m_location.y);
                    if(rect[0] != floatNodeLoc)
                    {
                        if(intersectsWall(floatLoc, floatNodeLoc, rect[1]))
                        {
                            wallIntersects = true;
                            break;
                        }
                    }
                }

                m_nodes[x][y].m_hasSeen = m_nodes[x][y].m_hasSeen || !wallIntersects;
                if(!m_goalFound && Vector2u(x, y) == m_endLocation && m_nodes[x][y].m_hasSeen)
                {
                    m_goalFound = true;
                }
            }
        }

        // Step 2: if any of the tiles in 3x3 grid are unknown, set to edge.
        // Ignore the fact that it's a wall, since that's dealt with later.
        int numNeighborsSeen;
        int numNeighbors;
        foreach(x; minX .. maxX)
        {
            foreach(y; minY .. maxY)
            {
                numNeighborsSeen = 0;
                numNeighbors = 0;
                foreach(x2; (x - 1) .. (x + 1))
                {
                    foreach(y2; (y - 1) .. (y + 1))
                    {
                        if(x2 >= 0 && y2 >= 0 && x2 < m_sizeOfMap.x
                            && y2 < m_sizeOfMap.y)
                        {
                            if(m_nodes[x2][y2].m_hasSeen)
                            {
                                numNeighborsSeen++;
                            }
                            numNeighbors++;
                        }
                    }
                }

                m_nodes[x][y].m_isEdge = numNeighborsSeen != numNeighbors;
            }
        }
    }

    bool intersectsWall(Vector2f p1, Vector2f p2, FloatRect wall)
    {
        auto topLeft = Vector2f(wall.left, wall.top);
        auto topRight = topLeft + Vector2f(wall.width, 0);
        auto bottomRight = topLeft + Vector2f(wall.width, wall.height);
        auto bottomLeft = topLeft + Vector2f(0, wall.height);

        if(intersectsLine(p1, p2, topLeft, bottomLeft))
        {
            return true;
        }
        if(intersectsLine(p1, p2, bottomLeft, bottomRight))
        {
            return true;
        }
        if(intersectsLine(p1, p2, bottomRight, topRight))
        {
            return true;
        }
        if(intersectsLine(p1, p2, topLeft, topRight))
        {
            return true;
        }

        return false;
    }

    // R1 and R2 are the points on the rectangle, l1 and l2 are points
    // on the line we are intersecting with the rectangle.
    bool intersectsLine(Vector2f l1, Vector2f l2, Vector2f r1, Vector2f r2)
    {
        double denom = (l1.x-l2.x)*(r1.y-r2.y) - (l1.y-l2.y)*(r1.x-r2.x);
        if(denom != 0)
        {
            double xTop = (l1.x*l2.y - l1.y*l2.x)*(r1.x-r2.x) - (l1.x-l2.x)*(r1.x*r2.y - r1.y*r2.x);
            double yTop = (l1.x*l2.y - l1.y*l2.x)*(r1.y-r2.y) - (l1.y-l2.y)*(r1.x*r2.y - r1.y*r2.x);

            double pX = xTop / denom;
            double pY = yTop / denom;

            //Now check if the point is on the two line segments...
            auto point = Vector2f(pX, pY);
            return distanceTo(l1, point) + distanceTo(l2, point) == distanceTo(l1, l2)
                    && distanceTo(r1, point) + distanceTo(r2, point) == distanceTo(r1, r2);
        }

        return false;
    }

    bool intersectsLineNEW(Vector2f p1, Vector2f p2, Vector2f p3, Vector2f p4)
    {
        double l1xDiff = p2.x - p1.x;
        double l2xDiff = p4.x - p3.x;
        double l1yDiff = p2.y - p1.y;
        double l2yDiff = p4.y - p3.y;

        double denom = l1yDiff/l1xDiff - l2yDiff/l2xDiff;
        if(denom != 0)
        {
            double xTop = (p1.x * l1yDiff) / l1xDiff - (p3.x * l2yDiff) / l2xDiff + p3.y - p1.y;

            double pX = xTop / denom;

            double pY = (l1yDiff / l1xDiff) * (pX - p1.x) + p1.y;

            //Now check if the point is on the two line segments...
            auto point = Vector2f(pX, pY);
            return distanceTo(p1, point) + distanceTo(p2, point) == distanceTo(p1, p2)
                    && distanceTo(p3, point) + distanceTo(p4, point) == distanceTo(p3, p4);
        }

        return false;
    }
}

float distanceTo(Vector2f first, Vector2f second)
{
    auto dist = first - second;
    return sqrt(dist.x * dist.x) + sqrt(dist.y * dist.y);
}

Bot initBot(shared TileMap map, MapGenConfig config)
{
    Bot bot;
    final switch(config.vConfig.bot)
    {
        case BotType.Random:
            bot = new RandomBot(map);
            break;
        case BotType.SpeedRunner:
            bot = new AStarBot(map);
            break;
        case BotType.Moron:
            bot = new BlindBot(map);
            break;
        case BotType.Human:
            bot = new BetterBlindBot(map);
            break;
    }

    return bot;
}

void runBotThread(shared TileMap map, MapGenConfig config)
{
    Bot bot = initBot(map, config);

    debug writeln("Bot successfully initialised.");

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

class DistNode
{
    BotMapNode m_node;
    int m_distance = int.max;
    bool m_visited = false;

    this(BotMapNode node)
    {
        m_node = node;
    }

    override int opCmp(Object other)
    {
        auto otherDN = cast(DistNode) other;
        return otherDN.m_distance - m_distance;
    }
}


void setReachability(BotMapNode[][] nodes, Vector2u location)
{
    DistNode[][] distNodes = new DistNode[][nodes.length];
    foreach(x; 0 .. nodes.length)
    {
        distNodes[x] = new DistNode[nodes[x].length];
        foreach(y; 0 .. nodes[x].length)
        {
            distNodes[x][y] = new DistNode(nodes[x][y]);
        }
    }

    DistNode[] unvisitedNodes;

    auto root = distNodes[location.x][location.y];
    root.m_distance = 0;
    unvisitedNodes ~= root;

    while(unvisitedNodes.length > 0)
    {
        auto currentNode = unvisitedNodes[$-1];
        currentNode.m_visited = true;
        currentNode.m_node.m_isReachable = true;
        unvisitedNodes = unvisitedNodes[0 .. $-1];

        int distance = currentNode.m_distance + 1;
        auto neighbors = getNeighbors(distNodes, currentNode.m_node.m_location.x,
                                        currentNode.m_node.m_location.y, distance);
        foreach(node; neighbors)
        {
            if(node.m_node.m_isWalkable)
            {
                node.m_distance = distance;

                if(!node.m_visited)
                {
                    unvisitedNodes ~= node;
                }
            }
        }

        unvisitedNodes.sort;
    }
}


DistNode[] getNeighbors(DistNode[][] nodes, int x, int y, int distance)
{
    DistNode[] neighbors;
    if(x + 1 < nodes.length && !nodes[x + 1][y].m_visited && nodes[x + 1][y].m_distance > distance)
    {
        neighbors ~= nodes[x + 1][y];
    }
    if(y + 1 < nodes.length && !nodes[x][y + 1].m_visited && nodes[x][y + 1].m_distance > distance)
    {
        neighbors ~= nodes[x][y + 1];
    }
    if(x > 0 && !nodes[x - 1][y].m_visited && nodes[x - 1][y].m_distance > distance)
    {
        neighbors ~= nodes[x - 1][y];
    }
    if(y > 0 && !nodes[x][y - 1].m_visited && nodes[x][y - 1].m_distance > distance)
    {
        neighbors ~= nodes[x][y - 1];
    }

    return neighbors;
}
