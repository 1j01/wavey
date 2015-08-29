
class @AudioTrack extends E.Component
	render: ->
		{selection} = @props
		at_time = (t)-> t * scale
		E ".track.audio-track",
			E TrackControls
			E ".track-content",
				ref: "content"
				style: position: "relative", height: 80, boxSizing: "content-box" # 80 = canvas height
				E AudioClip, style: position: "absolute", left: 0
				if selection
					if selection[0] < selection[1]
						[start, end] = selection
					else
						[end, start] = selection
					start = Math.max(0, start)
					end = Math.max(0, end)
					E ".selection",
						style:
							position: "absolute"
							left: at_time start
							top: 0
							width: (at_time end) - (at_time start)
							height: "100%"
