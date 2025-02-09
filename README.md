# Comparalem
R script to autodetect lemma with graphical variation.

> This is a alpha version of Comparalem V2, not intended for public use. Yet, it is fonctional; if you wish to use it, you're free to do so.

# Documentation
Documentation writing is undergoing. Some information is provided in ```Instructions.md```, but this is hardly a documentation. Scripts are interactive and ask the user for the input files and parameters.

1. Run ```MASTER_pre-tratment_R_form_SRC.R``` on your input files (with all forms of all lemma) to create dictionnaries of alternating lemmas
2. Run ```MASTER_R_form_distrib_txt_SRC.R``` on your input files (with all or part of all forms and lemma) to process lemma-alternation, statistical computation and map generation.

# Input files
The core difficulty of documenting this programm is documenting the format of input files. The script is delivered with a example dataset. Until full documentation is provided, make your input files look like the sample ones.

# Acknowledgement for Shapefiles
NCA shapefiles has been produced by Guylaine Brun-Triagaud for the ADE22 project : <http://atlasdees.unice.fr/>

# Outputs
This script orduces various graphs, maps and mesures such as the followings (example for OldFrench _jo_ ~ _j_ variation, i.e., elision).

## Rate of _j_ by text and time (NCA corpus)

<img src="https://github.com/user-attachments/assets/755e093c-e527-4a2d-aec4-880f902bfa46" width="600">

## Rate of _j_ by text and region (NCA corpus)

<img src="https://github.com/user-attachments/assets/36bf7d02-5483-43ef-b87b-bea1aa2b4c0d" width="600">

## GLM : rate of _j_ as a function of date, verse, region, and POS of following word
```
1 
2 Call:
3 glm(formula = type ~ std_date + vers + regionDees_supp + category, family = binomial("logit"), data = combined_data)
4 
5 Coefficients:
6                                             Estimate Std. Error z value Pr(>|z|)    
7 (Intercept)                                -14.08285    1.43650  -9.804  < 2e-16 ***
8 std_date                                     0.01021    0.00111   9.193  < 2e-16 ***
9 versoui                                      1.75291    0.10851  16.154  < 2e-16 ***
10 regionDees_suppAngleterre                   -2.89244    0.26168 -11.053  < 2e-16 ***
11 regionDees_suppArdennes                     -0.36219    0.32643  -1.110  0.26720    
12 regionDees_suppAube                         -0.52577    0.23014  -2.285  0.02233 *  
13 regionDees_suppBourgogne                    -0.96162    0.71560  -1.344  0.17902    
14 regionDees_suppCharente-Maritime            -0.98847    0.69478  -1.423  0.15482    
15 regionDees_suppFranche-Comte                -0.45028    0.35986  -1.251  0.21084    
16 regionDees_suppHainaut                      -0.74717    0.30253  -2.470  0.01352 *  
17 regionDees_suppHaute-Marne                  -0.75194    0.21120  -3.560  0.00037 ***
18 regionDees_suppIndre-et-Loire               12.39764  308.24387   0.040  0.96792    
19 regionDees_suppIndre, Cher                  12.24953  535.41120   0.023  0.98175    
20 regionDees_suppMarne                        -1.28160    0.26551  -4.827 1.39e-06 ***
21 regionDees_suppMeuse                         1.46855    0.51214   2.867  0.00414 ** 
22 regionDees_suppMoselle, Meurthe-et-Moselle  -0.03594    0.50732  -0.071  0.94352    
23 regionDees_suppNievre, Allier               -0.26885    0.22739  -1.182  0.23708    
24 regionDees_suppNord                         -0.90102    0.47167  -1.910  0.05610 .  
25 regionDees_suppNormandie                     0.02502    0.22888   0.109  0.91294    
26 regionDees_suppOise                          0.52073    0.31538   1.651  0.09871 .  
27 regionDees_suppOrleanais                     0.66947    0.60909   1.099  0.27171    
28 regionDees_suppRegion parisienne            -0.75876    0.22226  -3.414  0.00064 ***
29 regionDees_suppSomme, Pas-de-Calais         -0.05668    0.21453  -0.264  0.79164    
30 regionDees_suppVendee, Deux-Sevres          -0.27039    0.30092  -0.899  0.36890    
31 regionDees_suppVosges                        1.01726    0.60377   1.685  0.09202 .  
32 regionDees_suppWallonie                     -0.28881    0.31609  -0.914  0.36087    
33 regionDees_suppYonne                        -0.12610    0.33113  -0.381  0.70335    
34 categoryPRE                                 -1.35700    0.31677  -4.284 1.84e-05 ***
35 categoryPROadv                               1.48546    0.23881   6.220 4.96e-10 ***
36 categoryVERcjg                               1.14408    0.22540   5.076 3.86e-07 ***
37 ---
38 Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
39 
40 (Dispersion parameter for binomial family taken to be 1)
41 
42     Null deviance: 5416.5  on 3922  degrees of freedom
43 Residual deviance: 4101.9  on 3893  degrees of freedom
44   (36 observations deleted due to missingness)
45 AIC: 4161.9
46 
47 Number of Fisher Scoring iterations: 12
48
```
