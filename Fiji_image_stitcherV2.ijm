// --------------------------------------------------------------------
// Stitching script for Fiji/ImageJ,
// --------------------------------------------------------------------

// --------------------------------------------------
// 1) Query dialog
// --------------------------------------------------
Dialog.create("Stitching Configuration");
Dialog.addMessage("Please specify the following parameters:");
Dialog.addMessage("Note on the filename pattern:");
Dialog.addMessage("- {subfolder} is replaced by the subfolder name (e.g. XY01).");
Dialog.addMessage("- {i}  without leading zeros (e.g. 1, 2, 3, ...)");
Dialog.addMessage("- {ii} for 2-digit indices with leading zeros (01, 02, ...)");
Dialog.addMessage("- {iii} for 3-digit indices (001, 002, ...), etc.");
Dialog.addMessage("- Example: H2_Image_{subfolder}_{iiiii}_CH4 for 5 leading zeros (00001, 00002, ...)");

Dialog.addString("Subfolder prefix (e.g. 'XY'):", "XY");
// Default e.g. with 5 leading zeros:
Dialog.addString("Filename pattern (e.g. H2_Image_{subfolder}_{iiiii}_CH4):", "H2_Image_{subfolder}_{iiiii}_CH4");
Dialog.addString("File extension (e.g. .tif):", ".tif");

Dialog.addString("Overlap in % (e.g. 20):", "20");
Dialog.addMessage("Grid Size (e.g. 2x3). 0x0 => calculate automatically.");
Dialog.addString("Grid Size:", "0x0");

Dialog.show();

subfolderPrefix    = Dialog.getString();
fileNamePatternRaw = Dialog.getString();
fileExtension      = Dialog.getString();
tileOverlapPercent = Dialog.getString();
gridSizeInput      = Dialog.getString();

// --------------------------------------------------
// 2) Select main directory
// --------------------------------------------------
mainDir = getDirectory("Select the folder containing the '" + subfolderPrefix + "...'-subfolders:");
if (mainDir == "") {
    exit("No main directory selected. Aborting.");
}

// --------------------------------------------------
// 3) Settings for "Grid/Collection stitching"
// --------------------------------------------------
fusionMethod    = "[Linear Blending]";
regThreshold    = 0.30;
maxAvgThreshold = 2.50;
absThreshold    = 3.50;
computeOverlap  = "[Save memory (but be slower)]";
imageOutput     = "[Fuse and display]";
outputName      = "stitched_result.tif";

// --------------------------------------------------
// Additional helper functions for the macro environment
// --------------------------------------------------

// Simple "ceil"
function macroCeil(x) {
    intPart = floor(x);
    if (x > intPart) {
        return intPart + 1;
    } else {
        return intPart;
    }
}

// Extract the last sequence of digits from the filename (e.g. "_00009_") -> parseInt
function extractNumberForI(fname) {
    // 1) Remove the extension .tif (only if you have exactly .tif)
    if (endsWith(fname, ".tif")) {
        fnameNoExt = substring(fname, 0, lengthOf(fname) - 4);
    } else {
        fnameNoExt = fname;
    }

    // 2) Check if we have a "_CH" + something
    //    (e.g. "_CH4", "_CH405", etc.)
    chPos = lastIndexOf(fnameNoExt, "_CH");
    if (chPos >= 0) {
        // Then cut off everything from "_CH"
        fnameNoExt = substring(fnameNoExt, 0, chPos);
    }

    // 3) Get the last sequence of digits from the remaining filename
    numberString = "";
    i = lengthOf(fnameNoExt) - 1;
    while (i >= 0) {
        c = substring(fnameNoExt, i, i+1);
        if (matches(c, "[0-9]")) {
            numberString = c + numberString;
        } else {
            // If we have already found digits, then stop
            // as soon as a non-digit character comes
            if (lengthOf(numberString) > 0) {
                break;
            }
        }
        i--;
    }

    // If we have not found any digits:
    if (lengthOf(numberString) == 0) {
        return 0;
    }
    return parseInt(numberString);
}

// --------------------------------------------------
// 4) Go through all folders in the main directory
// --------------------------------------------------
allEntries = getFileList(mainDir);
for (i = 0; i < allEntries.length; i++) {
    entryName = allEntries[i];
    fullPath  = mainDir + entryName;

    // Only folders that start with subfolderPrefix
    if (startsWith(entryName, subfolderPrefix) && File.isDirectory(fullPath)) {
        
        // Remove trailing slash, e.g. "XY01/" -> "XY01"
        if (endsWith(entryName, "/")) {
            cleanEntryName = substring(entryName, 0, lengthOf(entryName) - 1);
        } else {
            cleanEntryName = entryName;
        }

        fullPath = mainDir + cleanEntryName + File.separator;
        stitchFolder(fullPath, cleanEntryName);
    }
}

print("All stitching processes completed.");

// ====================================================================
// Function to process a subfolder (e.g. XY01)
// ====================================================================
function stitchFolder(folderPath, subfolderName) {
    print("");
    print("=== Starting stitching for subfolder: " + subfolderName + " ===");

    // 1) Get file list
    list = getFileList(folderPath);
    
    // Debug output
    print("----- Folder:", folderPath);
    for (j = 0; j < list.length; j++) {
        print("File found:", list[j]);
    }

    // 2) Adjust file pattern: {subfolder} -> subfolderName
    fileNamePattern = replace(fileNamePatternRaw, "\\{subfolder\\}", subfolderName);

    // 3) Collect all matching files
    imgFiles = newArray(0);
    for (j = 0; j < list.length; j++) {
        fName = list[j];

        // skip subfolders
        if (File.isDirectory(folderPath + File.separator + fName)) {
            continue;
        }

        // Must match extension?
        if (!endsWith(fName, fileExtension)) {
            continue;
        }

        // Must contain "pattern" (without {i}):
        splittedParts = split(fileNamePattern, "{i}");
        if (lengthOf(splittedParts) == 2) {
            part1 = splittedParts[0];
            part2 = splittedParts[1];

            // Check if the filename matches the pattern:
            if (startsWith(fName, part1) && indexOf(fName, part2) > 0) {
                // Part between part1 and part2
                middlePart = substring(fName, lengthOf(part1), indexOf(fName, part2));
                // Check if only digits
                if (matches(middlePart, "^[0-9]+$")) {
                    imgFiles = Array.concat(imgFiles, fName);
                }
            }
        } else {
            // No {i} in the pattern -> check if fName contains the string fileNamePattern
            if (indexOf(fName, fileNamePattern) >= 0) {
                imgFiles = Array.concat(imgFiles, fName);
            }
        }
    }

    nImagesFound = lengthOf(imgFiles);
    print("Images found:", nImagesFound);

    if (nImagesFound < 2) {
        print("Too few images in " + subfolderName + " => Aborting.");
        return;
    }

    // 4) Sort by numbers - via keys array
    keys = newArray(nImagesFound);
    for (k = 0; k < nImagesFound; k++) {
        keys[k] = extractNumberForI(imgFiles[k]);
    }
    Array.sort(keys, imgFiles);

    // 5) Determine grid size
    tileOverlap = parseFloat(tileOverlapPercent);
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
        // Automatically sqrt(n)
        gridAuto = macroCeil(sqrt(nImagesFound));
        gridX = gridAuto;
        gridY = gridAuto;
        print("Grid Size automatically = " + gridX + "x" + gridY);
    } else {
        print("Selected Grid Size = " + gridX + "x" + gridY);
    }

    // 6) Pass index range to the stitching plugin:
    firstIndex = keys[0];               // smallest image number found
    lastIndex  = keys[nImagesFound-1];  // largest image number found
    
    // Now we build the filename pattern for the plugin.
    // There MUST be an {i} where the index comes in.
    // Example: "H2_Image_XY01_{i}_CH4.tif"
// New (correct):
fileNamesArg = replace(fileNamePattern, "\\{i\\}", "{i}") + fileExtension;

    // 7) Call Grid/Collection stitching with all parameters
    run("Grid/Collection stitching",
        "type=[Grid: snake by rows] " +
        "order=[Right & Down                ] " + // Spaces are important
        "grid_size_x=" + gridX + " " +
        "grid_size_y=" + gridY + " " +
        "tile_overlap=" + tileOverlap + " " +
        "directory=[" + folderPath + "] " +
        "file_names=" + fileNamesArg + " " +
        "output_textfile_name=TileConfiguration.txt " +
        "first_file_index_i=" + firstIndex + " " +
        "last_file_index_i=" + lastIndex + " " +
        "fusion_method=" + fusionMethod + " " +
        "regression_threshold=" + regThreshold + " " +
        "max/avg_displacement_threshold=" + maxAvgThreshold + " " +
        "absolute_displacement_threshold=" + absThreshold + " " +
        "computation_parameters=" + computeOverlap + " " +
        "image_output=" + imageOutput
    );

    // 8) Save stitched image if open
    if (nImages > 0) {
        run("Flatten");
        saveAs("Tiff", folderPath + File.separator + outputName);
        run("Close All");
        print("Stitching successful. Saved under:", folderPath + File.separator + outputName);
    } else {
        print("Stitching failed (no image open).");
    }
}
