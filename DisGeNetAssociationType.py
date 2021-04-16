
import urllib
import gzip
import io
from tqdm.notebook import tqdm
import requests
import shutil
import os
from collections import defaultdict
import sqlite3

"""
CONFIG
"""

path_train = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\train_sample.csv"
path_test = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\test_sample.csv"
path_valid = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\val_sample.csv"

path_train_out = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\new_train_sample.csv"
path_test_out = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\new_test_sample.csv"
path_valid_out = r"C:\Users\sott\Documents\HQ_DIR\HQ_DIR\train_test_data\new_val_sample.csv"

db_file = r"https://www.disgenet.org/static/disgenet_ap1/files/sqlite_downloads/current/disgenet_2020.db.gz"
db_name = "disgenet_2020.db"
mapping_file = r"http://www.disgenet.org/static/disgenet_ap1/files/downloads/disease_mappings.tsv.gz"
mapping_name = "disease_mappings.tsv"

LQ_CUTOFF = 0
MQ_CUTOFF = 0.4
HQ_CUTOFF = 0.7

cutoff = LQ_CUTOFF

class TqdmUpTo(tqdm):
    """Provides `update_to(n)` which uses `tqdm.update(delta_n)`."""
    def update_to(self, b=1, bsize=1, tsize=None):
        """
        b  : int, optional
            Number of blocks transferred so far [default: 1].
        bsize  : int, optional
            Size of each block (in tqdm units) [default: 1].
        tsize  : int, optional
            Total size (in tqdm units). If [default: None] remains unchanged.
        """
        if tsize is not None:
            self.total = tsize
        return self.update(b * bsize - self.n)  # also sets self.n = b * bsize

def download_and_extract(url, file_name):
    if os.path.isfile('./' + file_name):
        print(f"{file_name} already exists, skipping download..")
        return
    gzip_name = url.split("/")[-1]
    with TqdmUpTo(unit='B', unit_scale=True, unit_divisor=1024, miniters=1,
              desc=url.split('/')[-1]) as t:  # all optional kwargs
        urllib.request.urlretrieve(url=url, filename=gzip_name, reporthook=t.update_to, data=None)
        t.total = t.n
    file_name = gzip_name.replace(".gz","")

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

download_and_extract(mapping_file, mapping_name)
mapping = read_mapping(mapping_name)

download_and_extract(db_file, db_name)
association_types = read_db(db_name, mapping)

enrich_set(path_test, path_test_out, association_types, cutoff)
enrich_set(path_train, path_train_out, association_types, cutoff)
enrich_set(path_valid, path_valid_out, association_types, cutoff)

