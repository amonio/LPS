### update in Order parameter calculation

proc get_scc {frames name} {
	set tail {1 3 5 6 7 8}
	set cmax 14
	set open_file [open "raw_data_$name.dat" w]
	puts $open_file "frame\tfragment\ttail\tCarbon\tOrder"
	for {set frag 0} {$frag < 72} {incr frag} {
		foreach t $tail {
			for {set c 2} {$c <= $cmax} {incr c} {
				set CXN_1 [atomselect top "fragment $frag and name C$t$c"]
				if { [$CXN_1 num] == 0 } {
					puts "skipping name C${t}${c} of tail $t"
					continue
				}		
				set c_1 [expr {$c - 1}]
				set CXN_0 [atomselect top "fragment $frag and name C$t$c_1"]
				if { [$CXN_0 num] == 0 } {
					puts "skipping name C${t}${c_1} of tail $t"
					continue
				}
				for {set i 0} {$i < $frames} {incr i} {
					$CXN_1 frame ${i}
					$CXN_0 frame ${i}
					set c1_coords [lindex [$CXN_1 get {x y z}] 0]
					set c0_coords [lindex [$CXN_0 get {x y z}] 0]
					set cos_0 [lindex [vecnorm [vecsub $c1_coords $c0_coords]] 2]
					set Scc [expr 1.5 * ($cos_0 ** 2) - 0.5]
					puts $open_file "$i\t$frag\t$t\tC$c\t$Scc"
				}
				$CXN_1 delete
				$CXN_0 delete
			}
		}
	}
	close $open_file
}


time {set name "wt_310"
set frames [molinfo top get numframes]
get_scc $frames $name
}
