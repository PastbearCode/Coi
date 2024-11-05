module coi;
import std.stdio;
import std.conv;
import std.file;
import std.algorithm;
import std.math;

struct Pos {
    int x;
    int y;

    // Constructor for convenience
    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

void coi_encode(int width, int height, string[][] pixels, File file) {
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            string v = pixels[i][j];
            file.write(v);
        }
        file.write("|");
    }
}

string[][] coi_make_canvas(int width, int height) {
    string[][] canvas = new string[][](height+1);
    
    for (int i = 0; i < height; i++) {
        canvas[i] = new string[width+1]; 
        for (int j = 0; j < width; j++) {
            canvas[i][j] = "89898EFF"; // Initialize with a default hex color
        }
    }
    return canvas;
}

// Updated to accept Pos structs for line coordinates
string[][] coi_line(string[][] pixels, Pos start, Pos end, string color) {
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int sx = (start.x < end.x) ? 1 : -1; // Step in x
    int sy = (start.y < end.y) ? 1 : -1; // Step in y
    int err = dx - dy; // Error term

    while (true) {
        // Set pixel at (x0, y0) to the specified color
        if (start.x >= 0 && start.x < pixels[0].length && start.y >= 0 && start.y < pixels.length) {
            pixels[start.y][start.x] = color; 
        }

        // Check if we have reached the endpoint (x1, y1)
        if (start.x == end.x && start.y == end.y) break;

        // Calculate error value to determine when to move in y direction
        int err2 = err * 2;

        if (err2 > -dy) {
            err -= dy;
            start.x += sx; // Move in x direction
        }

        if (err2 < dx) {
            err += dx;
            start.y += sy; // Move in y direction
        }
    }

    return pixels; // Return the modified pixels
}

// Updated to accept Pos for center coordinates
string[][] coi_circle(string[][] pixels, Pos center, int r, string color) {
    int x = 0;
    int y = r; // Fixed from -r to r
    int p = 1 - r; // Changed from float to int for simplicity

    while (x <= y) { // Use <= instead of < for a full circle
        // Set pixels in all eight octants
        if (center.y + y < pixels.length && center.x + x < pixels[0].length)
            pixels[center.y + y][center.x + x] = color;  // Octant 1
        if (center.y + y < pixels.length && center.x - x >= 0)
            pixels[center.y + y][center.x - x] = color;  // Octant 2
        if (center.y - y >= 0 && center.x + x < pixels[0].length)
            pixels[center.y - y][center.x + x] = color;  // Octant 3
        if (center.y - y >= 0 && center.x - x >= 0)
            pixels[center.y - y][center.x - x] = color;  // Octant 4
        if (center.y + x < pixels.length && center.x + y < pixels[0].length)
            pixels[center.y + x][center.x + y] = color;  // Octant 5
        if (center.y + x < pixels.length && center.x - y >= 0)
            pixels[center.y + x][center.x - y] = color;  // Octant 6
        if (center.y - x >= 0 && center.x + y < pixels[0].length)
            pixels[center.y - x][center.x + y] = color;  // Octant 7
        if (center.y - x >= 0 && center.x - y >= 0)
            pixels[center.y - x][center.x - y] = color;  // Octant 8

        x++;
        
        if (p < 0) {
            p += 2 * x + 1;
        } else {
            y--;
            p += 2 * (x - y) + 1;
        }
    }
    return pixels;
}

// Now using Pos for rectangle corners
string[][] coi_rectangle(string[][] pixels, Pos topLeft, int w, int h, string color) {
    Pos bottomRight = Pos(topLeft.x + w, topLeft.y + h);
    pixels = coi_line(pixels, topLeft, Pos(bottomRight.x, topLeft.y), color);
    pixels = coi_line(pixels, topLeft, Pos(topLeft.x, bottomRight.y), color);
    pixels = coi_line(pixels, Pos(bottomRight.x, topLeft.y), bottomRight, color);
    pixels = coi_line(pixels, Pos(topLeft.x, bottomRight.y), bottomRight, color);
    return pixels;
}

string[][] coi_rectangle_fill(string[][] pixels, Pos topLeft, int w, int h, string color) {
    Pos bottomRight = Pos(topLeft.x + w, topLeft.y + h);
    pixels = coi_line(pixels, topLeft, Pos(bottomRight.x, topLeft.y), color);
    pixels = coi_line(pixels, topLeft, Pos(topLeft.x, bottomRight.y), color);
    pixels = coi_line(pixels, Pos(bottomRight.x, topLeft.y), bottomRight, color);
    pixels = coi_line(pixels, Pos(topLeft.x, bottomRight.y), bottomRight, color);
    for (int i = 0; i < w; i++) {
        Pos colTop = Pos(topLeft.x + i, topLeft.y);
        Pos colBottom = Pos(topLeft.x + i, bottomRight.y);
        pixels = coi_line(pixels, colTop, colBottom, color);
    }
    return pixels;
}

string[][] coi_triangle(string[][] pixels, Pos p0, Pos p1, Pos p2, string color) {
    pixels = coi_line(pixels, p0, p1, color);
    pixels = coi_line(pixels, p1, p2, color);
    pixels = coi_line(pixels, p2, p0, color);
    return pixels;
}

string[][] coi_circle_fill(string[][] pixels, Pos center, int r, string color) {
    int cx = center.x;
    int cy = center.y;

    // Midpoint circle algorithm to draw a filled circle
    int x = 0;
    int y = r;
    int d = 1 - r;

    // Helper function to draw horizontal lines for filling
    void fill_line(int x_start, int x_end, int y) {
        if (y >= 0 && y < pixels.length) {
            int min_x = max(0, min(x_start, x_end));
            int max_x = min(pixels[0].length - 1, max(x_start, x_end));
            for (int x_fill = min_x; x_fill <= max_x; x_fill++) {
                pixels[y][x_fill] = color;
            }
        }
    }

    // Draw the initial points and fill horizontal lines
    while (x <= y) {
        // Fill lines between the points
        fill_line(cx - x, cx + x, cy + y);
        fill_line(cx - y, cx + y, cy + x);
        fill_line(cx - x, cx + x, cy - y);
        fill_line(cx - y, cx + y, cy - x);

        if (d < 0) {
            d = d + 2 * x + 3;
        } else {
            d = d + 2 * (x - y) + 5;
            y--;
        }
        x++;
    }

    return pixels;
}

string[][] coi_triangle_fill(string[][] pixels, Pos p0, Pos p1, Pos p2, string color) {
    // Step 1: Sort vertices by their y-coordinates
    if (p1.y < p0.y) { swap(p0, p1); }
    if (p2.y < p0.y) { swap(p0, p2); }
    if (p2.y < p1.y) { swap(p1, p2); }

    // Step 2: Calculate x-coordinates for interpolation
    auto interpolate = (int y, Pos pA, Pos pB) => 
        pA.x + (pB.x - pA.x) * (y - pA.y) / (pB.y - pA.y);

    // Step 3: Draw horizontal lines between each edge
    for (int y = p0.y; y <= p2.y; y++) {
        int xLeft, xRight;
        
        if (y < p1.y) {
            xLeft = interpolate(y, p0, p1);
            xRight = interpolate(y, p0, p2);
        } else {
            xLeft = interpolate(y, p1, p2);
            xRight = interpolate(y, p0, p2);
        }

        // Draw line between calculated xLeft and xRight
        for (int x = xLeft; x <= xRight; x++) {
            if (y >= 0 && y < pixels.length && x >= 0 && x < pixels[0].length) {
                pixels[y][x] = color;
            }
        }
    }

    return pixels;
}
