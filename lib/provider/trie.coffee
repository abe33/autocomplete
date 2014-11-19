###
  lib/provider/trie.coffee
###

Scope = require './scope'

module.exports =
class Trie

  addWord: (word, scopeList) ->
    curNode = this
    for char, idx in word.toLowerCase()
      curNode = curNode[char] ?= {}
    list = (curNode['~'] ?= [])
    for scope in scopeList then (new Scope scope).mergeToList list
      
  addScopes: (scopeList) ->
    scopeList.sort (scope1, scope2) -> (if scope1.word > scope2.word then 1 else -1)
    list = []
    lastWord = null
    chkWordBreak = (scope) =>
      if lastWord and lastWord isnt scope.word
        @addWord lastWord, list
        list = []
    for scope in scopeList 
      chkWordBreak scope
      list.push scope
      lastWord = scope.word
    chkWordBreak {}

    # console.log 'exit addScopes', require('util').inspect (this), depth: null
    
  getResultList: (lineNum, prefix, wordFragment) ->
    resultList = []
    subTree = this
    for char in wordFragment.toLowerCase()
      if not (subTree = subTree[char]) then return
    do walkSubTree = (subTree) ->
      for char, node of subTree
        if char is '~'
          for scope in node
            scope.mergeToResultListWeighted lineNum, prefix, resultList
        else
          walkSubTree node
    resultList
    