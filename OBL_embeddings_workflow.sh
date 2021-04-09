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
MODE=$4
TOPK=$5
#TRAIN=SUBGRAPH_train_samples.csv 
#TRAIN=ALL_SUBGRAPH_train_samples.rmset.qfiltered.csv
#TEST=ALL_SUBGRAPH_test_samples.qfiltered.csv 
#VAL=ALL_SUBGRAPH_val_samples.qfiltered.csv
DS_ROOT=$6
#HQ_DIR.triangle.DRUGONLY
#DS_ROOT=SUBGRAPH.GENE_DIS
TRAIN=$DS_ROOT.train_samples.csv
TEST=$DS_ROOT.test_samples.csv
VAL=$DS_ROOT.val_samples.csv
ENTITY_MAP="entities.tsv"
REL_MAP="relations.tsv"
SCORE_FUNC="logsigmoid"
SAVE_PATH=$ROOT"/models/"
MODEL_PATH=$SAVE_PATH""$MODEL_NAME"/"
NODE1=node1
NODE2=node2
EDGE=edge

PREDICT_OUT=$ROOT""$MODEL_NAME"_results.csv"

case $MODE in

TRAIN)
echo "TRAIN"


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
--num_thread 8 \
--num_proc 1 \
--dataset OBL \
--test \
--save_path $SAVE_PATH

# store model performance (somehow)
;;
TEST)
echo "TEST"


#eval perfomance - compare to dgl_train
dglke_eval --model_name $MODEL \
--format 'raw_udd_hrt'  \
--data_path $DATA_PATH \
--data_files $TRAIN $TEST $VAL \
--batch_size 1000 \
--neg_sample_size 200 \
--hidden_dim 400 \
--gamma 19.9 \
--batch_size_eval 16 \
--num_thread 1 \
--num_proc 1 \
--dataset OBL \
--model_path $MODEL_PATH
;;
# run predictions (what wouldve been predicted vs new predictions)
## all possible combinations - flag training
## special set 

PREDICT)
echo "PREDICT"

dglke_predict --model_path $MODEL_PATH  \
--format h_r_t \
--data_files $NODE1 $EDGE $NODE2 \
--exec_mode 'triplet_wise' \
--topK $TOPK \
--score_func $SCORE_FUNC \
--raw_data \
--entity_mfile $ENTITY_MAP \
--rel_mfile $REL_MAP \
--output $PREDICT_OUT
# summary stats
## score histogram, annotated by training, testing, valition, special set 

;;
esac


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
