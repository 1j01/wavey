
module.exports =
export_audio_buffer_as = (audio_buffer, file_type, number_of_channels, sample_rate)->
	
	number_of_channels ?= audio_buffer.numberOfChannels
	sample_rate ?= audio_buffer.sampleRate
	
	forceDownload = (blob, file_name)->
		url = (window.URL ? window.webkitURL).createObjectURL(blob)
		a = document.createElement "a"
		a.href = url
		a.download = file_name ? "output.#{file_type}"
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
						audio_buffer.getChannelData i
			
			# ask it to export the WAV...
			worker.postMessage
				command: "exportWAV"
				type: "audio/wav"
			
			# when it's done...
			worker.onmessage = (e)=>
				forceDownload e.data, "export.wav"
		
		when "mp3"
			mp3Worker = new Worker "lib/export/mp3/lame-worker.js"
			
			mp3Worker.postMessage
				config:
					sampleRate: sample_rate
					kbps: 128
				channels:
					for i in [0...number_of_channels]
						audio_buffer.getChannelData i
			
			mp3Worker.onmessage = (e)->
				mp3Blob = new Blob e.data, type: "audio/mp3"
				forceDownload mp3Blob, "export.mp3"
