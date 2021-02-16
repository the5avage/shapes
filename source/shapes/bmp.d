/** This module contains functions to create bmp files.
 *
 *  The only supported source format is an array of uints (interpreted as rgba).
 *  Reading bmp files back in is not supported.
 *
 *  Authors:    René Heldmaier
 *  Copyright:  Copyright (c) 2020, René Heldmaier
 *  License:    $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0)
 *  Source:     //
 */

module shapes.bmp;

import std.stdio;

/** Converts an image from an rgba buffer to bmp file format and writes it to a file.
 *
 *  If height is negative the y-axis starts at the top of the screen and increases downwards.
 *
 *  Params:
 *  filename = The name or path of the file.
 *  pixels   = Array of pixels containing the image.
 *  width    = The image width in pixels
 *  height   = The image height in pixels. Can be negative to invert y-axis
 */

void saveBMP(string filename, const(uint)[] pixels, int width, int height)
{
    uint bmpSize;
    ubyte[] bmpBuffer = createBMP(pixels, width, height, &bmpSize);

    File f = File(filename, "w");
    f.rawWrite(bmpBuffer);
}

/** Converts an image from an rgba buffer to bmp file format and loads it
 *  in an array of ubytes
 *
 *  This function is called by saveBMP internally.
 *
 *  Params:
 *  pixels  = Array of input pixels in rgba. Must have width*height elements.
 *  width   = Image width in pixels.
 *  height  = Image height in pixels. Can be negative to invert y-axis.
 *  bmpSize = The size of the created bmp is written here.
 *
 *  Returns: Array containing the image in bmp format
 */

ubyte[] createBMP(const (uint)[] pixels, int width, int height, uint* bmpSize)
{
    if (width <= 0 || height == 0 || pixels == null)
        throw new Exception("Invalid arguments");

    int y_direction = 1;
    if (height < 0)
    {
        height *= -1;
        y_direction = -1;
    }

    // calculate size width padding
    uint paddedWidth = roundMultipleOf4(width * 3);   // 3 bytes per pixel
    uint sizePixelArray = paddedWidth * height;
    *bmpSize = bmpHeaderSize + sizePixelArray;

    ubyte[] bmpBuffer = new ubyte[](BmpHeader.sizeof + sizePixelArray);

    *cast(BmpHeader*)bmpBuffer.ptr = BmpHeader(width, height * y_direction, sizePixelArray);

    writeBMP_body(cast(const Color[]) pixels, bmpBuffer[BmpHeader.sizeof .. $], width, height, paddedWidth);

    return bmpBuffer[2 .. $];     // BMP Data starts with offset two because of alignment
}

private enum bmpHeaderSize = 54;  // size without padding

// File header according to bmp file format
private struct BmpHeader
{
    byte[2] padForAlingnment; //pad header size to multiple of 4 bytes
    // BMP Fileheader
    char[2] headerField = "BM";
    uint fileSize;
    ushort reserved1 = 0x6552;
    ushort reserved2 = 0x656E;
    uint offsetPixelArray = bmpHeaderSize;
    // BITMAPINFOHEADER
    uint headerSize = 40;
    int bmpWidth;
    int bmpHeight;
    ushort numColorPlanes = 1;
    ushort bitsPerPixel = 24;
    uint compressionMethod = 0;
    uint bmpPixelArraySize;
    uint horizontalResolution = 2835;      // pixel / metre
    uint verticalResolution = 2835;
    uint numColorsInPalette = 0;
    uint numImportantColors = 0;

    this(int width, int height, uint sizePixelArray)
    {
        bmpWidth = width;
        bmpHeight = height;
        bmpPixelArraySize = sizePixelArray;
        fileSize = sizePixelArray + bmpHeaderSize;
    }
}

// for byte access
private union Color
{
    uint asUint;
    struct
    {
        ubyte alpha;
        ubyte blue;
        ubyte green;
        ubyte red;
    }
}

private void writeBMP_body(const (Color)[] source,
                   ubyte[] target,
                   int width,
                   int height,
                   uint paddedWidth)
{
    for (int row = 0; row < height; row++) {
        for (int column = 0; column < width; column++) {
            target[row * paddedWidth + column * 3]     = source[row * width + column].blue;
            target[row * paddedWidth + column * 3 + 1] = source[row * width + column].green;
            target[row * paddedWidth + column * 3 + 2] = source[row * width + column].red;
        }
    }
}

private uint roundMultipleOf4(uint x)
{
    return (x + 3) &~ 3;
}