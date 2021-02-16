module shapes.triangle;

import std.algorithm;
import std.range;
import shapes.util;
import shapes.line;

auto triangle(Point p1, Point p2, Point p3)
{
    if (p2.y > p3.y)
        swap(p2, p3);
    if (p1.y > p2.y)
        swap(p1, p2);
    if (p2.y > p3.y)
        swap(p2, p3);

    return fill(line(p1, p2)
        .chain(line(p2, p3))
        .chunkBy!((a, b) => a.y == b.y)
        .zip(line(p1, p3).chunkBy!((a, b) => a.y == b.y))
        .map!(a => a[0].chain(a[1])));
}

/* more convenient but slower
auto triangleV2(Point p1, Point p2, Point p3)
{
    if (p2.y > p3.y)
        swap(p2, p3);
    if (p1.y > p2.y)
        swap(p1, p2);
    if (p2.y > p3.y)
        swap(p2, p3);

    return merge!(cmpPoints)(
        line(p1, p2).assumeSorted!cmpPoints,
        line(p2, p3).assumeSorted!cmpPoints,
        line(p1, p3).assumeSorted!cmpPoints)
        .chunkBy!((a, b) => a.y == b.y)
        .fill();
}

private bool cmpPoints(Point a, Point b)
{
    return a.y <= b.y;
}
*/
