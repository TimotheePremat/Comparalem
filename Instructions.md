# Extract data from TXM
- For NCA4, use concordance (corpus not built correctly for use with Index command)
- Set View \#1 to display following properties:
 - word
 - pos
 - ttpos
 - rnnpos
 - ttlemma
 - rnnlemma
 - subcorpus_id
 - s_line
 - (position)
- Set left and right contexts to zero
- For internal scha syncope, queries are:
 - ```[word=".*[bcdfgklmnpqrstç]e[bcdfgklmnpqrstç]+[aeiouyáéíóúàèìòùâêîôûäëïöü].*"]```
 - ```[word=".*[bcdfgklmnpqrstç]e[bcdfgklmnpqrstç].*"]```
 - voyelle + schwa
 	- ```[word=".*[aeoiuyáéíóúàèìòùâêîôûäëïöü]e[bcdfgklmnpqrstç]+[aeiouyáéíóúàèìòùâêîôûäëïöü].*"]```
	- ```[word=".*[aeoiuyáéíóúàèìòùâêîôûäëïöü][^e][bcdfgklmnpqrstç]+[aeiouyáéíóúàèìòùâêîôûäëïöü].*"]```
	- ADV:
	 - Without <ee>:
	  - ```[word=".*([^gq]u|[aioy])ement" & rnnpos="ADVgen"]```
	  - ```[word=".*[aiouy]ment" & rnnpos="ADVgen"]```
	 - With <ee>:
	  - ```[word=".*eement" & rnnpos="ADVgen"]```
	  - ```[word=".*[^e]ement" & rnnpos="ADVgen"]``` [not done]
	- Hors ADV
	 - ```[word=".*([^gq]u|[ay])e.*" & rnnpos!="ADV.*"]```
	-
	 - ```[word=".*([^ln]i|[^gq]u|[aoyáéíóúàèìòùâêîôûäëïöü])e[s]?" & pos=".*femi.*" & pos!="(DET|PRO|PREDET).*"]```
	 - ```[word=".*([^ln]i|[^gq]u|[aoyáéíóúàèìòùâêîôûäëïöü])[s]?" & pos=".*femi.*" & pos!="(DET|PRO|PREDET).*"]```
	- JO
	 - ```[pos="PRO:pers:suj:1:sg.*" & word="(j|i|g)(e|o|ou|eo)"] [word="[aeiouyáéíóúàèìòùâêîôûäëïöü].*"]```
	 - ```[pos="PRO:pers:suj:1:sg.*" & word="(j|i|g)"] [word="[aeiouyáéíóúàèìòùâêîôûäëïöü].*"]```
 - schwa + voyelle
- For <ei>/<oi> diphtongs, queries are:
 - ```[word=".*ei.*" & word!=".*oi.*"]```
 - ```[word=".*oi.*" & word!=".*ei.*"]```
 - These avoid having both <ei> and <oi> in the same word (e.g., _eincois_, _conoisseit_)
 - In cleaning lemmas and tokens, be careful about targets: you have to choose if you accept different targets or not. E.g., lemma "chaloir" has _chaleit_ for <ei> but for <oi> it has _chaloir_ and _chauroit_ : the two <oi> are not the same, and one is not present in <ei> dataset. Here I make the decision to accept it.

 ideally, <ei>/<oi> alternation should have a unique target per lemma (e.g., not _ateigne_ versus _ateignoit_ (made up example)).

- Run script Clean_data_NCA.sh
 - At first run, make it executable:
  - open a terminal where script is
  - enter ```chmod 755 Clean_data_NCA.sh``` or ```+x``` instead of ```755```
  - then script can be run with ```./Clean_data_NCA.sh [file name]```
  	- or ```.././Clean_data_NCA.sh [file name]``` if located in the repertory above the current one.

# Run MASTER_pre_tratment_R_form_SRC.R

# Filter out lemma (optional)
Go to ```Data/2_filtering_in_lemmas```, open file produced by ```MASTER_pre_tratment_R_form_SRC.R``` (e.g., ```EI_OI_merged_freq.csv```), and write (in col. "validated") "Y" or "Yes" for each lemma to keep and "N" or "No" for each lemma to exclude. Freely write remarks to remember why you did this choice for each lemma.
- Use TXM to check for tokens in context (e.g., ```[word=".*(ei|oi).*" & rnnlemma="concevoir"]```)
	- Goals:
		- Check for lemma confusion or splitting
		- Check for grapho-phonological irrelevance (e.g., <eil> for /eʎ/)
		- Check for other irrelevancies (e.g., <ei> for <ai> with other possibility of <oi>, _beigne_: this syllable is not alternating with <oi>)
- Use R (```View(Data_cat1_duplicated)``` and ```View(Data_cat2_duplicated)```) to check for tokens without context

# Appendix
Classes:
- consonants
	- [bcdfgklmnpqrstç]
	- Plosives: [bdgptkq]
	- Liquids: []
- vowels
	- [aeiouyáéíóúàèìòùâêîôûäëïöü]
