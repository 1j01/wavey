
class @Controls extends E.Component
	render: ->
		{playing, recording, selection, precording_enabled, themes, set_theme, editor} = @props
		{play, pause, seek_to_start, seek_to_end, record, stop_recording, precord, enable_precording, export_as} = editor
		E ".controls",
			# role: "menubar"
			# @TODO: left/right arrow keys?
			# maybe a key (Esc, probably) to unfocus the controls and allow the normal keyboard shortcuts
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
				title: "Precording options"
				menu:
					if precording_enabled
						[
							{label: "Record last minute", action: -> precord 60}
							{label: "Record last 2 minutes", action: -> precord 60 * 2}
							{label: "Record last 5 minutes", action: -> precord 60 * 5}
						]
					else
						[
							{label: "Enable precording", action: -> enable_precording 60 * 5}
						]
			E "span.floated", style: float: "right",
				E DropdownButton,
					title: "Export"
					menu: [
						{label: "Export as MP3", action: -> export_as "mp3"}
						{label: "Export as WAV", action: -> export_as "wav"}
						{label: "Export selection as MP3", action: -> export_as "mp3", selection} if selection?.length()
						{label: "Export selection as WAV", action: -> export_as "wav", selection} if selection?.length()
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
