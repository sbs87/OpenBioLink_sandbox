# Unit test for map_uid.py

import pandas as pd
import map_uid

# read mapping file
mapping_fn="id_mappings.tsv"

# initialize a query_df
query_df=pd.DataFrame() 
query_df['UID']=['NCBIGENE:8629','NCBIGENE:3600','NCBIGENE:NONEXIST']
query_df['other_col_1']=['VAL_1','VAL_2','VAL_3']
query_df['other_col_2']=[1.11,2.22,3.33]

# perform test 
## NCBIGENE:NONEXIST should have NaN in common_name
print("////\nTEST1")
print(map_uid.map_uid(mapping_fn,query_df))

# perform test - duplicate query
query_df=query_df.append(pd.DataFrame([['NCBIGENE:3600','VAL_2',2.22]], columns=['UID','other_col_1','other_col_2']))
query_df=query_df.append(pd.DataFrame([['NCBIGENE:3600','VAL_200',20.22]], columns=['UID','other_col_1','other_col_2']))
print("////\nTEST2")
print(map_uid.map_uid(mapping_fn,query_df)) # should map both query rows

# perform test - new UID name
## NCBIGENE:NONEXIST should have NaN in common_name; there should be additional columns from mapping_file
query_df=query_df.rename(columns={"UID": "query"})
print("////\nTEST3")
print(map_uid.map_uid(mapping_fn,query_df,query_uid='query')) # should work




