module test.maptest;

import std.stdio;

import dunit;

import dsfml.system;
import dsfml.graphics;

import ridgway.pmgcrawler.map;
import ridgway.pmgcrawler.constants;

class MapTest
{
    mixin UnitTest;

    TileMap map;

    @BeforeClass
    void setupMap()
    {
        map = new TileMap();
        map.loadFromImage(TILE_MAP_LOC, ASSET_LOC ~ "map-test.png", Vector2u(2, 2));
    }

    @Test
    void testStartLocation()
    {
        assertEquals(Vector2u(0, 1), map.getPlayerStart());
    }

    @Test
    void testEndLocation()
    {
        assertEquals(Vector2u(1 ,0), map.getPlayerEnd());
    }

    @Test
    void testWalkableTiles()
    {
        assertTrue(map.isWalkable(Vector2u(1, 0)));
        assertTrue(map.isWalkable(Vector2u(0, 1)));
        assertTrue(map.isWalkable(Vector2u(0, 0)));
        assertFalse(map.isWalkable(Vector2u(1, 1)));
    }
}
