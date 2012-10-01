capture program drop mark_children_of_undocumented
program define mark_children_of_undocumented
  sort serial pernum
  capture drop child_of_undoc
  by serial: gen child_of_undoc = yrimmig & ((poploc & undocumented[poploc]) | (momloc & undocumented[momloc]))
  replace undocumented = 1 if child_of_undoc
end


