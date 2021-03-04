# BIOG-69
# Steve Smith
# March 2021 

# Run embeddings analysis from dgl-ke on OBL subgraphs and full graphs

# generate input data & removing special set 

# get/set iteration variables

# run model with given parameters, including
##model alroithim
##input data 
##hyperparameters
##results output variables
MODEL=$3 #"TransE_l2"
ROOT=$1
MODEL_NAME=$2
DATA_PATH=$ROOT #"/Users/stevensmith/Projects/OpenBioLink_sandbox/"

#TRAIN=SUBGRAPH_train_samples.csv 
TRAIN=SUBGRAPH_train_samples.no_list1.tsv
TEST=SUBGRAPH_test_samples.csv 
VAL=SUBGRAPH_val_samples.csv
ENTITY_MAP="entities.tsv"
REL_MAP="relations.tsv"
SCORE_FUNC="logsigmoid"
SAVE_PATH=$ROOT"/models/"
MODEL_PATH=$SAVE_PATH""$MODEL_NAME"/"

PREDICT_OUT=$ROOT""$MODEL_NAME"_results.csv"


dglke_train --model_name $MODEL \
--format 'raw_udd_hrt'  \
--data_path $DATA_PATH \
--data_files $TRAIN $TEST $VAL \
--batch_size 1000 \
--neg_sample_size 200 \
--hidden_dim 400 \
--gamma 19.9 \
--lr 0.25 \
--max_step 500 \
--log_interval 100 \
--batch_size_eval 16 \
-adv \
--regularization_coef 1.00E-09  \
--num_thread 1 \
--num_proc 1 \
--dataset OBL \
--test \
--save_path $SAVE_PATH

# store model performance (somehow)

#eval perfomance - compare to dgl_train
# dglke_eval --model_name $MODEL \
# --format 'raw_udd_hrt'  \
# --data_path $DATA_PATH \
# --data_files $TEST $VAL $TRAIN \
# --batch_size 1000 \
# --neg_sample_size 200 \
# --hidden_dim 400 \
# --gamma 19.9 \
# --batch_size_eval 16 \
# --num_thread 1 \
# --num_proc 1 \
# --dataset OBL \
# --model_path $MODEL_PATH

# run predictions (what wouldve been predicted vs new predictions)
## all possible combinations - flag training
## special set 

# dglke_predict --model_path $MODEL_PATH  \
# --format h_r_t \
# --data_files node1 edge node2 \
# --exec_mode 'triplet_wise' \
# --topK 900 \
# --score_func $SCORE_FUNC \
# --raw_data \
# --entity_mfile $ENTITY_MAP \
# --rel_mfile $REL_MAP \
# --output $PREDICT_OUT
# summary stats
## score histogram, annotated by training, testing, valition, special set 



# DIS_DRUG
# GENE_DIS
# DRUG_ACTIVATION_GENE
# DRUG_BINDACT_GENE
# DRUG_BINDING_GENE
# DRUG_BINDINH_GENE
# DRUG_CATALYSIS_GENE
# DRUG_INHIBITION_GENE
# DRUG_REACTION_GENE
# GENE_DRUG


# DIS_PHENOTYPE
# DRUG_PHENOTYPE

# find repurposed drug - diseases 
# map the IDs 
# create manifest so that can be removed from training
# same manifest can be used to filter predicted results 


# datafile to removie edfes: 
# DRUG DRUG_DIS DIS


#common name -> many IDs
# lsit all combinations 


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