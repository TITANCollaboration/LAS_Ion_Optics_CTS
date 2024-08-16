import numpy as np
import matplotlib.pyplot as plt
import TOFResolutionlib as tr

L_dt = np.arange(0,0.900,0.001)
#L_dt = 0.6096 #2ft
L_extra = 0
K = 1300 #eV same as the MR-TOF floated potential

switch_time = 5e-7 #Total on-->off-->on time  

optical_jitter = 4e-7 #This value is for the one-sided window (needs doubling to match switch_time window see t_window below)

arduino_jitter = 2.4e-7

total_jitter = np.sqrt(arduino_jitter**2+optical_jitter**2)

t_window = switch_time+total_jitter

periodic_dict = {"Al":26.982, "Cu":63.546, "Ag":107.87, 
                "Au":196.97, "Pb":207.20, "Th":232.04, 
                "Fe":55.845, "Cr":51.99, "W":183.84, "Ni":58.693, "Mo": 95.95} #Stainless steel 304 contains Fe, Cr, Ni, Mn, Mo 

periodic_dict = dict(sorted(periodic_dict.items(), key=lambda item: item[1]))

prevkey = None
fig, ax = plt.subplots()
colors= ['purple','blue','cyan', 'green','yellow', 'red']
color_ind = 0
for key in periodic_dict:

    mass = periodic_dict[key]

    m_max, m_min = tr.get_mass_window(mass, t_window, L_dt, L_extra, K)

    mass_window = m_max-m_min

    mass_window_p = m_max-mass

    mass_window_m = mass-m_min

    mass_resolving_power = mass/(mass_window)

    
    ax.fill_between(L_dt,m_max, m_min, color = colors[color_ind], alpha = 0.3)
    ax.axhline(mass, linestyle = "--", color = colors[color_ind], label = key)

    color_ind =(color_ind+1)%len(colors)

ax.vlines([0.120, 0.855],0,300)
ax.legend()
ax.set_xlabel("Length of Drift Post Einzel lens(m)")
ax.set_ylabel("Mass (amu)")
ax.set_title("Unresolvable Mass Window of " + ', '.join(periodic_dict.keys()))
plt.show()
