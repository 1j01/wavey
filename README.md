audio-editor
============

An html5 audio editor. "Hopefully."

I mean, this is mostly just a reminder that this should exist.


(How) Can it be done?
---------------------

Audio?
Web Audio API https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html

MIDI?
Web MIDI API http://webaudio.github.io/web-midi-api/

Loading? Easy.

Saving? https://github.com/mattdiamond/Recorderjs (creates `.wav` files)

Wave visualization? Sure! (`AnalyserNode`)

Effects? Possible, although I'm not sure how it could work statically. (probably something with `context.createBufferSource()`)
It might be better dynamically though, as you would keep the original data. But for a senario like reversing the audio in your selection...
