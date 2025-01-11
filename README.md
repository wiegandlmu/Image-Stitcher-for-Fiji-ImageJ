# Image Stitcher for Fiji ImageJ

This ImageJ macro, designed for use within **Fiji** ([https://fiji.sc/](https://fiji.sc/)), automates the stitching of multiple images into a single large image. It's particularly useful for images acquired using a **microscope** with a **tiling** function.

## Features

*   **Flexible Filename Handling:**  Highly adaptable to various file and folder naming conventions through a user-friendly dialog.
*   **Customizable:** Easily adjust overlap settings and stitching parameters.
*   **Optimized for Single Images:** Streamlined for stitching individual 2D images (no Z-stacks).
*   **Sharp Stitching:** Offers options for precise overlap computation, resulting in sharp stitching results.
*   **User-Friendly:** Includes a configuration dialog and detailed instructions for users with no programming experience.
*   **Automatic Grid Size Calculation**: If needed, the script can calculate an appropriate grid size.

## Prerequisites

*   **Fiji:** Download and install Fiji from [https://fiji.sc/](https://fiji.sc/).

## How to Use

**1. Acquire Images with Your Microscope**

*   **Storage Format:** Save images as **TIFF** (uncompressed or LZW-compressed).
*   **Tiling:** Use the **tiling** function of your microscope to capture multiple images for stitching.
*   **Folder Structure:** The script expects images to be organized in subfolders within a main directory. Each subfolder should contain images belonging to one stitched image.
*   **File Naming:** You can customize the expected file naming in the dialog (see step 2).
*   **Overlap:** Ensure an overlap of **15-25%** between adjacent images. Adjust in your microscope settings if necessary.
*   **No Z-Stacks:** This script is designed for **single images only**, not Z-stacks.

**2. Install and Run the Script in Fiji**

1. Open Fiji.
2. Go to "Plugins" -> "New" -> "Macro".
3. Copy the code from the `Fiji_image_stitcher.ijm` file and paste it into the editor.
4. Click "Run" in the script editor.
5. A dialog box will appear. Fill in the following parameters:
    *   **Subfolder prefix:** The prefix of your subfolder names (e.g., "XY" if your subfolders are named "XY01", "XY02", etc.).
    *   **Filename pattern:** The pattern of your image filenames.
        *   Use `{subfolder}` as a placeholder for the subfolder name.
        *   Use `{i}`, `{ii}`, `{iii}`, etc. to represent the sequential image number. The number of `i`s determines the number of digits (e.g., `{i}` for 1, 2, 3..., `{ii}` for 01, 02, 03..., `{iii}` for 001, 002, 003...).
        *   Example: `H2_Image_{subfolder}_{iiiii}_CH4` might represent files named `H2_Image_XY01_00001_CH4.tif`, `H2_Image_XY01_00002_CH4.tif`, etc.
    *   **File extension:** The extension of your image files (e.g., ".tif").
    *   **Overlap in %:** The percentage of overlap between adjacent tiles.
    *   **Grid Size:** Specify the grid size (e.g., "2x3") or use "0x0" to let the script automatically determine the grid size based on the number of images.
6. Click "OK".
7. Choose the main folder (the folder containing the subfolders) when prompted.

**3. Further Adjustments in the Script (for advanced users)**

If needed you can directly adjust the script settings in the section "Settings for 'Grid/Collection stitching'". These parameters are usually fine and should not be changed if not needed:

*   **`fusionMethod`:** Method for blending overlapping regions (default: `"[Linear Blending]"`).
*   **`regThreshold`:** Regression threshold for the stitching algorithm.
*   **`maxAvgThreshold`:** Maximum/average displacement threshold.
*   **`absThreshold`:** Absolute displacement threshold.
*   **`computeOverlap`:** This setting can be changed between `"[Save memory (but be slower)]"` which is the default and `"[Compute overlap (but use more RAM)]"`: Faster, but might result in **less sharp** stitching. `"[Compute overlap precisely (less RAM consumption)]"`: **Slower** but usually produces **sharper** results. Recommended if you experience blurry edges.
*   **`imageOutput`:** How the output should be handled (default: `"[Fuse and display]"`).
*   **`outputName`:** The desired name for the stitched output image (default: `"stitched_result.tif"`).

**Troubleshooting**

*   **"All stitching operations done." message appears immediately:** This usually means the script can't find the subfolders or images. Double-check the parameters entered in the dialog, especially the "Subfolder prefix" and "Filename pattern".
*   **Double or blurred edges in the stitched image:**
    1. **Verify `Overlap in %`:** Ensure it accurately reflects the actual overlap.
    2. If that does not help, you can change `computeOverlap` to `"[Compute overlap precisely (less RAM consumption)]"` in the script. This setting is slower but may result in sharper results.

## Citation

If you use this script in your research and publish the results, **please cite it as follows**:

Wiegand, M. (2024). Keyence Image Stitcher for Fiji (Version 1.0.1) [Software]. [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14633250.svg)](https://doi.org/10.5281/zenodo.14633250)

**Citing this work allows others to find and utilize this tool and acknowledges the effort put into its development.**

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

*   This script uses the "Grid/Collection stitching" plugin in Fiji which is based on the publication: **Preibisch, S., Saalfeld, S., & Tomancak, P. (2009). Globally optimal stitching of tiled 3D microscopic image acquisitions. Bioinformatics, 25(11), 1463–1465.** [https://imagej.net/plugins/image-stitching](https://imagej.net/plugins/image-stitching)
*   Thanks to all contributors of the ImageJ and Fiji community.
