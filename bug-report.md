
I'm getting an error often although Atom seems to keep working.  This is new to 145

---
## Error

```
TypeError: undefined is not a function
  at C:\apps\autocomplete\lib\responder-io.coffee:27:28
  at Emitter.module.exports.Emitter.emit (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\event-kit\lib\emitter.js:71:11)
  at c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane-container.js:342:34
  at Emitter.module.exports.Emitter.emit (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\event-kit\lib\emitter.js:71:11)
  at Pane.module.exports.Pane.setActiveItem (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:254:22)
  at Pane.module.exports.Pane.activateItem (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:318:21)
  at Pane.module.exports.Pane.activateItemAtIndex (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:312:19)
  at Pane.module.exports.Pane.activatePreviousItem (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:283:21)
  at Pane.module.exports.Pane.removeItem (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:383:16)
  at Pane.module.exports.Pane.destroyItem (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\pane.js:436:16)
  at PaneView._results.push._this.(anonymous function) [as destroyItem] (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\delegato\lib\delegator.js:67:61)
  at HTMLDivElement.<anonymous> (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\tabs\lib\tab-bar-view.js:169:22)
  at HTMLDivElement.handler (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\src\space-pen-extensions.js:110:34)
  at HTMLUListElement.jQuery.event.dispatch (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\space-pen\vendor\jquery.js:4681:9)
  at HTMLUListElement.elemData.handle (c:\Chocolatey\lib\atom.0.145.0\tools\atom\resources\app\node_modules\space-pen\vendor\jquery.js:4359:46)

```

## Repro Steps

1. [First Step]
2. [Second Step]
3. [and so on...]

**Expected:** [Enter expected behavior here]
**Actual:** [Enter actual behavior here]

## Command History:
```
     -0:06.5 editor:display-updated (atom-text-editor.editor.editor-colors)
     -0:05.0 cursor:moved (atom-text-editor.editor.editor-colors)
     -0:05.0 selection:changed (atom-text-editor.editor.editor-colors)
  2x -0:05.0 editor:display-updated (atom-text-editor.editor.editor-colors)
     -0:00.9 pane:before-item-destroyed (atom-pane.pane.active)
     -0:00.9 pane-container:active-pane-item-changed (atom-pane-container.panes)
     -0:00.0 Uncaught TypeError: undefined is not a function
```

## Versions
* **Atom:**       0.145.0
* **Atom-Shell:** 0.19.1
* **OS:**         Microsoft Windows 8.1 Pro with Media Center
* **Misc**
  * apm  0.111.0
  * npm  1.4.4
  * node 0.10.33
  * python 2.7.5
  * git 1.7.11.msysgit.1
  * visual studio 2013

---

<small>This report was created in and posted from the Atom editor using the package `bug-report` version 0.4.1.</small>