### update in Order parameter calculation

set frames [molinfo top get numframes]
set name [molinfo top get name]
set lista {}

for {set i 0} {$i < 1} {incr i} {
	for {set frag 0} {$frag < 1} {incr frag} {
		for {set tail 1} {$tail < 9} {if {$tail == 1 || $tail == 3} {incr tail 2} else {incr tail}} {
			if {$tail != 6} {
			  set cmax 14
			} else {set cmax 12}
			set order_list {}
			for {set c 2} {$c <= $cmax} {incr c} {
				set CXN_1 [atomselect top "fragment $frag and resname ECLI and name C$tail$c" frame ${i}]
				set c_1 [expr $c - 1]
				set CXN_0 [atomselect top "fragment $frag and resname ECLI and name C$tail$c_1" frame ${i}]
				set c1_coords [lindex [$CXN_1 get {x y z}] 0]
				set c0_coords [lindex [$CXN_0 get {x y z}] 0]
				$CXN_1 delete
				$CXN_0 delete
				set cos_0 [lindex [vecnorm [vecsub $c1_coords $c0_coords]] 2]
				set Scc [expr 1.5 * $cos_0 * $cos_0 - 0.5] 
				lappend order_list $Scc
			}
			lappend lista "$i\t$tail\t$frag\t[join $order_list "\t"]"
		}
	}
}
set open_file [open "raw_data_$name.dat" w]
puts $open_file "frame\ttail\tfragment\tC2\tC3\tC4\tC5\tC6\tC7\tC8\tC9\tC10\tC11\tC12\tC13\tC14"
foreach k $lista {
	puts $open_file $k
}
close $open_file
