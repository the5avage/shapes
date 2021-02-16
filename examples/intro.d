import shapes;

void main()
{
    int width = 640;
    int height = 480;
    Surface surface = Surface(width, height);
    surface.clear(0x3F3F3FFF);

    for (int i = 0; i < 640; i++)
        surface[i, i/2] = 0xFF000000;

    surface.toBmp("test.bmp");
}