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
MODEL="TransE_l2"
ROOT=$1
DATA_PATH=$ROOT #"/Users/stevensmith/Projects/OpenBioLink_sandbox/"
TRAIN=DRUG_train_samples.csv
TEST=DRUG_test_samples.csv 
VAL=DRUG_val_samples.csv
SAVE_PATH=$ROOT"/models/"

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
--valid \
--save_path $SAVE_PATH

# store model performance (somehow)

# run predictions (what wouldve been predicted vs new predictions)
## all possible combinations - flag training
## special set 

# summary stats
## score histogram, annotated by training, testing, valition, special set 


