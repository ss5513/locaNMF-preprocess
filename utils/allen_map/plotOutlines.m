function plotOutlines(outline, labels, sides, fignum, subplotnums)
% Plots the edge map of Allen CCF

if nargin<4, fignum=[]; end
if nargin<5, subplotnums=[]; end

if ~isempty(fignum), figure(fignum); else, figure; end
if ~isempty(subplotnums), subplot(subplotnums); end

hold on;
for p = 1:length(outline)
    plot(outline{p}(:, 2), outline{p}(:, 1));
    text(mean(outline{p}(:, 2)), mean(outline{p}(:, 1)), sprintf('%s %s', sides{p}, labels{p}), 'Horiz', 'center');
end
axis equal;
set(gca, 'YDir', 'reverse');
end