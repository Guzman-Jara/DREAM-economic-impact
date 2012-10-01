table educ_r [pw=perwt] if undocumented & age >= 25 & age <= 64, f(%12.0f)
table educ_r2 [pw=perwt] if undocumented & age >= 18 & age <= 24, f(%12.0f)

table statefip [pw=perwt] if undocumented, f(%12.0f)
