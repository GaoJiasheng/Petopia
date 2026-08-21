#!/usr/bin/env python3
"""Generate Hearth & Tails' original interaction and paper UI sounds.

The synthesis is deterministic and uses no third-party recordings, samples,
loops, melodies, or artist references. WAV masters are the low-latency runtime
assets required by docs/spec-audio.md.
"""

from __future__ import annotations

import hashlib
import json
import math
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[3]
SR = 48_000
SEED = 1_947_223
SFX_DIR = ROOT / "assets/audio/sfx/wav"
UI_DIR = ROOT / "assets/audio/ui/wav"
MANIFEST = ROOT / "assets/audio/provenance/sfx_provenance_manifest.json"


def rng(name: str) -> np.random.Generator:
    digest = hashlib.sha256(f"{SEED}:{name}".encode()).digest()
    return np.random.default_rng(int.from_bytes(digest[:8], "little"))


def buffer(seconds: float) -> np.ndarray:
    return np.zeros((round(seconds * SR), 2), dtype=np.float32)


def fade(signal: np.ndarray, attack: float = 0.008, release: float = 0.08) -> np.ndarray:
    result = signal.copy()
    a = min(len(result), round(attack * SR))
    r = min(len(result), round(release * SR))
    if a > 1:
        result[:a] *= np.linspace(0, 1, a, dtype=np.float32)[:, None]
    if r > 1:
        result[-r:] *= np.linspace(1, 0, r, dtype=np.float32)[:, None]
    return result


def pan(mono: np.ndarray, position: float) -> np.ndarray:
    angle = (position + 1) * math.pi / 4
    return np.column_stack((mono * math.cos(angle), mono * math.sin(angle)))


def add(target: np.ndarray, signal: np.ndarray, start: float) -> None:
    index = round(start * SR)
    if index >= len(target):
        return
    end = min(len(target), index + len(signal))
    target[index:end] += signal[: end - index]


def lowpass(signal: np.ndarray, width: int) -> np.ndarray:
    kernel = np.hanning(width).astype(np.float32)
    kernel /= kernel.sum()
    return np.convolve(signal, kernel, mode="same").astype(np.float32)


def noise_burst(
    name: str,
    duration: float,
    *,
    smooth: int,
    decay: float,
    gain: float,
    position: float = 0,
) -> np.ndarray:
    count = round(duration * SR)
    mono = lowpass(rng(name).normal(0, 1, count).astype(np.float32), smooth)
    mono /= max(1e-6, float(np.max(np.abs(mono))))
    envelope = np.exp(-np.linspace(0, decay, count, dtype=np.float32))
    return fade(pan(mono * envelope * gain, position), 0.002, 0.035)


def chirp(
    duration: float,
    start_hz: float,
    end_hz: float,
    *,
    gain: float,
    position: float = 0,
    harmonics: tuple[tuple[float, float], ...] = ((1, 1), (2, 0.16)),
) -> np.ndarray:
    count = round(duration * SR)
    t = np.arange(count, dtype=np.float32) / SR
    frequency = start_hz + (end_hz - start_hz) * (t / max(duration, 1e-6)) ** 1.35
    phase = 2 * np.pi * np.cumsum(frequency) / SR
    mono = np.zeros(count, dtype=np.float32)
    for multiple, amplitude in harmonics:
        mono += np.sin(phase * multiple).astype(np.float32) * amplitude
    envelope = np.exp(-np.linspace(0, 3.6, count, dtype=np.float32))
    return fade(pan(mono * envelope * gain, position), 0.006, 0.06)


def feed() -> np.ndarray:
    result = buffer(0.92)
    for index, start in enumerate((0.04, 0.19, 0.36)):
        add(
            result,
            noise_burst(
                f"feed-crunch-{index}",
                0.17,
                smooth=7,
                decay=5.2,
                gain=0.20,
                position=(-0.18, 0.12, -0.05)[index],
            ),
            start,
        )
    add(result, chirp(0.31, 1040, 720, gain=0.10, position=0.12), 0.54)
    return result


def pat() -> np.ndarray:
    result = buffer(0.94)
    count = round(0.68 * SR)
    raw = lowpass(rng("pat-fur").normal(0, 1, count).astype(np.float32), 190)
    raw /= max(1e-6, float(np.max(np.abs(raw))))
    sweep = np.clip(
        np.sin(np.linspace(0, np.pi, count, dtype=np.float32)), 0, 1
    ) ** 1.6
    add(result, pan(raw * sweep * 0.17, -0.08), 0.03)
    t = np.arange(count, dtype=np.float32) / SR
    purr = (
        np.sin(2 * np.pi * 118 * t)
        + 0.3 * np.sin(2 * np.pi * 236 * t)
    ).astype(np.float32)
    add(result, fade(pan(purr * sweep * 0.045, 0.05), 0.06, 0.16), 0.10)
    add(result, chirp(0.28, 660, 910, gain=0.075, position=0.18), 0.58)
    return result


def toy() -> np.ndarray:
    result = buffer(1.0)
    add(
        result,
        chirp(
            0.36,
            510,
            760,
            gain=0.14,
            position=-0.12,
            harmonics=((1, 1), (2, 0.24), (3, 0.08)),
        ),
        0.05,
    )
    add(result, noise_burst("toy-roll", 0.52, smooth=55, decay=2, gain=0.10), 0.23)
    add(result, chirp(0.29, 720, 560, gain=0.10, position=0.18), 0.63)
    return result


def bath() -> np.ndarray:
    result = buffer(1.18)
    for index, start in enumerate((0.03, 0.16, 0.29, 0.48, 0.66)):
        base = 320 + index * 55
        add(
            result,
            chirp(
                0.18 + index * 0.012,
                base,
                base * 1.7,
                gain=0.075,
                position=(-0.25 + index * 0.12),
                harmonics=((1, 1), (2, 0.10)),
            ),
            start,
        )
    add(
        result,
        noise_burst("bath-shake", 0.35, smooth=24, decay=2.7, gain=0.12),
        0.78,
    )
    return result


def event_card() -> np.ndarray:
    result = buffer(1.05)
    count = round(0.64 * SR)
    paper = lowpass(rng("event-paper").normal(0, 1, count).astype(np.float32), 24)
    paper /= max(1e-6, float(np.max(np.abs(paper))))
    envelope = np.clip(
        np.sin(np.linspace(0, np.pi, count, dtype=np.float32)), 0, 1
    ) ** 1.2
    add(result, pan(paper * envelope * 0.13, -0.05), 0.02)
    add(result, chirp(0.34, 620, 860, gain=0.08, position=0.16), 0.60)
    return result


def visitor_arrive() -> np.ndarray:
    result = buffer(1.15)
    add(result, chirp(0.42, 760, 980, gain=0.095, position=-0.14), 0.08)
    add(result, chirp(0.48, 920, 1120, gain=0.075, position=0.18), 0.43)
    return result


def paper_open() -> np.ndarray:
    result = buffer(0.74)
    count = round(0.66 * SR)
    raw = lowpass(rng("ui-paper-open").normal(0, 1, count).astype(np.float32), 18)
    raw /= max(1e-6, float(np.max(np.abs(raw))))
    shape = np.sin(np.linspace(0, np.pi, count, dtype=np.float32))
    flutter = 0.72 + 0.28 * np.sin(np.linspace(0, 14 * np.pi, count, dtype=np.float32))
    add(result, fade(pan(raw * shape * flutter * 0.12, -0.05), 0.01, 0.08), 0.02)
    return result


def tap_soft() -> np.ndarray:
    result = buffer(0.42)
    add(result, noise_burst("ui-tap", 0.12, smooth=60, decay=5, gain=0.10), 0.01)
    add(result, chirp(0.30, 610, 570, gain=0.065), 0.045)
    return result


ASSETS = {
    "sfx/wav/sfx_feed_eat.wav": feed,
    "sfx/wav/sfx_pat_fur.wav": pat,
    "sfx/wav/sfx_toy_play.wav": toy,
    "sfx/wav/sfx_bath_bubbles.wav": bath,
    "sfx/wav/sfx_event_card.wav": event_card,
    "sfx/wav/sfx_visitor_arrive.wav": visitor_arrive,
    "ui/wav/ui_paper_open.wav": paper_open,
    "ui/wav/ui_tap_soft.wav": tap_soft,
}


def master(signal: np.ndarray) -> np.ndarray:
    signal = np.tanh(signal * 1.25).astype(np.float32)
    peak = float(np.max(np.abs(signal)))
    if peak > 0:
        signal *= (10 ** (-5.5 / 20)) / peak
    signal -= np.mean(signal, axis=0, keepdims=True)
    return np.clip(signal, -1, 1)


def write_wav(path: Path, signal: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = (signal * 32767).round().astype("<i2")
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(SR)
        output.writeframes(pcm.tobytes())


def main() -> None:
    SFX_DIR.mkdir(parents=True, exist_ok=True)
    UI_DIR.mkdir(parents=True, exist_ok=True)
    entries = []
    for relative, builder in ASSETS.items():
        output = ROOT / "assets/audio" / relative
        signal = master(builder())
        write_wav(output, signal)
        peak = max(1e-9, float(np.max(np.abs(signal))))
        rms = max(1e-9, float(np.sqrt(np.mean(signal**2))))
        entries.append(
            {
                "asset": str(output.relative_to(ROOT)),
                "sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
                "sampleRate": SR,
                "channels": 2,
                "sampleWidthBits": 16,
                "durationMs": round(len(signal) / SR * 1000),
                "peakDbfs": round(20 * math.log10(peak), 2),
                "rmsDbfs": round(20 * math.log10(rms), 2),
                "source": "deterministic original procedural synthesis",
            }
        )
    MANIFEST.write_text(
        json.dumps(
            {
                "generator": str(Path(__file__).relative_to(ROOT)),
                "seed": SEED,
                "thirdPartySamples": False,
                "assets": entries,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
