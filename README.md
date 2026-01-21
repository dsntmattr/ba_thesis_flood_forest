# Forest Vegetation Dynamics Analysis - R Scripts Documentation

## Overview

This repository contains R scripts for analyzing forest vegetation dynamics using MODIS satellite data. The analysis focuses on comparing vegetation status between two reference period (2000–2012 and 2003-2012) and a study period (2013–2017) in floodplain forest areas. The workflow integrates MODIS NBAR (Nadir BRDF-Adjusted Reflectance) data to compute spectral vegetation indices (NDVI, EVI, NIRv) and uses MODIS LAI (Leaf Area Index) products to assess structural vegetation changes over time.

## Data Sources

- **MODIS NBAR Daily (MCD43A4.061)**: Nadir BRDF-Adjusted Reflectance
- **MODIS LAI/FPAR 8-Day (MCD15A2H.061)**: Leaf Area Index and Fraction of Photosynthetically Active Radiation
- **Forest Data**: Local forest vegetation shapefiles
- **Floodplain Data**: Floodplain boundary shapefiles
- **Forest Loss Data**: Forest loss polygon data for local analysis

## Workflow Overview

The analysis follows a sequential workflow divided into four main phases:

1. **Data Preparation**: Create study area, masks, and base grids
2. **Data Download & Processing**: Download and aggregate MODIS data
3. **Index Calculation**: Calculate vegetation indices for both periods
4. **Analysis & Visualization**: Compare periods and create time series plots

## Script Documentation

### Phase 1: Data Preparation

#### `script_01_1.r` - Create Area of Interest and Forest Masks
**Purpose**: Intersect floodplains with forest areas and create coverage masks with different thresholds

**Key Functions**:
- Intersects floodplains with forest vegetation data
- Creates base grid from MODIS data for spatial reference
- Calculates forest type coverage percentages per grid cell
- Generates binary masks with various coverage thresholds (30%, 50%, 66%, 70%, 90%, 99%)

**Inputs**:
- `data/raw/floodplains/FLUT_LK.shp` - Floodplain boundaries
- `data/raw/dlm_st_veg02_f/veg02_f.shp` - Forest vegetation data

**Outputs**:
- `data/work/flood_forest.shp` - Intersection of floodplains and forests
- `data/work/bbox.vector.RData` - Bounding box for study area
- `data/work/coverage.tif` - Forest coverage percentages
- `data/work/mask_*.tif` - Binary masks for different thresholds

#### `script_01_2.r` - Calculate Remaining Area Percentages and Pixel Counts
**Purpose**: Analyze remaining forest area and pixel counts after applying coverage threshold masks

**Key Functions**:
- Applies different threshold masks to coverage layers
- Calculates total forest areas in hectares for each forest type
- Computes relative areas as percentages of total area
- Counts valid pixels for each mask and forest type

**Inputs**:
- `data/work/coverage.tif` - Forest coverage layers
- `data/work/mask_*.tif` - Threshold mask files

**Outputs**:
- `data/final/remaining_area_and_pixels.xlsx` - Summary statistics in Excel format

### Phase 2: Data Download & Processing

#### `script_02_1.r` - Download, Aggregate and Rescale MODIS Data
**Purpose**: Download MODIS NBAR and LAI data, aggregate to monthly composites, and rescale values

**Key Functions**:
- Downloads MODIS data from Microsoft Planetary Computer STAC catalog
- Aggregates daily NBAR data to monthly means
- Rescales reflectance values from 0-10000 to 0-1 range
- Processes LAI data from 8-day to monthly composites with 0.1 scaling factor

**Processing Periods**:
- Reference: 2000-2012 (NBAR), 2003-2012 (LAI)
- Study: 2013-2017

**Outputs**:
- `data/work/reference/P1M/MODIS_*.tif` - Monthly reference period NBAR data
- `data/work/study/P1M/MODIS_*.tif` - Monthly study period NBAR data
- `data/work/reference/lai/no_qa/p1m/LAI_*.tif` - Monthly reference LAI data
- `data/work/study/lai/no_qa/p1m/LAI_*.tif` - Monthly study LAI data

#### `script_02_2.r` - Aggregate Reference Period Data
**Purpose**: Aggregate monthly MODIS data to create long-term monthly averages (P13Y = 13-year period, P10Y = 10-year period)

**Key Functions**:
- Stacks monthly data across multiple years
- Calculates long-term monthly averages for reference period
- Processes both NBAR and LAI data separately

**Outputs**:
- `data/work/reference/P13Y/MODIS_*.tif` - Long-term monthly NBAR averages
- `data/work/reference/lai/no_qa/p13y/LAI_*.tif` - Long-term monthly LAI averages

### Phase 3: Index Calculation

#### `script_02_3.r` - Calculate Vegetation Indices
**Purpose**: Calculate NDVI, EVI, and NIRv from MODIS reflectance data for both periods

**Key Functions**:
- Calculates vegetation indices using standard formulas:
  - **NDVI**: (NIR - Red) / (NIR + Red)
  - **EVI**: 2.5 × (NIR - Red) / (NIR + 6×Red - 7.5×Blue + 1)
  - **NIRv**: NDVI × NIR
- Processes both reference and study periods

**Outputs**:
- `data/work/reference/indices/*.tif` - Reference period vegetation indices
- `data/work/study/indices/*.tif` - Study period vegetation indices

### Phase 4: Analysis & Visualization

#### `script_02_4_1.r` - Calculate Mean Differences - Local Level Analysis
**Purpose**: Create time series dataframes comparing study period to reference period at forest loss sites

**Key Functions**:
- Extracts vegetation index values at specific forest loss locations
- Calculates differences between study and reference periods
- Creates dataframes for statistical analysis

**Inputs**:
- `data/raw/forest_loss/forest_loss.shp` - Forest loss polygon data
- Reference and study period vegetation indices and LAI data

**Outputs**:
- Time series dataframes for local analysis (both wide and long format)

#### `script_02_4_2.r` - Calculate Mean Differences - Regional Level Analysis
**Purpose**: Create time series dataframes comparing study period to reference period at regional level using forest type masks

**Key Functions**:
- Applies forest type masks (66% threshold) to vegetation indices
- Calculates regional means for broadleaf and coniferous forests
- Computes absolute and relative differences between periods
- Converts data to long format for visualization

**Outputs**:
- `data/work/dataframes/df_dif_absolute_regional.RData` - Absolute differences (wide format)
- `data/work/dataframes/df_dif_relative_regional.RData` - Relative differences (wide format)
- `data/work/dataframes/df_dif_absolute_regional_long.RData` - Absolute differences (long format)
- `data/work/dataframes/df_dif_relative_regional_long.RData` - Relative differences (long format)

#### `script_04_1.r` - Create Time Series Visualization Plots
**Purpose**: Generate standardized time series plots for local and regional analysis results

**Key Functions**:
- Creates time series plots with consistent styling
- Generates overview plots and index-specific plots
- Adds year separation lines and professional formatting
- Exports high-quality PNG files for publication

**Plot Types**:
- Local time series (forest loss sites)
- Regional overview (all indices and forest types)
- Index-specific plots (NDVI, EVI, NIRv, LAI)
- Forest type-specific plots (broadleaf vs. coniferous)

**Outputs**:
- `output/local_qa1.png` - Local site time series
- `output/regional_qa1.png` - Regional overview
- `output/regional_*_qa1.png` - Index and forest type specific plots

## Directory Structure

```
project/
├── data/
│   ├── raw/                          # Original input data
│   │   ├── floodplains/             # Floodplain shapefiles
│   │   ├── dlm_st_veg02_f/          # Forest vegetation data
│   │   └── forest_loss/             # Forest loss polygons
│   ├── work/                        # Intermediate processing files
│   │   ├── reference/               # Reference period data (2000-2012)
│   │   │   ├── P1M/                # Monthly data
│   │   │   ├── P13Y/               # Long-term averages
│   │   │   ├── indices/            # Vegetation indices
│   │   │   └── lai/                # LAI data
│   │   ├── study/                  # Study period data (2013-2017)
│   │   │   ├── P1M/                # Monthly data
│   │   │   ├── indices/            # Vegetation indices
│   │   │   └── lai/                # LAI data
│   │   ├── mask/                   # Coverage and mask files
│   │   └── dataframes/             # Analysis result dataframes
│   └── final/                      # Final results
└── output/                         # Visualization outputs
```


## Requirements

### R Version
- Tested with R version 4.4.3

### RStudio Version
- Tested with RStudio 2023.06.0+421 "Mountain Hydrangea" Release

### R Packages

- **Spatial Data**:  
  - `gdalcubes` (v0.7.1)  
  - `sf` (v1.0-20)  
  - `terra` (v1.8-29)

- **Data Access**:  
  - `rstac` (v1.0.1)

- **Data Manipulation and Visualization**:  
  - `tidyverse` (v2.0.0)  
  - `magrittr` (v2.0.3)  
  - `gdata` (v3.0.1)

- **Output**:  
  - `writexl` (v1.5.4)

### External Dependencies
- Access to Microsoft Planetary Computer STAC API
- Sufficient disk space for MODIS data downloads (several GB)

## Usage Instructions

1. **Setup**: Ensure all required R packages are installed
2. **Data Preparation**: Run scripts 01_1 and 01_2 to create study area and masks
3. **Data Download**: Execute script 02_1 to download MODIS data
4. **Data Aggregation**: Run script 02_2 to create reference period averages
5. **Index Calculation**: Execute script 02_3 to calculate vegetation indices
6. **Analysis**: Run scripts 02_4_1 and 02_4_2 for local and regional analysis
7. **Visualization**: Execute script 04_1 to generate time series plots

## Key Parameters

- **Study Area**: Intersection of floodplains and forest areas
- **Reference Period**: 2000-2012 (NBAR), 2003-2012 (LAI)
- **Study Period**: 2013-2017
- **Growing Season**: May-September (months 5-9)
- **Spatial Resolution**: 500m (MODIS native resolution)
- **Forest Types**: Broadleaf (VEG=1100), Coniferous (VEG=1200), Mixed (VEG=1300)
- **Coverage Threshold**: 66% for main analysis

## Notes

- Scripts should be run in numerical order due to data dependencies
- Processing times vary depending on study area size and internet connection
- Intermediate files are saved to enable resuming analysis at any step
- Quality flags (QA1) are applied to LAI data for improved accuracy