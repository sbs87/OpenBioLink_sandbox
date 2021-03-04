

# get DOID mapping 
# rm -f preprocessing/map.*
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i parkin > preprocessing/map.parkinson
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i Diabetes > preprocessing/map.Diabetes
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i Malaria > preprocessing/map.Malaria
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i gout > preprocessing/map.gout
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i "Dermatitis herpetiformis" > preprocessing/map.Dermatitis




# rm -f preprocessing/rel.*
# cut -f4 preprocessing/map.Diabetes  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:56843207"}' > preprocessing/rel.Diabetes_Colesevelam
# cut -f4 preprocessing/map.parkinson  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:31101"}' > preprocessing/rel.parkinson_Bromocriptine
# cut -f4 preprocessing/map.Malaria  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:2955"}' > preprocessing/rel.Malaria_Dapsone
# cut -f4 preprocessing/map.gout  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:135401907"}' > preprocessing/rel.gout_Allopurinol
# cut -f4 preprocessing/map.Dermatitis  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:2955"}' > preprocessing/rel.Dermatitis_Dapsone

# cat preprocessing/rel.* > preprocessing/rel.all

# cut 1, 2, 3 into node, edge,node OR rull all disease -< 1 drug (each drug) and filter out
# also need to ensure inputs are in training. 


# cut -f1 preprocessing/rel.all > preprocessing/node1.all
# cut -f1 SUBGRAPH_train_samples.no_list1.tsv | grep DOID |sort -u > node1_training
# grep -vwf node1_training preprocessing/node1.all  > node1_not_in_training
# grep -vwf node1_not_in_training preprocessing/rel.all > preprocessing/rel.all.filter

# cut -f3 preprocessing/rel.all > preprocessing/node2.all
# cut -f3 SUBGRAPH_train_samples.no_list1.tsv | grep PUBCHEM |sort -u > node2_training
# grep -vwf node2_training preprocessing/node2.all  > node2_not_in_training
# grep -vwf node2_not_in_training preprocessing/rel.all.filter > tmp # 
# preprocessing/rel.all.filter

#DIS_DRUG 
# awk -F '\t'  '$2~"DIS_DRUG" {print $1}' SUBGRAPH_{train,test,val}_samples.csv | sort -u  > preprocessing/all_dis
# awk -F '\t'  '$2~"DIS_DRUG" {print $3}' SUBGRAPH_{train,test,val}_samples.csv | sort -u  > preprocessing/all_drug
# while read chr; do
# awk -v chr="$chr" '{print chr"\tDIS_DRUG\t"$0}' preprocessing/all_drug >> predict_in.DIS_DRUG
# done < preprocessing/all_dis





# RESULTS=/Users/stevensmith/Projects/OpenBioLink_sandbox/TransE_l1_OBL_0_results.csv 
# RESULTS=TransE_l2_OBL_11_results.csv 
# #print $0"\tIN_TRAINING";
# else

while read chr; do
awk -v chr="$chr" 'chr==$1"\t"$2"\t"$3 {print $0"\tIN_TRAINING"}' $RESULTS
done < tmp.training.filt > res.training
while read chr; do
awk -v chr="$chr" 'chr!=$1"\t"$2"\t"$3 {print $0"\tIN_TRAINING"}' $RESULTS
done < tmp.training.filt > res.ntraining
cat res.* > TransE_l1_OBL_0_results_annotated.csv

# print $0"\tNOT_IN_TRAINING";
# while read chr; do
# awk -v chr="$chr" 'if (chr==$1"\t"$2"\t"$3) 
# {print chr"\t"$1"\t"$2"\t"$3}' $RESULTS
# done < tmp.training.filt

#./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ TransE_l1_OBL_1 TransE_L1


while read doid dname; do
awk -v doid="$doid" -v dname="$dname" 'doid==$1 {print $0"\t"dname}' TransE_l2_OBL_11_results_annotated.csv
done < disease_mappings_DOID.tsv

while read doid dname; do
awk -v doid="$doid" -v dname="$dname" 'doid==$1 {print doid"\t"dname"\t"$0}' TransE_l2_OBL_11_results_annotated.csv
done < disease_mappings_DOID.tsv