import numpy as np
import matplotlib.pyplot as plt 
import os


file = "data\ke_20\SelFocusNoSteer_ke_20_nvolts_50_Vcenter_-1650_nangle_5_Acenter_15_filled_false.csv"
os.chdir(os.path.dirname(__file__))
data = np.loadtxt(file, skiprows = 3, delimiter = ",")

sel_focus = data[:,0]

Half_angle = data[:,1]

efficiency = data[:,2]

nangles = np.unique(Half_angle)
print(nangles)

average_efficiency = np.zeros(1)
plt.figure()
for angle in nangles:
    indices = np.where(Half_angle ==angle)
    plt.plot(sel_focus[indices], efficiency[indices], label = "angle = "+str(angle))
    average_efficiency = average_efficiency+efficiency[indices]
average_efficiency = average_efficiency/len(nangles)
plt.title(file[27:-4])
plt.xlabel("Split Einzel Lens Voltage(V)")
plt.ylabel("Efficiency From Source To Far Cup (%)")
plt.legend()

plt.figure()
plt.plot(np.unique(sel_focus), average_efficiency)
plt.title(file[27:-4])
plt.xlabel("Split Einzel Lens Voltage(V)")
plt.ylabel("Average Efficiency From Source To Far Cup (%)")
plt.show()
