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

Verarbeitung Überflutungsflächen und Wald, Erstellung von Masken

-   `01_create_aoi_coverages_and_masks.R`
-   `01_calculate_remaining_area_percentage_pixels.R`

NDVI, EVI, NIRv

- `02.1_get_modis_aggregate_P1M_mean_rescale.R`
- `02.2_reference_aggregate_P13Y_mean.R`
- `02.3_calculate_indices.R`
- `02.4_create_dataframes_from_masked_indices`

**Inhalt der Skripte:**

**`01_create_aoi_coverages_and_masks.R`**

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
- Erstellen von Masken auf Grundlage der Flutwaldbedeckung je Rasterzelle (jede Maske = Rasterdatei mit 3 Layern, Layer 1: Laubwald, Layer 2:     Nadelwald, Layer 3: Mischwald)

**`01_calculate_remaining_area_percentage_pixels.R` **

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

**`02.1_get_modis_aggregate_P1M_mean_rescale.R`**

📦 Pakete: 

- `gdalcubes`
- `sf`        
- `rstac`       
- `magrittr`

📥 Eingangsdaten:

- `data/work/bbox.vector.RData`

📤 Ausgangsdaten:

- `data/work/reference/P1M/`
- `data/work/study/P1M/`

🧾 Zweck:

- Suchen von MODIS Überfliegungsdaten (*MODIS Nadir BRDF-Adjusted Reflectance (NBAR) Daily*) für die Monate Mai bis September der Jahre 2000 bis 2012 (Referenzzeitraum) und 2013 bis 2017 (Untersuchungszeitraum) im Untersuchungsgebiet
- Auswahl der benötigen Bänder (blue, red und nir)
- Zusammenfassen der täglichen Aufnahmen zu je einem Bild pro Monat und dem Mittelwert aus allen Bildern dieses Monats
- Zuschneiden der Bilder auf die Ausdehnung des Untersuchungsgebietes
- Speichern der Monatsbilder als .tif

**`02.2_reference_aggregate_P13Y_mean.R`**

📦 Pakete:

- `gdalcubes`

📥 Eingangsdaten:

- `data/work/reference/P1M/`

📤 Ausgangsdaten:

- `data/work/reference/P13Y/`

🧾 Zweck:

- Zusammenfassen der Monatsbilder des Referenzzeitraum zu je einem Bild pro Monat über den gesamten Referenzzeitraum (mit Berechnung Mittelwert)

**`02.3_calculate_indices.R`**

📦 Pakete:

- `gdalcubes`
- `sf`
- `terra`
- `magrittr`

📥 Eingangsdaten:

- `data/work/reference/P13Y/`
- `data/work/study/P1M/`

📤 Ausgangsdaten:

- `data/work/reference/P13Y/indices/`
- `data/work/study/P1M/indices/`

🧾 Zweck:

- Berechnung der Vegetationsindizes NDVI, EVI und NIRv für die über 13 Jahre      zusammengefassten Bilder der Referenzperiode 
  sowie für die Monatsbilder des Untersuchungszeitraum

**`02.4_create_dataframes_from_masked_indices`**

📦 Pakete:

- `dplyr`
- `magrittr`
- `terra`

📥 Eingangsdaten:

- `data/work/reference/indices`
- `data/work/study/indices`
- `mask_30p.tif`
- `mask_50p.tif`
- `mask_66p.tif`
- `mask_70p.tif`
- `mask_90p.tif`
- `mask_99p.tif`

📤 Ausgangsdaten:

- `df_differences.RData`

🧾 Zweck:

- Maskieren der Indexbilder (Referenzperiode und Untersuchungszeitraum) mit den Masken aus `01_create_aoi_coverages_and_masks.R`
- Berechnen des Mittelwerts je maskiertem Bild (Summe aller Zellwerte/Anzahl der Zellen)
- Zusammenfassen/Kombinieren der Mittelwerte in *dataframes*
- Berechnen von Differenzwerten (Mittelwert des Untersuchungszeitraum - Mittelwert der Referenzperiode)
- Mittelwertsabweichung des jeweiligen Index je Monat des Untersuchungszeitraum vom Mittelwert dieses Monat über die Referenzperiode

**`02.5_harmonsing_differences.R`**

📦 Pakete:

- `dplyr`
- `terra`

📥 Eingangsdaten:

- `df_differences.RData`
- `data/work/reference/indices`
- `mask_30p.tif`
- `mask_50p.tif`
- `mask_66p.tif`
- `mask_70p.tif`
- `mask_90p.tif`
- `mask_99p.tif`

📤 Ausgangsdaten:

- `df_ranges.RData`
- `df_differences_harmonised.RData`

🧾 Zweck:

- Ermitteln der Wertespannen der monatlichen Index-Mittelwerte (maskiert) der Referenzperiode (Abstand zwischen Mininum- und Maximumwert des Monats)
- Umrechnen der in `02.4_create_dataframes_from_masked_indices` ermittelten Differenzen in Prozentwerte von jeweiliger Wertespanne

**`03.1_get_lai_aggregate_P8D_P1M_QA.R`**

📦 Pakete: 

- `gdalcubes`
- `sf`        
- `rstac`       
- `magrittr`

📥 Eingangsdaten:

- `data/work/bbox.vector.RData`

📤 Ausgangsdaten:

- `data/work/reference/lai/P1M/`
- `data/work/study/lai/P1M/`

🧾 Zweck:

- Suchen von MODIS LAI 500m 8-day (*MODIS Leaf Area Index 8-Day*) für die Monate Mai bis September der Jahre 2003 bis 2012 (Referenzzeitraum) und 2013 bis 2017 (Untersuchungszeitraum) im Untersuchungsgebiet
- Auswahl der benötigen Bänder ("Lai_500m", "FparLai_QC", "FparExtra_QC")
- Zusammenfassen der täglichen Aufnahmen zu je einem Bild pro Monat und dem Mittelwert aus   allen Bildern dieses Monats
- Zuschneiden der Bilder auf die Ausdehnung des Untersuchungsgebietes
- Reskalieren der Pixelwerte des LAI-Bandes auf LAI-Wertebereich (0 bis 7)durch Multiplikation mit 0.1
- Speichern der Monatsbilder als .tif




















## \##### ACHTUNG TEMPLATE \#####

****

📦 Pakete:

-

📥 Eingangsdaten:

-

📤 Ausgangsdaten:

-

🧾 Zweck:

-
