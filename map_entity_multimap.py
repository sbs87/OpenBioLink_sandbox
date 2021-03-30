# Allow for multiple key IDs. Map each instance to a new value. 

import sys
import pandas as pd
import re

mapping_fn="/Users/stevensmith/Projects/OpenBioLink_sandbox/test_map" #sys.argv[1]
query_fn="/Users/stevensmith/Projects/OpenBioLink_sandbox/query" #sys.argv[2]
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
    query_i=query['query']
    result=""
    try:
        result=mapping[query_i]
    except:
        result=["NOT_FOUND"]
    for val in result:
        print("{}\t{}".format(query_i,val))

