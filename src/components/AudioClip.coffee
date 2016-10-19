
{E, Component} = require "../helpers.coffee"
InfoBar = require "./InfoBar.coffee"
audio_clips = require "../audio-clips.coffee"

localforage = require "localforage"

module.exports =
class AudioClip extends Component
	render: ->
		{data, sample_rate, length, offset, scale, position} = @props
		
		if data instanceof Array
			typed_arrays = data[0]
			chunk_length = typed_arrays[0]?.length
		else if data
			audio_buffer = data
			typed_array = audio_buffer.getChannelData 0
			chunk_length = 500
			typed_arrays =
				for i in [0..data.length] by chunk_length
					typed_array.subarray i, i + chunk_length
		
		width = (length ? 0) * scale
		height = 80 # = .track-content {height}
		
		# @TODO: visualize multiple channels
		
		E "svg.audio-clip", {
			style:
				position: "absolute"
				left: position * scale
			width, height
			data: {length}
			xmlns: "http://www.w3.org/svg/2000"
			viewBox: "0 0 #{width} #{height}"
			# bufferedRendering: "static"
		},
			if width
				at = (x)->
					len = typed_arrays[0]?.length
					idx = ~~((x/scale + offset) * sample_rate)
					typed_arrays[idx // len]?[idx % len]
				
				key = 0
				for chunk_x in [0..width] by chunk_length / scale
					pathdata = []
					for x in [0..chunk_length/scale] by 0.1
						v = at(chunk_x + x)
						if v?
							y = height * (v + 1) / 2
							pathdata.push "#{if x is 0 then "M" else "L"}#{(chunk_x + x).toFixed(2)} #{~~y}"
					key += 1
					E "path", {key, d: pathdata.join("")}
	
	shouldComponentUpdate: (last_props)->
		@props.data isnt last_props.data or
		@props.offset isnt last_props.offset or
		@props.length isnt last_props.length or
		@props.position isnt last_props.position or
		@props.scale isnt last_props.scale
