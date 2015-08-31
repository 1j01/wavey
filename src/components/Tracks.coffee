
closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no

sample_data_1 = for i in [0..50*sampleRate]
	x = i*90
	Math.sin((x/50)**0.9) * Math.sin(x**1.1) * (x**0.1) * 0.2
sample_data_2 = for i in [0..50*sampleRate]
	x = i*90
	# Math.sin((x/50)**0.9) * Math.sin(x**1.1) * 0.9 * ((x*50)%200)/200
	(
		((
			((i >> 10) & 42) * i
		) & 255) / 127 - 1
	) * 0.6

class @Tracks extends E.Component
	constructor: ->
		@state = selection: null
	render: ->
		E ".tracks",
			onMouseDown: (e)=>
				return unless e.button is 0
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
				
				tracks_el = closest e.target, ".tracks"
				track_index_at = (e)->
					# return null if not e.target?
					# track_el = closest e.target, ".track"
					# return null if not track_el?
					# ti = (_el for _el in track_el.parentElement.children).indexOf track_el
					track_index = 0
					for track_el in tracks_el.children
						rect = track_el.getBoundingClientRect()
						if e.clientY > rect.bottom
							track_index += 1
					track_index
				
				t = time_at e
				ti = track_index_at e
				@setState selection: new Selection t, t, ti, ti
				
				window.addEventListener "mousemove", onMouseMove = (e)=>
					if @state.selection
						@setState selection: Selection.drag @state.selection,
							to: time_at e
							toTrackIndex: track_index_at e
						e.preventDefault()
				
				window.addEventListener "mouseup", onMouseUp = (e)=>
					window.removeEventListener "mouseup", onMouseUp
					window.removeEventListener "mousemove", onMouseMove
			E BeatTrack, key: 0
			E AudioTrack, key: 1, data: sample_data_1, selection: (@state.selection if @state.selection?.containsTrack? 1)
			E AudioTrack, key: 2, data: sample_data_2, selection: (@state.selection if @state.selection?.containsTrack? 2)
