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
	var channels = e.data.config.channels || 1; // 1 for mono or 2 for stereo
	var sampleRate = e.data.config.sampleRate = 44100; // 44.1khz (normal mp3 samplerate)
	var kbps = e.data.config.kbps = 128;
	var samples = floatTo16BitPCM(e.data.samples);
	var mp3encoder = new lib.Mp3Encoder(channels, sampleRate, kbps);
	
	var mp3Data = [];
	
	sampleBlockSize = 1152; // can be anything but make it a multiple of 576 to make encoders life easier
	
	var mp3Data = [];
	for (var i = 0; i < samples.length; i += sampleBlockSize) {
		sampleChunk = samples.subarray(i, i + sampleBlockSize);
		var mp3buf = mp3encoder.encodeBuffer(sampleChunk);
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
