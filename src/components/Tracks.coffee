
class @Tracks extends E.Component
	render: ->
		{tracks, position, position_time, playing, editor} = @props
		
		E ".tracks",
			# @TODO: touch support
			onMouseDown: (e)=>
				return unless e.button is 0
				el = closest e.target, ".track-content"
				unless el
					unless closest e.target, ".track-controls"
						e.preventDefault()
						editor.deselect()
					return
				e.preventDefault()
				
				time_at = (e)->
					rect = el.getBoundingClientRect()
					(e.clientX - rect.left) / scale
				
				tracks_el = closest e.target, ".tracks"
				track_index_at = (e)->
					track_index = 0
					for track_el in tracks_el.children
						rect = track_el.getBoundingClientRect()
						if e.clientY > rect.bottom
							track_index += 1
					track_index
				
				t = time_at e
				track_index = track_index_at e
				# @TODO: Shift click
				editor.select new Selection t, t, track_index, track_index
				
				mouse_moved = no
				mouse_move_from_clientX = e.clientX
				window.addEventListener "mousemove", onMouseMove = (e)=>
					if Math.abs(e.clientX - mouse_move_from_clientX) > 5
						mouse_moved = yes
					if mouse_moved and @props.selection
						editor.select Selection.drag @props.selection,
							to: time_at e
							toTrackIndex: track_index_at e
						e.preventDefault()
				
				window.addEventListener "mouseup", onMouseUp = (e)=>
					window.removeEventListener "mouseup", onMouseUp
					window.removeEventListener "mousemove", onMouseMove
					unless mouse_moved
						editor.seek t
			
			for track, track_index in tracks
				switch track.type
					when "beat"
						E BeatTrack, {key: track.id, track, editor}
					when "audio"
						E AudioTrack, {
							key: track.id, track
							position, position_time, playing, editor
							selection: (@props.selection if @props.selection?.containsTrackIndex track_index)
						}
					else
						E UnknownTrack, {key: track.id, track, editor}
