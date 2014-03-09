{BufferedProcess} = require('atom')
fs = require('fs')
temp = require("temp").track()

module.exports =
  activate: ->
    atom.workspaceView.command "gofmt:gofmt", => @fmt()

    # add save hooks
    atom.project.eachEditor (editor) =>
      @addSaveHook(editor)

    atom.subscribe atom.project, 'editor-created', (editor) =>
      @addSaveHook(editor)

  addSaveHook: (editor) ->
    atom.subscribe editor.getBuffer(), 'will-be-saved', => @fmt()

  fmt: ->
    editor = atom.workspace.activePaneItem
    # Only process .go files.
    return unless /\.go$/.exec(editor.getUri())

    code = editor.getText()

    temp.open ".go", (err, info) ->
      fs.write(info.fd, code)
      fs.close(info.fd, ->)
      args = [info.path]
      fail = false

      stdout = (output) ->
        return if fail
        editor.setText(output)

      stderr = (output) ->
        console.log("Error running gofmt: " + output)
        fail = true

      command = "/usr/local/bin/gofmt"
      new BufferedProcess({command, args, stdout, stderr})
