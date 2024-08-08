# https://matplotlib.org/stable/gallery/pie_and_polar_charts/bar_of_pie.html

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import ConnectionPatch


def plot_bar_of_pie(var_slice_ratio, percent_slice_var, slice_var, **kwargs):
    """
    Make a "bar of pie" chart where the first slice of the pie is "exploded" into a bar chart with a further breakdown of said slice's characteristics.


    Parameters
    ----------
    var_slice_ratio : pandas.Series
        A series containing the overall ratios of households categorical variable. eg agricultural land.
        The index should contain the labels (e.g., 'YES', 'NO') and the values should be the ratios.

    perc_of_subcategorical_variable : pandas.DataFrame
        A DataFrame containing the percentage distribution of another categorical variable among households based on `var_slice_ratio`
        It should have two columns: 'var' for the land size categories and 'percentage' for the corresponding percentages.

    Returns
    -------
    None
        This function does not return any value. It displays the pie chart and bar chart.
    """
    # make figure and assign axis objects
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 6))
    fig.subplots_adjust(wspace=0)

    # pie chart parameters
    overall_ratios = list(var_slice_ratio)
    labels = list(var_slice_ratio.index)
    explode = [0.1, 0]
    # rotate so that first wedge is split by the x-axis
    angle = -180 * overall_ratios[0]
    wedges, *_ = ax1.pie(
        overall_ratios,
        autopct="%1.1f%%",
        startangle=angle,
        labels=labels,
        explode=explode,
    )

    # bar chart parameters
    ag_land_label = percent_slice_var[slice_var].to_list()
    ag_land_ratio = percent_slice_var["percentage"].to_list()

    bottom = 1
    width = 0.2

    # Adding from the top matches the legend.
    for j, (height, label) in enumerate(reversed([*zip(ag_land_ratio, ag_land_label)])):
        bottom -= height
        bc = ax2.bar(0, height, width, bottom=bottom, label=label, alpha=1 + 0 * j)
        ax2.bar_label(bc, labels=[f"{height:.1%}"], label_type="center")

    ax2.set_title(kwargs["title"])
    ax2.legend(loc="best")
    ax2.axis("off")
    ax2.set_xlim(-2.5 * width, 2.5 * width)

    # use ConnectionPatch to draw lines between the two plots
    theta1, theta2 = wedges[0].theta1, wedges[0].theta2
    center, r = wedges[0].center, wedges[0].r
    bar_height = sum(ag_land_ratio)

    # draw top connecting line
    x = r * np.cos(np.pi / 180 * theta2) + center[0]
    y = r * np.sin(np.pi / 180 * theta2) + center[1]
    con = ConnectionPatch(
        xyA=(-width / 2, bar_height),
        coordsA=ax2.transData,
        xyB=(x, y),
        coordsB=ax1.transData,
    )
    con.set_color([0, 0, 0])
    con.set_linewidth(2)
    ax2.add_artist(con)

    # draw bottom connecting line
    x = r * np.cos(np.pi / 180 * theta1) + center[0]
    y = r * np.sin(np.pi / 180 * theta1) + center[1]
    con = ConnectionPatch(
        xyA=(-width / 2, 0), coordsA=ax2.transData, xyB=(x, y), coordsB=ax1.transData
    )
    con.set_color([0, 0, 0])
    ax2.add_artist(con)
    con.set_linewidth(2)

    plt.show()
