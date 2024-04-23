# Define utility function

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


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


def compute_groupby(df: pd.DataFrame, col1: str, col2: str) -> pd.DataFrame:
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
    # Groupby the DataFrame to have a new column count
    grp_df = (
        df.groupby([col1, col2], observed=False)
        .agg(count=pd.NamedAgg(column=col2, aggfunc="size"))
        .reset_index()
    )

    # Pivot the DataFrame to have col1 as rows and col2 as columns
    pivot_df = grp_df.pivot(index=col1, columns=col2, values="count")

    # Calculate the percentage of each category within each category of col1
    pivot_df_percentage = pivot_df.div(pivot_df.sum(axis=1), axis=0) * 100

    return pivot_df_percentage


def plot_grouped_data(pivot_df_percentage: pd.DataFrame, **kwargs) -> None:
    # Plot the stacked bar chart
    ax = pivot_df_percentage.plot(
        kind="barh", 
        # stacked=kwargs["stacked"], 
        width=0.8, figsize=(12, 5)
    )

    plt.title(kwargs["title"])
    plt.legend(title=kwargs["legend_title"], bbox_to_anchor=(1.05, 1), loc="upper left")

    # Remove x-axis ticks
    ax.xaxis.set_ticks([])
    # Remove y_label
    ax.set_ylabel("")

    # Annotate each bar with the percentages for each category
    for p in ax.patches:
        width, height = p.get_width(), p.get_height()
        y, x = p.get_xy()
        ax.annotate(
            f"{width:.1f}%", (width, x + height / 2), ha="left", va="center", fontsize=8
        )

    plt.tight_layout()
    plt.show()


def calculate_groupby_percentage(df: pd.DataFrame, group_col: str) -> pd.DataFrame:
    """
    Calculate the percentage of each group in a DataFrame.

    Parameters:
        df (pd.DataFrame): DataFrame containing the data.
        group_col (str): Name of the column to group by.
        count_col (str): Name of the column containing the count.

    Returns:
        pd.DataFrame: DataFrame with percentage calculated.
    """
    # Group by the specified column and calculate count
    group_count = (
        df.groupby(group_col, observed=False)
        .agg(count=pd.NamedAgg(column=group_col, aggfunc="count"))
        .reset_index()
    )

    # Calculate total count of all groups
    total_count = group_count["count"].sum()

    # Calculate percentage of each group
    group_count["percentage"] = round((group_count["count"] / total_count) * 100, 2)

    return group_count


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
        order=grp_df.sort_values("count", ascending=False)[grp_by_col],
        # hue="percentage",
        palette="Spectral"
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
