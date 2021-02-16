import std.range;
import std.algorithm;
import std.typecons;
import std.math;
import shapes;

void main()
{
    int width = 640;
    int height = 480;
    Surface surface = Surface(width, height);
    surface.clear;

    surface.put(
        line(Point(50, 300), Point(480, 400), 50)
        .filter!(a => a.x % 50 > 25)
        .map!(a => Pixel(a, 0x0000FFFF)));

    surface.put(
        circle(Point(440, 150), 130)
        .filter!(a => a.x * a.y % 50 > 25)
        .map!(a => Pixel(a, 0xFF0000FF)));

    surface.put(
        circle(Point(120, 150), 90)
        .filter!(a => (abs(120 - a.x)^^2 + abs(150 - a.y)^^2) % 50 > 25)
        .map!(a => Pixel(a, 0x00FF00FF)));

    surface.toBmp("test.bmp");
}