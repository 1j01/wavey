
class @Controls extends E.Component
	render: ->
		{playing, play, pause, go_to_start, go_to_end, record, show_settings} = @props
		E ".controls",
			E "button.button.settings",
				style: float: "right"
				onClick: show_settings
				title: "Settings (there are none)"
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
			E "span.linked",
				E "button.button.record",
					onClick: record
					title: "Start recording"
					E "i.icon-record"
				E "button.button.prerecording-dropdown",
					title: "Recording options"
					E "i.octicon.octicon-chevron-down"
