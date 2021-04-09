# Allow for multiple key IDs. Map each instance to a new value. 
#////////////////////////
# map_entity_multimap.py
# Steve Smith
# April 2021
#
# this script will map "common name" identifiers given a mapping file and a query file. 
# input:
#   mapping (tsv)
#     Columns with header key/value - > Key is the original ID, value is the mapped value (common name)
#   query file (tsv)
#     Columns with header id -
# output
#   stdout of tab-delimited mapped file; mapped where possible
#////////////////////////
import sys
import pandas as pd
import re

mapping_fn=sys.argv[1]
query_fn=sys.argv[2]
mapping_raw=pd.read_csv(mapping_fn,sep="\t",dtype="str")
queries=pd.read_csv(query_fn,sep="\t")
mapping={}

for m,w in mapping_raw.iterrows():
    id_i=w['ID']
    value_i=w['value']
    if id_i in mapping.keys():
        mapping[id_i].append(value_i)
    else:
        mapping[id_i]=[value_i]

for r,query in queries.iterrows():
    query_i=str(query['query'])

    result=""
    try:
        result=mapping[query_i]
    except:
        result=["NOT_FOUND"]
    
    #for i in query:
    #    print(i, end=" ")
    for val in result:
        print("{}\tPUBCHEM.COMPOUND:{}".format(query_i,val))

