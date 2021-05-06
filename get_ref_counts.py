import numpy as np
import pandas as pd
import csv
import sys

dis_gene_file=sys.argv[1] # "all_gene_disease_pmid_associations.tsv.gz" -from DisGeNet https://www.disgenet.org/static/disgenet_ap1/files/downloads/all_gene_disease_pmid_associations.tsv.gz
doid_map=sys.argv[2] # from OBL mapping "/Users/stevensmith/Projects/OpenBioLink_sandbox/in_files/DB_ONTO_mapping_DO_UMLS.csv"
root_out_path=sys.argv[3] # where data should be written

## Load Gene-Dis associaions WITH PMID (each row is a differnet PMID Dis-gene source)
all_gene_dis=pd.read_csv(dis_gene_file,compression="gzip",sep="\t")

# Load OBL's UMLS-> DOID mapping file. Note that there a lot of unmappable UMLS IDs. This is the source of that. 
mapping=pd.read_csv(doid_map,sep=";",header=None).rename(columns={0:"DOID",1:"UMLS"})

# Map UMLS to DOIDs. This potentally collapses or loses infomration. 
all_gene_dis_mapped=pd.merge(all_gene_dis[['geneId','diseaseId']],mapping,left_on='diseaseId',right_on='UMLS',how='left')

# Count the number of Dis-Gene references using DOID and geneID
gene_dis_ref_count=all_gene_dis_mapped.groupby(['geneId','DOID']).size().to_frame().rename(columns={0:'PMID_count'})

# write unmappable UMLS IDs for reference
all_gene_dis_mapped.loc[all_gene_dis_mapped['DOID'].isnull()].to_csv(root_out_path+"gene_dis_ref_count.unmappable_DOIDs.tsv",sep="\t")

#Write the reference counts
gene_dis_ref_count.to_csv(root_out_path+"gene_dis_ref_count.tsv",sep="\t")
