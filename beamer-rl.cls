\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{beamer-rl}
[2020/08/04 v1.4a  LaTeX class to patch beamer for right to left presentation with babel]

\RequirePackage{kvoptions}
\RequirePackage{kvsetkeys}

\SetupKeyvalOptions{
	family=beamer-rl,
	prefix=beamer-rl@,
	setkeys=\kvsetkeys,
}

% babel options:
\define@key{beamer-rl}{babel}{%
	\PassOptionsToPackage{#1}{babel}%
}

\DeclareVoidOption{arabic}{%
             \@expandtwoargs\@removeelement\CurrentOption\@classoptionslist\@classoptionslist % remove arabic option from global list  
   %         \PassOptionsToPackage{arabic}{translator}%
              \AtBeginDocument{\uselanguage{Arabic}\languagealias{arabic}{Arabic}}
}

\DeclareDefaultOption{%
	\PassOptionsToClass{\CurrentOption}{beamer}%
}

\ProcessKeyvalOptions*\relax

\RequirePackage{ifluatex}

\ifluatex
\else
\ClassError{beamer-rl}{beamer-rl require lualatex}
\fi

\LoadClass[hyperref={unicode}]{beamer}

\RequirePackage[nil,bidi=basic]{babel}

\def\reset@temp#1#2{\expandafter\let\csname beamer@@tmpop@#1@#2\endcsname\relax}
\def\@@defbeamertemplate#1#2{\reset@temp{#1}{#2}\defbeamertemplate{#1}{#2}}
\def\@defbeamertemplate#1#2{\reset@temp{#1}{#2}\defbeamertemplate*{#1}{#2}}

\def\redefbeamertemplate{%
	\@ifstar{\@defbeamertemplate}{\@@defbeamertemplate}%
}

\let\old@blacktriangleright\blacktriangleright
\let\old@blacktriangleleft\blacktriangleleft

\def\blacktriangleright{%
	\ifcase\bbl@thepardir \old@blacktriangleright\else\old@blacktriangleleft\fi}
\def\blacktriangleleft{%
	\ifcase\bbl@thepardir \old@blacktriangleleft\else\old@blacktriangleright\fi}


\let\oldpgfpicture\pgfpicture
\let\endoldpgfpicture\endpgfpicture

\def\pgfpicture{\babelsublr\bgroup\oldpgfpicture}
\def\endpgfpicture{\endoldpgfpicture\egroup}

\let\oldpgfuseshading\pgfuseshading
\def\pgfuseshading#1{\babelsublr{\oldpgfuseshading{#1}}}


%% beamerbasebox 

\newdimen\bmb@dimc

\renewcommand\beamerboxesrounded[2][]{%
	\global\let\beamer@firstlineitemizeunskip=\relax%
	\vbox\bgroup%
	\setkeys{beamerboxes}{upper=block title,lower=block body,width=\textwidth,shadow=false}%
	\setkeys{beamerboxes}{#1}%
	{%
		\usebeamercolor{\bmb@lower}%
		\globalcolorstrue%
		\colorlet{lower.bg}{bg}%
	}%
	{%
		\usebeamercolor{\bmb@upper}%
		\globalcolorstrue%
		\colorlet{upper.bg}{bg}%
	}%
	%
	% Typeset head
	%
	\vskip4bp
	\setbox\bmb@box=\hbox{%
		\begin{minipage}[b]{\bmb@width}%
			\usebeamercolor[fg]{\bmb@upper}%
			#2%
	\end{minipage}}%
	\ifdim\wd\bmb@box=0pt%
	\setbox\bmb@box=\hbox{}%
	\ht\bmb@box=1.5pt%
	\bmb@prevheight=-4.5pt%
	\else%
	\wd\bmb@box=\bmb@width%
	\bmb@temp=\dp\bmb@box%
	\ifdim\bmb@temp<1.5pt%
	\bmb@temp=1.5pt%
	\fi%
	\setbox\bmb@box=\hbox{\raise\bmb@temp\hbox{\box\bmb@box}}%
	\dp\bmb@box=0pt%
	\bmb@prevheight=\ht\bmb@box%
	\fi%
	\bmb@temp=\bmb@width%
	\bmb@dima=\bmb@temp\advance\bmb@dima by2.2bp%
	\bmb@dimb=\bmb@temp\advance\bmb@dimb by4bp%
	\bmb@dimc=0pt%
	\ifdim\wd\bmb@box=0pt
	\bmb@dimc=\bmb@width%
	\fi
	\hbox{%
		\textdir TLT\begin{pgfpicture}{0bp}{+-\ht\bmb@box}{\bmb@dimc}{+-\ht\bmb@box}
			\ifdim\wd\bmb@box=0pt%
			\color{lower.bg}%
			\else%
			\color{upper.bg}%
			\fi%
			\pgfpathqmoveto{-4bp}{-1bp}
			\pgfpathqcurveto{-4bp}{1.2bp}{-2.2bp}{3bp}{0bp}{3bp}
			\pgfpathlineto{\pgfpoint{\bmb@temp}{3bp}}
			\pgfpathcurveto%
			{\pgfpoint{\bmb@dima}{3bp}}%
			{\pgfpoint{\bmb@dimb}{1.2bp}}%
			{\pgfpoint{\bmb@dimb}{-1bp}}%
			\bmb@dima=-\ht\bmb@box%
			\advance\bmb@dima by-2pt%
			\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
			\pgfpathlineto{\pgfpoint{-4bp}{\bmb@dima}}
			\pgfusepath{fill}
		\end{pgfpicture}%
		\copy\bmb@box%
	}%
	\nointerlineskip%
	\vskip-1pt%
	\ifdim\wd\bmb@box=0pt%
	\else%
	\hbox{%
		\begin{pgfpicture}{0pt}{0pt}{\bmb@width}{6pt}
			\bmb@dima=\bmb@width%
			\advance\bmb@dima by8bp%
			\pgfpathrectangle{\pgfpoint{-4bp}{-1bp}}{\pgfpoint{\bmb@dima}{8bp}}
			\pgfusepath{clip}
			{\pgftransformshift{\pgfpoint{-4bp}{0bp}}\pgftext[left,base]{\pgfuseshading{bmb@transition}}}%
		\end{pgfpicture}%
	}%
	\nointerlineskip%
	\vskip-0.5pt%
	\fi%
	\ifbmb@shadow%
	\setbox\bmb@boxshadow=\hbox{\pgfuseshading{bmb@shadow}}%
	\setbox\bmb@boxshadowball=\hbox{\pgfuseshading{bmb@shadowball}}%
	\setbox\bmb@boxshadowballlarge=\hbox{\pgfuseshading{bmb@shadowballlarge}}%
	\fi%
	\setbox\bmb@colorbox=\hbox{{\pgfpicturetrue\pgfsetcolor{lower.bg}}}%
	\setbox\bmb@box=\hbox\bgroup\begin{minipage}[b]{\bmb@width}%
		\vskip2pt%
		\usebeamercolor[fg]{\bmb@lower}%
		\colorlet{beamerstructure}{upper.bg}%
		\colorlet{structure}{upper.bg}%
		%\color{.}%
	}
	
	\def\endbeamerboxesrounded{%
	\end{minipage}\egroup%
	\wd\bmb@box=\bmb@width%
	\bmb@temp=\dp\bmb@box%
	\advance\bmb@temp by.5pt%
	\setbox\bmb@box=\hbox{\raise\bmb@temp\hbox{\box\bmb@box}}%
	\dp\bmb@box=0pt%
	\bmb@temp=\wd\bmb@box%
	\bmb@dima=\bmb@temp\advance\bmb@dima by2.2bp%
	\bmb@dimb=\bmb@temp\advance\bmb@dimb by4bp%
	\hbox{%
		\textdir TLT\begin{pgfpicture}{0bp}{0bp}{0bp}{0bp}
			\ifbmb@shadow%
			{\pgftransformshift{\pgfpoint{4bp}{-3bp}}\pgftext{\copy\bmb@boxshadowball}}
			\begin{pgfscope}
				{%
					\advance\bmb@temp by-1bp%
					\pgfpathrectangle{\pgfpoint{\bmb@temp}{-7bp}}{\pgfpoint{9bp}{9bp}}%
					\pgfusepath{clip}
				}%
				{\pgftransformshift{\pgfpoint{\bmb@temp}{1bp}}\pgftext{\box\bmb@boxshadowballlarge}}
			\end{pgfscope}
			\begin{pgfscope}
				\advance\bmb@temp by-4bp%
				\pgfpathrectangle{\pgfpoint{4bp}{-7bp}}{\pgfpoint{\bmb@temp}{5bp}}
				\pgfusepath{clip}
				{\pgftransformshift{\pgfpoint{4bp}{-7bp}}\pgftext[left,base]{\copy\bmb@boxshadow}}%
			\end{pgfscope}
			\begin{pgfscope}
				\advance\bmb@temp by 4bp%
				\bmb@dima=\ht\bmb@box%
				\advance\bmb@dima by\bmb@prevheight%
				\advance\bmb@dima by 4bp%
				\pgfpathrectangle{\pgfpoint{\bmb@temp}{1bp}}{\pgfpoint{4bp}{\bmb@dima}}
				\pgfusepath{clip}
				\advance\bmb@dima by-4bp%
				{\pgftransformshift{\pgfpoint{\bmb@temp}{\bmb@dima}}\pgftext{\box\bmb@boxshadowball}}
				\advance\bmb@dima by-1bp%
				\pgfpathrectangle{\pgfpoint{\bmb@temp}{1bp}}{\pgfpoint{4bp}{\bmb@dima}}
				\pgfusepath{clip}
				\advance\bmb@temp by4bp%
				{\pgftransformshift{\pgfpoint{\bmb@temp}{-3bp}}%
					\pgftransformrotate{90}%
					\pgftext[left,base]{\box\bmb@boxshadow}}%
			\end{pgfscope}
			\fi%
			\unhbox\bmb@colorbox%
			\pgfpathqmoveto{-4bp}{1bp}
			\pgfpathqcurveto{-4bp}{-1.2bp}{-2.2bp}{-3bp}{0bp}{-3bp}
			\pgfpathlineto{\pgfpoint{\the\bmb@temp}{-3bp}}
			\pgfpathcurveto%
			{\pgfpoint{\the\bmb@dima}{-3bp}}%
			{\pgfpoint{\the\bmb@dimb}{-1.2bp}}%
			{\pgfpoint{\the\bmb@dimb}{1bp}}%
			{
				\bmb@dima=\ht\bmb@box%
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfpathlineto{\pgfpoint{-4bp}{\bmb@dima}}
				\pgfusepath{fill}
			}
			\ifbmb@shadow%
			{
				\color{black!50!bg}
				\pgfsetlinewidth{0pt}
				\pgfpathmoveto{\pgfpoint{\bmb@dimb}{-.5bp}}
				\bmb@dima=\ht\bmb@box%
				\advance\bmb@dima by\bmb@prevheight%
				\advance\bmb@dima by 1bp%
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfusepath{stroke}
				\bmb@temp=\bmb@dima
				\advance\bmb@dima by 1bp%
				\color{black!31!bg}
				\pgfpathmoveto{\pgfpoint{\bmb@dimb}{\bmb@temp}}
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfusepath{stroke}
				\advance\bmb@dima by 1bp%
				\advance\bmb@temp by 1bp%
				\color{black!19!bg}
				\pgfpathmoveto{\pgfpoint{\bmb@dimb}{\bmb@temp}}
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfusepath{stroke}
				\advance\bmb@dima by 1bp%
				\advance\bmb@temp by 1bp%
				\color{black!6!bg}
				\pgfpathmoveto{\pgfpoint{\bmb@dimb}{\bmb@temp}}
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfusepath{stroke}
				\advance\bmb@dima by 1.5bp%
				\advance\bmb@temp by 1bp%
				\color{bg}
				\pgfpathmoveto{\pgfpoint{\bmb@dimb}{\bmb@temp}}
				\pgfpathlineto{\pgfpoint{\bmb@dimb}{\bmb@dima}}
				\pgfusepath{stroke}
			}
			\fi
		\end{pgfpicture}%
		\box\bmb@box%
	}%
	\ifbmb@shadow%
	\vskip4bp minus 2bp%
	\else%
	\vskip2bp%
	\fi%
	\egroup% of \vbox\bgroup
}


%% beamerbaseauxtemplates


% (sub-)section in toc: subsections numbered

\redefbeamertemplate{subsection in toc}{subsections numbered}
{\leavevmode\leftskip=2em\rlap{\hskip-2em \inserttocsectionnumber\hbox{.}\inserttocsubsectionnumber}\inserttocsubsection\par}


%% beamerinnerthemedefault

\redefbeamertemplate*{button}{default}
{%
	\setbox\beamer@tempbox=\hbox{{\insertbuttontext}}%
	\ht\beamer@tempbox=6pt%
	\dp\beamer@tempbox=0pt%
	\setbox\beamer@tempbox=\vbox{\box\beamer@tempbox\vskip2pt}%
	\beamer@tempdim=\wd\beamer@tempbox%
	\beamer@dima=\beamer@tempdim\advance\beamer@dima by2.2pt
	\beamer@dimb=\beamer@tempdim\advance\beamer@dimb by4pt
	\textdir TLT\begin{pgfpicture}{-4pt}{0pt}{\the\beamer@tempdim}{8pt}
		\color{bg}
		\pgfsetlinewidth{0.8pt}
		\pgfpathqmoveto{0pt}{0pt}
		\pgfpathqcurveto{-2.2pt}{0pt}{-4pt}{1.8pt}{-4pt}{4pt}
		\pgfpathqcurveto{-4pt}{6.2pt}{-2.2pt}{8pt}{0pt}{8pt}
		\pgfpathlineto{\pgfpoint{\the\beamer@tempdim}{8pt}}
		\pgfpathcurveto%
		{\pgfpoint{\the\beamer@dima}{8pt}}%
		{\pgfpoint{\the\beamer@dimb}{6.2pt}}%
		{\pgfpoint{\the\beamer@dimb}{4pt}}
		\pgfpathcurveto%
		{\pgfpoint{\the\beamer@dimb}{1.8pt}}%
		{\pgfpoint{\the\beamer@dima}{0pt}}%
		{\pgfpoint{\the\beamer@tempdim}{0pt}}
		\pgfpathclose
		\pgfusepathqfill
		\colorlet{bg}{parent.bg}
		\usebeamercolor[fg]{button border}
		\pgfpathqmoveto{0pt}{0pt}
		\pgfpathqcurveto{-2.2pt}{0pt}{-4pt}{1.8pt}{-4pt}{4pt}
		\pgfpathqcurveto{-4pt}{6.2pt}{-2.2pt}{8pt}{0pt}{8pt}
		\pgfpathlineto{\pgfpoint{\the\beamer@tempdim}{8pt}}
		\pgfpathcurveto%
		{\pgfpoint{\the\beamer@dima}{8pt}}%
		{\pgfpoint{\the\beamer@dimb}{6.2pt}}%
		{\pgfpoint{\the\beamer@dimb}{4pt}}
		\pgfpathcurveto%
		{\pgfpoint{\the\beamer@dimb}{1.8pt}}%
		{\pgfpoint{\the\beamer@dima}{0pt}}%
		{\pgfpoint{\the\beamer@tempdim}{0pt}}
		\pgfpathclose
		\pgfusepathqstroke
	\end{pgfpicture}%
	\hskip-\beamer@tempdim%
	\box\beamer@tempbox%
	\kern4pt%
}

%% beamerbasenavigation

% User Buttons

\pgfdefobject{beamergotosymbol}{\pgfpoint{0pt}{-1pt}}{\pgfpoint{5pt}{5pt}}
{
	\pgfpathqmoveto{1.5bp}{0.5bp}
	\pgfpathqlineto{3.5bp}{2bp}
	\pgfpathqlineto{1.5bp}{3.5bp}
	\pgfusepathqfill
}

\def\insertgotosymbol{%
	\begin{pgfpicture}{1pt}{0pt}{6pt}{5pt}
		\pgfuseobject{\ifcase\bbl@thepardir beamergotosymbol\else beamerreturnsymbol\fi}%
\end{pgfpicture}}

\pgfdefobject{beamerreturnsymbol}{\pgfpoint{0pt}{-1pt}}{\pgfpoint{5pt}{5pt}}
{
	\pgfpathqmoveto{3.5bp}{0.5bp}
	\pgfpathqlineto{1.5bp}{2bp}
	\pgfpathqlineto{3.5bp}{3.5bp}
	\pgfusepathqfill
}

\def\insertreturnsymbol{%
	\begin{pgfpicture}{1pt}{0pt}{6pt}{5pt}
		\pgfuseobject{\ifcase\bbl@thepardir beamerreturnsymbol\else beamergotosymbol\fi}%
\end{pgfpicture}}


\pgfdefobject{beamerskipsymbolrl}{\pgfpoint{0pt}{-1pt}}{\pgfpoint{7pt}{5pt}}
{
	\pgfpathqmoveto{3.5bp}{0.5bp}
	\pgfpathqlineto{1.5bp}{2bp}
	\pgfpathqlineto{3.5bp}{3.5bp}
	\pgfpathqmoveto{5.5bp}{0.5bp}
	\pgfpathqlineto{3.5bp}{2bp}
	\pgfpathqlineto{5.5bp}{3.5bp}
	\pgfusepathqfill
}

\pgfdefobject{beamerskipsymbol}{\pgfpoint{0pt}{-1pt}}{\pgfpoint{7pt}{5pt}}
{
	\pgfpathqmoveto{1.5bp}{0.5bp}
	\pgfpathqlineto{3.5bp}{2bp}
	\pgfpathqlineto{1.5bp}{3.5bp}
	\pgfpathqmoveto{3.5bp}{0.5bp}
	\pgfpathqlineto{5.5bp}{2bp}
	\pgfpathqlineto{3.5bp}{3.5bp}
	\pgfusepathqfill
}

\def\insertskipsymbol{%
	\begin{pgfpicture}{-1pt}{0pt}{6pt}{5pt}
		\pgfuseobject{\ifcase\bbl@thepardir beamerskipsymbol\else beamerskipsymbolrl\fi}%
\end{pgfpicture}}

\def\beamergotobutton#1{\beamerbutton{\insertgotosymbol\ #1}}
\def\beamerreturnbutton#1{\beamerbutton{\insertreturnsymbol\ #1}}
\def\beamerskipbutton#1{\beamerbutton{\insertskipsymbol\ #1}}

%% beamerbaseframesize

%
% Zoom stuff
%

\def\beamer@framezoom<#1><#2>[#3](#4,#5)(#6,#7){%
  \par\nointerlineskip%
  \global\beamer@slidehaszoomtrue%
  \advance\beamer@zoomcount by1\relax%
  \def\beamer@zoomborderwidth{0}%
  \edef\beamer@labelzoomed{beamer@labelzoomed@\the\beamer@zoomframecount @\the\beamer@zoomcount}%
  \setkeys{beamerzoom}{#3}%
  \only<#1>{%
    {\hypersetup{pdfhighlight={/P},pdfborder={0 0 \beamer@zoomborderwidth}}%
    \global\setbox\@tempboxa=\vbox{\hyperlink{\beamer@labelzoomed}{\vbox to #7{\hbox
          to#6{\hfil}\vfil}}}}%
    \ht\@tempboxa=0pt%
    \wd\@tempboxa=0pt%
    \dp\@tempboxa=0pt%
    \setbox\@tempboxa=\vbox{\moveright#4\hbox{\lower#5\vbox{\box\@tempboxa}}}%
    \ht\@tempboxa=0pt%
    \wd\@tempboxa=0pt%
    \dp\@tempboxa=0pt%
    \global\setbox\beamer@zoombox=\vbox to0pt{\unvbox\beamer@zoombox\box\@tempboxa}%
  }%
  \only<#2>{%
    \@ifundefined{\beamer@labelzoomed}%
    {%
      \hypertarget{\beamer@labelzoomed}{}%
      \expandafter\gdef\csname\beamer@labelzoomed\endcsname{}%
    }{}%
    \gdef\beamer@zoomer{%
      % compute zoom factor
      \@tempdima=\beamer@frametextheight%
      \@tempdimb=#7\relax%
      \@tempcnta=\@tempdimb%
      \divide\@tempcnta by4096\relax%
      \multiply\@tempdima by16\relax%
      \divide\@tempdima by\@tempcnta%
      \@tempdimb=\paperwidth%
      \ifbeamer@plainframe%
      \else%
        \advance\@tempdimb by-\beamer@leftsidebar%
        \advance\@tempdimb by-\beamer@rightsidebar\relax%
      \fi%
      \@tempdimc=#6\relax%
      \@tempcntb=\@tempdimc%
      \divide\@tempcntb by4096\relax%
      \multiply\@tempdimb by16\relax%
      \divide\@tempdimb by\@tempcntb%
      \ifdim\@tempdimb<\@tempdima%
        \@tempdima=\@tempdimb%
      \fi%
      \edef\beamer@temp{\strip@pt\@tempdima}%
      \@tempdimc=\beamer@frametextheight%
      \advance\@tempdimc by4pt%
      \@tempdimb=\paperwidth%
      \ifbeamer@plainframe%
      \else%
        \advance\@tempdimb by-\beamer@leftsidebar%
        \advance\@tempdimb by-\beamer@rightsidebar\relax%
      \fi%
      \setbox\@tempboxa=\vbox{\hsize=\@tempdimb\Acrobatmenu{GoBack}{\vbox to
          \beamer@frametextheight{\hbox to\@tempdimb{\hfil}\vfil}}}%
      \ht\@tempboxa=0pt%
      \wd\@tempboxa=0pt%
      \dp\@tempboxa=0pt%
      \setbox\beamer@framebox=\vbox to\beamer@frametextheight{{%
          \ifbeamer@plainframe\beamer@leftmargin=\Gm@lmargin\fi%
          \begin{oldpgfpicture}{\beamer@leftmargin}{-\beamer@frametextheight}{\beamer@leftmargin}{0pt}
            \pgftext[left,top]{\box\@tempboxa}
            \pgfpathrectangle{\pgfpoint{0pt}{-\@tempdimc}}{\pgfpoint{\ifcase\bbl@thepardir +\else-\fi\@tempdimb}{\@tempdimc}}%
            \pgfusepath{clip}
            \begingroup
              \pgftransformscale{\beamer@temp}
              \@tempdima=#4\relax%
              \@tempdimb=#5\relax%
              {\pgftransformshift{\pgfpoint{-\@tempdima}{\@tempdimb}}%
              \pgftext[left,top]{\vbox{\vbox{}\nointerlineskip\unvbox\beamer@framebox}}}
            \endgroup
          \end{oldpgfpicture}%
        }}%
      \setbox\beamer@framebox=\vbox{%
        \nobreak\vbox{}\nobreak\par\nobreak\beamer@entrycode\nobreak%
        \nointerlineskip\unvbox\beamer@frametitlebox%
        \nobreak%
        \box\beamer@framebox%
        \nobreak%
        \vss%
        \beamer@exitcode%
      }%
      \global\setbox\beamer@footins=\box\voidb@x% no footnotes in zoomed slides
    }%
  }%
}


%
% Shrink stuff
%

\def\beamer@shrinkframebox{%
  \@tempdima=\ht\beamer@framebox%
%  \ifdim\@tempdima>\beamer@frametextheight%
    \@tempcnta=\@tempdima%
    \divide\@tempcnta by 65536\relax%
    \@tempdimc=\beamer@frametextheight%
    \divide\@tempdimc by\@tempcnta\relax%
    \ifdim\@tempdimc>\beamer@shrinkfactor pt%
      \@tempdimc=\beamer@shrinkfactor pt%
    \else%
      \@tempdima=-100\@tempdimc%
      \advance\@tempdima by100pt%
      \ClassWarning{beamer}{Frame text is shrunk by a factor of %
      \strip@pt\@tempdima\space percent instead of
      \beamer@shrinkpercentage\space percent}%
    \fi%
    \edef\beamer@factortemp{\strip@pt\@tempdimc}%
    \setbox\beamer@framebox=\vbox to\beamer@frametextheight{%
      \begin{oldpgfpicture}{0pt}{-\beamer@frametextheight}{0pt}{0pt}
        {\pgftransformscale{\beamer@factortemp}%
          \pgftext[left,top]{\box\beamer@framebox}}%
      \end{oldpgfpicture}%
    }%
%  \fi%
}

% Use Amiri as default sans serif font

\font\sffont@rl="Amiri" at 10pt
\ifx\sffont@rl\nullfont
\else
\babelfont{sf}{Amiri}
\fi

\endinput
