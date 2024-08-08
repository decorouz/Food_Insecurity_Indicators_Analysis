# Define utility function


import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


## Bivariate Analysis FIES with socio-demographic, shock and difficulty
def fies_by_socio_demo(df, col):
    """
    Perform bivariate analysis of RFI by socio-demographic factors.

    Parameters:
        - df (DataFrame): The input DataFrame containing the data.
        - col (str): The column name representing the socio-demographic factor.

    Returns:
        - weighted_means (DataFrame): DataFrame containing the weighted means for
        each socio-demographic fact and probability type.
    """
    # Melt the DataFrame
    melted_df = pd.melt(
        df,
        id_vars=[col, "weight_final"],
        value_vars=["prob_mod_sev", "prob_sev"],
        var_name="RFI_level",
        value_name="prob_value",
    )

    # Calculate weighted percentage for each state and RFI
    weighted_percent = (
        melted_df.groupby([col, "RFI_level"], observed=True)
        .agg(
            percentage=(
                "prob_value",
                lambda x: (x * melted_df.loc[x.index, "weight_final"] * 100).sum()
                / melted_df.loc[x.index, "weight_final"].sum(),
            )
        )
        .reset_index()
    )
    return weighted_percent


# Plot the RFI levels by different variables such as state, gender etc
def plot_fies_levels_by_vars(grp_df, var="state", kind="bar", figsize=(7, 4), **kwargs):
    """
    Plot barplot showing the levels of RFI by a specified variable.
    e.g state, gender

    Parameters:
    - grp_df (DataFrame): The input DataFrame containing variable and the weighted percent levels of RFI.
    - var (str): The column name representing the variable to group by (default is "state").
    - **kwargs: Additional keyword arguments for customization.
        - title (str): Title of the plot.

    Returns:
    - None
    """
    # Sort the bar in descending order
    grp_df.sort_values("prob_mod_sev", inplace=True, ascending=False)

    ax = grp_df.plot(kind=kind, figsize=figsize)
    ax.set_xlabel("")
    plt.ylabel("Percentage (%)")
    # Remove y_label
    ax.set_title(kwargs["title"])
    plt.legend(title="RFI Level", bbox_to_anchor=(1.05, 1), loc="upper left")
    plt.xticks(rotation=0)

    for p in ax.patches:
        if kind == "barh":
            # Remove x-axis ticks
            # p.xaxis.set_ticks([])
            width, height = p.get_width(), p.get_height()
            y, x = p.get_xy()
            ax.annotate(
                f"{width:.1f}%",
                (width, x + height / 2),
                ha="left",
                va="center",
                fontsize=8,
            )
        else:
            width = p.get_width()
            height = p.get_height()
            x, y = p.get_xy()
            ax.annotate(
                f"{height:.1f}",
                (x + width / 2, height),
                ha="center",
                va="center",
                size=7,
                xytext=(0, 5),
                textcoords="offset points",
            )

    # plt.tight_layout()

    plt.show()


# Convert to the appropiate data type
def data_type_converter(
    df: pd.DataFrame, exclude_col: list = [None], dtype="object"
) -> pd.DataFrame:
    """
    Convert object datatype columns in a DataFrame to category datatype.

    Args:
        df (pd.DataFrame): The input DataFrame containing object datatype columns.
        dtype (pd.DataFrame): The datatype to convert to


    Returns:
        pd.DataFrame: DataFrame with object datatype columns converted to category datatype.
    """
    # Select object columns
    if dtype == "object":
        object_columns = df.select_dtypes(include=[dtype]).columns

        # Convert object columns to category datatype
        df[object_columns] = df[object_columns].astype("category")
    else:
        float_columns = (
            df.select_dtypes(include=[dtype]).drop(exclude_col, axis=1).columns
        )

        # Convert object columns to category datatype
        df[float_columns] = df[float_columns].astype("category")

    return df


def compute_groupby(
    df: pd.DataFrame, col1: str, col2: str, weight_col: str = "weight_final"
) -> pd.DataFrame:
    """
    Calculate the percentage of occurrences for two categorical variables in a DataFrame.

    Args:
        df (DataFrame): The pandas DataFrame containing the data.
        col1 (str): The name of the first categorical variable.
        col2 (str): The name of the second categorical variable.

    Returns:
        DataFrame: A DataFrame with the percentage of occurrences for each category of col2
        within each category of col1.

    Example:
        calculate_percentage_for_two_cat_variables(df, 'state', 'income_more_than_one')
    """
    grp_df = (
        df.groupby([col1, col2], observed=False)
        .agg(weight_sum=pd.NamedAgg(column=weight_col, aggfunc="sum"))
        .reset_index()
    )

    # Pivot the DataFrame to have col1 as rows and col2 as columns
    pivot_df = grp_df.pivot(index=col1, columns=col2, values="weight_sum")

    # Calculate the percentage of each category within each category of col1
    pivot_df_percentage = pivot_df.div(pivot_df.sum(axis=1), axis=0) * 100

    return pivot_df_percentage


def plot_grouped_data(
    pivot_df_percentage: pd.DataFrame, kind="barh", figsize=(12, 6), **kwargs
) -> None:
    # Plot the stacked bar chart
    ax = pivot_df_percentage.plot(
        kind=kind,
        # stacked=kwargs["stacked"],
        width=0.8,
        figsize=figsize,
        # hatch=['^']*len(pivot_df_percentage)
    )

    plt.title(kwargs["title"])
    plt.legend(title=kwargs["legend_title"], bbox_to_anchor=(1.05, 1), loc="upper left")

    # Remove y_label
    ax.set_ylabel("")

    # Annotate each bar with the percentages for each category
    for bar in ax.patches:
        if kind == "barh":
            # Remove x-axis ticks
            ax.xaxis.set_ticks([])
            width, height = bar.get_width(), bar.get_height()
            y, x = bar.get_xy()
            ax.annotate(
                f"{width:.1f}%",
                (width, x + height / 2),
                ha="left",
                va="center",
                fontsize=8,
                color="black",
                fontfamily="Times New Roman",
            )
        else:
            ax.yaxis.set_ticks([])
            ax.annotate(
                f"{bar.get_height():.1f}%",
                (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center",
                va="center",
                size=7,
                xytext=(0, 5),
                textcoords="offset points",
                color="black",
                fontfamily="Times New Roman",
            )

    plt.tight_layout()
    plt.show()


#################Calculate Weighted Percentage of a Column in a DataFrame#############################
def calculate_weighted_percentage(
    df: pd.DataFrame, group_col: str, weight_col: str
) -> pd.DataFrame:
    """
    Calculate the weighted percentage of a col in a DataFrame.

    Parameters:
        df (pd.DataFrame): DataFrame containing the data.
        group_col (str): Name of the column to group by

    Returns:
        pd.DataFrame: DataFrame with count and percentage calculated.
    """
    # Group by the specified column and calculate count
    group_weight_sum = (
        df.groupby(group_col, observed=False)
        .agg(weighted_sum=pd.NamedAgg(column=weight_col, aggfunc="sum"))
        .reset_index()
    )

    # Calculate total count of all groups
    total_weight = group_weight_sum["weighted_sum"].sum()

    # Calculate percentage of each group
    group_weight_sum["percentage"] = round(
        (group_weight_sum["weighted_sum"] / total_weight), 3
    )

    return group_weight_sum


############################################################################################


def plot_group_by_percentage(grp_df: pd.DataFrame, grp_by_col: str, **kwargs) -> None:
    """
    Plot the distribution of grouped variable (barplot).

    Args:
        grp_df (pd.DataFrame): DataFrame containing the percentage of each grouped variable.

    Returns:
        None
    """
    # Create the bar plot
    plt.figure(figsize=(10, 5))
    ax = sns.barplot(
        data=grp_df,
        y=grp_by_col,
        x="percentage",
        order=grp_df.sort_values("weighted_sum", ascending=False)[grp_by_col],
        # hue="percentage",
        # palette="Spectral"
    )

    # Add percentage labels to the bars
    ax.bar_label(ax.containers[0], fontsize=8, fmt="%1.1f%%")  # Add '%'

    # Remove x-axis ticks and labels
    ax.xaxis.set_ticks([])
    ax.set_xlabel("")

    # Set y-axis label and plot title
    ax.set_ylabel(kwargs["ylabel"])
    ax.set_title(kwargs["title"])

    # Show the plot
    plt.show()


# =================================================
# Crop production difficulty utility functions
# =================================================


# Main reported crop production difficulty
# ?>>?Come back to this
def percentage_crp_prod_dif(df, start, end, n):

    # Subset the difficulty variables
    diffulties = df.loc[:, start:end]
    wt = df["weight_final"]
    # weight_col =  df[["weight_final"]].columns
    valid_data = pd.concat([diffulties, wt], axis=1)

    results = pd.DataFrame()

    # Iterate over all columns except the weight column
    for col in valid_data.columns:
        if col != "weight_final":
            # Drop rows where the variable is NaN
            valid_data = df.dropna(subset=[col])

            # Calculate weighted sum for each category
            weighted_sum = valid_data.groupby(col, observed=True)["weight_final"].sum()

            # Calculate total weight
            total_weight = valid_data["weight_final"].sum()

            # Calculate percentage for each category
            percentage = (weighted_sum / total_weight) * 100
            # Add the result to the results DataFrame
            results = pd.concat([results, percentage.rename(col)], axis=1)
    # Melt the result
    results = pd.melt(
        results.reset_index(drop=True).iloc[[1]],
        var_name="difficulty_type",
        value_name="value",
    ).sort_values("value", ascending=False)
    return results.reset_index(drop=True).head(n)


# =====================Plot all production difficulty variables===========================
def plot_diff_variables(crp_proddiff_df: pd.DataFrame, title: str) -> None:
    # Plot the shocks
    plt.figure(figsize=(10, 4))
    ax = sns.barplot(
        crp_proddiff_df,
        x="value",
        y="difficulty_type",
    )

    # Add percentage labels to the bars
    ax.bar_label(ax.containers[0], fontsize=8, fmt="%1.1f%%")

    # Remove x-axis ticks and lables
    ax.xaxis.set_ticks([])
    ax.set_xlabel("")
    ax.set_title(title)

    plt.show()


# ==================== Crop Production Difficult by State ==================================
# Utitity function to compute all crop difficulty by state
def all_top_crp_diff_by_state(df, subset: list):
    crp_prod = df.dropna(subset=subset)
    weighted_crp_diff = (
        crp_prod[subset].astype(float).multiply(crp_prod["weight_final"], axis=0)
    )
    weighted_df = crp_prod[["state", "weight_final"]].join(weighted_crp_diff)

    # Group by state and sum the weighted counts and weights
    grouped = weighted_df.groupby("state", observed=True).sum()

    # Calculate the percentage for each shock
    for col in subset:
        grouped[col] = (grouped[col] / grouped["weight_final"]) * 100
        # Keep only the percentage columns
    percentage_columns = [col for col in subset]
    all_shocks_by_state = grouped[percentage_columns]
    return all_shocks_by_state


################Handling Outlier #########################

# Identifying outliers using IQR and zsocre methods


def outlier_infor_iqr(df: pd.DataFrame, column: str) -> pd.DataFrame:
    """
    Identifies and handles outliers in a specified column of a DataFrame using the Interquartile Range (IQR) method.

    This function calculates the IQR for the values in the specified column and identifies outliers
    as those values that fall below Q1 - 1.5 * IQR or above Q3 + 1.5 * IQR. It then replaces these
    outliers with the median value of the column.

    Parameters
    ----------
    df : pandas.DataFrame
        The input DataFrame containing the data.
    column : str
        The name of the column in which to identify and handle outliers.

    Returns
    -------
    pandas.DataFrame
        A new DataFrame with outliers in the specified column replaced by the median value of the column.
    """

    Q1 = df[column].quantile(0.25)
    Q3 = df[column].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR

    # Count the number of outlier records
    print("Outliers records using IQR:")
    print(np.sum((df.loc[:, column] < lower_bound) | (df.loc[:, column] > upper_bound)))

    df1 = df.copy()

    median = df[column].median()
    df1[f"{column}_clean_iqr"] = np.where(
        (df1[column] > upper_bound) | (df1[column] < lower_bound), median, df1[column]
    )
    return df1


#####################################
def outlier_info_zscore(
    df: pd.DataFrame, column: str, z_thresh: float = 2.5
) -> pd.DataFrame:
    """
    Identifies and handles outliers in a specified column of a DataFrame using the Z-score method.

    This function calculates the Z-scores for the values in the specified column and identifies outliers
    as those values with an absolute Z-score greater than the specified threshold. It then replaces these
    outliers with the mean value of the non-outlier data points in the column.

    Note
    ----

    Replace outlier values with the mean (where the mean is calculated excluding the outlier values)

    Parameters
    ----------
    df : pandas.DataFrame
        The input DataFrame containing the data.
    column : str
        The name of the column in which to identify and handle outliers.
    z_thresh : float, optional
        The Z-score threshold for identifying outliers. Default is 2.5.

    Returns
    -------
    pandas.DataFrame
        A new DataFrame with outliers in the specified column replaced by the mean value of the non-outlier data points.
    """
    from scipy import stats

    # Count the number of outlier records
    print("Outliers records using ZSCORE:")
    print(np.sum(np.abs(stats.zscore(df[column])) > z_thresh))

    df1 = df.copy()

    df1[f"{column}_outlier_z"] = np.abs(df1[column]) > z_thresh
    df1[f"{column}_mean"] = df1[df1[f"{column}_outlier_z"] == False][column].mean()
    df1[f"{column}_clean"] = np.where(
        df1[f"{column}_outlier_z"] == True, df1[f"{column}_mean"], df1[column]
    )
    return df1.drop(columns=[f"{column}_outlier_z", f"{column}_mean"], axis=1)


###############################################
