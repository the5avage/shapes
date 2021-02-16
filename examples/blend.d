import std.range;
import std.algorithm;
import std.typecons;
import std.stdio;
import shapes;

void main()
{
    int width = 640;
    int height = 480;
    Surface surface = Surface(width, height);
    surface.clear;

    surface.putBlend(
        circle(Point(230, 150), 120)
        .map!(a => Pixel(a, 0xFF0000FF)));

    surface.putBlend(
        circle(Point(410, 150), 120)
        .map!(a => Pixel(a, 0x00FF00FF)));

    surface.putBlend(
        circle(Point(320, 250), 120)
        .map!(a => Pixel(a, 0x0000FFFF)));

    surface.toBmp("test.bmp");
}