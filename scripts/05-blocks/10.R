# "Disjoint from any department" is not "outside all departments".
any_disjoint <- is.related(mines, dept, relation = "disjoint")
outside_all <- !is.related(mines, dept, relation = "intersects")
show_selection(mines, any_disjoint, "Disjoint from at least one department")
show_selection(mines, outside_all, "Outside every department")
c(disjoint_from_any = sum(any_disjoint), outside_all = sum(outside_all))
