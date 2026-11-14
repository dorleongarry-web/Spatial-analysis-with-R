# Read polygons, lines and points; verify their spatial references.
litho <- vect("data/vectors/litho.gpkg")
struct <- vect("data/vectors/struct.gpkg")
mines <- vect("data/vectors/mines.gpkg")
mines$point_id <- seq_len(nrow(mines))
stopifnot(same.crs(dept, litho), same.crs(dept, struct), same.crs(dept, mines),
          all(is.valid(dept)), all(is.valid(litho)))
data.frame(layer = c("departments", "lithology", "structures", "mines"),
           features = c(nrow(dept), nrow(litho), nrow(struct), nrow(mines)))
head(as.data.frame(litho))
head(as.data.frame(struct))
head(as.data.frame(mines))
