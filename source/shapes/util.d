module shapes.util;

struct Color
{
    union
    {
        uint rgba;
        struct
        {
            ubyte alpha;
            ubyte blue;
            ubyte green;
            ubyte red;
        }
        ubyte[4] asArray;
    }

    this(uint color)
    {
        rgba = color;
    }

    this(float red, float green, float blue, float alpha = 1.0f)
    {
        this.red = normalizedColorToUbyte(red);
        this.green = normalizedColorToUbyte(green);
        this.blue = normalizedColorToUbyte(blue);
        this.alpha = normalizedColorToUbyte(alpha);
    }

    ref Color opAssign(uint rgba)
    {
        this.rgba = rgba;
        return this;
    }

    @property uint asUint()
    {
        return rgba;
    }

    alias asUint this;
}

unittest
{
    Color test;
    test = 0x12345678;
    assert(test == 0x12345678);
    assert(test.red == 0x12);
    assert(test.green == 0x34);
    assert(test.blue == 0x56);
    assert(test.alpha == 0x78);
}

struct Point
{
    int x;
    int y;

    string toString() const
    {
        import std.format : format;
        return format("x:%d y:%d", x, y);
    }

    import std.typecons : Tuple;

    Tuple!(int, "x", int, "y") asTuple()
    {
        return Tuple!(int, "x", int, "y")(x, y);
    }

    alias asTuple this;
}

struct Pixel
{
    int x;
    int y;
    Color color;

    this(Point position, uint color)
    {
        this.x = position.x;
        this.y = position.y;
        this.color = Color(color);
    }

    this(uint x, uint y, uint color)
    {
        this.x = x;
        this.y = y;
        this.color = Color(color);
    }
}

struct Surface
{
    uint[] pixels;
    int width;
    @property int height()
    {
        return cast(int)pixels.length / width;
    }

    this(int width, int height)
    {
        this.width = width;
        pixels = new uint[width * height];
    }

    ref uint opIndex(uint x, uint y)
    {
        return pixels[y * width + x];
    }

    uint opIndexAssign(uint value, uint x, uint y)
    {
        pixels[y * width + x] = value;
        return Color(value);
    }

    void put(Pixel p)
    {
        pixels[p.y * width + p.x] = p.color;
    }

    void put(R)(R input)
        if (is(typeof(input.front.x) : int) &&
            is(typeof(input.front.y) : int) &&
            is(typeof(input.front.color) : uint))
    {
        foreach (p; input)
        {
            pixels[p.y * width + p.x] = p.color;
        }
    }

    void putBlend(R)(R input)
        if (is(typeof(input.front.x) : int) &&
            is(typeof(input.front.y) : int) &&
            is(typeof(input.front.color) : uint))
    {
        foreach (p; input)
        {
            pixels[p.y * width + p.x] = blend(Color(pixels[p.y * width + p.x]), Color(p.color));
        }
    }

    void clear(uint color = 0)
    {
        foreach (ref p; pixels)
        {
            p = color;
        }
    }

    void toBmp(string filename)
    {
        import shapes.bmp: saveBMP;
        saveBMP(filename, pixels, width, -height);
    }
}

unittest
{
    Surface test = Surface(640, 480);
    assert(test.pixels.length == 640 * 480);

    test[1, 2] = 0x12345678U;
    assert(test[1, 2] == 0x12345678U);

    Pixel p = Pixel(3, 4, 0xFF00FF00);
    test.put(p);
    assert(test[3, 4] == 0xFF00FF00);

    test.clear(0xFF00FFFF);
    assert(test[639, 479] == 0xFF00FFFF);
}

auto fill(Range)(Range r)
{
    struct FilledRange(Range)
    {
        Range edge;
        Point front;
        bool empty = false;
        int xSteps;

        this(Range edge)
        {
            this.edge = edge;
            front.y = edge.front.front.y;
            auto minmax = edge.front.minmaxX();
            front.x = minmax[0];
            xSteps = minmax[1] - minmax[0];
        }

        void popFront()
        {
            if (xSteps)
            {
                xSteps--;
                front.x++;
            }
            else
            {
                edge.popFront();
                if (edge.empty)
                {
                    empty = true;
                    return;
                }
                auto minmax = edge.front.minmaxX();
                front.x = minmax[0];
                xSteps = minmax[1] - minmax[0];
                front.y++;
            }
        }
    }
    return FilledRange!(Range)(r);
}

auto normalize(R)(R shape, int xMin, int xMax, int yMin, int yMax)
{
    import std.typecons : tuple;
    import std.algorithm : map;
    return shape.map!(a => tuple!("x", "y", "xNorm", "yNorm")
                      (a.x, a.y, norm(a.x, xMin, xMax), norm(a.y, yMin, yMax)));
}

Color blend(Color a, Color b)
{
    Color result = void;
    result.red = cast(ubyte)((a.red * a.alpha + b.red * b.alpha) / (a.alpha + b.alpha));
    result.green = cast(ubyte)((a.green * a.alpha + b.green * b.alpha) / (a.alpha + b.alpha));
    result.blue = cast(ubyte)((a.blue * a.alpha + b.blue * b.alpha) / (a.alpha + b.alpha));
    result.alpha = 0xFF;
    return result;
}

private float norm(int value, int min, int max)
{
    float result = (value - min) / cast(float)(max - min);
    if (result <= 0.0f)
        return 0.0f;
    else if (result >= 1.0f)
        return 1.0f;
    return result;
}

unittest
{
    import std.math : approxEqual;
    assert(approxEqual(norm(10, 10, 20), 0.0f));
    assert(approxEqual(norm(20, 10, 20), 1.0f));
    assert(approxEqual(norm(15, 10, 20), 0.5f));
}

private auto minmaxX(Range)(Range r)
{
    import std.algorithm;
    return r.fold!(
        ((a, b) => a < b.x ? a : b.x),
        ((a, b) => a > b.x ? a : b.x))
        (r.front.x, r.front.x);
}

private ubyte normalizedColorToUbyte(float c)
{
    if (c >= 1.0f)
        return 255;
    else if (c <= 0.0f)
        return 0;
    return cast(ubyte)(c * 255.0f);
}
