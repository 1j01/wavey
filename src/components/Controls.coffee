
class @Controls extends E.Component
	render: ->
		{playing, play, pause, go_to_start, go_to_end, record, themes, set_theme} = @props
		E ".controls",
			if themes and set_theme
				E "span",
					style: float: "right"
					E DropdownButton,
						title: "Settings"
						menu:
							for name, id of themes
								do (name, id)->
									label: name
									action: -> set_theme id
						E "i.icon-gear"
			E "button.button.play-pause",
				class: if playing then "pause" else "play"
				title: if playing then "Pause" else "Play"
				onClick: if playing then pause else play
				E "i.icon-#{if playing then "pause" else "play"}"
			E "span.linked",
				E "button.button.go-to-start",
					onClick: go_to_start
					title: "Go to start"
					E "i.icon-go-to-start"
				E "button.button.go-to-end",
					onClick: go_to_end
					title: "Go to end"
					E "i.icon-go-to-end"
			E DropdownButton,
				mainButton: E "button.button.record",
					onClick: record
					title: "Start recording"
					E "i.icon-record"
				title: "Precording options"
				menu: [
					{label: "Record last minute", action: -> record 60}
					{label: "Record last 2 minutes", action: -> record 60 * 2}
					{label: "Record last 5 minutes", action: -> record 60 * 5}
				]
