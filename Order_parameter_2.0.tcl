# Order parameter calculation
;# J Phys Chem B. 2009 Feb 5; 113(5): 1501–1510.
;# El parametro de orden se calculas segun la formula 1.5 * ($cos_0 ** 2) - 0.5
;# si S = 1, el enlace es paralelo a la normal de la bicapa;
;# S = -0.5 indica que el enlace es perpendicular a la normal;
;# S = 0 significa que la orientacion del enlace es completamente desordenada.

proc get_scc {frames name} {
	set tail {1 3 5 6 7 8}	# el LPS posee 6 colas aciles numeradas segun la lista
	set cmax 14				# el maximo numero de Carbonos por cola
	set open_file [open "raw_data_$name.dat" w]
	puts $open_file "frame\tfragment\ttail\tCarbon\tOrder"
	for {set frag 0} {$frag < 72} {incr frag} { # se sabe que cada cara de la membrana posee 36 LPS por lo tanto en total existen 72 fragmentos.
		foreach t $tail {
			for {set c 2} {$c <= $cmax} {incr c} { # el calculo de Scc comienza en el carbono 2 ya que el 1 no posee uno anterior.
				set CXN_1 [atomselect top "fragment $frag and name C$t$c"] # seleccion del carbono a medir.
				if { [$CXN_1 num] == 0 } { # condicional para saltar los carbonos que no existan en una cola.
					puts "skipping name C${t}${c} of tail $t" 
					continue
				}		
				set c_1 [expr {$c - 1}]
				set CXN_0 [atomselect top "fragment $frag and name C$t$c_1"] # Seleccionar el carbono C-1
				if { [$CXN_0 num] == 0 } {
					puts "skipping name C${t}${c_1} of tail $t"
					continue
				}
				for {set i 0} {$i < $frames} {incr i} { # Calcular para cada paso de la dinamica
					$CXN_1 frame ${i} # Actualiza el frame de la seleccion de carbonos.
					$CXN_0 frame ${i}
					set c1_coords [lindex [$CXN_1 get {x y z}] 0] # Obtener las coordenadas de los carbonos en formato sin {}, utilizando "lindex".
					set c0_coords [lindex [$CXN_0 get {x y z}] 0]
					set cos_0 [lindex [vecnorm [vecsub $c1_coords $c0_coords]] 2] # Calculo de la proyeccion en z del vector C-C normalizado a 1.
					set Scc [expr 1.5 * ($cos_0 ** 2) - 0.5] # Calculo del parmetro de orden
					puts $open_file "$i\t$frag\t$t\tC$c\t$Scc" # Comando para grabar la infromacion a un archivo.
				}
				$CXN_1 delete # Siempre eliminar las selecciones despues de utilizarlas para evitar la saturacion de la memoria.
				$CXN_0 delete
			}
		}
	}
	close $open_file
}


time {set name "wt_310" 
set frames [molinfo top get numframes] # Obtener frames de la simulacion.
get_scc $frames $name
}
