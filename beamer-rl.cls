\NeedsTeXFormat{LaTeX2e}[2022-11-01]
\ProvidesClass{beamer-rl}
[2023/12/24 v1.9  LaTeX class to patch beamer for right to left presentation with babel]

\DeclareKeys
  {
     layout  .code:n = \PassOptionsToPackage{layout=#1}{babel}
    ,unknown .code:n = \PassOptionsToClass{\CurrentOption}{beamer}
  }

\DeclareKeys
  {  
     arabic  .code:n = 
     \PassOptionsToPackage{arabic,provide=*}{babel}
     \AddToHook{env/document/before}{
     \babelprovide[#1]{arabic}
     \uselanguage{Arabic}\languagealias{arabic}{Arabic}     
     %\PassOptionsToPackage{arabic}{translator}
     }, 
     arabic .default:n =
  }  

\DeclareKeys
  {  
     hebrew  .code:n = 
     \PassOptionsToPackage{hebrew,provide=*}{babel}
     \AddToHook{env/document/before}{
     \babelprovide[#1]{hebrew}
     %\PassOptionsToPackage{hebrew}{translator}
     }, 
     hebrew .default:n =
  }  

  
\ExplSyntaxOn
\clist_map_inline:nn {arabic-ma,arabic-tn,arabic-dz,arabic-eg,arabic-sa,arabic-iq,arabic-sy,arabic-lb,arabic-ps,arabic-jo}
  {
    \DeclareKeys
      {
        #1 .code:n    = 
          \AddToHook{env/document/before}{\babelprovide[import,##1,main]{#1}
          \uselanguage{Arabic}\languagealias{arabic}{Arabic}},     
          %\PassOptionsToPackage{arabic}{translator},
        #1 .default:n = 
      }
  }

\clist_map_inline:nn {syriac,persian,urdu,centralkurdish,kashmiri,mazanderani,northernkurdish-arab,malayalam,pashto,punjabi-arab,uyghur,uzbek-arab,yiddish}
  {
    \DeclareKeys
      {
        #1 .code:n    = 
          \AddToHook{env/document/before}{\babelprovide[import,##1,main]{#1}},
        #1 .default:n = 
      }
  }
\ExplSyntaxOff

\ProcessKeyOptions

\RequirePackage{ifluatex}

\ifluatex
\else
\ClassError{beamer-rl}{beamer-rl require lualatex}
\fi

\LoadClass[hyperref={unicode}]{beamer}

\RequirePackage[nil,bidi=basic]{babel}

\let\oldpgfpicture\pgfpicture
\let\endoldpgfpicture\endpgfpicture

\let\oldpgfsys@beginpicture\pgfsys@beginpicture

\def\redefbeamertemplate{%
	\@ifstar{\@defbeamertemplate}{\@@defbeamertemplate}%
}

\def\reset@temp#1#2{\expandafter\let\csname beamer@@tmpop@#1@#2\endcsname\relax}
\def\@@defbeamertemplate#1#2{\reset@temp{#1}{#2}\defbeamertemplate{#1}{#2}}
\def\@defbeamertemplate#1#2{\reset@temp{#1}{#2}\defbeamertemplate*{#1}{#2}}


\let\oldpgfuseshading\pgfuseshading
\def\pgfuseshading#1{\babelsublr{\oldpgfuseshading{#1}}}

% add graphics layout by default

\let\bbl@pictresetdir\relax
   \def\bbl@pictsetdir#1{%
     \ifcase\bbl@thetextdir
       \let\bbl@pictresetdir\relax
     \else
       \ifcase#1\bodydir TLT  % Remember this sets the inner boxes
         \or\textdir TLT
         \else\bodydir TLT \textdir TLT
       \fi
       % \(text|par)dir required in pgf:
       \def\bbl@pictresetdir{\bodydir TRT\pardir TRT\textdir TRT\relax}%
     \fi}%
   \AddToHook{env/picture/begin}{\bbl@pictsetdir\tw@}%
   \directlua{
     Babel.get_picture_dir = true
     Babel.picture_has_bidi = 0
     %
     function Babel.picture_dir (head)
       if not Babel.get_picture_dir then return head end
       if Babel.hlist_has_bidi(head) then 
         Babel.picture_has_bidi = 1
       end
       return head
     end
     luatexbase.add_to_callback("hpack_filter", Babel.picture_dir,
       "Babel.picture_dir")
   }%
   \AtBeginDocument{%
     \def\LS@rot{%
       \setbox\@outputbox\vbox{%
         \hbox dir TLT{\rotatebox{90}{\box\@outputbox}}}}%
     \long\def\put(#1,#2)#3{%
       \@killglue 
       % Try:
       \ifx\bbl@pictresetdir\relax
         \def\bbl@tempc{0}%
       \else
         \directlua{
           Babel.get_picture_dir = true
           Babel.picture_has_bidi = 0
         }%
         \setbox\z@\hb@xt@\z@{%
           \@defaultunitsset\@tempdimc{#1}\unitlength
           \kern\@tempdimc
           #3\hss}% TODO: #3 executed twice (below). That’s bad.
         \edef\bbl@tempc{\directlua{tex.print(Babel.picture_has_bidi)}}%
       \fi
       % Do:
       \@defaultunitsset\@tempdimc{#2}\unitlength
       \raise\@tempdimc\hb@xt@\z@{%
         \@defaultunitsset\@tempdimc{#1}\unitlength
         \kern\@tempdimc
         {\ifnum\bbl@tempc>\z@\bbl@pictresetdir\fi#3}\hss}% 
       \ignorespaces}%
     \MakeRobust\put}%
   \AtBeginDocument
     {\AddToHook{cmd/diagbox@pict/before}{\let\bbl@pictsetdir\@gobble}%
       \AddToHook{env/pgfpicture/begin}{\bbl@pictsetdir\@ne}%
        \bbl@add\pgfinterruptpicture{\bbl@pictresetdir}%
        \bbl@add\pgfsys@beginpicture{\bbl@pictsetdir\@ne}%
      \ifx\tikzpicture\@undefined\else    
        \AddToHook{env/tikzpicture/begin}{\bbl@pictsetdir\tw@}%
        \bbl@add\tikz@atbegin@node{\bbl@pictresetdir}%
        \bbl@sreplace\tikz{\begingroup}{\begingroup\bbl@pictsetdir\tw@}%
      \fi
      \ifx\tcolorbox\@undefined\else
        \def\tcb@drawing@env@begin{%
        \csname tcb@before@\tcb@split@state\endcsname
        \bbl@pictsetdir\tw@
        \begin{\kvtcb@graphenv}%
        \tcb@bbdraw%
        \tcb@apply@graph@patches
        }%
       \def\tcb@drawing@env@end{%
       \end{\kvtcb@graphenv}%
       \bbl@pictresetdir
       \csname tcb@after@\tcb@split@state\endcsname
       }%
      \fi
    } 
 
%% beamerbasenotes

\defbeameroption{show notes on second screen}[right]%
{
  \ifx\@onlypreamble\@notprerr 
    \ltx@ifpackageloaded{pgfpages}{}{%
      \ClassError{beamer}{`pgfpages' package necessary for this option}{}%
    }%
  \else%
   \RequirePackage{pgfpages-rl} 
  \fi%
  \pgfpagesuselayout{two screens with optional second}[second #1]
  \beamer@twoscreensnotestrue
  \beamer@notestrue
}

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
	 \ifnum\textdirection=\z@
     \else%
       \bmb@dimc=\bmb@width%
     \fi% <--
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
    \hbox dir TLT {%
		\begin{pgfpicture}{0bp}{+-\ht\bmb@box}{\bmb@dimc}{+-\ht\bmb@box}
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
	\setbox\bmb@colorbox=\hbox{{\pgfpicturetrue\pgfsetcolor{lower.bg}}}%
	\setbox\bmb@box=\hbox\bgroup\begin{minipage}[b]{\bmb@width}%
		\vskip2pt%
		\usebeamercolor[fg]{\bmb@lower}%
		\colorlet{beamerstructure}{upper.bg}%
		\colorlet{structure}{upper.bg}%
		%\color{.}%
	}

\newdimen\bmb@dimd

\def\endbeamerboxesrounded{%
  \end{minipage}\egroup%
  \bmb@temp=\dp\bmb@box%
  \advance\bmb@temp by.5pt%
  \setbox\bmb@box=\hbox{\raise\bmb@temp\hbox{\box\bmb@box}}%
  \dp\bmb@box=0pt%
  \bmb@boxwidth=\bmb@width%
  \bmb@boxheight=\ht\bmb@box%
  \advance\bmb@boxheight by4bp%
  \advance\bmb@boxheight by\bmb@prevheight%
  \ifbmb@shadow%
    \xdef\beamer@storecolorhook{\beamer@colorhook}
    \xdef\beamer@colorhook{}
    \pgfdeclareradialshading{bmb@shadowball}{\pgfpointorigin}
    {%
      color(0bp)=(pgftransparent!50);
      color(4bp)=(pgftransparent!100)
    }%
    \pgfdeclareradialshading{bmb@shadowballlarge}{\pgfpointorigin}
    {%
      color(0bp)=(pgftransparent!0);
      color(8bp)=(pgftransparent!100)
    }%
    \pgfdeclarehorizontalshading{bmb@shadowhorz\the\bmb@boxheight}{\bmb@boxheight-5.5bp}
    {%
      color(0bp)=(pgftransparent!0);
      color(8bp)=(pgftransparent!100)
    }%
    \pgfdeclareverticalshading{bmb@shadowvert\the\bmb@boxwidth}{\bmb@boxwidth-4bp}
    {%
      color(0bp)=(pgftransparent!100);
      color(8bp)=(pgftransparent!0)
    }%
    \begingroup%
      \selectcolormodel{gray}
      \pgfdeclarefading{bmb@shadowmask\the\bmb@boxwidth\the\bmb@boxheight}
      {%
      \textdir TLT
        \begin{pgfpicture}
          \pgftext[at=\pgfpoint{4bp}{4bp}]{\pgfuseshading{bmb@shadowball}}% bottom left shadow
          \ifdim\bmb@boxheight>9.5bp%
            \pgftext[at=\pgfpoint{\bmb@boxwidth}{8bp}]{\pgfuseshading{bmb@shadowballlarge}}% bottom right shadow
            \pgftext[at=\pgfpoint{\bmb@boxwidth+4bp}{\bmb@boxheight+2bp}]{\pgfuseshading{bmb@shadowball}}% top right shadow
            \pgftext[base, at=\pgfpoint{\bmb@boxwidth+4bp}{7.5bp}]{\pgfuseshading{bmb@shadowhorz\the\bmb@boxheight}}% right edge shadow
          \else%
            \pgftext[at=\pgfpoint{\bmb@boxwidth}{4bp}]{\pgfuseshading{bmb@shadowball}}% right shadow
          \fi%
          \pgftext[left, at=\pgfpoint{4bp}{4bp}]{\pgfuseshading{bmb@shadowvert\the\bmb@boxwidth}}% bottom edge
          %
          % clipping is needed because shadow is typeset on top of box
          \begin{pgfscope}
            \pgfsetcolor{beamer@safeblack}
            \pgfpathrectangle{\pgfpoint{4bp}{8.1bp}}{\pgfpoint{\bmb@boxwidth}{\bmb@boxheight-2bp}}
            \pgfusepath{fill}
          \end{pgfscope}
        \end{pgfpicture}%
        \hskip4bp%      
      }%
    \endgroup%
  \fi%
  \bmb@temp=\bmb@width%
  \bmb@dima=\bmb@temp\advance\bmb@dima by2.2bp%
  \bmb@dimb=\bmb@temp\advance\bmb@dimb by4bp%
  \ifdim\wd\bmb@box=0pt%
   \ifnum\textdirection=\z@
   \else
    \bmb@dimd=\bmb@width%
   \fi%
  \fi%  
  \hbox{\textdir TLT%
    \begin{pgfpicture}{0bp}{0bp}{\bmb@dimd}{0bp}
      \ifbmb@shadow%
        \begin{pgfscope}
          \pgfpathrectangle{\pgfpoint{0bp}{-7bp}}
            {\pgfpoint{\bmb@boxwidth+8bp}{\bmb@boxheight+6bp}}
          \pgfsetfading{bmb@shadowmask\the\bmb@boxwidth\the\bmb@boxheight}{%
            \pgftransformshift{\pgfpoint{0.5\bmb@boxwidth+6bp}{0.5\bmb@boxheight-4bp}}}
          \pgfusepath{fill}
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
    \end{pgfpicture}%
    \box\bmb@box%
  }%
  \ifbmb@shadow%
    \vskip4bp minus 2bp%
  \else%
    \vskip2bp%
  \fi%
  \egroup% of \vbox\bgroup
  \ifbmb@shadow%
    \xdef\beamer@colorhook{\beamer@storecolorhook}
  \fi
}

%% beamerbaseauxtemplates

\redefbeamertemplate{bibliography item}{triangle}
{\scriptsize\raise1.25pt\hbox{\donotcoloroutermaths$\ifcase\bbl@thepardir\blacktriangleright\else\blacktriangleleft\fi$}}

% (sub-)section in toc: subsections numbered

\redefbeamertemplate{subsection in toc}{subsections numbered}
{\leavevmode\leftskip=2em\rlap{\hskip-2em \babelsublr{\inserttocsectionnumber}.\babelsublr{\inserttocsubsectionnumber}}\inserttocsubsection\par}

%% beamerinnerthemedefault

\redefbeamertemplate*{itemize item}{default}{\usebeamerfont*{itemize item}\raise1.25pt\hbox{\donotcoloroutermaths$\ifcase\bbl@thepardir\blacktriangleright\else\blacktriangleleft\fi$}}

\redefbeamertemplate*{itemize subitem}{default}{\usebeamerfont*{itemize subitem}\raise1.5pt\hbox{\donotcoloroutermaths$
\ifcase\bbl@thepardir\blacktriangleright\else\blacktriangleleft\fi$}}

\AtBeginDocument{\@ifpackageloaded{beamerthemeBoadilla}{%
\usesubitemizeitemtemplate{%
\tiny\raise1.5pt\hbox{\color{beamerstructure}$\ifcase\bbl@thepardir\blacktriangleright\else\blacktriangleleft\fi$}%
}
}{}}

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


%% beamerouterthemedefault

\redefbeamertemplate*{note page}{default}
{%
  {%
    \scriptsize
    \usebeamerfont{note title}\usebeamercolor[fg]{note title}%
    \ifbeamercolorempty[bg]{note title}{}{%
      \insertvrule{.25\paperheight}{note title.bg}%
      \vskip-.25\paperheight%
      \nointerlineskip%
    }%
    \vbox{
      \beamer@tempdim=0.2cm
      \ifnum\textdirection=\@ne \multiply \beamer@tempdim by -2\fi
      \hfill\insertslideintonotes{0.25}\hskip-\Gm@rmargin\hskip0pt%
      \vskip-0.25\paperheight%
      \nointerlineskip
      \begin{pgfpicture}{0cm}{0cm}{0cm}{0cm}
        \begin{pgflowlevelscope}{\pgftransformrotate{90}}
          {\pgftransformshift{\pgfpoint{-2cm}{\beamer@tempdim}}%
          \pgftext[base,left]{\usebeamerfont{note date}\usebeamercolor[fg]{note date}\the\year-\ifnum\month<10\relax0\fi\the\month-\ifnum\day<10\relax0\fi\the\day}}
        \end{pgflowlevelscope}
      \end{pgfpicture}}
    \nointerlineskip 
    \vbox to .25\paperheight{\vskip0.5em
      \hbox{\insertshorttitle[width=0.75\textwidth]}%
      \setbox\beamer@tempbox=\hbox{\insertsection}%
      \hbox{\ifdim\wd\beamer@tempbox>1pt{\hskip4pt\raise3pt\hbox{\vrule
            width0.4pt height7pt\vrule width 9pt
            height0.4pt}}\hskip1pt\hbox{\begin{minipage}[t]{0.71\textwidth}\def\breakhere{}\insertsection\end{minipage}}\fi%
      }%
      \setbox\beamer@tempbox=\hbox{\insertsubsection}%
      \hbox{\ifdim\wd\beamer@tempbox>1pt{\hskip17.4pt\raise3pt\hbox{\vrule
            width0.4pt height7pt\vrule width 9pt
            height0.4pt}}\hskip1pt\hbox{\begin{minipage}[t]{0.71\textwidth}\def\breakhere{}\insertsubsection\end{minipage}}\fi%
      }%
      \setbox\beamer@tempbox=\hbox{\insertshortframetitle}%
      \hbox{\ifdim\wd\beamer@tempbox>1pt{\hskip30.8pt\raise3pt\hbox{\vrule
            width0.4pt height7pt\vrule width 9pt
            height0.4pt}}\hskip1pt\hbox{\insertshortframetitle[width=0.67\textwidth]}\fi%
      }%
      \vfil}%
  }%
  \ifbeamercolorempty[bg]{note page}{}{%
    \nointerlineskip%
    \insertvrule{.75\paperheight}{note page.bg}%
    \vskip-.75\paperheight%
  }%
  \vskip.25em
  \nointerlineskip
  \insertnote
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
% The patch need improvement to cover all cases 

\bbl@sreplace\beamer@framezoom{\begin{pgfpicture}}%
{\ifcase\bbl@thepardir \else\multiply\@tempdimb by\m@ne\relax
\let\pgfsys@beginpicture\oldpgfsys@beginpicture\fi%
\begin{pgfpicture}}%

%
% Shrink stuff
%

\bbl@sreplace\beamer@shrinkframebox{\vbox}%
          {\vbox dir TLT}%

% issue of \shapemode bug 
% https://github.com/latex3/babel/issues/13
% we need to insert \shapemode=2  or \shapemode=0 manualy  at beginning of list
% \begin{enumerate} \shapemode=.. &  \begin{itemize} \shapemode=..


% Use Amiri as default sans serif font

\font\sffont@rl="Amiri" at 10pt
\ifx\sffont@rl\nullfont
\else
\babelfont{sf}{Amiri}
\fi

\endinput