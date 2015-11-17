importScripts("lame.min.js");

var lib = new lamejs;

var floatTo16BitPCM = function(arrayBuffer) {
	var f32 = new Float32Array(arrayBuffer);
	var i16 = new Int16Array(arrayBuffer.length);
	for (var i = 0, len = f32.length; i < len; i++) {
		var s = Math.max(-1, Math.min(+1, f32[i]));
		i16[i] = (s < 0 ? s * 0x8000 : s * 0x7FFF);
	}
	return i16;
};

self.onmessage = function(e) {
	var num_channels = Math.min(2, e.data.config.numChannels || e.data.channels.length); // 1 for mono or 2 for stereo
	var sample_rate = e.data.config.sampleRate = 44100; // 44.1khz (normal mp3 samplerate)
	var kbps = e.data.config.kbps = 128;
	
	var channels = [];
	for (var i = 0; i < num_channels; i++) {
		channels.push(floatTo16BitPCM(e.data.channels[i]));
	}
	
	var mp3encoder = new lib.Mp3Encoder(num_channels, sample_rate, kbps);
	
	sampleBlockSize = 1152; // can be anything but make it a multiple of 576 to make encoders life easier
	
	var mp3Data = [];
	var length = channels[0].length;
	for (var i = 0; i < length; i += sampleBlockSize) {
		if(num_channels == 2){
			var mp3buf = mp3encoder.encodeBuffer(
				channels[0].subarray(i, i + sampleBlockSize),
				channels[1].subarray(i, i + sampleBlockSize)
			);
		}else{
			var mp3buf = mp3encoder.encodeBuffer(
				channels[0].subarray(i, i + sampleBlockSize)
			);
		}
		if (mp3buf.length > 0) {
			mp3Data.push(mp3buf);
		}
	}
	var mp3buf = mp3encoder.flush(); // finish writing mp3
	
	if (mp3buf.length > 0) {
		mp3Data.push(new Int8Array(mp3buf));
	}
	
	self.postMessage(mp3Data);
};
