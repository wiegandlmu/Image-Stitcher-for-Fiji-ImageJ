// --------------------------------------------------------------------
// Automated Batch Stitching Script for Fiji/ImageJ
// Version 3.0 - Verbesserte Nummern-Erkennung
// Author: Max Wiegand (Modified with flexible pattern detection)
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
Dialog.addMessage("Wiegand, M. (2025). ImageJ Fiji Auto-Stitcher (Version 3.0)");
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
Dialog.addMessage("NEUE FUNKTION: Automatische Erkennung von Dateinamen-Mustern");
Dialog.addMessage("Das Script erkennt automatisch verschiedene Präfixe und findet");
Dialog.addMessage("die aufsteigenden Nummern in deinen Bildern.");
Dialog.addMessage("");
Dialog.addString("File extension (e.g. .tif):", ".tif");
Dialog.addMessage("Grid size (e.g. 3x3). 0x0 => calculate automatically.");
Dialog.addString("Grid size:", "0x0");
Dialog.show();

fileExtension      = Dialog.getString();
gridSizeInput      = Dialog.getString();

// Fixed overlap at 20%
tileOverlap        = "20";

// --------------------------------------------------
// 2) Select Main Directory
// --------------------------------------------------
mainDir = getDirectory("Select main folder containing subfolders to stitch:");
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
// 4) Create Output Directory
// --------------------------------------------------
outputDir = mainDir + "Autostitch" + File.separator;
if (!File.exists(outputDir)) {
    File.makeDirectory(outputDir);
    print("Created output directory: " + outputDir);
} else {
    print("Output directory exists: " + outputDir);
}

// --------------------------------------------------
// 5) Process All Subfolders
// --------------------------------------------------
allEntries = getFileList(mainDir);
for (i = 0; i < allEntries.length; i++) {
    entryName = allEntries[i];
    
    if (File.isDirectory(mainDir + entryName) && entryName != "Autostitch" && entryName != "Autostitch/") {
        currentFolder = mainDir + entryName;
        processFolder(currentFolder, outputDir);
    }
}

print("All stitching operations completed.");

// ====================================================================
// NEUE FUNKTION: Analysiere Dateinamen-Muster im Ordner
// ====================================================================
function analyzeFilenamePattern(folder) {
    list = getFileList(folder);
    
    // Sammle alle passenden Dateien
    validFiles = newArray();
    for (j = 0; j < list.length; j++) {
        if (endsWith(list[j], fileExtension)) {
            validFiles = Array.concat(validFiles, list[j]);
        }
    }
    
    if (validFiles.length == 0) {
        return newArray("", "", 0, 5); // pattern, prefix, count, padding
    }
    
    Array.sort(validFiles);
    
    print("DEBUG: Analyzing filename patterns from " + validFiles.length + " files");
    print("DEBUG: First file: " + validFiles[0]);
    if (validFiles.length > 1) {
        print("DEBUG: Second file: " + validFiles[1]);
    }
    
    // Analysiere das erste File um das Muster zu finden
    firstFile = validFiles[0];
    baseName = replace(firstFile, fileExtension, "");
    
    // Finde alle Zahlensequenzen im Dateinamen
    numberPositions = newArray();
    numberValues = newArray();
    numberLengths = newArray();
    
    i = 0;
    while (i < lengthOf(baseName)) {
        char = substring(baseName, i, i+1);
        if (char >= "0" && char <= "9") {
            // Start einer Zahlensequenz gefunden
            startPos = i;
            numStr = "";
            while (i < lengthOf(baseName)) {
                char = substring(baseName, i, i+1);
                if (char >= "0" && char <= "9") {
                    numStr += char;
                    i++;
                } else {
                    break;
                }
            }
            numberPositions = Array.concat(numberPositions, startPos);
            numberValues = Array.concat(numberValues, parseInt(numStr));
            numberLengths = Array.concat(numberLengths, lengthOf(numStr));
        } else {
            i++;
        }
    }
    
    print("DEBUG: Found " + numberPositions.length + " number sequences");
    for (n = 0; n < numberPositions.length; n++) {
        print("DEBUG: Position " + numberPositions[n] + ": value=" + numberValues[n] + ", length=" + numberLengths[n]);
    }
    
    // Finde die Nummer die sich zwischen Files ändert (wahrscheinlich die Tile-Nummer)
    bestNumberIndex = -1;
    if (validFiles.length > 1 && numberPositions.length > 0) {
        secondFile = validFiles[1];
        secondBaseName = replace(secondFile, fileExtension, "");
        
        for (n = 0; n < numberPositions.length; n++) {
            pos = numberPositions[n];
            len = numberLengths[n];
            
            if (pos + len <= lengthOf(secondBaseName)) {
                secondNumStr = substring(secondBaseName, pos, pos + len);
                secondNum = parseInt(secondNumStr);
                
                if (secondNum == numberValues[n] + 1) {
                    bestNumberIndex = n;
                    print("DEBUG: Found incrementing number at position " + pos);
                    break;
                }
            }
        }
    } else if (numberPositions.length > 0) {
        // Nur eine Datei: nimm die längste Zahlensequenz
        maxLen = 0;
        for (n = 0; n < numberPositions.length; n++) {
            if (numberLengths[n] > maxLen) {
                maxLen = numberLengths[n];
                bestNumberIndex = n;
            }
        }
    }
    
    if (bestNumberIndex == -1) {
        print("WARNING: Could not identify tile number sequence");
        return newArray("", "", 0, 5);
    }
    
    // Baue das Pattern
    numPos = numberPositions[bestNumberIndex];
    numLen = numberLengths[bestNumberIndex];
    
    prefix = substring(baseName, 0, numPos);
    suffix = substring(baseName, numPos + numLen);
    
    // Erstelle Padding-String für Fiji
    paddingStr = "";
    for (p = 0; p < numLen; p++) {
        paddingStr += "i";
    }
    
    pattern = prefix + "{" + paddingStr + "}" + suffix + fileExtension;
    
    print("DEBUG: Detected pattern: " + pattern);
    print("DEBUG: Prefix: " + prefix);
    print("DEBUG: Padding length: " + numLen);
    
    // Zähle sequentielle Bilder
    count = 0;
    index = 1;
    maxGaps = 3;
    gapCount = 0;
    
    while (gapCount < maxGaps && index <= 1000) {
        indexStr = "" + index;
        while (lengthOf(indexStr) < numLen) {
            indexStr = "0" + indexStr;
        }
        
        testFilename = prefix + indexStr + suffix + fileExtension;
        
        fileExists = false;
        for (j = 0; j < validFiles.length; j++) {
            if (validFiles[j] == testFilename) {
                fileExists = true;
                break;
            }
        }
        
        if (fileExists) {
            count = index;
            gapCount = 0;
        } else {
            gapCount++;
        }
        
        index++;
    }
    
    print("DEBUG: Found " + count + " sequential images");
    
    return newArray(pattern, prefix, count, numLen);
}

// ====================================================================
// Function to Process a Subfolder
// ====================================================================
function processFolder(folder, outputDirectory) {
    print("");
    print("=== Starting stitching for: " + folder + " ===");
    
    // Analysiere Dateinamen-Muster
    analysisResult = analyzeFilenamePattern(folder);
    filePattern = analysisResult[0];
    detectedPrefix = analysisResult[1];
    imageCount = parseInt(analysisResult[2]);
    paddingLength = parseInt(analysisResult[3]);
    
    if (filePattern == "" || imageCount < 2) {
        print("ERROR: Could not detect valid filename pattern or too few images");
        print("Found only " + imageCount + " sequential images. Skipping.");
        return;
    }
    
    print("Detected filename pattern: " + filePattern);
    print("Valid sequential images found: " + imageCount);
    
    // Determine grid size
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
        gridSize = Math.ceil(Math.sqrt(imageCount));
        gridX = gridSize;
        gridY = gridSize;
        print("Grid size automatically set to: " + gridX + "x" + gridY);
    } else {
        print("Selected grid size: " + gridX + "x" + gridY);
    }
    
    expectedImages = gridX * gridY;
    if (expectedImages > imageCount) {
        gridSize = Math.ceil(Math.sqrt(imageCount));
        gridX = gridSize;
        gridY = gridSize;
        print("Grid size adjusted to match available images: " + gridX + "x" + gridY);
    }
    
    // Generate output filename
    folderName = File.getName(folder);
    outputName = folderName + "_stitched";
    outputPath = outputDirectory + outputName + fileExtension;
    
    print("Output filename: " + outputName + fileExtension);
    
    // Delete existing file if exists
    if (File.exists(outputPath)) {
        File.delete(outputPath);
        print("Deleted existing file: " + outputPath);
    }
    
    // Execute Grid/Collection Stitching
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
    
    // Save result
    if (nImages > 0) {
        if (bitDepth() != 24) {
            run("RGB Color");
        }
        saveAs("Tiff", outputPath);
        run("Close All");
        print("Stitching successful: " + outputPath);
    } else {
        print("WARNING: Stitching completed but no image was generated for: " + folder);
        print("This may indicate that the images could not be aligned properly.");
    }
}
