clc;clear all;close all;

BrainSuitePath='/home/ajoshi/BrainSuite19a';
subbase='/home/ajoshi/coding_ground/brainstorm-duneuro/mesh/sample_data/T1w_acpc_dc';
setenv('PATH', [getenv('PATH'),':',BrainSuitePath,'/bin']);
% by default, vol2mesh uses 'cgalsurf' method, which requires the following

% set method for vol2mesh to 'simplify' to use these option
% opt(1).keepratio=0.05; % resample levelset 1 to 5%  
% opt(2).keepratio=0.1;  % resample levelset 2 to 10%
% 
% opt(1).radbound=4; % head surface element size bound
% opt(2).radbound=2; % brain surface element size bound
% opt(1).side='lower'; %
% opt(2).side='lower'; %
% 
% 
input=[subbase,'.nii.gz'];
%unix(['cortical_extraction.sh ',input]);

output=[subbase,'.skull.nii.gz'];
dewisp_mask=[subbase,'.cortex.dewisp.mask.nii.gz'];
%unix(['skullfinder -i ',input,' -o ', output,' -m ', mask]);

v=load_nii_BIG_Lab(output);
v2=load_nii_BIG_Lab(dewisp_mask);

cleanimg=v.img+v2.img;
opt.keepratio=0.1; % this option is only useful when vol2mesh uses 'simplify' method
opt.radbound=3;    % set the target surface mesh element bounding sphere be <3 pixels in radius.

cleanimg2=0*cleanimg;
lvl=1;
nl=unique(cleanimg(:));
nl=setdiff(nl,0);
for jj=1:length(nl)    
    cleanimg2(cleanimg==nl(jj))=jj;    
end

[node,elem,face]=vol2mesh(cleanimg2,1:size(cleanimg,1),1:size(cleanimg,2),1:size(cleanimg,3),opt,100,1,'cgalmesh');

%plotmesh(node(:,[2 1 3]),face,'facealpha',0.7);

plotmesh(node(:,[2 1 3]),face,'y>=150');
view(0,0)

