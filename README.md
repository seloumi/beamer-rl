# beamer-rl

Patchs  of some  beamer commands and templates for  right to left  presentations using babel with `bidi=basic` (lualatex)  

```latex
\documentclass{beamer-rl}

\babelprovide[import=ar-DZ, main]{arabic}


\usetheme{CambridgeUS}
\usecolortheme{spruce}

\title{beamer-rl class}

\author{Salim Bou}

\institute[]{%
{\color{blue} Repository: } https://github.com/seloumi/beamer-rl \par 
{\color{blue} Bug tracker: } https://github.com/seloumi/beamer-rl/issues
}

\date{\today}

\begin{document}

\begin{frame}
\titlepage
\end{frame}

\end{document}
```

<p align="center">
<img src="https://github.com/seloumi/beamer-rl/blob/master/preview.PNG" width="400"/> <img src="https://github.com/seloumi/beamer-rl/blob/master/preview-arabic.PNG" width="400"/>
</p> 
