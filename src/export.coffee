
@export_rendered_audio_buffer = (rendered_audio_buffer, file_type, number_of_channels, sample_rate)->
	# console.time "export_rendered_audio_buffer"
	
	forceDownload = (blob, filename)->
		url = (window.URL ? window.webkitURL).createObjectURL(blob)
		a = document.createElement "a"
		a.href = url
		a.download = filename ? "output.#{file_type}"
		a.click()
	
	switch file_type
		when "wav"
			worker = new Worker "lib/export/wav/recorderWorker.js"
			
			# get it started and send some config data...
			worker.postMessage
				command: "init"
				config:
					numChannels: number_of_channels
					sampleRate: sample_rate
			
			# pass it the full buffer...
			worker.postMessage
				command: "record"
				buffer:
					for i in [0...number_of_channels]
						rendered_audio_buffer.getChannelData i
			
			# ask it to export the WAV...
			worker.postMessage
				command: "exportWAV"
				type: "audio/wav"
			
			# when it's done...
			worker.onmessage = (e)=>
				forceDownload e.data, "export.wav"
				# console.timeEnd "export_rendered_audio_buffer"
		
		when "mp3"
			mp3Worker = new Worker "lib/export/mp3/lame-worker.js"
			
			mp3Worker.postMessage
				config:
					channels: 1
					sampleRate: sample_rate
					kbps: 128
				# samples: rendered_audio_buffer.getChannelData(0)
				# samples: Uint16Array.from rendered_audio_buffer.getChannelData(0)
				# samples: Uint16Array.from rendered_audio_buffer.getChannelData(0), (x)->
				# 	s = Math.max(-1, Math.min(1, x))
				# 	if s < 0 then s * 0x8000 else s * 0x7FFF
				samples: rendered_audio_buffer.getChannelData(0)

			
			mp3Worker.onmessage = (e)->
				# console.log "mp3Worker.onmessage", e.data
				mp3Blob = new Blob e.data, type: "audio/mp3"
				
				forceDownload mp3Blob, "export.mp3"
				# console.timeEnd "export_rendered_audio_buffer"
