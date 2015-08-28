
class @Tracks extends E.Component
	render: ->
		E ".tracks",
			E BeatTrack, key: 1
			E AudioTrack, key: 2
			E AudioTrack, key: 3
