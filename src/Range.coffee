
class @Range
	constructor: (@a, @b = @a, @track_ids = [])->
		unless @track_ids instanceof Array
			throw new Error "new Range(#{(JSON.stringify a for a in arguments).join ", "}): third argument must be an array of track IDs"
	# @TODO: rename start/end to startTime/endTime
	# and maybe have start/end methods that return a new Range at the start/end
	start: -> Math.min(@a, @b)
	end: -> Math.max(@a, @b)
	length: -> @end() - @start()
	containsTime: (time)-> @start() <= time <= @end()
	firstTrackID: -> @track_ids[0]
	lastTrackID: -> @track_ids[@track_ids.length - 1]
	containsTrack: (track)-> @track_ids.indexOf(track.id) isnt -1
	
	contents: (tracks)->
		# returns stuff from tracks within this range
		
		stuff = {version: AudioEditor.stuff_version, length: @length(), rows: []}
		
		for track in tracks when track.type is "audio" and @containsTrack track
			clips = []
			for clip in track.clips
				# buffer = AudioClip.audio_buffers[clip.audio_id]
				# unless buffer?
				# 	InfoBar.warn "Not all selected tracks have finished loading."
				# 	return
				{clip_start, clip_end} = get_clip_start_end clip
				if @start() < clip_end and @end() > clip_start
					# clip and selection overlap
					if @start() <= clip_start and @end() >= clip_end
						# clip is entirely contained within selection
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: clip_start - @start()
							length: clip.length
							offset: clip.offset
					else if @start() > clip_start and @end() < clip_end
						# selection is entirely within clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: 0
							length: @length()
							offset: clip.offset - clip_start + @start()
					else if @start() < clip_end <= @end()
						# selection overlaps end of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: 0
							length: clip_end - @start()
							offset: clip.offset - clip_start + @start()
					else if @start() <= clip_start < @end()
						# selection overlaps start of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: clip_start - @start()
							length: @end() - clip_start
							offset: clip.offset
			stuff.rows.push clips
		
		stuff
	
	collapse: (tracks)->
		# modifies tracks, removing everything within this range
		# returns a collapsed range
		
		for track in tracks when track.type is "audio" and @containsTrack track
			clips = []
			for clip in track.clips
				# buffer = AudioClip.audio_buffers[clip.audio_id]
				# unless buffer?
				# 	InfoBar.warn "Not all selected tracks have finished loading."
				# 	return
				{clip_start, clip_end} = get_clip_start_end clip
				if @start() < clip_end and @end() > clip_start
					if @start() > clip_start
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: clip_start
							length: @start() - clip_start
							offset: clip.offset
					if @end() < clip_end
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							time: @start()
							length: clip_end - @end()
							offset: clip.offset + @end() - clip_start
				else
					if clip_start >= @end()
						clip.time -= @length()
					clips.push clip
			track.clips = clips
		
		new Range @start(), @start(), @track_ids
	
	# @TODO? maybe there should be a class for "Stuff"
	# (this would be Stuff::insert)
	@insert: (stuff, tracks, insertion_position, insertion_track_start_index)->
		
		insertion_length = stuff.length
		insertion_track_end_index = insertion_track_start_index + stuff.rows.length - 1
		
		for track in tracks.slice(insertion_track_start_index, insertion_track_end_index + 1) when track.type is "audio"
			clips = []
			for clip in track.clips
				{clip_start, clip_end} = get_clip_start_end clip
				if clip_start >= insertion_position
					clip.time += insertion_length
					clips.push clip
				else if clip_end > insertion_position
					clips.push
						id: GUID()
						audio_id: clip.audio_id
						recording_id: clip.recording_id
						time: clip_start
						length: insertion_position - clip_start
						offset: clip.offset
					clips.push
						id: GUID()
						audio_id: clip.audio_id
						recording_id: clip.recording_id
						time: insertion_position + insertion_length
						length: clip_end - insertion_position
						offset: clip.offset + insertion_position - clip_start
				else
					clips.push clip
			track.clips = clips
		
		track_ids = []
		for clips, i in stuff.rows
			# @TODO @FIXME: go in visual order of tracks
			track = tracks[insertion_track_start_index + i]
			# @TODO: handle (skip over) non "audio" type tracks
			if not track? and clips.length
				track = {id: GUID(), type: "audio", clips: []}
				tracks.push track
			
			track_ids.push track.id
			
			for clip in clips
				clip.time += insertion_position
				clip.id = GUID()
				track.clips.push clip
		
		end = insertion_position + insertion_length
		new Range end, end, track_ids
	
	@fromJSON: (range)->
		new Range range.a, range.b, range.track_ids
