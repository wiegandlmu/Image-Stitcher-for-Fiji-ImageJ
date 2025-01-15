# Image Stitcher for Fiji ImageJ

This ImageJ macro, designed for use within **Fiji** ([https://fiji.sc/](https://fiji.sc/)), automates the stitching of multiple images into a single large image. It's particularly useful for images acquired using a **microscope** with a **tiling** function.

**Important:** This script requires **Fiji**, which is a distribution of ImageJ that includes many useful plugins, including the "Grid/Collection stitching" plugin used by this script. **Plain ImageJ might not have all the required plugins.** Download Fiji from [https://fiji.sc/](https://fiji.sc/).

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

1. **Download the script:**
    *   If you are on the GitHub repository page, **scroll up to the top**.
    *   Click the green "Code" button.
    *   Select "Download ZIP".
    *   Save the ZIP file to your computer and unzip it.
2. **Open the script in Fiji:**
    *   Open Fiji.
    *   Go to "Plugins" -> "Macros" -> "Run..."
    *   Navigate to the unzipped folder and select the `Fiji_image_stitcherV2.ijm` file.
    *   Click "Open".
3. **Configuration Dialog:**
    *   A dialog box will appear. Fill in the following parameters:
        *   **Subfolder prefix:** The prefix of your subfolder names (e.g., "XY" if your subfolders are named "XY01", "XY02", etc.).
        *   **Filename pattern:** The pattern of your image filenames.
            *   Use `{subfolder}` as a placeholder for the subfolder name.
            *   Use `{i}`, `{ii}`, `{iii}`, etc. to represent the sequential image number. The number of `i`s determines the number of digits (e.g., `{i}` for 1, 2, 3..., `{ii}` for 01, 02, 03..., `{iii}` for 001, 002, 003...).
            *   Example: `H2_Image_{subfolder}_{iiiii}_CH4` might represent files named `H2_Image_XY01_00001_CH4.tif`, `H2_Image_XY01_00002_CH4.tif`, etc.
        *   **File extension:** The extension of your image files (e.g., ".tif").
        *   **Overlap in %:** The percentage of overlap between adjacent tiles.
        *   **Grid Size:** Specify the grid size (e.g., "2x3") or use "0x0" to let the script automatically determine the grid size based on the number of images.
4. Click "OK".
5. Choose the main folder (the folder containing the subfolders) when prompted.
6. Let the script do it's job.
7. **Finding the stitched image:**
    *   The stitched image will be saved as `stitched_result.tif` (or the name you specified in the `outputName` variable) inside the **subfolders** that were stitched.
    *   The stitched image will also be **displayed in Fiji**.

## Troubleshooting

*   **"All stitching operations done." message appears immediately:** This usually means the script can't find the subfolders or images. Double-check the parameters entered in the dialog, especially the "Subfolder prefix" and "Filename pattern".
*   **Double or blurred edges in the stitched image:** Verify `Overlap in %`: Ensure it accurately reflects your actual overlap. Try different values until you get the desired results.

## Further Adjustments in the Script (for advanced users)

If needed, you can directly adjust the script settings. 

**To make changes to the script:**

1. Open the `Fiji_image_stitcherV2.ijm` file in a text editor (e.g., TextEdit on Mac, Notepad++ on Windows).
2. Make the desired changes.
3. Save the file.
4. Follow steps 2-7 in the "Install and Run the Script in Fiji" section to run the modified script.

These parameters are usually fine and should not be changed if not needed. Find further information on how to adjust the script here: [https://imagej.net/plugins/image-stitching](https://imagej.net/plugins/image-stitching)

*   **`fusionMethod`:** Method for blending overlapping regions (default: `"[Linear Blending]"`).
*   **`regThreshold`:** Regression threshold for the stitching algorithm.
*   **`maxAvgThreshold`:** Maximum/average displacement threshold.
*   **`absThreshold`:** Absolute displacement threshold.
*   **`computeOverlap`:** This setting can be changed between `"[Save memory (but be slower)]"` which is the default and `"[Save computation time (but use more RAM)]"`: Faster, but might be too much for your PC.
*   **`imageOutput`:** How the output should be handled (default: `"[Fuse and display]"`).
*   **`outputName`:** The desired name for the stitched output image (default: `"stitched_result.tif"`).

## Citation

If you use this script in your research and publish the results, **please cite it as follows**:

Wiegand, M. (2024). Keyence Image Stitcher for Fiji (Version 2.0.0) [Software]. [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14633250.svg)](https://doi.org/10.5281/zenodo.14633250)

**Citing this work allows others to find and utilize this tool and acknowledges the effort put into its development.**

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

*   This script uses the "Grid/Collection stitching" plugin in Fiji which is based on the publication: **Preibisch, S., Saalfeld, S., & Tomancak, P. (2009). Globally optimal stitching of tiled 3D microscopic image acquisitions. Bioinformatics, 25(11), 1463–1465.** [https://imagej.net/plugins/image-stitching](https://imagej.net/plugins/image-stitching)
*   Thanks to all contributors of the ImageJ and Fiji community.
