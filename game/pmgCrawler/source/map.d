module ridgway.pmgcrawler.map;

class MapData
{

	private
	{
		char[][] tileTypes;
	}

	this(int x, int y)
	{
		tileTypes = new char[x][y];
	}

}

class TileMap
{
	private
	{
		Sprite[][] m_tiles;
	}
}