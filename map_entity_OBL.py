#////////////////////////
# map_entity.py
# Steve Smith
# March 2021
#
# this script will map "common name" identifiers given a mapping file and a head/tail scoring file. 
# this will need to be modified for OBL data
# input:
#   mapping (tsv)
#     Columns with header To/From - > To is the Unique ID, from is the mapped value (common name)
#   dgl-ke results file (tsv)
#     Columns with header head/rel/tail/score -> File from dglke_predict
# output
#   stdout of tab-delimited head/rel/tail/score; head and tail mapped where possible
#////////////////////////
# TODO 
# BIOG-73 Modidy for OBL data... currenly set up as a stand-alone script for dgl-ke embeddings results

import sys
import pandas as pd
import re

# Load variables & data
mapping_fn=sys.argv[1] #id_mappings.tsv
query_fn=sys.argv[2] #TransE_l1_OBL_21_results.teva.rmtrain.csv
mapping=pd.read_csv(mapping_fn,sep="\t",dtype="str")
queries=pd.read_csv(query_fn,sep="\t")

# Set the 'To' column as the index and make into dict {To:From}. Assumes unique ID in To
mapping.set_index('To',inplace=True)
mapping=mapping.to_dict()['From']

# Map both head and tail IDs to common name. 
# Note if ID is not found, the original ID will be reported

for r,query in queries.iterrows():

    query_n1=query['head']
    query_n2=query['tail']

    result_n1=""
    result_n2=""

    # For both head and tail independently, try to map. If not, just report the original query
    try:
        result_n1=mapping[query_n1]
    except:
        result_n1=query_n1
    try:
        result_n2=mapping[query_n2]
    except:
        result_n2=query_n2
    print("{}\t{}\t{}\t{}".format(result_n1,query['rel'],result_n2,query['score'])) #rel and score unchanged


#----END-----






