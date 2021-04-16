#////////////////
# DisGeNetAssociationType.py
# April 2021
# This module written by Simon Ott from OBL as a feature request from Felipe Mello under OBL's issue #62 (https://github.com/OpenBioLink/OpenBioLink/issues/62)
# Script orignally at: https://gist.github.com/nomisto/4f2a21a93779be673a22d121157b14c3
# It was adapted by Steve Smith from Teva to suit our purposes
# -----------------------
# This script will take a given train, test or val set from OBL and 'expand' the edge types that come from DisGeNet (the Gene:Dis edge types)
# So instead of GENE_DIS as the only edge type in DisGeNet, the edge types will be more granular, i.e., GENE_ALTEREDEXPRESSION_DIS and GENE_BIOMARKER_DIS
# -----------------------
# Usage: see the series of function calls at the bottom, which will:
# 1. Downloads DisGeNet UMLS:DOID mapping file (DisGeNet Ids diseases using UMLS, OBL uses DOID)
# 2. Downloads 2020 version of DisGeNet sql database (contining granular edge types)
# 3. Reads in SQL db DOID:GENE edges to dict
# 4. Enriches the train/test/val sets with updated edge types
# Note that the quality score cutoff is only for new SQL database; if the train/test/val sets have scores >0.8 then the cutoffs won't do much. See note above enrich_set
#////////////////

import urllib
import gzip
import io
#from tqdm.notebook import tqdm - do not have this version of the lib
import tqdm
import requests
import shutil
import os
from collections import defaultdict
import sqlite3

"""
CONFIG
"""
data_path_root='/Users/stevensmith/Projects/OpenBioLink_sandbox/testing/db/' #"/Users/stevensmith/Projects/OpenBioLink/HQ_DIR/train_test_data/"
source_db_files='/Users/stevensmith/Projects/OpenBioLink_sandbox/testing/final/' 

path_train = data_path_root+"train_sample.csv"
path_test = data_path_root+"test_sample.csv"
path_valid = data_path_root+"val_sample.csv"

path_train_out = data_path_root+"new_train_sample.csv"
path_test_out = data_path_root+"new_test_sample.csv"
path_valid_out = data_path_root+"new_val_sample.csv"

db_url = "https://www.disgenet.org/static/disgenet_ap1/files/sqlite_downloads/current/disgenet_2020.db.gz"
db_name = source_db_files+"disgenet_2020.db"
mapping_url = "http://www.disgenet.org/static/disgenet_ap1/files/downloads/disease_mappings.tsv.gz"
mapping_name = source_db_files+"disease_mappings.tsv"

LQ_CUTOFF = 0
MQ_CUTOFF = 0.4
HQ_CUTOFF = 0.7

cutoff = LQ_CUTOFF

def download_and_extract(url, file_name):
    #file_path=os.path.dirname(file_name) ## will need to convert all instances so leave this for now. 
    if os.path.isfile(file_name):
        print(f"{file_name} already exists, skipping download..")
        return
    gzip_name = file_name + ".gz"

    # SS: OBL had a status bar, but I don't have tqdm.notebook/library needed to perform this. Replaced with a simple urlretrieve
    urllib.request.urlretrieve(url,gzip_name)
    #with TqdmUpTo(unit='B', unit_scale=True, unit_divisor=1024, miniters=1,
    #          desc=url.split('/')[-1]) as t:  # all optional kwargs
    #    urllib.request.urlretrieve(url=url, filename=gzip_name, reporthook=t.update_to, data=None)
    #    t.total = t.n
    
    #file_name = gzip_name.replace(".gz","")
    
    with gzip.open(gzip_name, 'rb') as f_in:
        with open(file_name, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    return file_name

def read_mapping(mapping_file):
    content = None
    with open(mapping_file, "r") as infile:
        content = infile.readlines()
    content = [x.strip() for x in content]
    mapping = defaultdict(list)
    for line in content[1:]:
        diseaseId,_,voc,code,_ = line.split("\t")
        if voc == "DO":
            mapping[diseaseId].append(code)
    return mapping

def read_db(db_file, mapping):
    # Getting association types from db file

    association_types = defaultdict(dict)

    with sqlite3.connect(db_file) as conn:
        for row in conn.execute('select geneId, diseaseID, associationType, score from geneDiseaseNetwork INNER JOIN diseaseAttributes ON geneDiseaseNetwork.diseaseNID = diseaseAttributes.diseaseNID INNER JOIN geneAttributes ON geneDiseaseNetwork.geneNID = geneAttributes.geneNID'):
            gene, disease, associationType, score = row
            if disease not in mapping.keys():
                continue
            else:
                for doid in mapping[disease]:
                    nbigenegene = "NCBIGENE:" + str(gene)
                    doid = "DOID:" + str(doid)
                    if score >= association_types[(nbigenegene,doid)].get(associationType, 0.0):
                        association_types[(nbigenegene,doid)][associationType] = score
    return association_types

"""
Extends all relations of type GENE_DIS with an association type if above cutoff.
If no association type has a higher confidence than the cutoff the old relation is written (see variable cutoff_met)
If you set cutoff to 0.0 all relations of type GENE_DIS (that can be found) are replaced with the association type relations
"""
def enrich_set(path_in, path_out, association_types, cutoff: float):
    content = None
    with open(path_in, "r") as infile:
        content = infile.readlines()
    content = [x.strip() for x in content]
    with open(path_out, "w") as out:
        for line in content:
            #TODO: SS: Note that 'qual' is never used. Unsure why. 
            head, rel, tail, qual, negative, src = line.split("\t")
            if rel == "GENE_DIS":
                if len(association_types[(head,tail)]) > 0:
                    cutoff_met = False
                    for association_type, confidence in association_types[(head,tail)].items():
                        new_rel = "GENE_" + "_".join(association_type.upper().split(" ")) + "_DIS"
                        if confidence > cutoff:
                            cutoff_met = True
                            out.write("\t".join([head, new_rel, tail, str(confidence), negative, src]) + "\n")
                    if not cutoff_met:
                        out.write(line + "\n")    
                else:
                    out.write(line + "\n")
            else:
                out.write(line + "\n")

download_and_extract(mapping_url, mapping_name)
mapping = read_mapping(mapping_name)

download_and_extract(db_url, db_name)
association_types = (db_name, mapping)

enrich_set(path_test, path_test_out, association_types, cutoff)
enrich_set(path_train, path_train_out, association_types, cutoff)
enrich_set(path_valid, path_valid_out, association_types, cutoff)

