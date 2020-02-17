function dorsalMaps=consolidateStructures(dorsalMaps,consolidateOB, consolidateAU, consolidateVI,consolidateSSp)

% Olfactory structures to merge
OBMembers = {'MOB', 'OLF', 'Pa5','SPVI'};
% What to call the result
OBNewName = 'MOB';

% Visual structures to merge
VIS_idx = cellfun(@(s)strncmp(s,'VIS',3),dorsalMaps.labelTable.abbreviation);
VIMembers=dorsalMaps.labelTable{VIS_idx,{'abbreviation'}};
VINewName = 'VIS';

% Auditory structures to merge
AUD_idx = cellfun(@(s)strncmp(s,'AUD',3),dorsalMaps.labelTable.abbreviation);
AUMembers=dorsalMaps.labelTable{AUD_idx,{'abbreviation'}};
AUNewName = 'AUD';

% Primary somatosensory structures to merge
SSp_idx = cellfun(@(s)strncmp(s,'SSp',3),dorsalMaps.labelTable.abbreviation);
SSpMembers=dorsalMaps.labelTable{SSp_idx,{'abbreviation'}};
SSpNewName = 'SSp';

%% Optional argument

if ~exist('consolidateOB', 'var')
  consolidateOB = 1;
end
if ~exist('consolidateAU', 'var')
  consolidateAU = 1;
end
if ~exist('consolidateVI', 'var')
  consolidateVI = 1;
end
if ~exist('consolidateSSp', 'var')
  consolidateSSp = 1;
end


%% Merge various regions
map = dorsalMaps.dorsalMapScaled;
% Merge olfactory bulb
if consolidateOB
  mergeRows = ismember(dorsalMaps.labelTable.abbreviation, OBMembers);
  mergeIDs = dorsalMaps.labelTable.id(mergeRows);
  newID = dorsalMaps.labelTable.id(strcmp(dorsalMaps.labelTable.abbreviation, OBNewName));
  map(ismember(map, mergeIDs)) = newID;
end
% Merge auditory cortex
if consolidateAU
  mergeRows = ismember(dorsalMaps.labelTable.abbreviation, AUMembers);
  mergeIDs = dorsalMaps.labelTable.id(mergeRows);
  newID = dorsalMaps.labelTable.id(strcmp(dorsalMaps.labelTable.abbreviation, AUNewName));
  map(ismember(map, mergeIDs)) = newID;
end
% Merge visual cortex
if consolidateVI
  mergeRows = ismember(dorsalMaps.labelTable.abbreviation, VIMembers);
  mergeIDs = dorsalMaps.labelTable.id(mergeRows);
  newID = dorsalMaps.labelTable.id(strcmp(dorsalMaps.labelTable.abbreviation, VINewName));
  map(ismember(map, mergeIDs)) = newID;
end
% Merge primary somatosensory cortex
if consolidateSSp
  mergeRows = ismember(dorsalMaps.labelTable.abbreviation, SSpMembers);
  mergeIDs = dorsalMaps.labelTable.id(mergeRows);
  newID = dorsalMaps.labelTable.id(strcmp(dorsalMaps.labelTable.abbreviation, SSpNewName));
  map(ismember(map, mergeIDs)) = newID;
end

dorsalMaps.dorsalMapScaled=map;
end