module shapes.line;

import std.math;
import std.algorithm;
import std.range;
import shapes.util;

struct LineRange
{
    Point front;
    bool empty = false;

    Point end;
    int dx;
    int xStep;
    int dy;
    int yStep;
    int err;

    this(Point start, Point end)
    {
        dx = abs(end.x - start.x);
        xStep = start.x < end.x ? 1 : -1;
        dy = -abs(end.y - start.y);
        yStep = start.y < end.y ? 1 : -1;
        err = dx + dy;

        front = start;
        this.end = end;
    }

    void popFront()
    {
        if (front == end)
        {
            empty = true;
            return;
        }
        int e2 = 2 * err;
        if (e2 > dy)
        {
            err += dy;
            front.x += xStep;
        }
        if (e2 < dx)
        {
            err += dx;
            front.y += yStep;
        }
    }
}

auto line(Point start, Point end)
{
    return LineRange(start, end);
}

auto perpLine(Point start, Point end, int length)
{
    struct LineRange
    {
        Point front;

        int remaining;
        int dx;
        int xStep;
        int dy;
        int yStep;
        int err;
        int yDecrement;
        int xDecrement;

        @property bool empty()
        {
            return remaining <= 0;
        }

        this(Point start, Point end, int length)
        {
            remaining = abs(length) * 1000;
            front = start;

            dx = abs(end.x - start.x);
            dy = -abs(end.y - start.y);

            xStep = (start.y - end.y) * length < 0 ? 1 : -1;
            yStep = (start.x - end.x) * length < 0 ? -1 : 1;

            err = dx + dy;

            if (dx + dy > 0)
            {
                xDecrement = 414;
                yDecrement = 1000;
            }
            else
            {
                xDecrement = 1000;
                yDecrement = 414;
            }
        }

        void popFront()
        {
            int e2 = 2 * err;
            if (e2 > dy)
            {
                err += dy;
                front.y += yStep;
                remaining -= yDecrement;
            }

            if (e2 < dx)
            {
                err += dx;
                front.x += xStep;
                remaining -= xDecrement;
            }
        }
    }
    return LineRange(start, end, length);
}

private auto findLast(Range)(Range haystack)
{
    alias ResultType = typeof(haystack.front);
    ResultType result = void;
    assert(!haystack.empty);
    while (!haystack.empty)
    {
        result = haystack.front;
        haystack.popFront();
    }
    return result;
}

auto line(Point start, Point end, int width)
{
    assert(width > 1);
    Point[4] corners = void;

    corners[0] = perpLine(start, end, width/2 + 1).findLast;
    corners[1] = perpLine(start, end, -(width/2 + (width & 1))).findLast;
    corners[2] = perpLine(end, start, width/2 + (width & 1)).findLast;
    corners[3] = perpLine(end, start, -(width/2 + 1)).findLast;

    Point[] tmp = corners;
    tmp.multiSort!((a, b) => a.y < b.y, (a, b) => a.x < b.x);

    return LineRange(corners[0], corners[1])
        .chain(LineRange(corners[1], corners[3]))
        .chunkBy!((a, b) => a.y == b.y)
        .zip(
            LineRange(corners[0], corners[2])
            .chain(LineRange(corners[2], corners[3]))
            .chunkBy!((a, b) => a.y == b.y))
        .map!(a => a[0].chain(a[1]))
        .fill;
}
