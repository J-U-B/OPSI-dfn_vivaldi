# ![](./SRC/CLIENT_DATA/images/vivaldi_32x32.png "Vivaldi") Vivaldi #

## ToC ##
* [Paketinfo](#paketinfo)
* [Paket erstellen](#paket_erstellen)
	* [Voraussetzungen](#voraussetzungen)
	* [Makefile und spec.json](#makefile_und_spec)
	* [Mustache](#mustache)
	* [Verzeichnisstruktur](#verzeichnisstruktur)
	* [Makefile-Parameter](#makefile_parameter)
	* [spec.json](#spec_json)
* [Installation](#installation)
* [Allgemeines](#allgemeines)
	* [Aufbau des Paketes](#paketaufbau)
	* [Nomenklatur](#nomenklatur)
	* [Unattended-Switches](#unattended_switches)
* [Lizenzen](#lizenzen)
	* [Dieses Paket](#licPaket)
	* [psdetail](#lic_psdetail)
	* [7zip](#lic_7zip)
	* [Vivaldi](#lic_vivaldi)
* [Anmerkungen/ToDo](#anmerkungen_todo)

----

<div id="paketinfo"></div>

## Paketinfo ##

Das vorliegende OPSI-Paket fuer **Vivaldi** wurde fuer das Repository von
*opsi4institutes (O4I)* entwickelt.  
Die Erstellung der eigentlichen OPSI-Pakete aus den Quellen erfolgt durch
ein einfaches *Makefile*.


<div id="paket_erstellen"></div>

## Paket erstellen ##

Dieser Abschnitt beschaeftigt sich mit der Erstellung des OPSI-Paketes aus
dem Source-Paket und nicht mit dem OPSI-Paket selbst.


<div id="voraussetzungen"></div>

### Voraussetzungen ###

Zur Erstellung der OPSI-Pakete aus den vorliegenden Quellen werden neben den
**opsi-utils** noch weitere Tools benoetigt, die aus den Repositories der
jeweiligen Distributionen zu beziehen sind.
Das sind (angegebenen Namen entsprechen Paketen in Debian/Ubuntu):

* make
* python-pystache
* curl oder wget


<div id="makefile_und_spec"></div>

### Makefile und spec.json ###

Da aus den Quellen verschiedene Versionen des Paketes mit entsprechenden Anpassungen
generiert werden sollen (intern, O4I; testing/release) wurde hierfuer ein
**<code>Makefile</code>** erstellt. Darueber hinaus steuert **<code>spec.json</code>**
die Erstellung der Pakete.

Im Idealfall ist beim Erscheinen einer neuen Release von Vivaldi lediglich die
**<code>spec.json</code>** anzupassen.


<div id="pystache"></div>

<div id="mustache"></div>

### Mustache ###

Als Template-Engine kommt **Mustache** zum Einsatz.  
Im Detail wird hier eine Go-Implementierung verwendet. Die Software ist auf 
[Github](https://github.com/cbroglie/mustache) zu finden. Binaries 
für Linux und Windows liegen diesem Paket bei.

Das in vorherigen Versionen dieses Paketes (<11) verwendete `pystache` kommt
nicht mehr zum Einsatz und wurde aus den Quellen entfernt.



<div id="verzeichnisstruktur"></div>

### Verzeichnisstruktur ###

* **<code>PACKAGES</code>** - erstellte Pakete
* **<code>DOWNLOAD</code>** - heruntergeladene Installationsarchive und md5sums
* **<code>BUILD</code>** - Arbeitsverzeichnis zur Erstellung der jeweiligen Pakete
* **<code>SRC</code>** - Skripte und Templates

Einige Files werden bei der Erstellung erst aus _<code>.in</code>_-Files
generiert, welche sich in den Verzeichnissen <code>SRC/OPSI</code> und <code>SRC/CLIENT_DATA</code> befinden.
Die <code>SRC</code>-Verzeichnisse sind in den OPSI-Paketen nicht mehr enthalten.


<div id="makefile_parameter"></div>

### Makefile-Parameter ###
Der vorliegende Code erlaubt die Erstellung von OPSI-Paketen fuer die Releases
gemaess der Angaben in <code>spec.json</code>. Es kann jedoch bei der Paketerstellung
ein alternatives Spec--File uebergeben werden:

> *<code>SPEC=&lt;spec_file&gt;</code>*

Das Paket kann mit *"batteries included"* erstellt werden. In dem Fall erfolgt 
der Download der Software beim Erstellen des OPSI-Paketes und nicht erst bei
dessen Installation:
> *<code>ALLINC=[true|false]</code>*

Standard ist hier die Erstellung des leichtgewichtigen Paketes (```ALLINC=false```).

Bei der Installation des Paketes im Depot wird ein eventuell vorhandenes 
```files```-Verzeichnis zunaechst gesichert und vom ```postinst```-Skript
spaeter wiederhergestellt. Diese Verzeichnis beeinhaltet die eigentlichen
Installationsfiles. Sollen alte Version aufgehoben werden, kann das ueber
einen Parameter beeinflusst werden:
> *<code>KEEPFILES=[true|false]</code>*

Standardmaessig sollen die Files geloescht werden.

OPSI erlaubt des Pakete im Format <code>cpio</code> und <code>tar</code> zu erstellen.  
Als Standard ist <code>cpio</code> festgelegt.  
Das Makefile erlaubt die Wahl des Formates ueber die Umgebungsvariable bzw. den Parameter:
> *<code>ARCHIVE_FORMAT=&lt;cpio|tar&gt;</code>*


<div id="spec_json"></div>

### spec.json ###

Haeufig beschraenkt sich die Aktualisierung eines Paketes auf das Aendern der 
Versionsnummern und des Datums etc. In einigen Faellen ist jedoch auch das Anpassen
weiterer Variablen erforderlich, die sich auf verschiedene Files verteilen.  
Auch das soll durch das Makefile vereinfacht werden. Die relevanten Variablen
sollen nur noch in <code>spec.json</code> angepasst werden. Den Rest uebernimmt *<code>make</code>*



<div id="installation"></div>

## Installation ##

Das <code>Makefile</code> erlaubt die Erstellung verschiedener Varianten des
OPSI-Paketes. Details hierzu liefert **<code>make help</code>**  
Standardmässig werden Pakete erstellt, bei denen die Software selbst <u>nicht</u>
mit dem OPSI-Paket vertrieben wird. Dennoch ist ein manueller Download der
Software hier nicht erforderlich. Bei der Installation des Paketes im Depot 
erfolgt im <code>postinst</code>-Script  der Download der Software vom Hersteller
(Windows, 32 und 64 Bit). Ensprechende Pakete sollten i.d.R. durch einen Suffix
"~dl" gekennzeichnet sein (siehe [Nomenklatur](#nomenklatur)). Beim Download
der erforderlichen Files erfolgt eine Ueberpruefung der MD5-Summen; diese sind
im OPSI-Paket hinterlegt.
Alternativ lassen sich auch *"batteries included"*-Pakete per Makefile erstellen.
In diesen ist - wie zu vermuten - die Software selbst bereits enthalten.

*"batteries included"*-Pakete und *"self download"*-Pakete sind nach der Installation
im Depot technisch identisch.

Die Aktivitaeten von <code>preinst</code> und <code>postinst</code> werden
auf dem Depot-Server in einem Logfile protokolliert. Standardmaessig (definiert
in <code>spec.json</code>) ist dieses unter 
**<code>/tmp/${PRODUCT_ID}__opsi_package_install.log</code>** zu finden.  
Hier eventuell auftretende Fehler werden an den opsi-package-manager uebergeben
und setzen das Paket in einen Fehlerzustand.


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

* **0_** oder **test_** - Es handelt sich um ein Test-Paket. Beim Uebergang zur Produktions-Release
wird der Praefix entfernt.
* **o4i_** oder **dfn_** - Das Paket ist zur Verwendung im O4I/DFN-Repository vorgesehen.

Suffix:

* **~dl** - Das Paket enthaelt die Installationsarchive selbst nicht. Diese werden
erst bei der Installation im Depot vom <code>postinst</code>-Skript heruntergeladen.  
Der Suffix ist kein Bestandteil der ProductId. Nach der Installation im Depot
gibt es hierauf keinerlei Hinweis mehr.

Die Reihenfolge der Praefixes ist relevant; die Markierung als Testpaket ist 
stets fuehrend.



<div id="unattended_switches"></div>

### Unattended-Switches ###

...gibt es derzeit beim Vivaldi-Installer nicht. Die Installation besteht daher
aus dem manuellen entpacken des Archivs und Erzeugen der Startmenueeintraege.

In der Folge gibt es auch keinen Eintrag in den Uninstall-Sektionen der Registry.  
Damit OPSI sich dennoch "orientieren" und den Installationsstatus abfragen kann, 
wird unter *<code>$PackageReg$</code>* ein Eintrag fuer derart installierte Pakete 
angelegt.



<div id="lizenzen"></div>

## Lizenzen ##


<div id="licPaket"></div>

###  Dieses Paket ###

Dieses OPSI-Paket steht unter der *GNU General Public License* **GPLv3**.

Ausgenommen von dieser Lizenz sind die unter **<code>bin/</code>** zu findenden
Hilfsprogramme. Diese unterliegen ihren jeweiligen Lizenzen.


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

Es gilt die Lizenz von [http://www.7-zip.org/license.txt](http://www.7-zip.org/license.txt).  
Die Lizenz liegt diesem Paket in <code>CLIENT_DATA/bin/</code> ebenfalls bei.



<div id="lic_vivaldi"></div>

### Vivaldi ###

Vivaldi steht unter [BSD-Lizenz](https://de.wikipedia.org/wiki/BSD-Lizenz) mit proprietären Bestandteilen.

Das verwendete Vivialdi-Logo ist gemeinfrei.  
Quelle: https://de.wikipedia.org/wiki/Vivaldi_(Browser)#/media/File:Vivaldi_web_browser_logo.svg



<div id="anmerkungen_todo"></div>

## Anmerkungen/ToDo ##

* Die vollstaendige Integration des Browsers ins System (Default-Browser, HTML-Handler, Self-Updater
erfolgt aufgrund der Art der Installation derzeit nicht).
* Die Product-Property *default_language* wird derzeit nicht ausgewertet uns ist daher deaktiviert
* Policies fuer Chromium/Vivaldi sind bislang noch nicht realisiert.

-----
Jens Boettge <<boettge@mpi-halle.mpg.de>>, 2020-08-05 10:15:37 +0200
