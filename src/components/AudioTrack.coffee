
class @AudioTrack extends E.Component
	render: ->
		{track, selection, position, playing, editor} = @props
		{clips, muted, pinned} = track
		
		E Track, {track, editor},
			E "div",
				style:
					position: "relative"
					height: 80 # = canvas height
					boxSizing: "content-box"
				onDragOver: (e)=>
					e.preventDefault()
				onDrop: (e)=>
					# @FIXME: WET, @TODO: DRY, this was copy/pasted from Tracks.coffee
					el = closest e.target, ".track-content"
					unless el
						unless closest e.target, ".track-controls"
							e.preventDefault()
							@setState selection: null
						return
					e.preventDefault()
					
					time_at = (e)->
						rect = el.getBoundingClientRect()
						(e.clientX - rect.left) / scale
					
					e.preventDefault()
					# @TODO: add multiple files in sequence, not on top of each other
					for file in e.dataTransfer.files
						editor.add_clip file, track.id, time_at e
				for clip, i in clips
					E AudioClip,
						key: clip.id
						clip: clip
						data: AudioClip.audio_buffers[clip.audio_id]
						editor: editor
						style:
							position: "absolute"
							left: clip.time * scale
							# marginTop: (i + 1) * 5
							# border: "2px dotted ##{clip.id.match /[0-9A-F]{6}/i}"
				if selection?
					E ".selection",
						key: "selection"
						className: ("cursor" if selection.end() is selection.start())
						style:
							left: scale * selection.start()
							width: scale * (selection.end() - selection.start())
				if position?
					E ".position",
						ref: (@position_indicator)=>
						key: "position"
						style:
							left: scale * position
	
	animate: ->
		@animation_frame = requestAnimationFrame => @animate()
		if @props.playing
			if @position_indicator
				position = @props.position + actx.currentTime - @props.position_time
				@position_indicator.getDOMNode().style.left = "#{scale * position}px"
	
	componentDidMount: ->
		@animate()
	
	componentWillUnmount: ->
		cancelAnimationFrame @animation_frame
