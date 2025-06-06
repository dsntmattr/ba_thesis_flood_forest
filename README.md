---
editor_options: 
  markdown: 
    wrap: 72
---

# ba_thesis_flood_forest

Inhalt der Bachelorarbeit: Vergleich der Reaktion von verschiedenen
Vegetationsindizes und LAI in Wäldern Sachsen-Anhalts nach dem
Elbehochwasser 2013.

Dieses Projekt enthält Skripte zur Beschaffung, Verarbeitung und
Auswertung der dazu benötigten Fernerkundungsdaten.

################################################################################################ 

**Rohdaten:**

- `data/raw/dlm_st_veg02_f/veg02_f.shp`: Objektart Wald des
Digitalen Basis-Landschaftsmodell Sachsen-Anhalt (Stand 2022?) mit den
Vegetationsmerkmalen "Laubholz" (VEG == 1100), "Nadelholz" (VEG == 1200)
und "Laub- und Nadelholz" (VEG == 1300) 
- `data/raw/floodplains/FLUT_LK.shp`: Ausbreitungsgebiet des
Überflutungsflächen des Hochwassers 2013

################################################################################################ 

**Übersicht der Skripte:**

-   `01_create_aoi_coverages_and_masks.R`
-   `01_calculate_remaining_area_percentage_pixels.R`

**Inhalt der Skripte:**

`01_create_aoi_coverages_and_masks.R`

📦 Pakete:

- `gdalcubes`
- `sf`
- `rstac`
- `terra`
- `tidyverse`

📥 Eingangsdaten:

- `data/raw/dlm_st_veg02_f/veg02_f.shp`
- `data/raw/floodplains/FLUT_LK.shp`

📤 Ausgangsdaten: 

- `data/work/bbox.vector.RData`
- `data/work/coverage.tif` 
- `data/work/mask_30p.tif` 
- `data/work/mask_50p.tif` 
- `data/work/mask_66p.tif` 
- `data/work/mask_70p.tif` 
- `data/work/mask_90p.tif` 
- `data/work/mask_99p.tif`

🧾 Zweck:

- Ermitteln der überfluteten Waldlfäche je Waldtyp
- Erstellen einer Bounding Box des Untersuchungsgebiet
- Ermitteln der prozentualen Flutwaldbedeckung jeder Rasterzelle
- Erstellen von Masken auf Grundlage der Flutwaldbedeckung je Rasterzelle

`01_calculate_remaining_area_percentage_pixels.R` 

📦 Pakete:

- `sf`
- `terra`
- `tidyverse`

📥 Eingangsdaten: 

- `data/work/coverage.tif` 
- `data/work/mask_30p.tif` 
- `data/work/mask_50p.tif` 
- `data/work/mask_66p.tif` 
- `data/work/mask_70p.tif` 
- `data/work/mask_90p.tif` 
- `data/work/mask_99p.tif`

📤 Ausgangsdaten:

- dataframes bzw. plots? muss noch rein

🧾 Zweck:

- Ermitteln der gesamten Überflutungsfläche je Waldtyp 
- Ermitteln der verbleibenden Überflutungswaldfläche nach Anwendung der Masken 
- Ermitteln der prozentual verbleibenden Überflutungswaldfläche nach Anwendung der Masken
- Ermitteln der Gesamtanzahl der je Waldtyp betroffenen Rasterzellen
- Ermitteln der verbleibenden Rasterzellen je Waldtyp nach Anwendung der Masken
- Ermitteln der prozentual verbleibenden Rasterzellen je Waldtyp nach Anwendung der Masken

## \##### ACHTUNG TEMPLATE \#####

📦 Pakete: -

📥 Eingangsdaten: -

📤 Ausgangsdaten: -

🧾 Zweck: -
