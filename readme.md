### Project Reference

[Mysic API](https://github.com/yusrilsabir22/mysic-api)

[Mysic App (Swift App)](https://github.com/yusrilsabir22/MysicApp)

[Audio Jax Whisper](https://github.com/yusrilsabir22/audio_jax_whisper)

```
|-------------------------|
|- Mysic App (Swift App) -|
|-------------------------|
        |
        |
        V
|-----------|
| Mysic API | --------------- Fetch and Extract Youtube Data
|-----------|______________
        |                  \ Callback to Mysic API and save to DB
        |                   \
        |                    \
        V                     \ 
|-------------------|          \ 
| Audio Jax Whisper | -------- Detect and Generate Lyrics
|-------------------|               (Background Task)
```