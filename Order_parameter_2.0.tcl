### update in Order parameter calculation

set frames [molinfo top get numframes]  ### st the max number of frames
set name [molinfo top get name]
set lista []

for {set i 0} {i < $frames} {incr i} {
	for {set frag 0} {$frag < 72} {incr frag} {
		for {set tail 1} {$tail < 9} {if {$tail == 1 || $tail == 3} {incr tail 2} else {incr tail}} {
			if {$tail != 6} {
				set cmax 14
			} else {set cmax 13} 																	  ### set the number of carbon in the short tail
			set order_list {}
			for {set c 2} {$c < $cmax} {incr c} {
				set CXN_1 [atomselect top "fragment $frag and resname ECLI and name C$tail$c" frame $i]   ### Carbon selection
				set c-1 [expr $c_num - 1]
				set CXN_0 [atomselect top "fragment $frag and resname ECLI and name C$tail$c-1" frame $i] ### C-1 selection
				set c1_coords [lindex [$CXN_1 get {x y z}] 0]  # convert {x y z} to x y z, this is done for vecsub to work
				set c0_coords [lindex [$CXN_0 get {x y z}] 0]
				$CXN_1 delete
				$CXN_0 delete
				set cos_0 [lindex [vecnorm [vecsub $c1_coords $c0_coords]] 2]
				set Scc [expr 1.5 * $cos_0 * $cos_0 - 0.5] 
				lappend order_list $Scc
			}
			lappend lista "$frame\t$tail\t$frag\t[join $order_list "\t"]"   ## append data in to list for better performance
		}
	}
}
set open_file [open "raw_data_$name.dat" w]
puts $open_file "frame\ttail\tfragment\tC2\tC3\tC4\tC5\tC6\tC7\tC8\tC9\tC10\tC11\tC12\tC13\tC14"  ## set title
foreach k $lista {
	puts $open_file $k
}
close $open_file