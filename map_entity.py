#!/usr/bin/env python
# coding: utf-8

# In[108]:


import pandas as pd

mapping=pd.read_csv("/Users/stevensmith/Projects/OpenBioLink_sandbox/genesymbol_ncbi.f.txt",sep="\t",dtype="str")


# In[109]:


queries=pd.read_csv("/Users/stevensmith/Projects/OpenBioLink_sandbox/TransE_l1_OBL_21_results.compiled_results.rmtrain.csv",sep="\t")


# In[110]:



mapping['To']='NCBIGENE:' + mapping['To'].astype(str)



# In[111]:


mapping.set_index('To',inplace=True)


# In[112]:


mapping=mapping.to_dict()['From']


# In[131]:


import re

for r,query in queries.iterrows():
    #print(query)
    query_n1=query['head']
    query_n2=query['tail']
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


            


# In[ ]:




