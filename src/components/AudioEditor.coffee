
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no
	render: ->
		{playing} = @state
		{themes, set_theme} = @props
		play = => @setState playing: yes
		pause = => @setState playing: no
		E ".audio-editor",
			E Controls, {playing, play, pause, themes, set_theme}
			E Tracks
