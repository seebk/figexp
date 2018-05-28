function figexp( filename, varargin )
%FIGEXP Export matlab figures
%   FIGEXP(FILENAME) will export and save the current figure to FILENAME.
%   The file type depends on the extension, supported types are .pdf, .png,
%   .jpg, ...
%   For file extension .tikz or .tex, the plot lines of the figure will be
%   saved as a PDF plus Tikz/Latex code to create the axes and labels.
%
%   FIGEXP(FILENAME, H) exports the figure with the given handle H
%
%   FIGEXP(FILENAME, AX) exports the given axis handle AX
%
%   FIGEXP(..., 'PaperSize', VAL, ...) set the size of the exported figure in
%   centimeters, e.g. [10, 5] will set a size of 10cm x 5cm 
%
%   FIGEXP(..., 'LineWidth', VAL, ...)
%
%   FIGEXP(..., 'FontSize', VAL, ...)
%
%
%   Example
%      x = -10:0.1:10;
%      y = x.^2;
%      h = plot(x,y);
%      figexp('out.pdf', h, 'PaperSize', [10 8]);
%

% Copyright (C) 2016,  Sebastian Kraft
% 
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
% 
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
% 
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software Foundation,
%    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA



%######################################################################
% parse and check input arguments

% split ordinary optional arguments and string/argument pairs
optpos = find(cellfun(@isstr, varargin));
if ~isempty(optpos)
    optpos = optpos(1);   
    optargs = varargin(optpos:end);    
else
    optpos = 0;
    optargs = {};                
end
noptargs = length(optargs);
nargs    = nargin - noptargs - 1;    

% set values from arguments
if nargs<1
    fig = gcf;
else
    fig = varargin{1};
end

if isinteger(fig)
    % duplicate the figure
    saveas(figure(fig), 'temp.fig');
    h = hgload('temp.fig');
    delete('temp.fig');
elseif ishandle(fig) && strcmp(get(fig, 'type'), 'figure')
    % duplicate the figure
    saveas(fig, 'temp.fig');
    h = hgload('temp.fig');
    delete('temp.fig');
elseif ishandle(fig) && strcmp(get(fig, 'type'), 'axes')
    % duplicate the axis
    h = figure;
    ax = copyobj(fig, h);
    set(ax, 'Units', get(h, 'Units'));
    p = get(ax,'OuterPosition');
    set(h,'Position', [0 0 p(3) p(4)]);
    set(ax,'OuterPosition', [0 0 p(3) p(4)]);
    set(ax,'Units', 'normalized');
else
    error('Invalid figure handle!');
end

% parse string/argument pairs
p = inputParser;
p.addParameter('PaperSize', [], @isvector);
p.addParameter('FontSize', 0, @isscalar);
p.addParameter('LineWidth', [], @isvector);
p.parse(optargs{:});    

opts = p.Results;

[pathstr,name,ext] = fileparts(filename);

%######################################################################
% prepare the figure

% set units to centimeters
set(h, 'PaperUnits','centimeters');
set(h, 'Units','centimeters');

allaxes = findall(h,'type','axes');    

% set font size
if (opts.FontSize > 0)
    set(allaxes,'fontsize', opts.FontSize)
    set(findall(h, 'type', 'text'), 'fontSize', opts.FontSize)
end

% set paper size
if (isempty(opts.PaperSize))
    pos = get(h,'PaperPosition');
    opts.PaperSize = [pos(3) pos(4)];
end
set(h, 'Position',[0 0 opts.PaperSize(1) opts.PaperSize(2)]);
set(h, 'PaperSize', opts.PaperSize);
set(h, 'PaperPosition',[0 0 opts.PaperSize(1) opts.PaperSize(2)]);

% reset units to normalized 
set(h, 'PaperUnits','normalized');
set(h, 'Units','normalized');    

% get all axis positions
for i=1:length(allaxes)        
    set(allaxes(i),'ActivePositionProperty','outerposition');
    ti = get(allaxes(i),'TightInset');
    ti = ti + 0.01;
    set(allaxes(i),'LooseInset', ti);
end

% set line width
if (~isempty(opts.LineWidth))
    hline = findobj(h, 'type', 'line');
    oldlinewidth = get(hline, 'LineWidth');
    if iscell(oldlinewidth)
        oldlinewidth = cell2mat(oldlinewidth);
    end
    line_width = opts.LineWidth;
    if length(line_width)~=length(oldlinewidth)
        line_width = ones(size(oldlinewidth)).*line_width(1); 
    end        
    for l=1:length(hline)
        set(hline(l), 'LineWidth', line_width(l));
    end
end

%######################################################################
% save everything as Latex/Tikz-Code + PDF or as a pure PDF

if strcmpi(ext, '.tikz') || strcmpi(ext, '.tex')

    if length(allaxes)>1
        warning('Multiple axes are not supported for Tikz+PDF output. Every axis will be exported to its own Tikz+PDF file.');
    end
    
    for i=1:length(allaxes)

        tikzStr = '';

        tikzStr = [tikzStr '\\begin{tikzpicture}\n'];        
        
        h_i = figure; clf;
        copyobj(allaxes(i), h_i);
        set(h_i,'Color','none');
        set(h_i,'inverthardcopy','off')
        set(gca,'Color','none');

        set(h_i, 'Units','centimeters');
        set(gca, 'Units','centimeters');
        set(gca,'XtickLabel',[],'YtickLabel',[],'Box','off');
        set(gca,'Visible','off');

        set(allaxes(i), 'Units','centimeters');
        pos = get(allaxes(i), 'Position');
        set(allaxes(i), 'Units','normalized');
        width = pos(3);
        height = pos(4);
        set(gca, 'Position', [0 0 width height]);
        set(h_i, 'Position', [0 0 width height]);
        set(h_i, 'PaperSize', [width height], 'PaperPosition', [0 0 width height]);
        set(gca, 'Units', 'normalized');
        
        % save the plot as PDF
        if length(allaxes)>1
            pdffile =  fullfile(pathstr, [name '-' num2str(i) '.pdf']);
        else
            pdffile =  fullfile(pathstr, [name '.pdf']);
        end
        saveas(h_i, pdffile);            
        close(h_i);            

        % create the axis and labels with Tikz
        tikzStr = [tikzStr, ...
                  '\\begin{axis} [\n', ...
                  'scale only axis,\n'];

        if strcmp(get(allaxes(i), 'YGrid'), 'on')
            tikzStr = [tikzStr, 'ymajorgrids,\n'];
        end
        if strcmp(get(allaxes(i), 'XGrid'), 'on')
            tikzStr = [tikzStr, 'xmajorgrids,\n'];
        end

        tikzStr = [tikzStr, ...
                   'width=', num2str(width), 'cm,\n', ...
                   'height=', num2str(height), 'cm,\n'];

        tikzStr = [tikzStr, ...
                  'title={', get(get(allaxes(i), 'title'), 'String'), '},\n', ...
                  'ylabel={', get(get(allaxes(i), 'ylabel'), 'String'), '},\n', ...
                  'xlabel={', get(get(allaxes(i), 'xlabel'), 'String'), '},\n' ];

        lim_x = get(allaxes(i),'XLim');
        lim_y = get(allaxes(i),'YLim');

        tikzStr = [tikzStr, ...
                  'xmin=', num2str(lim_x(1)), ', xmax=', num2str(lim_x(2)), ',\n', ...
                  'ymin=', num2str(lim_y(1)), ', ymax=', num2str(lim_y(2)), ',\n' ];

        tikzStr = [tikzStr, ']\n'];

        tikzStr = [tikzStr, ... 
                  '\\addplot graphics [xmin=' num2str(lim_x(1)) ',', ... 
                  'xmax=' num2str(lim_x(2)) ',', ...
                  'ymin=' num2str(lim_y(1)) ',', ... 
                  'ymax=' num2str(lim_y(2)) ']', ... 
                  '{' pdffile '};\n'];

        tikzStr = [tikzStr '\\end{axis}\n'];
        tikzStr = [tikzStr '\\end{tikzpicture}\n'];
        
        % write the Tikz file
        if length(allaxes)>1
            fid=fopen(fullfile(pathstr, [name '-' num2str(i) ext]), 'w');
        else
            fid=fopen(filename, 'w');
        end
        fprintf(fid, tikzStr);
        fclose(fid);
    end        

else
    % simply save the whole figure as image
    saveas(h, filename);
end

close(h)
    
end