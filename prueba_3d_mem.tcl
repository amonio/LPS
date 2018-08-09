### prueba 3d membrana

set pa_bot [atomselect top "name PA and z < 80"]
set pa_top [atomselect top "name PA and z > 80"]
set z_bot [vecmean [$pa_bot get {z}]]
set z_top [vecmean [$pa_top get {z}]]

set i_bot [$pa_bot get index]
set i_top [$pa_top get index]

set archivo [open "3dplot.dat" w]
puts $archivo "layer\tx\ty\tthick"
foreach i $i_bot {
	set sel [atomselect top "index $i"]
	set ix [$sel get {x}]
	set iy [$sel get {y}]
	set iz [lindex [$sel get {z}] 0]
	set thick [expr {($iz - $z_top)/2}]
	puts $archivo "b\t$ix\t$iy\t$thick"
}

foreach i $i_top {
	set sel [atomselect top "index $i"]
	set ix [$sel get {x}]
	set iy [$sel get {y}]
	set iz [lindex [$sel get {z}] 0]
	set thick [expr {($iz - $z_bot)/2}]
	puts $archivo "t\t$ix\t$iy\t$thick"
}
  
close $archivo

