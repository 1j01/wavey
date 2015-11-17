
@export_rendered_audio_buffer = (rendered_audio_buffer, file_type, number_of_channels, sample_rate)->
	
	forceDownload = (blob, filename)->
		url = (window.URL ? window.webkitURL).createObjectURL(blob)
		a = document.createElement "a"
		a.href = url
		a.download = filename ? "output.#{file_type}"
		a.click()
	
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
		switch file_type
			when "wav"
				forceDownload e.data, "export.#{file_type}"
			when "mp3"
				encode64 = (buffer)->
					binary = ""
					bytes = new Uint8Array buffer
					for i in [0..bytes.byteLength]
						binary += String.fromCharCode bytes[i]
					global.btoa binary
				
				parse_wav_meta_data = (wav_uint8_array)->
					
					read_int = (i, bytes)->
						val = 0
						shft = 0
						while bytes
							val += wav_uint8_array[i] << shft
							shft += 8
							i++
							bytes--
						val
					
					throw new Error "Invalid compression code, not PCM" if read_int(20, 2) isnt 1
					throw new Error "Invalid number of channels, not 1" if read_int(22, 2) isnt 1
					
					sampleRate: read_int 24, 4
					bitsPerSample: read_int 34, 2
					samples: wav_uint8_array.subarray 44
				
				Uint8ArrayToFloat32Array = (u8a)->
					f32a = new Float32Array u8a.length
					for i in [0..u8a.length]
						value = u8a[i << 1] + (u8a[(i << 1) + 1] << 8)
						value |= ~0x7FFF if value >= 0x8000
						f32a[i] = value / 0x8000
					f32a
				
				transcoderWorker = new Worker "lib/export/mp3/mp3Worker.js"
				
				file_reader = new FileReader
				
				file_reader.onload = (e)->
					
					wav_uint8_array = new Uint8Array @result
					wav_meta_data = parse_wav_meta_data wav_uint8_array
					
					transcoderWorker.postMessage
						cmd: "init"
						config:
							mode: 3
							channels: 1
							samplerate: wav_meta_data.sampleRate
							bitrate: wav_meta_data.bitsPerSample
					
					transcoderWorker.postMessage
						cmd: "encode"
						buf: Uint8ArrayToFloat32Array wav_meta_data.samples
					
					transcoderWorker.postMessage
						cmd: "finish"
					
					transcoderWorker.onmessage = (e)->
						if e.data.cmd == "data"
							
							mp3Blob = new Blob [new Uint8Array e.data.buf], type: "audio/mp3"
							
							forceDownload mp3Blob, "export.#{file_type}"
				
				file_reader.readAsArrayBuffer e.data
