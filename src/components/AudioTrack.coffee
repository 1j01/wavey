
class @AudioTrack extends E.Component
	render: ->
		{selection} = @props
		at_time = (t)-> t * scale
		E ".track.audio-track",
			E TrackControls
			E ".track-content",
				ref: "content"
				style: position: "relative", height: 80, boxSizing: "content-box" # 80 = canvas height
				E AudioClip, data: @props.data, style: position: "absolute", left: 0
				if selection
					E ".selection",
						style:
							position: "absolute"
							left: (at_time selection.start())
							top: 0
							width: (at_time selection.end()) - (at_time selection.start())
							height: "100%"
