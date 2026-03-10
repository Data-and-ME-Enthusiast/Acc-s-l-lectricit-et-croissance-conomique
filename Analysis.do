*********************************                          **********************************************
*                                                                                                       *
*     Modélisation VAR : Impact de l'accès à l'électricité sur la croissance économique au Togo         *
*     Do file édité par M. SANOUSSI Moudjibou (Analyste statisticien, suivi-évaluateur)                 *
*                    Date : Samedi, 28 Février 2026                                                     *
*                                                                                                       *
*********************************************************************************************************


version 17
clear all
set more off
cap log close

 

* Définition du repertoire de travail et chargement de la base de données
cd "ton_repertoire_de_travail"
import excel nom_de_la_base_excel, clear 



log using analyse.smcl_nouveau, replace  // Début du fichier log

*Traitement de la base de données

keep Time Accesstoelectricityrural Accesstoelectricityurban GDPpercapitacurrentUSNY
replace Accesstoelectricityrural = "." in 26
replace Accesstoelectricityurban = "." in 26

destring Accesstoelectricityrural Accesstoelectricityurban, replace
tabstat Accesstoelectricityrural Accesstoelectricityurban, stat(median) // Imputation des données manques par la médiane
replace Accesstoelectricityrural = 13.9   in 26
replace Accesstoelectricityurban = 67.2 in 26  
drop if  Time == .

rename Accesstoelectricityrural acces_rural
rename Accesstoelectricityurban acces_urban
rename GDPpercapitacurrentUSNY gdp
rename Time  annee

label var acces_rural "Taux d'accès à l'électricité (rural)"
label var acces_urban "Taux d'accès à l'électricité (urbain)"
label var gdp "PIB par habitant (current USD)"

save base_analyse, replace

* Analyse de données

tsset annee    // Déclaration des données en série temporelle

// Etude des propriété statistiques des séries (analyse graphique en niveau)
set scheme s1mono // Changement de l'apparence par defaut des graphiques
sum acces_rural acces_urban gdp 
tsline acces_rural, ylabel(14.40903 ) saving(acces_rural) 
tsline acces_urban, ylabel(69.64229 ) saving(acces_urban)
tsline gdp , ylabel(710.4808) saving(gdp)
graph combine acces_rural.gph acces_urban.gph gdp.gph
graph export serie_niv_sheme.png, as(png) name("Graph") replace

// Etude des propriété statistiques des séries (analyse graphique en niveau)
sum d.acces_rural d.acces_urban d.gdp 
tsline d.acces_rural, ylabel(.431888) saving(acces_rural1) 
tsline d.acces_urban, ylabel(1.04 ) saving(acces_urban1)
tsline d.gdp , ylabel(21.55526) saving(gdp1)
graph combine acces_rural1.gph acces_urban1.gph gdp1.gph
graph export serie_dif_sheme.png, as(png) name("Graph") replace

// Test ADF en niveau
varsoc acces_rural
dfuller acces_rural, lags(2) trend regress
dfuller acces_rural , lags(0) nocons  

varsoc acces_urban
dfuller acces_urban, lags(1) trend regress
dfuller acces_urban , lags(0) nocons  

varsoc gdp   
dfuller gdp, lags(1) trend regress
dfuller gdp , lags(0) trend 

// Test ADF en différence première
varsoc d.acces_rural   // Stationnaire
dfuller d.acces_rural, lags(1) trend regress
dfuller d.acces_rural , lags(1) nocons  

varsoc d.acces_urban  // Stationnaire
dfuller d.acces_urban, lags(0) trend regress
dfuller d.acces_urban , lags(0) nocons 

varsoc d.gdp          // Stationnair
dfuller d.gdp, lags(0) trend regress
dfuller d.gdp , lags(1) trend 


* Test de cointégration de Johansen (1988) 
vecrank gdp acces_rural acces_urban 



//Estimation du modèle 
varsoc d.gdp d.acces_rural d.acces_urban // Détermination du nombre de retard



var d.gdp d.acces_rural d.acces_urban, lags(1)
* varwle   computes Wald tests to determine whether certain lags can be excluded

* Tests de postestimation
varlmar             // Test d'autocorrélation
varnorm            //  Test de normalité 

varstable, graph        //   Test de statbilité

vargranger       //    Test de causalité

log close // Fermeture du fichier log 


* irf              //    Pour avoir les fonctions de reponses impultionnelles
* var basic      //      Etude des réponses impultionnelles 




















