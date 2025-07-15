//
//  ContentView.swift
//  SwiftMetronomeDemo
//
//  Created by Félix Dervaux on 15.07.25.
//

import SwiftUI
import AudioKit
import AudioKitEX
import AVFoundation
import SwiftMetronome

struct MetronomeView: View {
    @StateObject private var metronome = Metronome()
    @State private var isPlaying = false

    var body: some View {
        VStack {
            Text("Swift Metronome")
                .font(.largeTitle)
                .padding()

            // Tempo Display and Slider
            VStack {
                Text("Tempo: \(Int(metronome.tempo)) BPM")
                    .font(.title)
                Slider(value: $metronome.tempo, in: 40...240, step: 1)
                    .padding()
            }

            // Subdivision Picker
            Text("Subdivisions")
                .font(.headline)
            Picker("Subdivision", selection: $metronome.subdivision) {
                ForEach(1...5, id: \.self) { subdivision in
                    Text("\(subdivision)").tag(subdivision)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()


            // Play/Stop Button
            Button(action: {
                if isPlaying {
                    metronome.stop()
                    isPlaying = false
                } else {
                    metronome.start()
                    isPlaying = true
                }
            }) {
                Text(isPlaying ? "Stop" : "Start")
                    .font(.title)
                    .frame(width: 150, height: 150)
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding()
        }
        .onAppear {
            // Initial configuration of the metronome
            metronome.configure(tempo: 120, subdivision: 1)
        }
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
    }
}
