
{GUID, get_clip_start_end} = require "./helpers.coffee"
{stuff_version} = require "./versions.coffee"

module.exports =
class Range
	constructor: (@a, @b = @a, @track_ids = [])->
		unless @track_ids instanceof Array
			throw new Error "new Range(#{(JSON.stringify a for a in arguments).join ", "}): third argument must be an array of track IDs"
	
	# @TODO: rename start/end to startPosition/endPosition?
	# and maybe have start/end methods that return a new Range at the start/end
	# Would that even be useful?
	start: -> Math.min(@a, @b)
	end: -> Math.max(@a, @b)
	length: -> @end() - @start()
	
	# XXX?: these methods that take sorted tracks are kinda weird
	
	firstTrack: (sorted_tracks)->
		for track in sorted_tracks
			return track if track.id in @track_ids
	
	lastTrack: (sorted_tracks)->
		for track in sorted_tracks by -1
			return track if track.id in @track_ids
	
	firstTrackID: (sorted_tracks)->
		if sorted_tracks
			@firstTrack(sorted_tracks).id
		else
			@track_ids[0]
	
	lastTrackID: (sorted_tracks)->
		if sorted_tracks
			@lastTrack(sorted_tracks).id
		else
			@track_ids[@track_ids.length - 1]
	
	containsTrack: (track)->
		@track_ids.indexOf(track.id) isnt -1
	
	contents: (tracks)->
		# returns stuff from tracks within this range
		
		stuff = {version: stuff_version, length: @length(), rows: []}
		
		for track in tracks when track.type is "audio" and @containsTrack track
			clips = []
			for clip in track.clips
				{clip_start, clip_end} = get_clip_start_end clip
				if @start() < clip_end and @end() > clip_start
					# clip and selection overlap
					if @start() <= clip_start and @end() >= clip_end
						# clip is entirely contained within selection
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: clip_start - @start()
							length: clip.length
							offset: clip.offset
					else if @start() > clip_start and @end() < clip_end
						# selection is entirely within clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: 0
							length: @length()
							offset: clip.offset - clip_start + @start()
					else if @start() < clip_end <= @end()
						# selection overlaps end of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: 0
							length: clip_end - @start()
							offset: clip.offset - clip_start + @start()
					else if @start() <= clip_start < @end()
						# selection overlaps start of clip
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: clip_start - @start()
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
				{clip_start, clip_end} = get_clip_start_end clip
				if @start() < clip_end and @end() > clip_start
					if @start() > clip_start
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: clip_start
							length: @start() - clip_start
							offset: clip.offset
					if @end() < clip_end
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: @start()
							length: clip_end - @end()
							offset: clip.offset + @end() - clip_start
				else
					if clip_start >= @end()
						clip.position -= @length()
					clips.push clip
			track.clips = clips
		
		new Range @start(), @start(), @track_ids
	
	# @TODO? maybe there should be a class for "Stuff"
	# (this would be Stuff::insert)
	@insert: (stuff, insertion_position, start_track_id, tracks, sorted_tracks)->
		rows = (row for row in stuff.rows when row.length > 0)
		
		sorted_track_ids = (track.id for track in sorted_tracks)
		track_ids =
			if start_track_id
				sorted_track_ids.slice sorted_track_ids.indexOf(start_track_id)
			else
				[]
		while track_ids.length < rows.length
			new_track = {id: GUID(), type: "audio", clips: []}
			tracks.push new_track
			track_ids.push new_track.id
		
		for track in tracks when track.type is "audio" and track.id in track_ids
			row = rows[track_ids.indexOf track.id]
			if row
				clips = []
				
				for clip in track.clips
					{clip_start, clip_end} = get_clip_start_end clip
					if clip_start >= insertion_position
						clip.position += stuff.length
						clips.push clip
					else if clip_end > insertion_position
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: clip_start
							length: insertion_position - clip_start
							offset: clip.offset
						clips.push
							id: GUID()
							audio_id: clip.audio_id
							recording_id: clip.recording_id
							position: insertion_position + stuff.length
							length: clip_end - insertion_position
							offset: clip.offset + insertion_position - clip_start
					else
						clips.push clip
				
				for clip in row
					clip.position += insertion_position
					clip.id = GUID()
					clips.push clip
				
				track.clips = clips
		
		end = insertion_position + stuff.length
		new Range end, end, track_ids
	
	@fromJSON: (range)->
		new Range range.a, range.b, range.track_ids
