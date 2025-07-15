import AudioKit
import AudioKitEX
import AVFoundation
import Combine

/// A metronome implementation using AudioKit with support for programmable subdivisions
public class SwiftMetronome: ObservableObject {

    // MARK: - Properties

    private let engine: AudioEngine
    private let sequencer: Sequencer
    private let sampler: MIDISampler
    private var currentTrack: SequencerTrack?

    /// Current tempo in beats per minute
    @Published public var tempo: Double = 120 {
        didSet {
            sequencer.tempo = tempo
        }
    }

    /// Number of subdivisions per beat (1 = quarter notes, 2 = eighth notes, 3 = triplets, 4 = sixteenth notes, etc.)
    @Published public var subdivision: Int = 1 {
        didSet {
            if subdivision < 1 {
                subdivision = 1
            }
            if isPlaying {
                updateSequence()
            }
        }
    }

    /// Whether the metronome is currently playing
    public private(set) var isPlaying: Bool = false

    /// Volume level (0.0 to 1.0)
    public var volume: Float = 1.0 {
        didSet {
            sampler.volume = volume
        }
    }

    // MARK: - MIDI Note Numbers

    private enum ClickNote: UInt8 {
        case accent = 26    // D1 - for accented beats (downbeats) - click_D1
        case regular = 24   // C1 - for regular subdivision clicks - click_C1
    }

    // MARK: - Initialization

    public init() {
        engine = AudioEngine()

        // Initialize the MIDI sampler
        sampler = MIDISampler(name: "MetronomeSampler")

        // Create sequencer
        sequencer = Sequencer()

        // Now that all stored properties are initialized, we can call methods
        sequencer.tempo = tempo

        // Load click sounds
        sampler.loadSounds(fileNames: ["click_C1", "click_D1"])

        // Connect sampler to engine output
        engine.output = sampler

        // Set initial volume
        sampler.volume = volume
    }

    // MARK: - Public Methods

    /// Start the metronome
    public func start() {
        guard !isPlaying else { return }

        do {
            // Configure audio session (iOS only)
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            // Start audio engine
            try engine.start()

            // Setup and start sequence
            updateSequence()
            sequencer.playFromStart()

            isPlaying = true
            print("SwiftMetronome: Started with tempo \(tempo) BPM, subdivision \(subdivision)")

        } catch {
            print("SwiftMetronome: Error starting - \(error)")
        }
    }

    /// Stop the metronome
    public func stop() {
        guard isPlaying else { return }

        sequencer.stop()
        isPlaying = false
        print("SwiftMetronome: Stopped")
    }

    /// Toggle play/stop state
    public func toggle() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }

    // MARK: - Private Methods

    private func updateSequence() {
        // Clear existing track or create new one
        if let track = currentTrack {
            track.clear()
        } else {
            currentTrack = sequencer.addTrack(for: sampler)
        }

        guard let track = currentTrack else { return }

        // Add main beat
        track.add(noteNumber: 26, velocity: 100, position: 0.0, duration: 0.5)

        // Add subdivisions if needed
        if subdivision > 1 {
            let subdivisionDuration = 1.0 / Double(subdivision)
            for i in 1..<subdivision {
                let position = Double(i) * subdivisionDuration
                track.add(noteNumber: 24, velocity: 100, position: position, duration: 0.5)
            }
        }

        // Subdivision example
        //                track.add(noteNumber: 24, velocity: 100, position: 1.0, duration: 0.5)
        //                track.add(noteNumber: 24, velocity: 100, position: 2.0, duration: 0.5)
        //                track.add(noteNumber: 24, velocity: 100, position: 3.0, duration: 0.5)

        // Set track properties
        track.length = 1.0
        track.loopEnabled = true

        print("SwiftMetronome: Updated sequence - \(subdivision) subdivisions per beat")
    }
}

// MARK: - Convenience Extensions

extension SwiftMetronome {

    /// Set tempo and subdivision in one call
    public func configure(tempo: Double, subdivision: Int) {
        self.tempo = tempo
        self.subdivision = subdivision
    }

    /// Common subdivision presets
    public enum SubdivisionPreset: Int, CaseIterable {
        case quarter = 1        // Quarter notes
        case eighth = 2         // Eighth notes
        case triplet = 3        // Eighth note triplets
        case sixteenth = 4      // Sixteenth notes
        case quintuplet = 5     // Quintuplets
        case sextuplet = 6      // Sextuplets

        public var description: String {
            switch self {
            case .quarter: return "Quarter Notes"
            case .eighth: return "Eighth Notes"
            case .triplet: return "Triplets"
            case .sixteenth: return "Sixteenth Notes"
            case .quintuplet: return "Quintuplets"
            case .sextuplet: return "Sextuplets"
            }
        }
    }

    /// Apply a subdivision preset
    public func setSubdivision(_ preset: SubdivisionPreset) {
        subdivision = preset.rawValue
    }
}

// MARK: - MIDISampler Extension

extension MIDISampler {

    /// Load sounds from file names
    /// - Parameter fileNames: Array of file names without extension (assumed to be WAV files)
    func loadSounds(fileNames: [String]) {
        do {
            var audioFiles: [AVAudioFile] = []

            for fileName in fileNames {
                if let soundURL = Bundle.module.url(forResource: fileName, withExtension: "wav") {
                    let audioFile = try AVAudioFile(forReading: soundURL)
                    audioFiles.append(audioFile)
                } else {
                    print("SwiftMetronome: Warning - Could not find \(fileName).wav in package resources")
                }
            }

            // Load the audio files if any were found
            if !audioFiles.isEmpty {
                try loadAudioFiles(audioFiles)
            }

        } catch {
            print("SwiftMetronome: Error loading sounds - \(error)")
        }
    }
}
