clc;clear all;close all;

BrainSuitePath='/home/ajoshi/BrainSuite19a';
subbase='/home/ajoshi/coding_ground/brainstorm-duneuro/mesh/sample_data/T1w_acpc_dc';
setenv('PATH', [getenv('PATH'),':',BrainSuitePath,'/bin']);

input=[subbase,'.nii.gz'];
unix(['cortical_extraction.sh ',input]);

output=[subbase,'.skull.nii.gz'];
mask=[subbase,'.mask.nii.gz'];
unix(['skullfinder -i ',input,' -o ', output,' -m ', mask]);

