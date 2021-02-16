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

    surface.put(
        circle(Point(230, 150), 40)
        .map!(a => Pixel(a, 0xFF0000FF)));

    surface.put(
        triangle(Point(30, 300), Point(300, 200), Point(200, 280))
        .map!(a => a.asTuple ~ tuple!("color")(0x00FF00FF)));

    surface.put(
        line(Point(350, 300), Point(480, 400), 50)
        .map!(a => Pixel(a, 0x0000FFFF)));

    surface.toBmp("test.bmp");
}