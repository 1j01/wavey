
class @TracksArea extends E.Component
	render: ->
		{tracks, position, position_time, playing, editor} = @props
		
		E ".tracks-area",
			onMouseDown: (e)=>
				return if e.isDefaultPrevented()
				unless e.button > 0
					e.preventDefault()
				if e.target is React.findDOMNode(@)
					e.preventDefault()
					editor.deselect()
			E ".tracks",
				key: "tracks"
				# @TODO: touch support
				# @TODO: double click to select either to the bounds of adjacent audio clips or everything on the track
				# @TODO: drag and drop the selection?
				# @TODO: better overall drag and drop feedback
				onMouseDown: (e)=>
					return unless e.button is 0
					el = closest e.target, ".track-content"
					if closest el, ".add-track, .unknown-track"
						e.preventDefault()
						editor.deselect()
						return
					unless el
						unless closest e.target, ".track-controls"
							e.preventDefault()
							editor.deselect()
						return
					e.preventDefault()
					
					tracks_el = closest e.target, ".tracks"
					
					time_at = (e)->
						rect = el.getBoundingClientRect()
						(e.clientX - rect.left) / scale
					
					track_index_at = (e)->
						track_index = 0
						for track_el in tracks_el.children
							rect = track_el.getBoundingClientRect()
							if e.clientY > rect.bottom
								track_index += 1
						track_index
					
					t = time_at e
					track_index = track_index_at e
					
					if e.shiftKey
						editor.select Range.drag @props.selection,
							to: t
							toTrackIndex: track_index
					else
						editor.select new Range t, t, track_index, track_index
					
					mouse_moved = no
					mouse_move_from_clientX = e.clientX
					window.addEventListener "mousemove", onMouseMove = (e)=>
						if Math.abs(e.clientX - mouse_move_from_clientX) > 5
							mouse_moved = yes
						if mouse_moved and @props.selection
							editor.select Range.drag @props.selection,
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
				
				E AddTrack, {key: "add-track", editor}
