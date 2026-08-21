#!/usr/bin/env python3
"""Generate Hearth & Tails' original seamless ambience and visitor voice palette.

All sounds are deterministic synthesis. No recordings, sample libraries,
melodies, model outputs, or third-party source material are used.
"""

from __future__ import annotations

import hashlib
import json
import math
import subprocess
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[3]
SR = 48_000
LOOP_SECONDS = 24.0
LOOP_SAMPLES = round(SR * LOOP_SECONDS)
SEED = 7_240_726
AMBIENT_WAV = ROOT / "assets/audio/ambient/wav"
AMBIENT_M4A = ROOT / "assets/audio/ambient/m4a"
VOC_WAV = ROOT / "assets/audio/voc/wav"
VOC_M4A = ROOT / "assets/audio/voc/m4a"
MANIFEST = ROOT / "assets/audio/provenance/ambient_voc_provenance_manifest.json"


def rng(name: str) -> np.random.Generator:
    digest = hashlib.sha256(f"{SEED}:{name}".encode()).digest()
    return np.random.default_rng(int.from_bytes(digest[:8], "little"))


def stereo_buffer(seconds: float) -> np.ndarray:
    return np.zeros((round(seconds * SR), 2), dtype=np.float32)


def periodic_noise(
    name: str,
    *,
    low_hz: float = 0,
    high_hz: float = SR / 2,
    tilt: float = 0,
) -> np.ndarray:
    """Frequency-shaped stereo noise whose endpoints loop without a seam."""
    channels = []
    frequencies = np.fft.rfftfreq(LOOP_SAMPLES, 1 / SR)
    lower = 1 - np.exp(-((frequencies / max(low_hz, 0.1)) ** 4))
    upper = np.exp(-((frequencies / max(high_hz, 0.1)) ** 4))
    shape = lower * upper
    if tilt:
        shape *= np.maximum(frequencies, 20) ** tilt
    shape[0] = 0
    for channel in range(2):
        source = rng(f"{name}:{channel}").normal(0, 1, LOOP_SAMPLES)
        spectrum = np.fft.rfft(source)
        signal = np.fft.irfft(spectrum * shape, n=LOOP_SAMPLES).astype(
            np.float32
        )
        signal /= max(float(np.max(np.abs(signal))), 1e-7)
        channels.append(signal)
    return np.column_stack(channels)


def periodic_lfo(
    cycles: int,
    *,
    phase: float = 0,
    floor: float = 0,
    power: float = 1,
) -> np.ndarray:
    angle = (
        np.arange(LOOP_SAMPLES, dtype=np.float32)
        * (2 * np.pi * cycles / LOOP_SAMPLES)
        + phase
    )
    wave = (np.sin(angle) + 1) * 0.5
    return floor + (1 - floor) * wave**power


def pan(mono: np.ndarray, position: float) -> np.ndarray:
    angle = (position + 1) * math.pi / 4
    return np.column_stack((mono * math.cos(angle), mono * math.sin(angle)))


def add_wrap(target: np.ndarray, signal: np.ndarray, start: float) -> None:
    start_index = round(start * SR) % len(target)
    for index in range(len(signal)):
        target[(start_index + index) % len(target)] += signal[index]


def fade(signal: np.ndarray, attack: float, release: float) -> np.ndarray:
    result = signal.copy()
    attack_count = min(len(result), round(attack * SR))
    release_count = min(len(result), round(release * SR))
    if attack_count > 1:
        result[:attack_count] *= np.linspace(
            0, 1, attack_count, dtype=np.float32
        )[:, None]
    if release_count > 1:
        result[-release_count:] *= np.linspace(
            1, 0, release_count, dtype=np.float32
        )[:, None]
    return result


def chirp(
    duration: float,
    start_hz: float,
    end_hz: float,
    *,
    gain: float,
    position: float,
    vibrato_hz: float = 0,
    harmonics: tuple[tuple[float, float], ...] = ((1, 1), (2, 0.12)),
) -> np.ndarray:
    count = round(duration * SR)
    t = np.arange(count, dtype=np.float32) / SR
    bend = (t / max(duration, 1e-6)) ** 1.25
    frequency = start_hz + (end_hz - start_hz) * bend
    if vibrato_hz:
        frequency *= 1 + 0.012 * np.sin(2 * np.pi * vibrato_hz * t)
    phase = 2 * np.pi * np.cumsum(frequency) / SR
    mono = np.zeros(count, dtype=np.float32)
    for multiple, amplitude in harmonics:
        mono += np.sin(phase * multiple).astype(np.float32) * amplitude
    envelope = np.clip(
        np.sin(np.linspace(0, np.pi, count, dtype=np.float32)), 0, 1
    ) ** 1.7
    return fade(pan(mono * envelope * gain, position), 0.008, 0.05)


def noise_gesture(
    name: str,
    duration: float,
    *,
    gain: float,
    position: float,
    smooth: int = 40,
    pulse_hz: float = 0,
) -> np.ndarray:
    count = round(duration * SR)
    source = rng(name).normal(0, 1, count).astype(np.float32)
    kernel = np.hanning(max(5, smooth)).astype(np.float32)
    kernel /= kernel.sum()
    mono = np.convolve(source, kernel, mode="same").astype(np.float32)
    mono /= max(float(np.max(np.abs(mono))), 1e-7)
    envelope = np.clip(
        np.sin(np.linspace(0, np.pi, count, dtype=np.float32)), 0, 1
    ) ** 1.5
    if pulse_hz:
        t = np.arange(count, dtype=np.float32) / SR
        envelope *= np.clip(np.sin(2 * np.pi * pulse_hz * t), 0, 1) ** 2
    return fade(pan(mono * envelope * gain, position), 0.01, 0.06)


def meadow_day() -> np.ndarray:
    result = periodic_noise("day-wind", high_hz=720) * 0.055
    leaves = periodic_noise("day-leaves", low_hz=750, high_hz=5_200)
    result += leaves * periodic_lfo(3, phase=0.7, floor=0.06, power=3)[:, None] * 0.035
    for index, start in enumerate((2.1, 6.7, 12.4, 18.8, 22.0)):
        position = (-0.62, 0.46, -0.18, 0.68, -0.42)[index]
        add_wrap(
            result,
            chirp(
                0.34,
                1_180 + index * 45,
                1_720 + index * 75,
                gain=0.055,
                position=position,
                vibrato_hz=8,
            ),
            start,
        )
        add_wrap(
            result,
            chirp(
                0.25,
                1_420 + index * 35,
                1_090 + index * 40,
                gain=0.040,
                position=position,
                vibrato_hz=7,
            ),
            start + 0.43,
        )
    return result


def meadow_dusk() -> np.ndarray:
    result = periodic_noise("dusk-wind", high_hz=560) * 0.046
    insects = periodic_noise("dusk-insects", low_hz=3_500, high_hz=8_200)
    tremolo = (
        np.clip(periodic_lfo(84, phase=0.2, floor=0), 0.32, 1) - 0.32
    ) / 0.68
    result += insects * tremolo[:, None] * 0.025
    for index, start in enumerate((4.2, 14.7, 20.6)):
        add_wrap(
            result,
            chirp(
                0.48,
                920,
                1_260,
                gain=0.037,
                position=(-0.52, 0.38, -0.16)[index],
                vibrato_hz=5,
            ),
            start,
        )
    return result


def meadow_night() -> np.ndarray:
    result = periodic_noise("night-air", high_hz=430) * 0.036
    insects = periodic_noise("night-insects", low_hz=4_100, high_hz=9_000)
    pulse = periodic_lfo(96, phase=1.1, floor=0, power=6)
    result += insects * pulse[:, None] * 0.020
    for start, position in ((3.8, -0.42), (15.9, 0.52)):
        add_wrap(
            result,
            chirp(
                0.72,
                510,
                430,
                gain=0.042,
                position=position,
                vibrato_hz=3,
                harmonics=((1, 1), (2, 0.05)),
            ),
            start,
        )
        add_wrap(
            result,
            chirp(
                0.62,
                470,
                390,
                gain=0.032,
                position=position,
                vibrato_hz=2.5,
                harmonics=((1, 1),),
            ),
            start + 0.78,
        )
    return result


def gentle_rain() -> np.ndarray:
    body = periodic_noise("rain-body", low_hz=280, high_hz=9_500)
    soft = periodic_noise("rain-soft", high_hz=1_800)
    result = body * 0.055 + soft * 0.040
    result *= periodic_lfo(2, phase=0.4, floor=0.66, power=1.4)[:, None]
    for index, start in enumerate((1.3, 4.9, 8.7, 13.2, 17.6, 21.4)):
        add_wrap(
            result,
            chirp(
                0.18,
                1_450 + index * 45,
                820 + index * 25,
                gain=0.026,
                position=(-0.7 + index * 0.27),
                harmonics=((1, 1),),
            ),
            start,
        )
    return result


def soft_snow() -> np.ndarray:
    wind = periodic_noise("snow-wind", low_hz=35, high_hz=620)
    result = wind * periodic_lfo(2, phase=2.2, floor=0.12, power=2.4)[:, None] * 0.052
    hush = periodic_noise("snow-hush", high_hz=1_900)
    result += hush * 0.012
    for index, start in enumerate((5.0, 11.8, 19.4)):
        base = (680, 760, 620)[index]
        add_wrap(
            result,
            chirp(
                1.15,
                base,
                base * 0.995,
                gain=0.023,
                position=(-0.45, 0.33, 0.05)[index],
                harmonics=((1, 1), (2, 0.25), (3, 0.08)),
            ),
            start,
        )
    return result


def seaside() -> np.ndarray:
    low = periodic_noise("sea-low", low_hz=35, high_hz=780)
    foam = periodic_noise("sea-foam", low_hz=650, high_hz=7_200)
    wave_a = periodic_lfo(3, phase=0.2, floor=0.08, power=3.6)
    wave_b = periodic_lfo(4, phase=2.1, floor=0.04, power=4.2)
    result = low * wave_a[:, None] * 0.075
    result += foam * wave_b[:, None] * 0.042
    for index, start in enumerate((6.2, 17.3)):
        add_wrap(
            result,
            chirp(
                0.82,
                760,
                1_080,
                gain=0.032,
                position=(-0.56, 0.46)[index],
                vibrato_hz=5,
            ),
            start,
        )
    return result


def tonal_voice(
    name: str,
    *,
    notes: tuple[tuple[float, float, float], ...],
    duration: float = 0.9,
    noise: float = 0,
) -> np.ndarray:
    result = stereo_buffer(duration)
    for index, (start, start_hz, end_hz) in enumerate(notes):
        add_wrap(
            result,
            chirp(
                min(0.34, duration - start),
                start_hz,
                end_hz,
                gain=0.15,
                position=(-0.12 + 0.24 * (index % 2)),
                vibrato_hz=5,
            ),
            start,
        )
    if noise:
        add_wrap(
            result,
            noise_gesture(
                f"{name}-texture",
                duration * 0.82,
                gain=noise,
                position=0,
                smooth=36,
            ),
            0.04,
        )
    return result


def visitor_voices() -> dict[str, np.ndarray]:
    voices = {
        "visitor_sparrow": tonal_voice(
            "sparrow", notes=((0.05, 1_650, 2_280), (0.34, 1_980, 1_520))
        ),
        "visitor_calico": tonal_voice(
            "calico",
            notes=((0.08, 520, 690), (0.38, 650, 560)),
            duration=1.0,
            noise=0.018,
        ),
        "visitor_snail": tonal_voice(
            "snail", notes=((0.12, 460, 620),), duration=0.72, noise=0.025
        ),
        "visitor_butterfly": tonal_voice(
            "butterfly",
            notes=((0.18, 1_100, 1_480),),
            duration=0.72,
            noise=0.055,
        ),
        "visitor_hedgehog": tonal_voice(
            "hedgehog",
            notes=((0.30, 610, 530),),
            duration=0.85,
            noise=0.075,
        ),
        "visitor_pigeon": tonal_voice(
            "pigeon", notes=((0.05, 310, 270), (0.42, 290, 255)), duration=1.05
        ),
        "visitor_squirrel": tonal_voice(
            "squirrel", notes=((0.04, 1_180, 1_640), (0.28, 1_420, 1_080))
        ),
        "visitor_crow": tonal_voice(
            "crow", notes=((0.08, 410, 330), (0.43, 370, 305)), duration=1.0
        ),
        "visitor_frog": tonal_voice(
            "frog",
            notes=((0.08, 240, 190), (0.45, 225, 180)),
            duration=1.0,
            noise=0.020,
        ),
        "visitor_firefly": tonal_voice(
            "firefly", notes=((0.10, 980, 1_360), (0.46, 1_240, 1_610))
        ),
        "visitor_tanuki": tonal_voice(
            "tanuki", notes=((0.10, 430, 520), (0.48, 500, 440)), duration=1.0
        ),
        "visitor_egret": tonal_voice(
            "egret",
            notes=((0.12, 860, 720),),
            duration=0.88,
            noise=0.035,
        ),
        "visitor_fox": tonal_voice(
            "fox", notes=((0.06, 720, 940), (0.36, 880, 760)), duration=0.92
        ),
        "visitor_owl": tonal_voice(
            "owl", notes=((0.08, 440, 365), (0.52, 410, 350)), duration=1.15
        ),
        "visitor_deer": tonal_voice(
            "deer", notes=((0.16, 620, 700),), duration=0.9, noise=0.030
        ),
        "visitor_snowhare": tonal_voice(
            "snowhare",
            notes=((0.28, 820, 1_040),),
            duration=0.82,
            noise=0.060,
        ),
        "visitor_starbug": tonal_voice(
            "starbug", notes=((0.08, 1_020, 1_520), (0.43, 1_310, 1_780))
        ),
        "visitor_campfire_light": tonal_voice(
            "campfire", notes=((0.30, 620, 780),), duration=0.9, noise=0.080
        ),
        "visitor_rainbow_shade": tonal_voice(
            "rainbow",
            notes=((0.05, 690, 980), (0.31, 920, 1_210), (0.57, 1_120, 1_360)),
            duration=1.08,
        ),
        "visitor_night_blob": tonal_voice(
            "night-blob",
            notes=((0.08, 360, 470), (0.49, 430, 340)),
            duration=1.08,
            noise=0.022,
        ),
    }
    return voices


AMBIENCES = {
    "amb_meadow_day": meadow_day,
    "amb_meadow_dusk": meadow_dusk,
    "amb_meadow_night": meadow_night,
    "amb_gentle_rain": gentle_rain,
    "amb_soft_snow": soft_snow,
    "amb_seaside": seaside,
}


def master(signal: np.ndarray, *, peak_db: float) -> np.ndarray:
    signal = signal.astype(np.float32)
    signal -= np.mean(signal, axis=0, keepdims=True)
    signal = np.tanh(signal * 1.1).astype(np.float32)
    peak = float(np.max(np.abs(signal)))
    if peak > 0:
        signal *= (10 ** (peak_db / 20)) / peak
    return np.clip(signal, -1, 1)


def write_wav(path: Path, signal: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = (signal * 32767).round().astype("<i2")
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(SR)
        output.writeframes(pcm.tobytes())


def encode_m4a(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source),
            "-c:a",
            "aac",
            "-b:a",
            "96k",
            "-movflags",
            "+faststart",
            str(destination),
        ],
        check=True,
    )


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    entries: list[dict[str, object]] = []
    for name, builder in AMBIENCES.items():
        wav = AMBIENT_WAV / f"{name}.wav"
        m4a = AMBIENT_M4A / f"{name}.m4a"
        write_wav(wav, master(builder(), peak_db=-12.0))
        encode_m4a(wav, m4a)
        entries.append(
            {
                "id": name,
                "kind": "seamless_ambient_loop",
                "durationSeconds": LOOP_SECONDS,
                "wav": str(wav.relative_to(ROOT)),
                "m4a": str(m4a.relative_to(ROOT)),
                "sha256": sha256(m4a),
            }
        )

    for visitor_id, signal in visitor_voices().items():
        wav = VOC_WAV / f"voc_{visitor_id}.wav"
        m4a = VOC_M4A / f"voc_{visitor_id}.m4a"
        write_wav(wav, master(signal, peak_db=-7.0))
        encode_m4a(wav, m4a)
        entries.append(
            {
                "id": visitor_id,
                "kind": "visitor_voice",
                "durationSeconds": round(len(signal) / SR, 3),
                "wav": str(wav.relative_to(ROOT)),
                "m4a": str(m4a.relative_to(ROOT)),
                "sha256": sha256(m4a),
            }
        )

    manifest = {
        "schemaVersion": 1,
        "generator": Path(__file__).name,
        "sampleRate": SR,
        "channels": 2,
        "thirdPartySamples": False,
        "sourceMethod": "deterministic procedural synthesis",
        "assets": entries,
    }
    MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=True, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"generated {len(AMBIENCES)} ambience loops")
    print(f"generated {len(visitor_voices())} visitor voices")


if __name__ == "__main__":
    main()
