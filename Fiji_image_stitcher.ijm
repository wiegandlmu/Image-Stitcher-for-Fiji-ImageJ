// Description: Stitches images from Keyence microscopes using Fiji.

// Configurable main path
mainDir = getDirectory("Choose the Main Directory");

// Get list of all subfolders
subFolders = getFileList(mainDir);

// Loop through each subfolder
for (i = 0; i < subFolders.length; i++) {
    // Configurable prefix for subfolders (Default: "Image_")
    subfolderPrefix = "Image_";
    if (startsWith(subFolders[i], subfolderPrefix) && File.isDirectory(mainDir + subFolders[i])) {
        currentFolder = mainDir + subFolders[i];
        processFolder(currentFolder);
    }
}

function processFolder(folder) {
    // List and sort images in the folder
    list = getFileList(folder);
    Array.sort(list);

    // Count relevant images
    imageCount = 0;

    // Configurable image suffix (Default: ".tif")
    imageNameSuffix = ".tif";

    for (j = 0; j < list.length; j++) {
        imageName = list[j];
        if (endsWith(imageName, imageNameSuffix)) {
            imageCount++;
        }
    }

    // Configurable minimum number of images
    minImages = 2;

    if (imageCount < minImages) {
        print("Not enough images for stitching in: " + folder + ". At least " + minImages + " images required.");
        return;
    }

    // Extract number from folder name
    // Configurable start position of the number in the subfolder name (Default: 6 for "Image_XXX")
    // This is the index of the first character of the number within the subfolder name, starting the count from 0.
    numStartPos = 6;

    xyNum = substring(File.getName(folder), numStartPos);

    // Calculate grid size
    gridSize = Math.ceil(Math.sqrt(imageCount));
    numRows = gridSize;
    numCols = gridSize;

    // Perform image stitching
    // Configurable stitching parameters
    gridType = "[Grid: snake by rows]";
    gridOrder = "[Right & Down                ]";
    tileOverlap = "20"; // Configurable overlap area
    firstFileIndex = "1";
    outputTxtFile = "TileConfiguration.txt";
    fusionMethod = "[Linear Blending]";
    regThreshold = "0.30";
    maxAvgThreshold = "2.50";
    absThreshold = "3.50";
    computeOverlap = "[Save computation time (but use more RAM)]"; // IMPORTANT: Can be changed for better results
    imageOutput = "[Fuse and display]";

    // Configurable file name pattern for the stitching plugin (Default: "Image_XXX_CH1.tif")
    fileNamePattern = "Image_" + xyNum + "_{iiiii}_CH" + 1 + imageNameSuffix; // Adjust if CH number is different

    run("Grid/Collection stitching", "type=" + gridType + " order=" + gridOrder + " grid_size_x=" + numCols + " grid_size_y=" + numRows + " tile_overlap=" + tileOverlap + " first_file_index_i=" + firstFileIndex + " directory=[" + folder + "] file_names=" + fileNamePattern + " output_textfile_name=" + outputTxtFile + " fusion_method=" + fusionMethod + " regression_threshold=" + regThreshold + " max/avg_displacement_threshold=" + maxAvgThreshold + " absolute_displacement_threshold=" + absThreshold + " compute_overlap=" + computeOverlap + " image_output=" + imageOutput);

    // Check if an image is open
    if (nImages > 0) {
        // Flatten the image
        run("Flatten");

        // Configurable output file name (Default: "stitched_result.tif")
        outputName = "stitched_result.tif";

        // Save the result
        saveAs("Tiff", folder + File.separator + outputName);

        // Close all images
        run("Close All");

        print("Stitching successful for folder: " + folder + " with " + imageCount + " images");
    } else {
        print("Stitching failed for folder: " + folder);
    }
}

print("All stitching operations done.");
