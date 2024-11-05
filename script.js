function drawFromHexString(hexString) {
    const canvas = document.getElementById('coiCanvas');
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    const pixelSize = 1; // Each pixel is 1x1
    const rowSeparator = '|';
    const colors = hexString.split(rowSeparator);

    ctx.imageSmoothingEnabled = false;
    canvas.style.imageRendering = 'pixelated';
    // Calculate the maximum number of pixels in a row
    const maxRowLength = Math.floor(width / pixelSize);

    // Loop through each row
    for (let i = 0; i < colors.length; i++) {
        const colorRow = colors[i];
        // Split the colors in the row into chunks of 8 characters
        for (let j = 0; j < colorRow.length; j += 8) {
            const hexColor = colorRow.substring(j, j + 8);
            
            if (hexColor.length === 8) {
                // Calculating pixel position
                const x = j / 8;
                const y = i;

                // Setting pixel color
                ctx.fillStyle = `#${hexColor}`;
                ctx.fillRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);

                // Break if we exceed the width of the canvas
                if (x >= maxRowLength) break;  
            }
        }
    }
}

// Function to fetch string from the file
async function fetchHexString() {
    try {
        const response = await fetch('image.coi');
        if (!response.ok) {
            throw new Error('Failed to fetch file: ' + response.status);
        }
        const text = await response.text();
        drawFromHexString(text);
    } catch (error) {
        console.error('Error fetching the hex string: ', error);
    }
}

// Fetch the input string from the file
fetchHexString();
