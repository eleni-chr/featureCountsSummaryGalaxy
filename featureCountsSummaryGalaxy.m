function featureCountsSummaryGalaxy
%% Function written by Eleni Christoforidou in MATLAB R2019b.

%This function extracts useful information from the results generated by
%running featureCounts online on Galaxy.

%Run this function from inside the folder containing the TXT file outputted
%by featureCounts.

%Note: There are a lot of hardcoded variables in this function, so
%adjustments to the code will need to be made if using with new samples.

%INPUT ARGUMENTS: None.

%OUTPUT ARGUMENTS: None, but a new TXT file and a new XLSX file, both 
%called "featureCountsSummary", are saved in the working directory.

%%
data=readtable('all_barcodes_counts.txt'); %import featureCounts results.
geneIDs=table2cell(data(:,1)); %extract only the gene IDs.
t=data(:,2:7); %extract only the columns with the counts.
m=table2array(t); %convert table to matrix.

%For all samples combined.
total=sum(m,2); %calculate the total number of counts per gene (sum all samples).
idx=find(total); %find indices of non-zero elements.
NumGenesFound=length(idx); %get number of genes that were found in at least one of the samples.

%For wildtype samples only.
totalWT=sum(m(:,1:3),2); %calculate the total number of counts per gene (sum all wildtype samples).
idxWT=find(totalWT); %find indices of non-zero elements.
NumGenesFoundWT=length(idxWT); %get number of genes that were found in at least one of the wildtype samples.

%For mutant samples only.
totalMT=sum(m(:,4:6),2); %calculate the total number of counts per gene (sum all mutant samples).
idxMT=find(totalMT); %find indices of non-zero elements.
NumGenesFoundMT=length(idxMT); %get number of genes that were found in at least one of the mutant samples.

%% Extract information from data.

all=(1:length(m))'; %indices of all genes in annotation file.
ALLgenes=geneIDs(idx); %list of genes found in at least one of the samples (regardless of group).
WTgenes=geneIDs(idxWT); %list of genes found in at least one of the wildtype samples.
MTgenes=geneIDs(idxMT); %list of genes found in at least one of the mutant samples.

zeroIdx=setxor(all,idx,'stable'); %indices of genes not detected in any of the samples.
zeroGenes=geneIDs(zeroIdx); %list of genes found in none of the samples.

commonGenesIdx=intersect(idxWT,idxMT,'stable'); %indices of genes present in both wildtypes and mutants.
commonGenes=geneIDs(commonGenesIdx); %list of genes found in both wildtypes and mutants.

WTonlyIdx=setdiff(idxWT,idxMT); %indices of genes found in wildtypes but not in mutants.
WTonlyGenes=geneIDs(WTonlyIdx); %list of genes found in wildtypes but not in mutants.

MTonlyIdx=setdiff(idxMT,idxWT); %indices of genes found in mutants but not in wildtypes.
MTonlyGenes=geneIDs(MTonlyIdx); %list of genes found in mutants but not in wildtypes.

%Information to write to file.
info{1,1}='Number of genes in annotation file';
info{2,1}='Number of genes not present in any of the samples';
info{3,1}='Number of genes present in at least one sample';
info{4,1}='Number of genes present in at least one WT sample';
info{5,1}='Number of genes present in at least one MT sample';
info{6,1}='Number of genes present in at least one WT sample but in zero MT samples';
info{7,1}='Number of genes present in at least one MT sample but in zero WT samples';
info{8,1}='Number of genes present in at least on WT sample and at least one MT sample';

info{1,2}=length(total);
info{2,2}=length(zeroIdx);
info{3,2}=NumGenesFound;
info{4,2}=NumGenesFoundWT;
info{5,2}=NumGenesFoundMT;
info{6,2}=length(WTonlyIdx);
info{7,2}=length(MTonlyIdx);
info{8,2}=length(commonGenesIdx);

%Save results.
writecell(info,'featureCountsSummaryGalaxy','Delimiter','tab'); %summary information as TXT file.

%Create temporary CSV files.
writecell(ALLgenes,'ALLgenes.csv'); %list of genes found in at least one of the samples (regardless of group).
writecell(WTgenes,'WTgenes.csv'); %list of genes found in at least one of the wildtype samples.
writecell(MTgenes,'MTgenes.csv'); %list of genes found in at least one of the mutant samples.
writecell(zeroGenes,'zeroGenes.csv'); %list of genes found in none of the samples.
writecell(commonGenes,'commonGenes.csv'); %list of genes found in both wildtypes and mutants.
writecell(WTonlyGenes,'WTonlyGenes.csv'); %list of genes found in wildtypes but not in mutants.
writecell(MTonlyGenes,'MTonlyGenes.csv'); %list of genes found in mutants but not in wildtypes.

%Combine CSV files into one Excel file.
D=pwd;
S=dir(fullfile(D,'*.csv'));
for k=1:numel(S)
    [~,~,mat]=xlsread(fullfile(D,S(k).name));
    [~,fnm]=fileparts(S(k).name);
    xlswrite('featureCountsSummaryGalaxy.xlsx',mat,fnm);
end

delete *.csv %delete temporary CSV files.
clear
end