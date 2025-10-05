# ImageJ Fiji Auto-Stitcher

This ImageJ macro, designed for use within Fiji (https://fiji.sc/), automates the stitching of multiple images into a single large image. It's particularly useful for images acquired using a microscope with a tiling function.

**Important**: This script requires Fiji, which is a distribution of ImageJ that includes many useful plugins, including the "Grid/Collection stitching" plugin used by this script. Plain ImageJ might not have all the required plugins. Download Fiji from https://fiji.sc/.

## ⚠️ Terms of Use and Citation

**By using this script, you agree to cite it in any resulting publications, presentations, or other academic work.**

If you use this script in your research and publish the results, please cite it as follows:

```
Wiegand, M. (2025). ImageJ Fiji Auto-Stitcher (Version 2.1) [Computer software]. 
GitHub. https://github.com/wiegandlmu/ImageJ-Fiji-Auto-Stitcher
Zenodo. https://doi.org/10.5281/zenodo.14633250
```

**Recommended citation style for BibTeX:**
```bibtex
@software{wiegand2025autostitcher,
  author = {Wiegand, Max},
  title = {ImageJ Fiji Auto-Stitcher},
  year = {2025},
  version = {2.1},
  url = {https://github.com/wiegandlmu/ImageJ-Fiji-Auto-Stitcher},
  note = {Computer software}
}
```

**When you run the script for the first time, you will be asked to acknowledge this citation requirement.**

Citing this work allows others to find and utilize this tool and acknowledges the effort put into its development.

## Features

- **Flexible Filename Handling**: Highly adaptable to various file and folder naming conventions through a user-friendly dialog
- **Optimized Overlap**: Uses a standard 20% overlap value that works well for most microscopy applications
- **Optimized for Single Images**: Streamlined for stitching individual 2D images (no Z-stacks)
- **Sharp Stitching**: Uses subpixel accuracy and optimized computation for precise overlap, resulting in sharp stitching results
- **RGB Color Preservation**: Automatically maintains color information in stitched images
- **User-Friendly**: Includes a configuration dialog and detailed instructions for users with no programming experience
- **Automatic Grid Size Calculation**: If needed, the script can calculate an appropriate grid size

## Prerequisites

- **Fiji**: Download and install Fiji from https://fiji.sc/

## How to Use

### 1. Acquire Images with Your Microscope

- **Storage Format**: Save images as TIFF (uncompressed or LZW-compressed)
- **Tiling**: Use the tiling function of your microscope to capture multiple images for stitching
- **Folder Structure**: The script expects images to be organized in subfolders within a main directory. Each subfolder should contain images belonging to one stitched image
- **File Naming**: You can customize the expected file naming in the dialog (see step 2)
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
   - Navigate to the unzipped folder and select the `AutoStitch.ijm` file
   - Click "Open"

3. **Accept Citation Terms**:
   - A dialog will appear asking you to acknowledge the citation requirement
   - Click "I Agree" to proceed

4. **Configuration Dialog**:
   - A dialog box will appear. Fill in the following parameters:
     - **Subfolder prefix**: The prefix of your subfolder names (e.g., "XY" if your subfolders are named "XY01", "XY02", etc.)
     - **Filename pattern**: The pattern of your image filenames
       - Use `{xy}` as a placeholder for the subfolder number
       - Use `{i}` to represent the sequential image number
       - Example: `H2_Image_XY{xy}_0000{i}_CH4` might represent files named `H2_Image_XY01_00001_CH4.tif`, `H2_Image_XY01_00002_CH4.tif`, etc.
     - **File extension**: The extension of your image files (e.g., ".tif")
     - **Grid Size**: Specify the grid size (e.g., "3x3") or use "0x0" to let the script automatically calculate the grid size
       - **Automatic calculation (0x0)**: The script calculates a square grid based on the number of images
         - Example: 9 images → 3×3 grid, 16 images → 4×4 grid, 10 images → 4×4 grid (with 6 empty positions)
         - ⚠️ **Important**: Automatic calculation assumes a square or nearly-square grid arrangement
         - If your images are arranged in a rectangular grid (e.g., 2×6), you **must** enter the grid size manually
       - **Manual entry**: Recommended if you know your exact grid dimensions (e.g., "2x6", "3x4")
   - Click "OK"

5. **Select Main Folder**:
   - A new window will appear
   - Navigate to the main folder and select it (the folder containing the subfolders with the images)

6. **Let the script do its job**

7. **Finding the stitched image**:
   - The stitched image will be saved as `stitched_result.tif` inside each processed subfolder
   - The stitched image will also be displayed in Fiji

## Troubleshooting

### "All stitching operations completed." message appears immediately
This usually means the script can't find the subfolders or images. Double-check:
- The parameters entered in the dialog, especially the "Subfolder prefix" and "Filename pattern"
- That your subfolders actually start with the specified prefix
- That your files match the pattern

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
By default, the script uses 20% overlap. To change this:
```javascript
// Fixed overlap at 20% (standard value for most applications)
tileOverlap = "20";
```
Change `"20"` to your desired overlap percentage (e.g., `"15"` or `"25"`).

### Other Parameters
These are usually fine and should not be changed unless needed:
- `fusionMethod`: Method for blending overlapping regions (default: "[Linear Blending]")
- `regThreshold`: Regression threshold for the stitching algorithm (default: 0.30)
- `maxAvgThreshold`: Maximum/average displacement threshold (default: 2.50)
- `absThreshold`: Absolute displacement threshold (default: 3.50)
- `computation_parameters`: Set to "[Save computation time (but use more RAM)]" for best results
- `imageOutput`: How the output should be handled (default: "[Fuse and display]")
- `outputName`: The desired name for the stitched output image (default: "stitched_result.tif")

Find further information on how to adjust the script here: https://imagej.net/plugins/image-stitching

## Changelog

### Version 2.1 (2025)
- ✅ Simplified user interface by removing overlap setting from dialog
- ✅ Set standard overlap to 20% (optimal for most microscopy applications)
- ✅ Added advanced settings section in README for custom overlap values
- ✅ Improved citation format with BibTeX support

### Version 2.0 (2025)
- ✅ Fixed blurry stitching results by optimizing computation parameters
- ✅ Added subpixel accuracy for sharper tile transitions
- ✅ Fixed black and white output by adding RGB conversion
- ✅ Added automatic overlap computation
- ✅ Improved user interface with flexible configuration dialog
- ✅ Added citation requirement dialog
- ✅ Simplified code and removed unnecessary functions
- ✅ Better console output for debugging

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- This script uses the "Grid/Collection stitching" plugin in Fiji which is based on the publication: Preibisch, S., Saalfeld, S., & Tomancak, P. (2009). Globally optimal stitching of tiled 3D microscopic image acquisitions. Bioinformatics, 25(11), 1463–1465. https://imagej.net/plugins/image-stitching
- Thanks to all contributors of the ImageJ and Fiji community

---

**Remember**: If you use this script in your research, please cite it! Your citation helps others discover this tool and supports continued development.
