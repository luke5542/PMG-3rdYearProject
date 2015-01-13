module ridgway.pmgcrawler.verification.dijkstras;

import ridgway.pmgcrawler.map;

class DijkstrasVerifier
{
	private
	{
		int m_numWalkable;
		int m_numReachable;
		int m_score;

		TileMap m_mapToTest;
	}

	this(TileMap map)
	{
		m_mapToTest = map;
	}

	//Returns whether or not the map is playable,
	//while calculating the various statistics.
	bool verify()
	{
		return false;
	}
}