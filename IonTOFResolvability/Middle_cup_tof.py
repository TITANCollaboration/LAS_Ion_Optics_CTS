import numpy as np
import TOFResolutionlib as tr

#This accounts for a drift distance to FC3 with the 2ft drift tube removed
#L_drift = 0.245 # Distance from the end of the einzel lens (accounted for by t0) to the full drift - the drift tube
L_drift = 0.385 # Distance from the end of the einzel lens (accounted for by t0) to the position just behind FC2
L_extra = 0
K = 1300 #eV same as the MR-TOF floated potential

periodic_dict = {"Al":26.982, "Cu":63.546, "Ag":107.87, 
                "Au":196.97, "Pb":207.20, "Th":232.04, 
                "Fe":55.845, "Cr":51.99, "W":183.84, "Ni":58.693, "Mo": 95.95, "Ti":47.867} #Stainless steel 304 contains Fe, Cr, Ni, Mn, Mo 
periodic_dict = dict(sorted(periodic_dict.items(), key=lambda item: item[1]))
for key in periodic_dict:
    mass = periodic_dict[key]
    tof = tr.get_t0(tr.amu_to_kg(mass))+tr.get_t_drift(L_drift,mass,K)
    print(key + str(mass)+ ": " +str(tof))
