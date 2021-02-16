import std.range;
import std.algorithm;
import std.typecons;
import shapes;

void main()
{
    int width = 640;
    int height = 480;
    Surface surface = Surface(width, height);
    surface.clear;

    surface.put(triangle(Point(320, 50), Point(50, 430), Point(590, 430))
                .normalize(50, 590, 50, 430)
                .map!(a => a ~ tuple!("color")(Color(a.xNorm, 1-a.xNorm, 1-a.yNorm))));

    surface.toBmp("test.bmp");
}