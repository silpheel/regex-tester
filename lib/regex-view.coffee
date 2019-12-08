{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
xregex = require './xregex'
regex = require './regex'

module.exports =
  class RegexView extends View
    RegexEditor: null
    TestEditor: null

    @content: ->
      @div class:'regex-tester', =>
        @div class: 'header', =>
          @div class: 'name', 'RegEx Tester'
        @div class: 'body', =>
          @div class:'block flex', =>
            @div class:'editor-item flex-editor expression', =>
              @subview 'regex_data', new TextEditorView({placeholderText:'Regular Expression', softWrapped:false})
            @div =>
              @div id:'regex-type', class:'btn-group', =>
                @button outlet:'regexp', class:'btn selected', 'RegExp'
                @button outlet:'xregexp', class:'btn', 'XRegExp'
              @div id:'regex-config', =>
                @div class:'btn-group', =>
                  @button outlet:'global', class:'btn icon icon-globe'
                  @button outlet:'ignore_case', class:'btn', 'Aa'
                  @button outlet:'multiline', class:'btn icon icon-three-bars'
                @div class:'xregex-config hidden btn-group', =>
                  @button outlet:'explicit_capture', class:'btn icon icon-code'
                  @button outlet:'free_space', class:'btn', '__'
                  @button outlet:'dot_all', class:'btn', '.'
          @div class:'block flex', =>
            @div class:'input-block editor-item flex-left scroll', =>
              @subview 'test_data', new TextEditorView({placeholderText:'Test Input', softWrapped: false})
            @div class:'output editor-item flex-right scroll', outlet: 'output'

    initialize: ->
      @RegexEditor = @regex_data.getModel()
      @TestEditor = @test_data.getModel()

      @RegexEditor.setText ''
      @TestEditor.setText ''
      @find('.btn').removeClass 'selected'
      @regexp.addClass 'selected'

      @on 'click', '#regex-config .btn', (e) =>
        item = e.currentTarget
        if item.classList.contains 'selected'
          item.classList.remove 'selected'
        else
          item.classList.add 'selected'
        @update()
        @test_data.focus()

      @on 'click', '#regex-type .btn', (e) =>
        item = e.currentTarget
        if not item.classList.contains 'selected'
          @find('#regex-type .btn').removeClass('selected')
          item.classList.add 'selected'
        if @xregexp.hasClass 'selected'
          @find('.xregex-config').removeClass('hidden')
        else
          @find('.xregex-config').addClass('hidden')
        @update()
        @regex_data.focus()

      @disposables = new CompositeDisposable
      @disposables.add atom.commands.add 'atom-workspace', 'core:cancel': => @hide()
      @disposables.add atom.tooltips.add(@global, title: 'Global Match')
      @disposables.add atom.tooltips.add(@ignore_case, title: 'Ignore Case')
      @disposables.add atom.tooltips.add(@multiline, title: 'Multiline')
      @disposables.add atom.tooltips.add(@explicit_capture, title: 'Explicit capture')
      @disposables.add atom.tooltips.add(@free_space, title: 'Free-spacing and line comments')
      @disposables.add atom.tooltips.add(@dot_all, title: 'Dot matches all')
      @disposables.add atom.tooltips.add(@xregexp, title: 'Use XRegExp')

      @RegexEditor.onDidStopChanging => @update()
      @TestEditor.onDidStopChanging => @update()


    destroy: ->
      @disposables.dispose()
      @panel?.destroy()
      @panel = null

    hide: ->
      @panel?.hide()

    show: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      @panel.show()
      @regex_data.focus()

    clear: ->
      @output.html('')

    joinLines: (editor) ->
      editor.setText(editor.getText().replace(/\n/g,'\\n'))

    splitLines: (editor) ->
      editor.setText(editor.getText().replace(/\\n/g,'\n'))

    createMatchItem: (match, matchIndex) ->
      $$ ->
        @div class:'match', =>
            @div class:'key', 'Match ' + (matchIndex + 1) + ": "
            @div class:'full_match', =>
                @span class:'full_match', match.match
            @div class:'block flex', =>
                if match.named_groups?
                    @div class:'block flex-left', =>
                        @table class:'named-table match', =>
                            @tr =>
                                @th 'Named', colspan: 2
                            for k in Object.keys(match.named_groups)
                                if (k!="groups")
                                    @tr =>
                                        @td class:'key', k
                                        @td =>
                                            @div class:'match_value', =>
                                                @span class:'match_value', match.named_groups[k]
                    @div class:'block flex-left', =>
                        @table class:'positional-table match', =>
                            @tr =>
                                @th 'Positional', colspan: 2
                            for k, i in match.groups
                                @tr =>
                                    @td class:'key', '#' + (i + 1)
                                    @td =>
                                        @div class:'match_value', =>
                                            @span class:'match_value', k


    update: ->
      @clear()

      if (@RegexEditor.getText()=="")
          return
      options =
        global: @global.hasClass('selected')
        multiline: @multiline.hasClass('selected')
        ignore_case: @ignore_case.hasClass('selected')
        free_space: @free_space.hasClass('selected')
        explicit: @explicit_capture.hasClass('selected')
        dot: @dot_all.hasClass('selected')
      try
        if @xregexp.hasClass 'selected'
          m = xregex.getMatches @RegexEditor.getText(), @TestEditor.getText(), options
        else
          m = regex.getMatches @RegexEditor.getText(), @TestEditor.getText(), options
        if m?
          if m.length isnt 0
            for match, matchIndex in m
              @output.append @createMatchItem match, matchIndex
          else
            @output.html "<span class='warning'>No matches found!</span>"
        else
          @output.html ''
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
