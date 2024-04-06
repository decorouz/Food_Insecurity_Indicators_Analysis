import pandas as pd


def show_columns_with_only_na(data: pd.DataFrame) -> pd.Index:
    """Return a pandas index with columns with only NaN values

    Args:
        data (pd.DataFrame): input dataframe to be analysed

    Returns:
        pd.Index: Columns with all all missing value
    """
    missing = data.isnull().sum()
    # Filter for columns where all values are NaN
    columns_with_all_missing = missing[missing == len(data)].index

    return columns_with_all_missing
