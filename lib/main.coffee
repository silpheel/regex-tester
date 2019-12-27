RegexView = require './regex-view'
{CompositeDisposable} = require 'atom'

module.exports = RegexTester =
  RegexView: null
  regexview: null

  disposables: null

  createRegexView: ->
    @RegexView ?= require './regex-view'
    @regexview ?= new @RegexView
    @regexview.setResultPanel(@resultview)

  activate: (state) ->
    @createRegexView()
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:show': => @regexview.show()
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:hide': => @regexview.hide()
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:showresults': => @regexview.showresults()
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:hideresults': => @regexview.hideresults()

  deactivate: ->
    @disposables.dispose()
    @regexview.destroy()
    @resultview.destroy()
