import sys
import pandas as pd
import re

mapping_fn=sys.argv[1]
query_fn=sys.argv[2]
mapping=pd.read_csv(mapping_fn,sep="\t",dtype="str")
queries=pd.read_csv(query_fn,sep="\t")

#mapping['To']='NCBIGENE:' + mapping['To'].astype(str)
mapping.set_index('To',inplace=True)
mapping=mapping.to_dict()['From']
for r,query in queries.iterrows():
    #print(query)
    query_n1=query['head']
    query_n2=query['tail']
    #print(mapping[query_n1])
    result_n1=""
    result_n2=""
    try:
        result_n1=mapping[query_n1]
    except:
        result_n1=query_n1
    try:
        result_n2=mapping[query_n2]
    except:
        result_n2=query_n2
    print("{}\t{}\t{}\t{}".format(result_n1,query['rel'],result_n2,query['score']))
    #print("{}\t{}".format(result_n1,query_n2))





