![](images/vivaldi.png "Vivaldi")

# Vivaldi #

## ToC ##
* [Installation](#installation)
* [Allgemeines](#allgemeines)
  * [Aufbau des Paketes](#paketaufbau)
  * [Nomenklatur](#nomenklatur)
  * [Unattended-Switches](#unattended_switches) 
* [Lizenzen](#lizenzen) 
  * [psdetail](#lic_psdetail)
  * [7zip](#lic_7zip)
  * [Vivaldi](#lic_vivaldi)
* [Anmerkungen/ToDo](#anmerkungen_todo) 



Diese OPSI-Paket fuer **Vivaldi** wurde aus dem internen Paket des *Max-Planck-Institut fuer Mikrostrukturphysik*
abgeleitet und fuer die Verwendung im *DFN*-Repository angepasst und erweitert.
Es wird versucht auf die Besonderheiten der jeweiligen Repositories einzugehen;
entsprechend werden durch ein einfaches ***Makefile*** aus den Quellen verschiedene
Pakete erstellt.



<div id="installation"></div>

## Installation ##

Bei der Installation des Paketes im Depot erfolgt im <code>postinst</code>-Script 
der Download der Software vom Hersteller (Windows, 32 und 64 Bit). Ein manueller
Download sollte nicht erforderlich sein.  
Die Software selbst wird <u>nicht</u> mit diesem Paket vertrieben.



<div id="allgemeines"></div>

## Allgemeines ##


<div id="paketaufbau"></div>

### Aufbau des Paketes ###

* **<code>variables.opsiinc</code>** - Da Variablen ueber die Scripte hinweg mehrfach
verwendet werden, werden diese (bis auf wenige Ausnahmen) zusammengefasst hier deklariert.
* **<code>product_variables.opsiinc</code>** - die producktspezifischen Variablen werden
hier definiert
* **<code>setup.opsiscript </code>** - Das Script fuer die Installation.
* **<code>uninstall.opsiscript</code>** - Das Uninstall-Script
* **<code>delsub.opsiinc</code>**- Wird von Setup und Uninstall gemeinsam verwendet.
Vor jeder Installation/jedem Update wird eine alte Version entfernt. (Ein explizites
Update-Script existiert derzeit nicht.)
* **<code>checkinstance.opsiinc</code>** - Pruefung, ob eine Instanz der Software laeuft.
Gegebenenfalls wird das Setup abgebrochen. Optional kann eine laufende Instanz 
zwangsweise beendet werden.
* **<code>checkvars.sh</code>** - Hilfsscript fuer die Entwicklung zur Ueberpruefung,
ob alle verwendeten Variablen deklariert sind bzw. nicht verwendete Variablen
aufzuspueren.
* **<code>bin/</code>** - Hilfprogramme; hier: **7zip**, **psdetail**
* **<code>images/</code>** - Programmbilder fuer OPSI



<div id="nomenklatur"></div>

### Nomenklatur ###

Praefixes in der Produkt-Id definieren die Art des Paketes:

* **0_** - Es handelt sich um ein Test-Paket. Beim Uebergang zur Produktions-Release
wird der Praefix entfernt.
* **dfn_** - Das Paket ist zur Verwendung im DFN-Repository vorgesehen.

Die Reihenfolge der Praefixes ist relevant; die Markierung als Testpaket ist 
stets fuehrend.



<div id="unattended_switches"></div>

### Unattended-Switches ###

...gibt es derzeit beim Vivaldi-Installer nicht. Die Installation besteht daher
aus dem manuellen entpacken des Archivs und Erzeugen der Startmenueeintraege.

In der Folge gibt es auch keinen Eintrag in den Uninstall-Sektionen der Registry.  
Damit OPSI sich dennoch "orientieren" und den Installationsstatus abfragen kann, 
wird unter *<code>$MPIMSP_Reg$</code>* ein Eintrag fuer derart installierte Pakete 
angelegt.



<div id="lizenzen"></div>

## Lizenzen ##


<div id="lic_psdetail"></div>

### psdetail ###

**Autor** der Software: Jens Boettge <<boettge@mpi-halle.mpg.de>> 

Die Software **psdetail.exe**  wird als Freeware kostenlos angeboten und darf fuer 
nichtkommerzielle sowie kommerzielle Zwecke genutzt werden. Die Software
darf nicht veraendert werden; es duerfen keine abgeleiteten Versionen daraus 
erstellt werden.

Es ist erlaubt Kopien der Software herzustellen und weiterzugeben, solange 
Vervielfaeltigung und Weitergabe nicht auf Gewinnerwirtschaftung oder Spendensammlung
abzielt.

Haftungsausschluss:  
Der Auto lehnt ausdruecklich jede Haftung fuer eventuell durch die Nutzung 
der Software entstandene Schaeden ab.  
Es werden keine ex- oder impliziten Zusagen gemacht oder Garantien bezueglich
der Eigenschaften, des Funktionsumfanges oder Fehlerfreiheit gegeben.  
Alle Risiken des Softwareeinsatzes liegen beim Nutzer.

Der Autor behaelt sich eine Anpassung bzw. weitere Ausformulierung der Lizenzbedingungen
vor.

Fuer die Nutzung wird das *.NET Framework ab v3.5*  benoetigt.



<div id="lic_7zip"></div>

### 7zip ###

Es gilt die Lizenz von http://www.7-zip.org/license.txt.



<div id="lic_vivaldi"></div>

### Vivaldi ###

Das verwendete Vivialdi-Logo ist gemeinfrei.  
Quelle: https://de.wikipedia.org/wiki/Vivaldi_(Browser)#/media/File:Vivaldi_web_browser_logo.svg



<div id="anmerkungen_todo"></div>

## Anmerkungen/ToDo ##

* Die vollstaendige Integration des Browsers ins System (Default-Browser, HTML-Handler, Self-Updater
erfolgt aufgrund der Art der Installation derzeit nicht).
* Die Product-Property *default_language* wird derzeit nicht ausgewertet.
* Das <code>postinst</code>-Script legt unter <code>/tmp/${PRODUCT_ID}__opsi_package_install.log</code> ein Logfile an.
* <s>Bereits heruntergeladene Software (unter <code>files</code>) werden beim 
Update geloescht. Ggf. kann das Verzeichnis analog zu <code>custom</code> 
zuvor gesichert und wiederhergestellt werden.</s>
* Policies fuer Chromium/Vivaldi sind bislang noch nicht realisiert.
* Fuer die OPSI-Pakete wird noch ein ***Lizenzmodell*** benoetigt.

-----
Jens Boettge <<boettge@mpi-halle.mpg.de>>, 2017-08-23 11:46:37 +0200
