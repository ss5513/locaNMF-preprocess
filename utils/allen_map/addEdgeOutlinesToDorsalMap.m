function dorsalMaps = addEdgeOutlinesToDorsalMap(dorsalMaps, consolidate_opts, figon)
% 
% Add two new fields to dorsalMaps containing the area outlines as cell
% arrays of polygons. The last entry is the outline of the whole brain. If
% consolidate_opts.structure is 1 (default), the 3 structures that appear in the
% olfactory bulbs are merged, as well as all auditory structures, 
% visual structures, and primary somatosensory structures.
% 
% One version of the map, edgeOutlineSplit, has structures that would cross
% the midline split instead. edgeOutline does not.
% 
% Small outlined areas are discarded. Outlines are smoothed using a
% Savitzky-Golay filter.
% author: Matt Kaufman (2018), modified by Shreya Saxena (2018)

%% Optional argument

if ~exist('consolidate_opts', 'var')
    consolidate_opts.olf=1;
    consolidate_opts.aud=1;
    consolidate_opts.vis=1;
    consolidate_opts.ssp=1;
%     consolidate_opts.msm=1;
end


%% Merge olfactory bulb, auditory structures, visual structures, and primary somatosensory structures
dorsalMaps=consolidateStructures(dorsalMaps,consolidate_opts.olf,consolidate_opts.aud,...
    consolidate_opts.vis,consolidate_opts.ssp);
map = dorsalMaps.dorsalMapScaled;

%% Outline and smooth normal map

[dorsalMaps.edgeOutline, dorsalMaps.labels, dorsalMaps.sides] = ...
  outlineAndSmooth(map, dorsalMaps.labelTable);
if figon
plotOutlines(dorsalMaps.edgeOutline, dorsalMaps.labels, dorsalMaps.sides);
title('Edge map');
end


%% Outline and smooth with hemispheres separated

% In practice, the scaled map comes out slightly asymmetrical, and using
% the +1 instead of the +0 and the +1 looks much better.
centerline = round(size(map, 2) / 2) + 1;
map(:, centerline) = 0;

[dorsalMaps.edgeOutlineSplit, dorsalMaps.labelsSplit, dorsalMaps.sidesSplit] = ...
  outlineAndSmooth(map, dorsalMaps.labelTable);

% Restore whole-brain outline
% Split version will have two components, so delete one and replace the other
dorsalMaps.edgeOutlineSplit(end) = [];
dorsalMaps.edgeOutlineSplit{end} = dorsalMaps.edgeOutline{end};
dorsalMaps.labelsSplit(end) = [];
dorsalMaps.sidesSplit(end) = [];
dorsalMaps.sidesSplit{end} = '';

if figon
plotOutlines(dorsalMaps.edgeOutlineSplit, dorsalMaps.labelsSplit, dorsalMaps.sidesSplit);
title('Edge map split');
end
end



function [outlineSm, abbrevs, sides] = outlineAndSmooth(map, labelTable)

%% Parameters

minArea = 50;
minAreaWidth = 2;

% The window width is what really matters
smoothWindowWidth = 31;
smoothPolyOrder = 2;


%% Produce basic outlines of areas

areas = unique(map(:));
areas(areas == 0) = [];
nAreas = length(areas);

outline = cell(nAreas + 1, 1);
abbrevs = cell(nAreas + 1, 1);
for a = 1:nAreas
  area = imfill(map == areas(a), 'holes');
  outline{a} = bwboundaries(area);
  abbrevs{a} = repmat({getAllenLabel(labelTable, areas(a))}, length(outline{a}), 1);
end

% Whole brain
outline{end} = bwboundaries(map > 0);
abbrevs{end} = repmat({'allcortex'}, length(outline{end}), 1);

% Un-nest cell arrays
outline = vertcat(outline{:});
abbrevs = vertcat(abbrevs{:});
abbrevs = vertcat(abbrevs{:});

%% Get rid of junk polygons (tiny areas)

pAreas = NaN(1, length(outline));
pWidth = NaN(1, length(outline));
for p = 1:length(outline)
  pAreas(p) = polyarea(outline{p}(:, 1), outline{p}(:, 2));
  pWidth(p) = min(range(outline{p}(:, 1)), range(outline{p}(:, 2)));
end
outline = outline(pAreas >= minArea & pWidth > minAreaWidth);
abbrevs = abbrevs(pAreas >= minArea & pWidth > minAreaWidth);


%% Determine sides

sides = cell(length(outline), 1);
for p = 1:length(outline)
  x = mean(outline{p}(:, 2));
  if x < size(map, 2) / 2
    sides{p} = 'L';
  else
    sides{p} = 'R';
  end
end


%% Smooth

hw = (smoothWindowWidth - 1) / 2;

outlineSm = outline;

% Circularize polygons
for p = 1:length(outlineSm)
  outlineSm{p} = [outlineSm{p}(end-hw+1:end, :); outlineSm{p}; outlineSm{p}(1:hw, :)];
end

% Perform Savitzky-Golay smoothing
for p = 1:length(outlineSm)
  outlineSm{p}(:, 1) = sgolayfilt(outlineSm{p}(:, 1), smoothPolyOrder, smoothWindowWidth);
  outlineSm{p}(:, 2) = sgolayfilt(outlineSm{p}(:, 2), smoothPolyOrder, smoothWindowWidth);
end

% Trim excess points, leave one point of circularization
for p = 1:length(outlineSm)
  outlineSm{p} = outlineSm{p}(hw+1:end-hw+1, :);
end

end

function plotOutlines(outline, labels, sides)

figure;
hold on;
for p = 1:length(outline)
  plot(outline{p}(:, 2), outline{p}(:, 1));
  text(mean(outline{p}(:, 2)), mean(outline{p}(:, 1)), sprintf('%s %s', sides{p}, labels{p}), 'Horiz', 'center');
end
axis equal;
set(gca, 'YDir', 'reverse');
end