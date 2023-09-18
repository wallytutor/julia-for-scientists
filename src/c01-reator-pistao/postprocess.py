# %%
import matplotlib.pyplot as plt
import numpy as np
import pyvista as pv

# %% [markdown]
# foamToVTK -latestTime

# %%
pv.set_jupyter_backend("static")

# %%
mesh = pv.read("VTK/pitzDaily_10000/internal.vtu")

print(f"Time = {mesh['TimeValue'][0]}")

midplane = mesh.slice(normal=[0, 0, 1])

# %%
midplane

# %%

axes = lambda y: ([0, y, 0], [10, y, 0])

Xy = midplane.sample_over_line(*axes(0)).points[:, 0]
Ty = np.mean([
      midplane.sample_over_line(*axes(y))["T"]
      for y in np.linspace(0.0, 0.0049, 30)
      ], axis=0)

# %%
plt.close("all")
plt.style.use("seaborn-white")
plt.plot(Xy, Ty)
plt.grid(linestyle=":")
plt.tight_layout()


