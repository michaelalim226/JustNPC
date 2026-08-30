$code = @"
using System;
using System.IO;

public class FastAudio {
    public static void GenerateAll(string audioDir) {
        int sampleRate = 22050;

        // 1. Footstep (0.08s)
        CreateWav(Path.Combine(audioDir, "sfx_footstep.wav"), sampleRate, 0.08, (t, i) => {
            double env = Math.Exp(-t * 50.0);
            double noise = (((i * 7919) % 2000) - 1000) / 1000.0;
            double wave = Math.Sin(2.0 * Math.PI * (120.0 - t * 400.0) * t) * 0.7 + noise * 0.3;
            return (short)(wave * env * 16000);
        });

        // 2. Dialog blip (0.04s)
        CreateWav(Path.Combine(audioDir, "sfx_dialog.wav"), sampleRate, 0.04, (t, i) => {
            double env = Math.Exp(-t * 70.0);
            double wave = Math.Sin(2.0 * Math.PI * 520.0 * t);
            return (short)(wave * env * 14000);
        });

        // 3. Collect item (0.35s)
        CreateWav(Path.Combine(audioDir, "sfx_collect.wav"), sampleRate, 0.35, (t, i) => {
            double freq = (t < 0.12) ? 1046.5 : 1567.98; // C6 -> G6
            double env = Math.Exp(-(t % 0.12) * 18.0);
            double wave = Math.Sin(2.0 * Math.PI * freq * t) + 0.3 * Math.Sin(4.0 * Math.PI * freq * t);
            return (short)(wave * env * 18000);
        });

        // 4. Gate unlock (0.7s)
        CreateWav(Path.Combine(audioDir, "sfx_gate_unlock.wav"), sampleRate, 0.7, (t, i) => {
            double env = Math.Exp(-t * 4.0);
            double hum = Math.Sin(2.0 * Math.PI * 130.0 * t) * 0.6;
            double sparkle = Math.Sin(2.0 * Math.PI * (440.0 + t * 800.0) * t) * 0.4;
            return (short)((hum + sparkle) * env * 20000);
        });

        // 5. Escape fanfare (1.5s)
        CreateWav(Path.Combine(audioDir, "sfx_escape.wav"), sampleRate, 1.5, (t, i) => {
            double freq = 523.25;
            double noteT = t;
            if (t < 0.2) { freq = 523.25; noteT = t; }
            else if (t < 0.4) { freq = 659.25; noteT = t - 0.2; }
            else if (t < 0.65) { freq = 783.99; noteT = t - 0.4; }
            else { freq = 1046.5; noteT = t - 0.65; }
            double decay = (freq == 1046.5) ? 2.0 : 8.0;
            double env = Math.Exp(-noteT * decay);
            double wave = Math.Sin(2.0 * Math.PI * freq * t) + 0.35 * Math.Sin(4.0 * Math.PI * freq * t);
            return (short)(wave * env * 22000);
        });

        // 6. Ambient BGM (8.0s looping calm melody)
        CreateWav(Path.Combine(audioDir, "bgm_calm.wav"), sampleRate, 8.0, (t, i) => {
            double[] freqs = { 261.63, 329.63, 392.00, 329.63, 293.66, 349.23, 392.00, 261.63 };
            int noteIdx = Math.Min(7, (int)(t));
            double f = freqs[noteIdx];
            double localT = t - noteIdx;
            double env = (1.0 - Math.Exp(-localT * 10.0)) * Math.Exp(-localT * 1.5);
            double wave = Math.Sin(2.0 * Math.PI * f * t) + 0.25 * Math.Sin(4.0 * Math.PI * f * t);
            double pad = Math.Sin(2.0 * Math.PI * 130.81 * t) * 0.2 + Math.Sin(2.0 * Math.PI * 196.0 * t) * 0.15;
            return (short)((wave * env * 0.7 + pad * 0.3) * 12000);
        });
    }

    private static void CreateWav(string path, int sampleRate, double duration, Func<double, int, short> generator) {
        int numSamples = (int)(sampleRate * duration);
        int subChunk2Size = numSamples * 2;
        int chunkSize = 36 + subChunk2Size;

        using (var stream = File.Create(path))
        using (var writer = new BinaryWriter(stream)) {
            writer.Write(System.Text.Encoding.ASCII.GetBytes("RIFF"));
            writer.Write(chunkSize);
            writer.Write(System.Text.Encoding.ASCII.GetBytes("WAVE"));

            writer.Write(System.Text.Encoding.ASCII.GetBytes("fmt "));
            writer.Write(16); // Subchunk1Size
            writer.Write((short)1); // AudioFormat (PCM)
            writer.Write((short)1); // NumChannels (Mono)
            writer.Write(sampleRate);
            writer.Write(sampleRate * 2); // ByteRate
            writer.Write((short)2); // BlockAlign
            writer.Write((short)16); // BitsPerSample

            writer.Write(System.Text.Encoding.ASCII.GetBytes("data"));
            writer.Write(subChunk2Size);

            for (int i = 0; i < numSamples; i++) {
                double t = (double)i / sampleRate;
                short val = generator(t, i);
                writer.Write(val);
            }
        }
    }
}
"@

Add-Type -TypeDefinition $code
$audioDir = "c:\Users\LENOVO\Videos\Game Projek\npcdayoff\assets\audio"
[FastAudio]::GenerateAll($audioDir)
Write-Output "FAST AUDIO GENERATION COMPLETE!"
