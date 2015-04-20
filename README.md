# Lightbeats

Lightbeats je aplikace napsaná v [Processingu](https://processing.org/) pro tracking svítících žonglovacích míčků webkamerou a vizualizaci jejich trajektorií.

- **Propagační web:** [www.lightbeats.cz](http://www.lightbeats.cz/)  
- **Ukázka:** [screenshoty](https://github.com/kukas/Lightbeats/#screenshoty)
- **Download:** [link na release](https://github.com/kukas/Lightbeats/releases)
- **Dokumentace:** [uživatelská i programátorská dokumentace](https://github.com/kukas/Lightbeats/blob/master/docs/lightbeats_dokumentace.pdf)
- **Repozitář:** [kukas/Lightbeats](http://github.com/kukas/Lightbeats) + [fork](http://github.com/gjkcz/Lightbeats) se stavem maturitní práce
- **Autor:** [Jiří Balhar](http://kukas.homenet.org/)
- **Maturitní práce 2014/15** na [GJK](https://github.com/gjkcz/gjkcz)

## Dokumentace pro uživatele
### Instalace
Pro spuštění Lightbeats je potřeba [Processing](https://processing.org/download/?processing). Projekt využívá knihovny [JMyron](http://webcamxtra.sourceforge.net/download.shtml), [ControlP5](http://www.sojamo.de/libraries/controlP5/) a [CL-Eye SDK](https://codelaboratories.com/about/), pro jejich instalaci se řiďte instrukcemi na jejich stránkách, případně využijte připravené knihovny ve složce `libraries` (složku překopírujte do složky `Dokumenty/Processing/`). Knihovna CL-Eye je komerční, pro použití programu s kamerou PS3Eye je nutné zakoupit driver a SDK na oficiálním webu.

### Spuštění
Otevřete lightbeats.pde v Processingu a spustťe. Aplikace vyžaduje připojenou webkameru. Pro nejlepší výsledky program používejte v temném prostředí.
Lightbeats má dva základní pohledy. Debug mód, který je přizpůsobený pro nastavení kamery a ladění parametrů pro hledání míčků, a prezentační mód, ve kterém se trackované míčky vizualizují. Ve výchozím nastavení je po spuštění programu zapnut debug mód. Do prezentačního módu lze přepnout stisknutím klávesy D.

#### Základní nastavení
Nastavit aplikaci je možné pouze při zapnutém debug módu. V levém horním rohu obrazovky se nachází tlačítka pro přepínání jednotlivých záložek nastavení. Pro základní nastavení aplikace stačí měnit nastavení v kategorii _camera settings_, případně v _other_. Pod přepínačem záložek se nachází také tlačítko pro uložení aktuálního nastavení.

Podrobnější popis nastavení naleznete v [dokumentaci](https://github.com/kukas/Lightbeats/blob/master/docs/lightbeats_dokumentace.pdf)

#### Klávesové zkratky
* **ESC**: Ukončení programu.
* **D**: Zapnutí/vypnutí debug módu. Vhodné pro kalibraci při prvním použití.
* **C**: Zapnutí/vypnutí nahrávání obrazovky. Snímky jsou ukládány ve formátu tga do složky `frames/`.
* **Mezerník**: Uložení aktuálního snímku.

## Dokumentace pro programátory
### Příprava prostředí
Program stačí nainstalovat pro spuštění (viz Dokumentace pro uživatele - Instalace), další příprava pro úpravu kódu není potřeba.

### Struktura kódu
Program na každé zavolání `draw()` funkce získá seznam _globů_ z instance třídy Myron (`myron.pde`). Ten pak program předává instanci třídy `Balls` (`balls.pde`), která jednotlivé _globy_ identifikuje a zařadí již jako `State` (`state.pde`) do správných `Ball` (`ball.pde`).
Třída `Finder` (`finder.pde`) obsahuje algoritmus pro přesné hledání kružnic pomocí pixelových hranic _globů_, nalezené kružnice se využívají v `Balls` při třídění.

Po třídění následuje vizualizace instancí třídy `Renderer` (`renderer.pde`).

Podrobnější popis algoritmu naleznete v [dokumentaci](https://github.com/kukas/Lightbeats/blob/master/docs/lightbeats_dokumentace.pdf)

## Screenshoty!
![Animace z Lightbeats](http://kukas.homenet.org/lightbeats/animated.gif "Kachny!")

![Screenshot z debug módu](http://kukas.homenet.org/lightbeats/debug.jpg "Debug mód")

![Screenshot vizualizace stop míčků](http://kukas.homenet.org/lightbeats/snail.jpg "Vizualizace stop")
