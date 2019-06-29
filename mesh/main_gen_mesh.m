clc;clear all;close all;
addpath(genpath('/home/ajoshi/coding_ground/svreg/src'));
addpath(genpath('/home/ajoshi/coding_ground/svreg/3rdParty'));
addpath(genpath('/home/ajoshi/coding_ground/brainstorm-duneuro/mesh/iso2mesh'));

BrainSuitePath='/home/ajoshi/BrainSuite19a';
subbase='/home/ajoshi/coding_ground/brainstorm-duneuro/mesh/sample_data/T1w_acpc_dc';
'/deneb_disk/for_bogdan/bfpout/CN/002_S_0413/anat/002_S_0413_T1w'
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

mask=[subbase,'.mask.nii.gz'];

skull=[subbase,'.skull.nii.gz'];
dewisp_mask=[subbase,'.cortex.dewisp.mask.nii.gz'];
label_vol=[subbase,'.pvc.frac.nii.gz'];

unix(['skullfinder -i ',input,' -o ', skull,' -m ', mask]);

v1=load_nii_BIG_Lab(skull);
v2=load_nii_BIG_Lab(dewisp_mask);
v3=load_nii_BIG_Lab(label_vol);

% wm = 1: dewisp mask
cleanimg=10.0*(v2.img>0);

% gm = 2: generate mask from pvc_frac + dewisp mask
gm=(v3.img>1.1 & v3.img<3) & (v2.img==0);
cleanimg(gm>0) = 20.0;

% csf = 3: from pvc frac
csf = (v3.img<1.1) & (v3.img>0);
cleanimg(csf>0) = 30.0;

% skull = 4: from skull
cleanimg(v1.img==17)=40;

% scalp = 5: from skull file
cleanimg(v1.img==16)=50;

% space = 6: from scalp file
cleanimg(v1.img==18)=60;

% head = 7: from scalp file
%cleanimg(v3.img==19)=7;

% fill holes and call the rest air

%cleanimg=double(v.img)+double(v2.img)+double(v3.img);
opt.keepratio=0.1; % this option is only useful when vol2mesh uses 'simplify' method
opt.radbound=3;    % set the target surface mesh element bounding sphere be <3 pixels in radius.

% cleanimg2=0*cleanimg;
% lvl=1;
% nl=unique(cleanimg(:));
% nl=setdiff(nl,0);
% for jj=1:length(nl)
%     cleanimg2(cleanimg==nl(jj))=jj;
% end
v3.img=cleanimg;
save_untouch_nii_gz(v3,'out.nii.gz')
tic
[node,elem,face]=vol2mesh(uint8(cleanimg),1:size(cleanimg,1),1:size(cleanimg,2),1:size(cleanimg,3),opt,100,1,'cgalmesh');
toc
%plotmesh(node(:,[2 1 3]),face,'facealpha',0.7);

h=figure;
plotmesh(node(:,[2 1 3]),face,'x<=190');
view(90,0);axis equal;axis off;axis tight;
saveas(h,'brainsuite4.png');


