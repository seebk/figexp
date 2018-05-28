

Introduction
============

`figexp.m` is a Matlab script to export figures into various formats. Compared 
to a simple `Save as...` from the Matlab figure window, the script allows to 
configure additional options like paper size, font size, line widths.

Furthermore, when you want to include the exported figure into a Latex document 
it is often desired to have the same font shape and size in the figure labels 
as in the whole document. For a filename with an extension `.tikz` or `.tex` the 
plot lines of the figure will be saved as a PDF plus Latex/Pgfplots code to 
render the axes and labels (see [Tikz/Pgfplots axes](#Tikz/Pgfplots-axes)). 


General Usage
=============

`FIGEXP(FILENAME)` will export and save the current figure to FILENAME.
The file type depends on the extension, supported types are .pdf, .png,
.jpg, ...

Optional parameters (type `help figexp` in Matlab to list all available options):

    FIGEXP(FILENAME, H) exports the figure with the given handle H

    FIGEXP(FILENAME, AX) exports the given axis handle AX

    FIGEXP(..., 'PaperSize', VAL, ...) set the size of the exported figure in
    centimeters, e.g. [10, 5] will set a size of 10cm x 5cm 

    FIGEXP(..., 'LineWidth', VAL, ...)

    FIGEXP(..., 'FontSize', VAL, ...)


Example:
```matlab
  x = -10:0.1:10;
  y = x.^2;
  h = plot(x,y);
  figexp('out.pdf', h, 'PaperSize', [10 8]);
```


Tikz/Pgfplots axes
==================

Giving a filename with an extension `.tikz` or `.tex` will create two 
separate files: 

  1. A Latex file with the text elements (e.g. axis and tick labels, titles, ...)
  2. A PDF file with all graphical elements.

The exported Tex/Pgfplots code has to to be included in the main Latex document.

```latex
\documentclass{article}

\usepackage{pgfplots}
\pgfplotsset{compat=newest}

%%% optional commands
% set the font size
%\tikzset{font=\scriptsize}

\begin{document}

  \begin{figure}
      \centering \input{test.tikz}
      \caption{This image was exported with the figexp() function.}
  \end{figure}

\end{document}
```

Licence
=======

`figexp.m` is licensed under he GPLv3 licence.