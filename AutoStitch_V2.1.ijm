// --------------------------------------------------------------------
// Automated Batch Stitching Script for Fiji/ImageJ
// Version 2.1
// Author: Max Wiegand
// --------------------------------------------------------------------

// --------------------------------------------------
// 0) Citation Agreement Dialog
// --------------------------------------------------
Dialog.create("Terms of Use - Citation Required");
Dialog.addMessage("IMPORTANT: Terms of Use");
Dialog.addMessage("By using this script, you agree to cite it in any resulting");
Dialog.addMessage("publications, presentations, or other academic work.");
Dialog.addMessage("");
Dialog.addMessage("Please cite as:");
Dialog.addMessage("Wiegand, M. (2025). ImageJ Fiji Auto-Stitcher (Version 2.1)");
Dialog.addMessage("[Computer software].");
Dialog.addMessage("GitHub. https://github.com/wiegandlmu/ImageJ-Fiji-Auto-Stitcher");
Dialog.addMessage("Zenodo. https://doi.org/10.5281/zenodo.17273821");
Dialog.addMessage("");
Dialog.addCheckbox("I agree to cite this script in my work", false);
Dialog.show();

citationAgreed = Dialog.getCheckbox();
if (!citationAgreed) {
    exit("You must agree to the citation terms to use this script.");
}

// --------------------------------------------------
// 1) Configuration Dialog
// --------------------------------------------------
Dialog.create("Stitching Configuration");
Dialog.addMessage("Please specify the following parameters:");
Dialog.addString("Subfolder prefix (e.g. 'XY'):", "XY");
Dialog.addString("Filename pattern (e.g. H2_Image_XY{xy}_0000{i}_CH4):", "H2_Image_XY{xy}_0000{i}_CH4");
Dialog.addString("File extension (e.g. .tif):", ".tif");
Dialog.addMessage("Grid size (e.g. 3x3). 0x0 => calculate automatically.");
Dialog.addString("Grid size:", "0x0");
Dialog.show();

subfolderPrefix    = Dialog.getString();
fileNamePattern    = Dialog.getString();
fileExtension      = Dialog.getString();
gridSizeInput      = Dialog.getString();

// Fixed overlap at 20% (standard value for most applications)
tileOverlap        = "20";

// --------------------------------------------------
// 2) Select Main Directory
// --------------------------------------------------
mainDir = getDirectory("Select folder containing '" + subfolderPrefix + "' subfolders:");
if (mainDir == "") {
    exit("No directory selected. Aborting.");
}

// --------------------------------------------------
// 3) Stitching Settings
// --------------------------------------------------
fusionMethod    = "[Linear Blending]";
regThreshold    = 0.30;
maxAvgThreshold = 2.50;
absThreshold    = 3.50;

// --------------------------------------------------
// 4) Process All Matching Subfolders
// --------------------------------------------------
allEntries = getFileList(mainDir);
for (i = 0; i < allEntries.length; i++) {
    entryName = allEntries[i];
    
    if (startsWith(entryName, subfolderPrefix) && File.isDirectory(mainDir + entryName)) {
        currentFolder = mainDir + entryName;
        processFolder(currentFolder);
    }
}

print("All stitching operations completed.");

// ====================================================================
// Function to Process a Subfolder
// ====================================================================
function processFolder(folder) {
    print("");
    print("=== Starting stitching for: " + folder + " ===");
    
    // 1) Get file list and sort
    list = getFileList(folder);
    Array.sort(list);
    
    // 2) Extract XY number from folder name
    folderName = File.getName(folder);
    xyNum = substring(folderName, lengthOf(subfolderPrefix));
    
    // 3) Count relevant images
    imageCount = 0;
    for (j = 0; j < list.length; j++) {
        if (endsWith(list[j], fileExtension)) {
            imageCount++;
        }
    }
    
    if (imageCount < 2) {
        print("Too few images in: " + folder + ". Skipping.");
        return;
    }
    
    print("Images found: " + imageCount);
    
    // 4) Determine grid size
    gridX = 0;
    gridY = 0;
    if (indexOf(gridSizeInput, "x") != -1) {
        parts = split(gridSizeInput, "x");
        if (lengthOf(parts) == 2) {
            gridX = parseInt(parts[0]);
            gridY = parseInt(parts[1]);
        }
    }
    
    if (isNaN(gridX) || isNaN(gridY) || gridX <= 0 || gridY <= 0) {
        // Calculate automatically
        gridSize = Math.ceil(Math.sqrt(imageCount));
        gridX = gridSize;
        gridY = gridSize;
        print("Grid size automatically set to: " + gridX + "x" + gridY);
    } else {
        print("Selected grid size: " + gridX + "x" + gridY);
    }
    
    // 5) Adjust filename pattern
    filePattern = replace(fileNamePattern, "\\{xy\\}", xyNum);
    filePattern = replace(filePattern, "\\{i\\}", "{i}");
    filePattern = filePattern + fileExtension;
    
    print("Filename pattern: " + filePattern);
    
    // 6) Execute Grid/Collection Stitching
    run("Grid/Collection stitching",
        "type=[Grid: snake by rows] " +
        "order=[Right & Down                ] " +
        "grid_size_x=" + gridX + " " +
        "grid_size_y=" + gridY + " " +
        "tile_overlap=" + tileOverlap + " " +
        "first_file_index_i=1 " +
        "directory=[" + folder + "] " +
        "file_names=" + filePattern + " " +
        "output_textfile_name=TileConfiguration.txt " +
        "fusion_method=" + fusionMethod + " " +
        "regression_threshold=" + regThreshold + " " +
        "max/avg_displacement_threshold=" + maxAvgThreshold + " " +
        "absolute_displacement_threshold=" + absThreshold + " " +
        "subpixel_accuracy " +
        "compute_overlap " +
        "computation_parameters=[Save computation time (but use more RAM)] " +
        "image_output=[Fuse and display]"
    );
    
    // 7) Save result
    if (nImages > 0) {
        // Ensure image is in RGB
        if (bitDepth() != 24) {
            run("RGB Color");
        }
        saveAs("Tiff", folder + File.separator + "stitched_result.tif");
        run("Close All");
        print("Stitching successful: " + folder);
    } else {
        print("Stitching failed: " + folder);
    }
}
