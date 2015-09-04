
class @Controls extends E.Component
	constructor: ->
		@state = precording_menu_open: no
	render: ->
		{precording_menu_open} = @state
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
			
			E ".precording-menu-container",
				style: position: "relative", display: "inline-block"
				if precording_menu_open
					E ".precording.menu",
						style: position: "absolute"
						E ".menu-item",
							onClick: => @setState precording_menu_open: no
							"Record since 1min ago"
						E ".menu-item",
							onClick: => @setState precording_menu_open: no
							"Record since 2min ago"
						E ".menu-item",
							onClick: => @setState precording_menu_open: no
							"Record since 5min ago"
			
			E "span.linked",
				E "button.button.record",
					onClick: record
					title: "Start recording"
					E "i.icon-record"
				E "button.button.precording-dropdown",
					onClick: =>
						if precording_menu_open
							@setState precording_menu_open: no
						else
							@setState precording_menu_open: yes
							window.removeEventListener "mousedown", @_onmousedown
							window.addEventListener "mousedown", @_onmousedown = (e)=>
								unless closest e.target, ".precording-dropdown, .precording-menu-container"
									@setState precording_menu_open: no
					title: "Precording options"
					E "i.octicon.octicon-chevron-down"
	
	componentDidUpdate: ->
		unless @state.precording_menu_open
			window.removeEventListener "mousedown", @_onmousedown
