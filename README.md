# Geospatial Analysis with R

A lightweight, responsive educational website for **GitHub Pages**. Nine learning modules covering GIS principles, `terra` / `sf`, projections, WMS, vectors, rasters, Sentinel-2, spatial models, and case studies.

## Publish with GitHub Pages

1. Create a **public** GitHub repository called `geospatial-analysis-with-r`.
2. Upload **all files and folders** in this project to the repository root (or push with Git).
3. Open repository **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select branch `main`, folder `/ (root)`, and save.
6. When publishing completes, visit `https://YOUR-USERNAME.github.io/geospatial-analysis-with-r/`.

No build tools or server required. Open `index.html` locally to preview.

## Structure

- `index.html`: homepage and curriculum
- `lessons/`: nine standalone HTML lessons
- `scripts/`: downloadable R examples
- `assets/style.css`: website styling

## R dependencies

Install at least `terra` and optionally `sf` for vector workflows:

```r
install.packages(c("terra", "sf"))
```

The illustrative scripts are starter exercises, **not exact transcriptions** of the supplied PDFs, and not all have been executed on your local R installation. Advanced analyses are introductory outlines, not fully implemented statistical pipelines.

## Source materials and attribution

The curriculum is informed by seven supplied course handouts on geospatial data analysis with R and two reference PDFs by Robert J. Hijmans. Their full text and figures have **not** been reproduced. Before republishing course PDFs or reference books, check authorship, copyright, and reuse permissions. Relevant external resources: [Spatial Data Analysis with R](https://rspatial.org/), [Geocomputation with R](https://r.geocompx.org/), [terra](https://rspatial.github.io/terra/).

## Customization

Update the title, author / institutional attribution, lesson content, resources, and licenses as appropriate before public release.
