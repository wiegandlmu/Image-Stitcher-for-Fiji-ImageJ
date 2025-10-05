// --------------------------------------------------
// 1) Konfigurationsdialog
// --------------------------------------------------
Dialog.create("Stitching Konfiguration");
Dialog.addMessage("Bitte folgende Parameter angeben:");
Dialog.addString("Unterordner-Praefix (z.B. 'XY'):", "XY");
Dialog.addString("Dateiname-Muster (z.B. H2_Image_XY{xy}_0000{i}_CH4):", "H2_Image_XY{xy}_0000{i}_CH4");
Dialog.addString("Dateiendung (z.B. .tif):", ".tif");
Dialog.addString("Ueberlappung in % (z.B. 20):", "20");
Dialog.addMessage("Grid-Groeße (z.B. 3x3). 0x0 => automatisch berechnen.");
Dialog.addString("Grid-Größe:", "0x0");
Dialog.show();

subfolderPrefix    = Dialog.getString();
fileNamePattern    = Dialog.getString();
fileExtension      = Dialog.getString();
tileOverlap        = Dialog.getString();
gridSizeInput      = Dialog.getString();

// --------------------------------------------------
// 2) Hauptverzeichnis auswählen
// --------------------------------------------------
mainDir = getDirectory("Ordner mit '" + subfolderPrefix + "'-Unterordnern auswählen:");
if (mainDir == "") {
    exit("Kein Verzeichnis ausgewählt. Abbruch.");
}

// --------------------------------------------------
// 3) Stitching-Einstellungen
// --------------------------------------------------
fusionMethod    = "[Linear Blending]";
regThreshold    = 0.30;
maxAvgThreshold = 2.50;
absThreshold    = 3.50;

// --------------------------------------------------
// 4) Alle passenden Unterordner verarbeiten
// --------------------------------------------------
allEntries = getFileList(mainDir);
for (i = 0; i < allEntries.length; i++) {
    entryName = allEntries[i];
    
    if (startsWith(entryName, subfolderPrefix) && File.isDirectory(mainDir + entryName)) {
        currentFolder = mainDir + entryName;
        processFolder(currentFolder);
    }
}

print("Alle Stitching-Operationen abgeschlossen.");

// ====================================================================
// Funktion zum Verarbeiten eines Unterordners
// ====================================================================
function processFolder(folder) {
    print("");
    print("=== Starte Stitching für: " + folder + " ===");
    
    // 1) Dateiliste abrufen und sortieren
    list = getFileList(folder);
    Array.sort(list);
    
    // 2) XY-Nummer aus Ordnername extrahieren
    folderName = File.getName(folder);
    xyNum = substring(folderName, lengthOf(subfolderPrefix));
    
    // 3) Relevante Bilder zählen
    imageCount = 0;
    for (j = 0; j < list.length; j++) {
        if (endsWith(list[j], fileExtension)) {
            imageCount++;
        }
    }
    
    if (imageCount < 2) {
        print("Zu wenige Bilder in: " + folder + ". Überspringe.");
        return;
    }
    
    print("Gefundene Bilder: " + imageCount);
    
    // 4) Grid-Größe bestimmen
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
        // Automatisch berechnen
        gridSize = Math.ceil(Math.sqrt(imageCount));
        gridX = gridSize;
        gridY = gridSize;
        print("Grid-Größe automatisch: " + gridX + "x" + gridY);
    } else {
        print("Gewählte Grid-Größe: " + gridX + "x" + gridY);
    }
    
    // 5) Dateiname-Muster anpassen
    filePattern = replace(fileNamePattern, "\\{xy\\}", xyNum);
    filePattern = replace(filePattern, "\\{i\\}", "{i}");
    filePattern = filePattern + fileExtension;
    
    print("Dateiname-Muster: " + filePattern);
    
    // 6) Grid/Collection Stitching ausführen
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
        "compute_overlap " +
        "computation_parameters=[Save computation time (but use more RAM)] " +
        "image_output=[Fuse and display]"
    );
    
    // 7) Ergebnis speichern
    if (nImages > 0) {
        // Sicherstellen, dass das Bild in RGB ist
        if (bitDepth() != 24) {
            run("RGB Color");
        }
        saveAs("Tiff", folder + File.separator + "stitched_result.tif");
        run("Close All");
        print("Stitching erfolgreich: " + folder);
    } else {
        print("Stitching fehlgeschlagen: " + folder);
    }
}
