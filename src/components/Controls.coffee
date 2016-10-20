
{E, Component} = require "../helpers.coffee"
DropdownButton = require "./DropdownButton.coffee"

module.exports =
class Controls extends Component
	render: ->
		{playing, recording, selection, precording_enabled, themes, set_theme, editor} = @props
		{play, pause, seek_to_start, seek_to_end, record, record_midi, stop_recording, precord, enable_precording, export_as, import_files} = editor
		
		recording_options_menu = []
		if editor.state.midi_inputs.length
			for midi_input in editor.state.midi_inputs
				do (midi_input)->
					recording_options_menu.push
						label: midi_input.name
						action: -> record_midi(midi_input)
		if recording_options_menu.length > 0
			recording_options_menu.push {type: "separator"}
		
		recording_options_menu = recording_options_menu.concat(
			if precording_enabled
				[
					{label: "Record last minute", action: -> precord 60}
					{label: "Record last 2 minutes", action: -> precord 60 * 2}
					{label: "Record last 5 minutes", action: -> precord 60 * 5}
					{label: "Disable precording", action: -> enable_precording 0}
				]
			else
				[
					{label: "Enable precording", action: -> enable_precording 60 * 5}
				]
		)
		
		E ".controls",
			# role: "menubar"
			# @TODO: left/right arrow keys?
			# maybe a key (Esc, probably) to unfocus the controls and allow the normal keyboard shortcuts
			E ".playback-controls",
				E "button.button.play-pause",
					class: if playing then "pause" else "play"
					title: if playing then "Pause" else "Play"
					onClick: if playing then pause else play
					E "i.icon-#{if playing then "pause" else "play"}"
				E "span.linked",
					E "button.button.go-to-start",
						onClick: seek_to_start
						title: "Go to start"
						E "i.icon-go-to-start"
					E "button.button.go-to-end",
						onClick: seek_to_end
						title: "Go to end"
						E "i.icon-go-to-end"
				E DropdownButton,
					mainButton:
						if recording
							E "button.button.record",
								onClick: stop_recording
								title: "Stop recording"
								E "i.icon-stop"
						else
							E "button.button.record",
								onClick: record
								title: "Start recording"
								E "i.icon-record"
					title: "Recording options"
					menu: recording_options_menu
			E ".document-controls",
				E "button.button",
					title: "Import tracks"
					onClick: import_files
					E "i.icon-import"
				E DropdownButton,
					title: "Export"
					menu: [
						{label: "Export as MP3", action: -> export_as "mp3"}
						{label: "Export as WAV", action: -> export_as "wav"}
						{type: "separator"}
						{label: "Export selection as MP3", enabled: selection?.length(), action: -> export_as "mp3", selection}
						{label: "Export selection as WAV", enabled: selection?.length(), action: -> export_as "wav", selection}
					]
					E "i.icon-export"
				if themes and set_theme
					E DropdownButton,
						title: "Settings"
						menu:
							for name, id of themes
								do (name, id)->
									label: name
									action: -> set_theme id
						E "i.icon-gear"
