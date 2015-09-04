
class @AudioEditor extends E.Component
	constructor: ->
		@state = playing: no
	render: ->
		{playing} = @state
		play = => @setState playing: yes
		pause = => @setState playing: no
		E ".audio-editor",
			E Controls, {playing, play, pause}
			E Tracks
