module shapes.rectangle;

import shapes;

struct RectangleRange
{
    bool empty = false;
    Point front;
    int xRemaining;
    int yRemaining;
    int xSteps;

    this(Point topLeft, int width, int height)
    {
        front = topLeft;
        xRemaining = xSteps = width - 1;
        yRemaining = height - 1;
    }

    void popFront()
    {
        if (xRemaining)
        {
            front.x++;
            xRemaining--;
        }
        else if (yRemaining)
        {
            front.x -= xSteps;
            xRemaining = xSteps;
            front.y++;
            yRemaining--;
        }
        else
        {
            empty = true;
        }
    }
}

unittest
{
    import std.algorithm.comparison : equal;
    Point[] expected = [Point(0, 0), Point(1, 0), Point(2, 0),
                        Point(0, 1), Point(1, 1), Point(2, 1)];

    assert(RectangleRange(Point(0, 0), 3, 2).equal(expected));
}

auto rectangle(Point topLeft, int width, int height)
{
    return RectangleRange(topLeft, width, height);
}

auto rectangle(int width, int height)
{
    return RectangleRange(Point(0, 0), width, height);
}