proc Scc {frames} {
set lista []
for {set tail 1} {$tail < 9} {if {$tail == 1 || $tail == 3} {incr tail 2} else {incr tail}} {
puts "measuring tail $tail"
if {$tail != 6} {
    set cmax_num 14
  } else {
    set cmax_num 13
  }
for {set frag 0} {$frag < 72} {incr frag} {
for {set frame 0} {$frame < $frames} {incr frame} {
set order_list {}
for {set c_num 2} {$c_num < $cmax_num} {incr c_num} {
    set CXN_1 [atomselect top "fragment $frag and resname ECLI and name C$tail$c_num"]
    set prev_num [expr $c_num - 1]
    set CXN_0 [atomselect top "fragment $frag and resname ECLI and name C$tail$prev_num"]
    $CXN_1 frame $frame
    $CXN_0 frame $frame
    set c1_coords [lindex [$CXN_1 get {x y z}] 0]
    set c0_coords [lindex [$CXN_0 get {x y z}] 0]
    set cos_0 [lindex [vecnorm [vecsub $c1_coords $c0_coords]] 2]
    set Scc [expr 1.5 * $cos_0 * $cos_0 - 0.5]
    lappend order_list $Scc
    $CXN_1 delete
    $CXN_0 delete
}
lappend lista "$frame\t$tail\t$frag\t[join $order_list "\t"]"
}    
}
}
set open_file [open "raw_data.dat" w]
puts $open_file "frame\ttail\tfragment\tC2\tC3\tC4\tC5\tC6\tC7\tC8\tC9\tC10\tC11\tC12\tC13\tC14"
foreach k $lista {
	puts $open_file $k
}
close $open_file
}

puts "calculando parametros de orden"

set n [molinfo top get numframes]
Scc $n
puts finalizado
