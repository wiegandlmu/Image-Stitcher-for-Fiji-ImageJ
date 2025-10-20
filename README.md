# ImageJ Fiji Auto-Stitcher

This ImageJ macro, designed for use within Fiji (https://fiji.sc/), automates the stitching of multiple images into a single large image. It's particularly useful for images acquired using a microscope with a tiling function.

**Important**: This script requires Fiji, which is a distribution of ImageJ that includes many useful plugins, including the "Grid/Collection stitching" plugin used by this script. Plain ImageJ might not have all the required plugins. Download Fiji from https://fiji.sc/.

## ⚠️ Terms of Use and Citation

**By using this script, you agree to cite it in any resulting publications, presentations, or other academic work.**

If you use this script in your research and publish the results, please cite it as follows:

```
Wiegand, M. (2025). ImageJ Fiji Auto-Stitcher (Version 3.0) [Computer software]. 
GitHub. https://github.com/wiegandlmu/ImageJ-Fiji-Auto-Stitcher
Zenodo. https://doi.org/10.5281/zenodo.17273821
```

**Recommended citation style for BibTeX:**

```bibtex
@software{wiegand2025autostitcher,
  author = {Wiegand, Max},
  title = {ImageJ Fiji Auto-Stitcher},
  year = {2025},
  version = {3.0},
  url = {https://github.com/wiegandlmu/ImageJ-Fiji-Auto-Stitcher},
  note = {Computer software}
}
```

**When you run the script for the first time, you will be asked to acknowledge this citation requirement.**

Citing this work allows others to find and utilize this tool and acknowledges the effort put into its development.

## Features

- **NEW: Intelligent Pattern Recognition**: Automatically detects filename patterns and numbering schemes without manual configuration
- **NEW: Flexible File Naming**: Handles different prefixes in different folders (e.g., `Image_XY01_00001.tif` vs `H2_Image_XY01_00001.tif`)
- **NEW: Automatic Padding Detection**: Recognizes different zero-padding lengths (00001, 0001, 001, etc.)
- **Optimized Overlap**: Uses a standard 20% overlap value that works well for most microscopy applications
- **Optimized for Single Images**: Streamlined for stitching individual 2D images (no Z-stacks)
- **Sharp Stitching**: Uses subpixel accuracy and optimized computation for precise overlap, resulting in sharp stitching results
- **RGB Color Preservation**: Automatically maintains color information in stitched images
- **User-Friendly**: Minimal configuration required - the script does the heavy lifting
- **Automatic Grid Size Calculation**: Intelligently calculates appropriate grid sizes based on image count

## What's New in Version 3.0?

Version 3.0 introduces **intelligent pattern recognition** that eliminates the need for manual filename pattern configuration:

- **Automatic Pattern Detection**: The script now analyzes your files and automatically detects:
  - File name structure and prefixes
  - Which number sequence represents the tile numbers
  - Zero-padding length (e.g., 00001 vs 0001)
  
- **Handles Varying Prefixes**: Works seamlessly even when different folders have different filename prefixes:
  - Folder XY01: `Image_XY01_00001_CH4.tif`
  - Folder XY02: `H2_Image_XY02_00001_CH4.tif`
  - Folder XY03: `Sample1_Image_XY03_00001_CH4.tif`

- **Enhanced Diagnostics**: Provides detailed debug output showing what was detected

## Prerequisites

- **Fiji**: Download and install Fiji from https://fiji.sc/

## How to Use

### 1. Acquire Images with Your Microscope

- **Storage Format**: Save images as TIFF (uncompressed or LZW-compressed)
- **Tiling**: Use the tiling function of your microscope to capture multiple images for stitching
- **Folder Structure**: The script expects images to be organized in subfolders within a main directory. Each subfolder should contain images belonging to one stitched image

#### Example folder structure:
```
MainFolder/
├── XY01/
│   ├── Image_XY01_00001_CH4.tif
│   ├── Image_XY01_00002_CH4.tif
│   └── Image_XY01_00003_CH4.tif
├── XY02/
│   ├── H2_Image_XY02_00001_CH4.tif
│   ├── H2_Image_XY02_00002_CH4.tif
│   └── H2_Image_XY02_00003_CH4.tif
└── XY03/
    ├── Sample1_Image_XY03_00001_CH4.tif
    ├── Sample1_Image_XY03_00002_CH4.tif
    └── Sample1_Image_XY03_00003_CH4.tif
```

**The script will automatically detect the pattern in each folder!**

- **File Naming**: 
  -  **Sequential numbering required**: Files must have sequential numbers (1, 2, 3... or 00001, 00002, 00003...)
  -  **Any prefix allowed**: The script automatically detects prefixes
  -  **Consistent numbering within folders**: Each folder should use the same numbering pattern
  -  **Different prefixes between folders**: Each folder can have its own unique prefix

- **Overlap**: The script uses a standard **20% overlap** value
  - This works well for most microscopy applications
  - Ensure your microscope is configured to capture images with approximately 15-25% overlap
  - **What is overlap?** The percentage of the image area that overlaps with the neighboring image
  - **Example**: With 20% overlap, a 1000×1000 pixel image overlaps 200 pixels with its neighbor
  - If your microscope uses a significantly different overlap (e.g., 10% or 40%), you may need to modify the script (see "Advanced Settings" section)

- **No Z-Stacks**: This script is designed for single images only, not Z-stacks

### 2. Install and Run the Script in Fiji

1. **Download the script**:
   - If you are on the GitHub repository page, scroll up to the top
   - Click the green "Code" button
   - Select "Download ZIP"
   - Save the ZIP file to your computer and unzip it

2. **Open the script in Fiji**:
   - Open Fiji
   - Go to "Plugins" → "Macros" → "Run..."
   - Navigate to the unzipped folder and select the `AutoStitch_V3.0.ijm` file
   - Click "Open"

3. **Accept Citation Terms**:
   - A dialog will appear asking you to acknowledge the citation requirement
   - Click "I agree to cite this script in my work" checkbox
   - Click "OK" to proceed

4. **Configuration Dialog** (Simplified!):
   - A dialog box will appear with minimal configuration needed:
     - **File extension**: The extension of your image files (default: ".tif")
     - **Grid Size**: Specify the grid size (e.g., "3x3") or use "0x0" for automatic calculation
       - **Automatic calculation (0x0)**: The script calculates a square grid based on the number of images
         - Example: 9 images → 3×3 grid, 16 images → 4×4 grid, 10 images → 4×4 grid (with 6 empty positions)
         - ⚠️ **Important**: Automatic calculation assumes a square or nearly-square grid arrangement
         - If your images are arranged in a rectangular grid (e.g., 2×6), you **must** enter the grid size manually
       - **Manual entry**: Recommended if you know your exact grid dimensions (e.g., "2x6", "3x4")
   - Click "OK"

5. **Select Main Folder**:
   - A new window will appear
   - Navigate to the main folder and select it (the folder containing the subfolders with the images)

6. **Monitor Progress**:
   - The script will process each subfolder automatically
   - Watch the Log window for detailed information about pattern detection and progress
   - The log will show:
     - Detected filename patterns for each folder
     - Number of sequential images found
     - Grid size being used
     - Success/error messages

7. **Finding the stitched images**:
   - Stitched images will be saved in a new folder called `Autostitch` in your main directory
   - Each stitched image is named after its source folder (e.g., `XY01_stitched.tif`)
   - The final stitched image will also be displayed in Fiji

## Understanding the Pattern Detection

The script automatically analyzes your files and detects the sequential numbering pattern. **The actual filename doesn't matter - only the sequential numbers!**

### Example 1: Simplest Possible Case
**Files**: `1.tif`, `2.tif`, `3.tif`, `4.tif`
- **Detected**: Single number sequence
- **Pattern**: `{i}.tif` (1-digit)
- **Works perfectly!**

### Example 2: With Padding
**Files**: `001.tif`, `002.tif`, `003.tif`
- **Detected**: Zero-padded sequence
- **Pattern**: `{iii}.tif` (3-digit padding)

### Example 3: Standard Pattern
**Files**: `Image_XY01_00001_CH4.tif`, `Image_XY01_00002_CH4.tif`
- **Detected**: Multiple number sequences found (XY01 and 00001)
- **Identified**: The sequence that increments (00001 → 00002) is the tile number
- **Pattern**: `Image_XY01_{iiiii}_CH4.tif` (5-digit padding)

### Example 4: Complex Custom Naming
**Files**: `MyExperiment_Sample3_Tile_00001_488nm.tif`, `MyExperiment_Sample3_Tile_00002_488nm.tif`
- **Detected**: The incrementing sequence is "00001" → "00002"
- **Pattern**: `MyExperiment_Sample3_Tile_{iiiii}_488nm.tif`
- **Everything else is just text - the script handles it automatically!**

### Example 5: Different Folders, Different Filenames
**Folder XY01**: `Image_XY01_00001.tif`
**Folder XY02**: `Scan2_Image_XY02_00001.tif`
**Folder XY03**: `1.tif`, `2.tif`, `3.tif`
- Each folder is analyzed independently
- Different patterns are applied to each folder automatically
- **The script doesn't care about folder names or filename prefixes - it just finds the sequential numbers!**

## Troubleshooting

### "Could not detect valid filename pattern" message

This usually means the script couldn't identify sequential numbering. Check:
- **Sequential numbering**: Files must be numbered 1, 2, 3... (or 00001, 00002, 00003...) **starting from 1**
- **No gaps**: The sequence should be continuous (1, 2, 3, not 1, 3, 5)
- **Consistent pattern**: All files in a folder should use the same numbering and padding
- **File extension**: Ensure the file extension matches what you specified (default: .tif)

**The filename itself can be anything - only the sequential numbers matter!**

### Example of good numbering:
- Good: `1.tif`, `2.tif`, `3.tif`, `4.tif`
- Good: `Image_001.tif`, `Image_002.tif`, `Image_003.tif`
- Good: `Tile_00001.tif`, `Tile_00002.tif`, `Tile_00003.tif`
- Good: `abc_xyz_123_00001.tif`, `abc_xyz_123_00002.tif`

**Example of problematic numbering**:
- Bad: `Image_1.tif`, `Image_3.tif`, `Image_7.tif` (gaps in sequence)
- Bad: `Image_0.tif`, `Image_1.tif`, `Image_2.tif` (starts from 0 instead of 1)
- Bad: `Image_a.tif`, `Image_b.tif` (letters instead of numbers)
- Bad: `Image_001.tif`, `Image_02.tif`, `Image_003.tif` (inconsistent padding)

### "Too few sequential images" message

- The script found files but couldn't identify enough sequential images
- Check the log window for DEBUG information showing what was detected
- Ensure files are numbered starting from 1 (not 0)
- Verify zero-padding is consistent (all 00001 or all 0001, not mixed)

### Double or blurred edges in the stitched image

- The script uses a standard 20% overlap value that works for most applications
- If your microscope uses a significantly different overlap:
  - Check your microscope settings to confirm the actual overlap percentage
  - Modify the `tileOverlap` variable in the script (see "Advanced Settings" section below)
  - Try values between 15-25%

### Black and white images instead of color

- This should not happen with version 2.0+
- If it does, the script automatically converts to RGB before saving

### Out of memory errors

- The script uses the "Save computation time (but use more RAM)" option for best results
- If you have limited RAM, you can modify the script to use "Save memory (but be slower)"

## Advanced Settings (for advanced users)

If needed, you can directly adjust the script settings.

**To make changes to the script**:
1. Open the `AutoStitch.ijm` file in a text editor (e.g., TextEdit on Mac, Notepad++ on Windows)
2. Make the desired changes
3. Save the file
4. Run the modified script in Fiji

**Available parameters**:

### Overlap Setting

By default, the script uses 20% overlap. To change this, find this line in the script:

```javascript
// Fixed overlap at 20% (standard value for most applications)
tileOverlap = "20";
```

Change `"20"` to your desired overlap percentage (e.g., `"15"` or `"25"`).

### Disabling Automatic Pattern Detection

If you want to use a manual pattern (like in older versions), you can modify the script. However, the automatic detection is recommended for most users.

### Other Parameters

These are usually fine and should not be changed unless needed:
- `fusionMethod`: Method for blending overlapping regions (default: "[Linear Blending]")
- `regThreshold`: Regression threshold for the stitching algorithm (default: 0.30)
- `maxAvgThreshold`: Maximum/average displacement threshold (default: 2.50)
- `absThreshold`: Absolute displacement threshold (default: 3.50)
- `computation_parameters`: Set to "[Save computation time (but use more RAM)]" for best results
- `imageOutput`: How the output should be handled (default: "[Fuse and display]")

Find further information on how to adjust the script here: https://imagej.net/plugins/image-stitching

## Changelog

### Version 3.0 (2025)
- **NEW: Intelligent Pattern Recognition**: Automatically detects filename patterns
- **NEW: Flexible Prefix Handling**: Works with different prefixes in different folders
- **NEW: Automatic Padding Detection**: Recognizes zero-padding length automatically
- **NEW: Ultimate Filename Flexibility**: Works with any filename as long as sequential numbering is present (even simple `1.tif`, `2.tif`, `3.tif`)
- Eliminated need for manual filename pattern configuration
- Enhanced diagnostic output with detailed pattern detection information
- Improved robustness for diverse naming conventions
- Output files now named after source folders for better organization
- Complete rewrite of pattern detection algorithm for maximum flexibility

### Version 2.1 (2025)
- Simplified user interface by removing overlap setting from dialog
- Set standard overlap to 20% (optimal for most microscopy applications)
- Added advanced settings section in README for custom overlap values
- Improved citation format with BibTeX support

### Version 2.0 (2025)
- Fixed blurry stitching results by optimizing computation parameters
- Added subpixel accuracy for sharper tile transitions
- Fixed black and white output by adding RGB conversion
- Added automatic overlap computation
- Improved user interface with flexible configuration dialog
- Added citation requirement dialog
- Simplified code and removed unnecessary functions
- Better console output for debugging

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- This script uses the "Grid/Collection stitching" plugin in Fiji which is based on the publication: Preibisch, S., Saalfeld, S., & Tomancak, P. (2009). Globally optimal stitching of tiled 3D microscopic image acquisitions. Bioinformatics, 25(11), 1463–1465. https://imagej.net/plugins/image-stitching
- Thanks to all contributors of the ImageJ and Fiji community

---

**Remember**: If you use this script in your research, please cite it! Your citation helps others discover this tool and supports continued development.
