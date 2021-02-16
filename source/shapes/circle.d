module shapes.circle;

import std.array;
import std.algorithm;
import shapes.util;
import shapes.triangle;

struct CircleEdgeRange
{
    Point mid;
    Point front;
    int rad;
    int x = 0;
    int y;
    int remainigOctants = 3;
    int stepOctant = 2;
    int decision;
    int delta_east;
    int delta_south_east;
    bool empty = false;

    this(Point mid, int rad)
    {
        assert(rad > 0);
        this.mid = mid;
        this.rad = rad;
        decision = 1 - rad;
        delta_east = 3;
        delta_south_east = -2 * rad + 5;
        y = rad;
        front = Point(mid.x, mid.y + rad);
    }

    void popFront()
    {
        switch (remainigOctants--)
        {
        case 7:
            front = Point(mid.x - x, mid.y + y);
            return;
        case 6:
            front = Point(mid.x - x, mid.y - y);
            return;
        case 5:
            front = Point(mid.x + y, mid.y - x);
            return;
        case 4:
            front = Point(mid.x - y, mid.y - x);
            return;
        case 3:
            front = Point(mid.x + x, mid.y - y);
            return;
        case 2:
            front = Point(mid.x + y, mid.y + x);
            return;
        case 1:
            front = Point(mid.x - y, mid.y + x);
            return;
        case 0:
            x++;
            if (decision < 0)
            {
                decision += delta_east;
                delta_south_east += 2;
            }
            else
            {
                decision += delta_south_east;
                delta_south_east += 4;
                y--;
            }

            if (x == y)
            {
                front = Point(mid.x - x, mid.y - y);
                remainigOctants = 3;
            }
            else if (x > y)
            {
                empty = true;
                return;
            }
            else
            {
                front = Point(mid.x + x, mid.y + y);
                remainigOctants = 7;
            }

            delta_east += 2;
            return;
        default:
            assert(0);
        }
    }
}

auto circleEdge(Point mid, int rad)
{
    return CircleEdgeRange(mid, rad);
}

auto circle(Point mid, int rad)
{
    return fill(circleEdge(mid, rad).array
                    .sort!((a, b) => a.y < b.y)
                    .chunkBy!((a, b) => a.y == b.y));
}