# Confirm that the attribute joins did not change point count or geometry.
reopened <- vect("outputs/05-mines-with-context.gpkg")
stopifnot(nrow(mines_joined) == nrow(mines),
          identical(geom(mines_joined), geom(mines)),
          same.crs(reopened, mines), nrow(reopened) == nrow(mines),
          nrow(litho_groups) == length(type_levels))
c(original_points = nrow(mines), joined_points = nrow(mines_joined),
  missing_department = sum(is.na(mines_joined$nom)),
  missing_lithology = sum(is.na(mines_joined$TYPE)))
capture.output(sessionInfo(), file = "outputs/05-session-info.txt")
