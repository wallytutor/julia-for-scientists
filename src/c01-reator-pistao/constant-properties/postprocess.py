# -*- coding: utf-8 -*-
""" Post-processing of OpenFOAM results.

Before finishing the simulation and then running this script
run `foamToVTK -latestTime` from the command line.  This will
generate a `VTK/` folder with data in VTK format for reading
and processing with help of PyVista.
"""
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import pyvista as pv

LENGTH = 10
""" Reactor length over x-axis [m]. """


def axis(y):
    """ Reactor axis coordinates at radius `y`. """
    return ([0, y, 0], [LENGTH, y, 0])


def tabulate(mesh, Y_space):
    """ Create table with mean temperature per slice. """
    X = mesh.sample_over_line(*axis(0)).points[:, 0]
    T = np.mean([mesh.sample_over_line(*axis(y))["T"]
                for y in Y_space], axis=0)
    return pd.DataFrame({"X": X, "T": T})


def plot_results(X, T):
    """ Plot temperature profile along reactor axis. """
    plt.close("all")
    plt.style.use("seaborn-white")
    plt.plot(X, T)
    plt.grid(linestyle=":")
    plt.xlabel("Posição [m]")
    plt.ylabel("Temperatura [K]")
    plt.xlim(0, LENGTH)
    plt.ylim(300, 400)
    plt.tight_layout()
    plt.show()


def main():
    """ Post-processing workflow. """
    here = Path(__file__).parent.name
    mesh = pv.read(f"VTK/{here}_10000/internal.vtu")
    df = tabulate(mesh, np.linspace(0.0, 0.0049, 10))

    # Downsample results, every 5 cm is enough!
    df = df.iloc[::1000]
    df.to_csv("postprocess.dat", index=False, sep="\t",
            header=None, float_format="%.6f")

    plot_results(df["X"].to_numpy(), df["T"].to_numpy())


if __name__ == "__main__":
    main()
