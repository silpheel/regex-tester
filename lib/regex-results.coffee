{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
xregex = require './xregex'
regex = require './regex'

module.exports =
  class ResultView extends View
    RegexResults: null

    @content: ->
      @div class:'result-main', =>
        @div class:'output editor-item flex-right scroll', outlet: 'output'
        @div class:'regex-config', =>
          @button id:'help-test', "Test me"
          @div class:'help-1', 'woohoo'
          # @div id:'help', class:'btn-group', =>
          #   @button outlet:'showtest', class:'btn collapsible', 'Test'
          # @div id:"helptest", class:'hidden', =>
          #   @helpblock

    show: =>
      @panel ?= atom.workspace.add.addRightPanel(item: this)
      @panel.show()

    hide: =>
      @panel?.hide()

    initialize: ->
      @find('.btn').removeClass 'selected'

      @on 'click', '#help-test', (e) =>
        item = e.currentTarget
        if item.classList.contains 'selected'
          @find('.help-1').addClass('hidden')
          item.classList.remove 'selected'
        else
          @find('.help-1').removeClass('hidden')
          item.classList.add 'selected'
