
{E, Component} = require "../helpers.coffee"
ReactDOM = require "react-dom"
InfoBar = require "./InfoBar.coffee"
TrackControls = require "./TrackControls.coffee"
BeatTrack = require "./BeatTrack.coffee"
AudioTrack = require "./AudioTrack.coffee"
MIDITrack = require "./MIDITrack.coffee"
UnknownTrack = require "./UnknownTrack.coffee"
Range = require "../Range.coffee"
easing = require "easingjs"

module.exports =
class TracksArea extends Component
	render: ->
		{tracks, position, position_time, scale, playing, editor} = @props
		
		drag = (range, to_position, to_track_id)=>
			sorted_tracks = editor.get_sorted_tracks tracks
			from_track = track for track in sorted_tracks when track.id is range.firstTrackID()
			to_track = track for track in sorted_tracks when track.id is to_track_id
			include_tracks =
				if sorted_tracks.indexOf(from_track) < sorted_tracks.indexOf(to_track)
					sorted_tracks.slice sorted_tracks.indexOf(from_track), sorted_tracks.indexOf(to_track) + 1
				else
					sorted_tracks.slice sorted_tracks.indexOf(to_track), sorted_tracks.indexOf(from_track) + 1
			new Range range.a, Math.max(0, to_position), [range.firstTrackID()].concat(track.id for track in include_tracks when track.id isnt range.firstTrackID())
		
		select_at_mouse = (e)=>
			# TODO: DRY, parts were copy/pasted from onMouseMove
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
		
		
		document_is_basically_empty = yes
		for track in tracks when track.type isnt "beat"
			document_is_basically_empty = no
		
		
		# TODO: decide if this is the ideal or what (seems pretty decent)
		document_width_padding = window.innerWidth/2
		
		# FIXME: XXX: HACK: this is Not the Way
		HACK_InfoBar_warn = InfoBar.warn
		InfoBar.warn = ->
		document_width = (editor.get_max_length() ? 0) * scale + document_width_padding
		InfoBar.warn = HACK_InfoBar_warn
		
		E ".tracks-area",
			onMouseDown: (e)=>
				# TODO: DRY onMouseDowns
				return if e.isDefaultPrevented()
				return if e.target.closest("p")
				unless e.button > 0
					e.preventDefault()
				if e.target is ReactDOM.findDOMNode(@)
					e.preventDefault()
					editor.deselect()
					getSelection().removeAllRanges()
			E ".track-controls-area",
				key: "track-controls-area"
				for track in tracks
					switch track.type
						when "beat"
							E TrackControls, {key: track.id, track, scale, editor}
						when "audio"
							E TrackControls, {key: track.id, track, scale, editor}
						else
							# XXX: This is needed for associating the track-controls with the track
							# Could probably use aria-controls or something instead
							E ".track-controls.no-track-controls", key: track.id
			
			E ".track-content-area",
				key: "track-content-area"
				# @TODO: touch support
				# @TODO: double click to select either to the bounds of adjacent audio clips or everything on the track
				# @TODO: drag and drop the selection?
				# @TODO: better overall drag and drop feedback
				# @TODO: scroll by dragging to the left or right edges
				
				onDragOver: (e)=>
					# FIXME: lags a bit in chrome
					e.preventDefault()
					e.dataTransfer.dropEffect = "copy"
					if Math.random() < 0.5
						unless editor.state.moving_selection
							editor.setState moving_selection: yes
							window.addEventListener "dragend", dragEnd = (e)=>
								window.removeEventListener "dragend", dragEnd
								editor.setState moving_selection: no
								editor.save()
						select_at_mouse e
				
				onDragLeave: (e)=>
					editor.deselect()
				
				onDrop: (e)=>
					e.preventDefault()
					select_at_mouse e
					# TODO: add tracks in the order we get them, not by how long each clip takes to load
					# do it by making loading state placeholder track/clip representations
					# also DRY with code in AudioEditor
					for file in e.dataTransfer.files
						editor.add_clip file, yes
				
				onMouseDown: (e)=>
					# TODO: DRY onMouseDowns
					# TODO: DRY, parts were copy/pasted into select_at_mouse
					return unless e.button is 0
					track_content_el = e.target.closest(".track-content")
					track_content_area_el = e.target.closest(".track-content-area")
					if track_content_el?.closest(".timeline-independent")
						editor.deselect()
						getSelection().removeAllRanges()
						return
					unless track_content_el
						unless e.target.closest(".track-controls")
							e.preventDefault()
							editor.deselect()
						getSelection().removeAllRanges()
						return
					e.preventDefault()
					
					position_at = (e)=>
						rect = track_content_el.getBoundingClientRect()
						(e.clientX - rect.left + track_content_area_el.scrollLeft) / scale
					
					track_id_at = (e)=>
						track_el = e.target.closest(".track")
						if track_el and track_el.dataset.trackId
							track_el.dataset.trackId
						else
							track_els = ReactDOM.findDOMNode(@).querySelectorAll(".track")
							nearest_track_el = track_els[0]
							distance = Infinity
							for track_el in track_els when track_el.dataset.trackId
								rect = track_el.getBoundingClientRect()
								_distance = Math.abs(e.clientY - (rect.top + rect.height / 2))
								if _distance < distance
									nearest_track_el = track_el
									distance = _distance
							nearest_track_el.dataset.trackId
					
					position = position_at e
					track_id = track_id_at e
					
					editor.setState moving_selection: yes
					
					if e.shiftKey
						editor.select drag @props.selection, position, track_id
					else
						editor.select new Range position, position, [track_id]
					
					mouse_moved_timewise = no
					mouse_moved_trackwise = no
					starting_clientX = e.clientX
					window.addEventListener "mousemove", onMouseMove = (e)=>
						if Math.abs(e.clientX - starting_clientX) > 5
							mouse_moved_timewise = yes
						if track_id_at(e) isnt track_id
							mouse_moved_trackwise = yes
						if @props.selection and (mouse_moved_timewise or mouse_moved_trackwise)
							drag_position = if mouse_moved_timewise then position_at(e) else position
							drag_track_id = if mouse_moved_trackwise then track_id_at(e) else track_id
							editor.select drag @props.selection, drag_position, drag_track_id
							e.preventDefault()
					
					window.addEventListener "mouseup", onMouseUp = (e)=>
						window.removeEventListener "mouseup", onMouseUp
						window.removeEventListener "mousemove", onMouseMove
						unless mouse_moved_timewise
							editor.seek position
						editor.setState moving_selection: no
						editor.save()
				
				E ".document-width",
					key: "document-width"
					style:
						width: document_width
						# NOTE: it apparently needs some height to cause scrolling
						flex: "0 0 1px"
						# and we don't want some random extra height somewhere
						# so we at least try to put it at the bottom
						order: 100000
				
				if position?
					E ".position-indicator",
						key: "position-indicator"
						ref: "position_indicator"
				
				for track in tracks
					switch track.type
						when "beat"
							E BeatTrack, {key: track.id, track, scale, editor}
						when "audio"
							E AudioTrack, {
								key: track.id, track, scale, editor
								selection: (@props.selection if @props.selection?.containsTrack track)
							}
						else
							E UnknownTrack, {key: track.id, track, scale, editor}
				
				# E MIDITrack, {
				# 	key: "midi-test-track"
				# 	track: {
				# 		notes: [
				# 			{t: 0, length: 1/4, note: 65}
				# 			{t: 1/4, length: 1/4, note: 66}
				# 			{t: 2/4, length: 2/4, note: 68}
				# 		]
				# 	}
				# 	scale, editor
				# 	selection: (@props.selection if @props.selection?.containsTrack track)
				# }
				
				if document_is_basically_empty
					E ".track.getting-started.timeline-independent", {key: "getting-on-track"},
						E ".track-content",
							E "p", "To get started, hit record above or drag and drop to add some tracks."
	
	animate: ->
		{scale} = @props
		@animation_frame = requestAnimationFrame => @animate()
		
		tracks_area_el = ReactDOM.findDOMNode(@)
		tracks_area_rect = tracks_area_el.getBoundingClientRect()
		
		tracks_content_area_el = tracks_area_el.querySelector(".track-content-area")
		tracks_content_area_rect = tracks_content_area_el.getBoundingClientRect()
		
		track_els = tracks_area_el.querySelectorAll(".track")
		track_controls_els = tracks_area_el.querySelectorAll(".track-controls")
		for track_controls_el, i in track_controls_els
			track_el = track_els[i]
			track_rect = track_el.getBoundingClientRect()
			track_controls_el.style.top = "#{track_rect.top - tracks_area_rect.top + parseInt(getComputedStyle(track_el).paddingTop)}px"
		
		scroll_x = tracks_content_area_el.scrollLeft
		for track_el in track_els
			track_content_el = track_el.querySelector(".track-content > *")
			track_el.y_offset_fns ?= []
			y_offset = 0
			y_offset += fn() for fn in track_el.y_offset_fns
			track_el.style.transform = "translate(#{scroll_x}px, #{y_offset}px)"
			unless track_el.classList.contains("timeline-independent")
				track_content_el.style.transform = "translateX(#{-scroll_x}px)"
		
		if @refs.position_indicator
			position_indicator_el = @refs.position_indicator
			position = @props.position + if @props.playing then actx.currentTime - @props.position_time else 0
			any_old_track_content_el = track_el.querySelector(".track-content")
			rect = any_old_track_content_el.getBoundingClientRect()
			position_indicator_el.style.left = "#{scale * position + rect.left - tracks_content_area_rect.left}px"
			position_indicator_el.style.top = "#{tracks_content_area_el.scrollTop}px"
	
	componentWillUpdate: (next_props, next_state)=>
		# for transitioning track positions
		# get a baseline for measuring differences in track y positions
		@last_track_rects = {}
		for track_current, track_index in @props.tracks
			track_els = ReactDOM.findDOMNode(@).querySelectorAll(".track")
			track_el = track_els[track_index]
			@last_track_rects[track_current.id] = track_el.getBoundingClientRect()
	
	componentDidUpdate: (last_props, last_state)=>
		# measure differences in track y positions
		# and add track transitions
		track_els = ReactDOM.findDOMNode(@).querySelectorAll(".track")
		for track_el, track_index in track_els
			current_rect = track_el.getBoundingClientRect()
			last_rect = @last_track_rects[track_el.dataset.trackId]
			if last_rect?
				do (last_rect, current_rect)->
					delta_y = last_rect.top - current_rect.top
					if delta_y
						# add a transition
						transition_seconds = 0.3
						start_time = Date.now()
						track_el.y_offset_fns ?= []
						fn = ->
							pos = (Date.now() - start_time) / 1000 / transition_seconds
							if pos > 1
								index = track_el.y_offset_fns.indexOf(fn)
								track_el.y_offset_fns.splice(index, 1)
								return 0
							delta_y * easing.easeInOutQuart(1 - pos)
						track_el.y_offset_fns.push(fn)
		
		# update immediately to avoid one-frame artifacts
		cancelAnimationFrame @animation_frame
		@animate()
	
	componentDidMount: ->
		@animate()
	
	componentWillUnmount: ->
		cancelAnimationFrame @animation_frame
