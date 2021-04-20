#////////////////
# create_uberon_mapping.py
# April 2021
# This script will map an UBERON ID (for example, CL, cell line) to its common name. 
# This could be used in either the master mapping_uid.py function or as a stand-alone to add to id_mapping.txt file
# -----------------------
# This script will take the obo flatfile from UBERON (https://uberon.github.io/downloads.html), and write out the ID and common name
# -----------------------
#////////////////

import networkx
import obonet

url = 'http://purl.obolibrary.org/obo/uberon/ext.obo'
# Alternativley you can download the above file and save locally

graph = obonet.read_obo(url)
# Map the UID to common name via dict
id_to_name = {id_: data.get('name') for id_, data in graph.nodes(data=True)}

#id_to_name['CL:0000008'] 
for i in id_to_name:
    if(re.search("CL",i)):
        print("{}\t{}".format(i,id_to_name[i]))
    
