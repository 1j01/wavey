
{E} = require "../helpers.coffee"
Track = require "./Track.coffee"
AudioClip = require "./AudioClip.coffee"
Range = require "../Range.coffee"

module.exports =
class AudioTrack extends E.Component
	render: ->
		{track, selection, position, scale, playing, editor} = @props
		{clips, muted, pinned} = track
		
		select_at_mouse = (e)=>
			# FIXME: WET, TODO: DRY, NOTE: this was copy/pasted from Tracks::onMouseMove
			track_content_el = e.target.closest(".track-content")
			track_content_area_el = e.target.closest(".track-content-area")
			return unless track_content_el?
			
			track_el = e.target.closest(".track")
			
			position_at = (e)=>
				rect = track_content_el.getBoundingClientRect()
				(e.clientX - rect.left + track_content_area_el.scrollLeft) / scale
			
			track_id_at = (e)->
				track_el = e.target.closest(".track")
				track_el.dataset.trackId
			
			position = position_at e
			track_id = track_id_at e
			
			editor.select new Range position, position, [track_id]
		
		E Track, {track, editor},
			E ".audio-clips",
				style:
					position: "relative"
					height: 80 # = canvas height
					boxSizing: "content-box"
				
				onDragOver: (e)=>
					# FIXME: incredible lag
					e.preventDefault()
					e.dataTransfer.dropEffect = "copy"
					select_at_mouse e
				
				onDragLeave: (e)=>
					editor.deselect()
				
				onDrop: (e)=>
					e.preventDefault()
					select_at_mouse e
					# @TODO: order by position in this array, not by how long each clip takes to load
					for file in e.dataTransfer.files
						editor.add_clip file, yes
				
				for clip, i in clips
					recording = AudioClip.recordings[clip.recording_id]
					recording_length =
						if recording?
							if recording.length?
								recording.length
							else
								one_channel = recording.chunks[0]
								num_chunks = one_channel.length
								if num_chunks > 0
									chunk_size = one_channel[0].length
									chunk_size * num_chunks / recording.sample_rate
								else
									0
					
					E AudioClip,
						key: clip.id
						length: clip.length ? recording_length
						offset: clip.offset ? 0
						scale: scale
						sample_rate:
							if clip.recording_id?
								recording?.sample_rate
							else
								AudioClip.audio_buffers[clip.audio_id]?.sampleRate
						data:
							if clip.recording_id?
								if recording?
									recording.chunks
								else
									null
							else
								AudioClip.audio_buffers[clip.audio_id]
						editor: editor
						style:
							position: "absolute"
							left: clip.position * scale
							# marginTop: (i + 1) * 2
							# border: "2px dotted ##{clip.id.match /[0-9A-F]{6}/i}"
				if selection?
					E ".selection",
						key: "selection"
						className: ("cursor" if selection.end() is selection.start())
						style:
							left: scale * selection.start()
							width: scale * (selection.end() - selection.start())
	
	animate: ->
		{scale} = @props
		@animation_frame = requestAnimationFrame => @animate()
		if @props.playing
			if @refs.position_indicator
				position = @props.position + actx.currentTime - @props.position_time
				@refs.position_indicator.style.left = "#{scale * position}px"
	
	componentDidMount: ->
		@animate()
	
	componentWillUnmount: ->
		cancelAnimationFrame @animation_frame
