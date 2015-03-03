# [Lightbeats](http://www.lightbeats.cz/)

Lightbeats je aplikace napsaná v [Processingu](https://processing.org/) pro tracking svítících žonglovacích míčků a vizualizaci jejich trajektorií.

## Instalace
Pro spuštění Lightbeats je potřeba [Processing](https://processing.org/download/?processing). Projekt využívá knihovny [JMyron](http://webcamxtra.sourceforge.net/download.shtml) a [ControlP5](http://www.sojamo.de/libraries/controlP5/), pro jejich instalaci se řiďte instrukcemi na jejich stránkách.

## Použití
Otevřete lightbeats.pde v Processingu a spustťe. Aplikace vyžaduje připojenou webkameru. Pro nejlepší výsledky program používejte v temném prostředí.

### Klávesové zkratky
* **ESC**: Ukončení programu.
* **D**: Zapnutí/vypnutí debug módu. Vhodné pro kalibraci při prvním použití.
* **C**: Zapnutí/vypnutí nahrávání obrazovky. Snímky jsou ukládány ve formátu tga do složky `frames/`.
* **Mezerník**: Uložení aktuálního snímku.

### Nastavení
Globální nastavení programu naleznete v hlavičce souboru `lightbeats.pde`.

## Struktura kódu
Program na každé zavolání `draw()` funkce získá seznam _globů_ z instance JMyron. Ten pak program předává instanci třídy `Balls`, která jednotlivé _globy_ identifikuje a zařadí již jako `State` do správných `Ball`.

Po třídění následuje vizualizace instancí třídy `Renderer`.

## Screenshoty!
![Animace z Lightbeats](http://kukas.homenet.org/lightbeats/animated.gif "Kachny!")

![Screenshot z debug módu](http://kukas.homenet.org/lightbeats/debug.jpg "Debug mód")

![Screenshot vizualizace stop míčků](http://kukas.homenet.org/lightbeats/snail.jpg "Vizualizace stop")
