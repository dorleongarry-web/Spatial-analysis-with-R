# Watercourse teaching selection — BD Topage 2026

Source: Cours d’eau — Métropole 2026 — BD Topage, Système d’Information sur l’Eau (IGN/OFB).
Dataset: https://www.data.gouv.fr/datasets/cours-deau-metropole-2026-bd-topage-r
WFS layer: sa:CoursEau_FXX_Topage2026
Endpoint: https://services.sandre.eaufrance.fr/geo/topage2026
Licence: Licence Ouverte / Open Licence 2.0.
Retrieved: 14 November 2026.

This is a pedagogical subset, not a complete hydrographic network. Watercourses in this source can include navigation canals. Original source identifiers and names are preserved as river_id and river_name. Unnamed features retain an empty name.

Preparation: two capped WFS extracts (a regional bounding box and a name-based query) were combined and deduplicated by CdOH. The source XML geometry coordinates were read directly as longitude/latitude from gml:coordinates and transformed from EPSG:4326 to EPSG:2154. No coordinate simplification or pre-clipping was applied to the selected features.

Among the 1,187 retrieved features intersecting a 30 km buffer around the study area, the selection includes the 20 longest intersecting features, six short features over 5 km entirely within one department, and five exterior features between 5 and 30 km. The resulting 31-feature set is deliberately chosen to demonstrate different spatial predicates, not to estimate environmental statistics. Query caps mean the retrieval is not an exhaustive regional extract.

Per-department output lengths describe this selection only. The generalized 100 m department boundaries introduce approximate attribution near borders. A watercourse exactly on a shared boundary can be attributed to both departments, so department totals must not be treated as a unique regional network length.

GeoPackage and GeoJSON supplied here use EPSG:2154. See WATERCOURSE_WFS_REQUESTS.txt for the retrieval requests.
