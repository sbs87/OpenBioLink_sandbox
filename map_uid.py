#////////////////////////
# map_uid.py
# Steve Smith
# April 2021
#
# this function will map "common name" identifiers (OBL) given a mapping df and a query df. 
# Perfoms a right join on mapping-query df (keeps unmapped query IDs)
# input:
#   mapping (filename, string)
#     Columns with header UID/value pairs - > UID is the original Unique ID, value is the mapped value (common name)
#   query (dataframe)
#     Columns with at least the UID in mapping file
#   (optional) mapping_uid_col_name - the column header containing uniuqe ID of mapping (Default 'UID')
#   (optional) query_uid - the column header containing uniuqe ID of query (Default 'UID')
# output
#   dataframe with original content + mapped ID
#   Unmappable IDs with have a 'NaN' in the 'common_name' column
#   <UID>//<common_name>//<other_columns>
# assumes mapping_file has unique IDs in UID column
#////////////////////////
import pandas as pd

def map_uid(mapping_fn,query_df,mapping_uid_col_name='UID',query_uid='UID'):
    # Read mapping file
    mapping=pd.read_csv(mapping_fn,sep="\t",dtype="str")
    # Perfom right join to map IDs
    mapped_df=pd.merge(mapping,query_df,left_on=mapping_uid_col_name,right_on=query_uid,how='right')
    return(mapped_df)

