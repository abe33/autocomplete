`ctrl-alt-O` threw this error ..

---
## Error

```
SyntaxError: Invalid regular expression: /]*([A-Za-z_$][A-Za-z0-9_$]+)?[ /: Unterminated character class
  at new RegExp (native)
  at RegExp (native)
  at String.search (native)
  at TagParser.module.exports.TagParser.buildMissedParent (c:\Users\Administrator\.atom\packages\symbols-tree-view\lib\tag-parser.coffee:46:18)
  at TagParser.module.exports.TagParser.parse (c:\Users\Administrator\.atom\packages\symbols-tree-view\lib\tag-parser.coffee:72:8)
  at c:\Users\Administrator\.atom\packages\symbols-tree-view\lib\symbols-tree-view.coffee:49:24
  at _fulfilled (c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\q\q.js:787:54)
  at Promise.then.self.promiseDispatch.done (c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\q\q.js:816:30)
  at Promise.promise.promiseDispatch (c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\q\q.js:749:13)
  at c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\q\q.js:557:44
  at flush (c:\Chocolatey\lib\atom.0.146.0\tools\atom\resources\app\node_modules\q\q.js:108:17)
  at process._tickCallback (node.js:378:11)

```

## Command History:
```
     -0:07.2 pane:active-item-changed (atom-pane.pane.active)
     -0:07.2 uri-opened (atom-workspace.workspace.scrollbars-visible-always.theme-atom-light-syntax.theme-atom-light-ui)
  3x -0:07.1 editor:display-updated (atom-text-editor.editor.editor-colors)
     -0:06.3 cursor:moved (atom-text-editor.editor.editor-colors)
     -0:06.3 selection:changed (atom-text-editor.editor.editor-colors)
  4x -0:06.3 editor:display-updated (atom-text-editor.editor.editor-colors)
     -0:04.8 symbols-tree-view:toggle (input.hidden-input)
  9x -0:04.8 editor:display-updated (atom-text-editor.editor.editor-colors)
     -0:00.0 Uncaught SyntaxError: Invalid regular expression: /]*([A-Za-z_$][A-Za-z0-9_$]+)?[ /: Unterminated character class
```

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