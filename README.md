audio-editor
============

An html5 audio editor. "Hopefully."

I mean, this is mostly just a reminder that this should exist.


(How) Can it be done?
--------
Audio?
Web Audio API https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html

Midi?
Web MIDI API http://webaudio.github.io/web-midi-api/

Wave visualization?
Possible.

Effects?
Possible, although I'm not sure how it would work statically as opposed to realtime. 
Maybe it could just be realtime? No, some things like reverse would be too complicated.

Loading? Easy.

Saving? ...
I suppose this could be hacked with a javascript node that generates a wave file, then outputs it as a data or blog uri.
There's gotta be a better way to do this.
