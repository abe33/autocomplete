After loading 146 I have a problem starting atom.  I use `atom --dev .` in my console and instead of just starting atom it shows debug stuff I'm not familiar with and never returns to a prompt.  It runs in the foreground instead of separately.  This also happens in safe mode.

This is what I see ...

```
C:\apps\autocomplete>App load time: 246ms
[9516:1113/150212:INFO:renderer_main.cc(204)] Renderer process started
[9652:1113/150214:INFO:CONSOLE(92)] "Download the React DevTools for a better development experience: http://fb.me/react-devtools"
, source: c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\react-atom-fork\lib\React.js (92)
[9652:1113/150218:INFO:CONSOLE(46)] "Window load time: 4921ms", source: file:///C:/Chocolatey/lib/atom.0.146.0/tools/atom/resource
s/app/static/index.js (46)
[9652:1113/150219:INFO:CONSOLE(63)] "RESPONDER:", source: C:\apps\autocomplete\js\api.js (63)
[9652:1113/150219:INFO:CONSOLE(63)] "RESPONDER:", source: C:\apps\autocomplete\js\api.js (63)
[9652:1113/150219:INFO:CONSOLE(63)] "RESPONDER:", source: C:\apps\autocomplete\js\api.js (63)
```

---

## Repro Steps

1. cd to project directory
2. `atom --dev .`

**Expected:** Return to prompt and load atom
**Actual:** see above

## Versions
* **Atom:**       0.146.0
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