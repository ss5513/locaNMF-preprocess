function dorsalMaps = computeAllenDorsalMap(iConst, excludeCerebellum, maxDepth)
% dorsalMaps = computeAllenDorsalMap([iConst] [, excludeCerebellum] [, maxDepth])
% 
% Read in the Allen atlas CCFv3 from Brain Explorer 2. Take a dorsal view
% and:
% - compute the 2-D map
% - do edge detection to produce a map of borders
% - produce a mask of in-brain pixels
% 
% In addition, produce re-scaled versions of all 3 of the above. These will
% be rescaled according to iConst, where iConst is the desired pixel size /
% the Allen atlas pixel size. 
% 
% For our widefield rig, our pixels are 19.4175 um. For the Allen atlas
% from Brain Explorer, the pixels are 25 um according to the mousebrain-API
% whitepaper and the internal info.xml. These are the default values.
% 
% By default, the cerebellum is removed from the maps. If you want it
% included, supply 0 for excludeCerebellum.
%
% Written by Matt Kaufman, 2018
% 
% To use, please cite:
% Musall S*, Kaufman MT*, Gluf S, Churchland AK (2018). 
% "Movement-related activity dominates cortex during sensory-guided
% decision making." bioRxiv.


%% Parameters

WFRes = 19.4175;
allenRes = 25;


%% Optional arguments

if ~exist('iConst', 'var') || isnan(iConst)
  iConst = WFRes / allenRes;
end

if ~exist('excludeCerebellum', 'var')
  excludeCerebellum = 1;
end

if ~exist('maxDepth', 'var')
  maxDepth = NaN;
end


%% Load up Allen volume data

% Read in data
% 25 micron volume size
% AP x VD x ML
siz = [528 320 456];
fid = fopen('/Users/matt/Library/Application Support/Brain Explorer 2/Atlases/Allen Mouse Brain Common Coordinate Framework/Spaces/P56/Annotation', ...
  'r', 'l');
% The documentation says it's uint32's, but that seems to be wrong, at
% least on the Mac
ANO = fread(fid, prod(siz), 'uint16');
fclose(fid);
ANO = reshape(ANO, siz);

% Out-of-brain values are 0
nAreas = max(ANO(:));


%% Load up Allen area label info

labelTable = readtable('/Users/matt/Library/Application Support/Brain Explorer 2/Atlases/Allen Mouse Brain Common Coordinate Framework/ontology_v2.csv');


%% Project most-dorsal non-background value into image

dorsalMap = zeros(siz(1), siz(3));

if isnan(maxDepth)
  for ap = 1:siz(1)
    for ml = 1:siz(3)
      i = find(squeeze(ANO(ap, :, ml)), 1);
      if ~isempty(i)
        dorsalMap(ap, ml) = ANO(ap, i, ml);
      end
    end
  end
else
  for ap = 1:siz(1)
    for ml = 1:siz(3)
      i = find(squeeze(ANO(ap, :, ml)), 1);
      if ~isempty(i) && i <= maxDepth
        dorsalMap(ap, ml) = ANO(ap, i, ml);
      end
    end
  end
end


%% Get rid of the cerebellum if requested

% Cerebellum annotation IDs are all higher than cortex, but not olfactory
% bulb. We'll figure out which IDs to chuck by finding the lowest ID in the
% back of the brain, and dumping those and higher.

if excludeCerebellum
  % Find cerebellum IDs. We'll use the lowest ID, looking only posterior to
  % cortex
  postIDs = dorsalMap(420:end, :);
  postIDs = postIDs(:);
  postIDs(postIDs == 0) = nAreas;
  minCerebellum = min(postIDs);  % 492
  
  % Cut out those IDs, in the back of the brain only
  mapNoCBRear = dorsalMap(300:end, :);
  mapNoCBRear(mapNoCBRear >= minCerebellum) = 0;
  dorsalMap(300:end, :) = mapNoCBRear;
end


%% Clean up image using imclose

uIDs = unique(dorsalMap(:));
uIDs(uIDs == 0) = [];

dorsalMapOrig = dorsalMap;

% Use a tiny structuring element; don't want to obliterate small
% features, just want to clean up stray pixels
se = strel('square', 2);
for id = uIDs'
  bw = (dorsalMap == id);
  bw = imclose(bw, se);
  dorsalMap(bw) = id;
end


%% Interpolate dorsal map to rescale

xi = 1:iConst:size(dorsalMap, 2);
yi = 1:iConst:size(dorsalMap, 1);

F = griddedInterpolant(dorsalMap, 'nearest');
dorsalMapScaled = F({yi, xi});


%% Find edges

% Original res
edgeMap = computeEdges(dorsalMap);

% Scaled res
edgeMapScaled = computeEdges(dorsalMapScaled);


%% Compute masks

mask = (dorsalMap ~= 0);
maskScaled = (dorsalMapScaled ~= 0);


%% Pack output

dorsalMaps.dorsalMap = dorsalMap;
dorsalMaps.dorsalMapScaled = dorsalMapScaled;
dorsalMaps.edgeMap = edgeMap;
dorsalMaps.edgeMapScaled = edgeMapScaled;
dorsalMaps.mask = mask;
dorsalMaps.maskScaled = maskScaled;
dorsalMaps.desiredPixelSize = WFRes;
dorsalMaps.allenPixelSize = allenRes;
dorsalMaps.labelTable = labelTable;
if ~isnan(maxDepth)
  dorsalMaps.maxDepth = maxDepth * allenRes;
end

dorsalMaps.authorInfo = sprintf([' Written by Matt Kaufman, 2017\n\n', ...
'To use, please cite:\n', ...
'Musall S*, Kaufman MT*, Gluf S, Churchland AK (2018).\n', ... 
'"Movement-related activity dominates cortex during sensory-guided decision making." bioRxiv.']);



function edgeMap = computeEdges(map)
% Edges are found using the Roberts cross operator with no thinning. I
% chose this algorithm because it is simple, local, empirically effective,
% and works well without thinning (which can introduce problems at
% three-way junctures). 

% Pad, so we don't lose edges at the image boundaries
pMap = zeros(size(map) + 2);
pMap(2:end-1, 2:end-1) = map;

% Find edges
edgeMap = edge(pMap, 'Roberts', 0.5, 'both', 'nothinning');

% Un-pad
edgeMap = edgeMap(2:end-1, 2:end-1);
