# SwiftMetronome

A Swift package for creating metronomes with AudioKit integration.

## Usage

```swift
import SwiftMetronome

let metronome = Metronome()
metronome.tempo = 120        // BPM (supports wide range, e.g., 1-400+)
metronome.subdivision = 4    // Subdivisions per beat (1-6+)
metronome.start()
metronome.stop()
```

## Published Properties

- `@Published var tempo: Double` - Beats per minute (supports wide range)
- `@Published var subdivision: Int` - Number of subdivisions per beat
- `@Published var isPlaying: Bool` - Current playback state

## Methods

- `configure(tempo: Double, subdivision: Int)` - Set tempo and subdivision
- `start()` - Start the metronome
- `stop()` - Stop the metronome
- `toggle()` - Toggle play/stop state
