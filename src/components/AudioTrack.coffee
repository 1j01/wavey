
class @AudioTrack extends E.Component
	render: ->
		{selection} = @props
		at_time = (t)-> t * scale
		# E ".audio-track",
		E Track,
			E ".audio-clips",
				ref: "content"
				style: position: "relative", height: 80
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
							width: (at_time end) - (at_time start)
							height: "100%"
