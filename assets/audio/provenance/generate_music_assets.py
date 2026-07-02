#!/usr/bin/env python3
"""Generate Petopia music assets from docs/spec-audio.md.

This is a production-source script for music assets, not game runtime code.
It uses only procedural synthesis: no third-party samples, loops, reference
audio, artist-style prompts, or commercial melodies.
"""

from __future__ import annotations

import hashlib
import json
import math
import struct
import subprocess
import time
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[3]
SR = 48_000
SEED = 732451

BGM_STEM_WAV = ROOT / "assets/audio/bgm/stems/wav"
BGM_STEM_OGG = ROOT / "assets/audio/bgm/stems/ogg"
BGM_MIX_WAV = ROOT / "assets/audio/bgm/mix/wav"
BGM_MIX_OGG = ROOT / "assets/audio/bgm/mix/ogg"
STING_WAV = ROOT / "assets/audio/sting/wav"
STING_OGG = ROOT / "assets/audio/sting/ogg"
PROV = ROOT / "assets/audio/provenance"


def ensure_dirs() -> None:
    for path in [
        BGM_STEM_WAV,
        BGM_STEM_OGG,
        BGM_MIX_WAV,
        BGM_MIX_OGG,
        STING_WAV,
        STING_OGG,
        PROV,
    ]:
        path.mkdir(parents=True, exist_ok=True)


def seed_for(name: str) -> int:
    data = hashlib.sha256(f"{SEED}:{name}".encode()).digest()
    return int.from_bytes(data[:8], "little") & 0xFFFFFFFF


def rng_for(name: str) -> np.random.Generator:
    return np.random.default_rng(seed_for(name))


def midi_to_freq(midi: float) -> float:
    return 440.0 * (2.0 ** ((midi - 69.0) / 12.0))


def db_to_amp(db: float) -> float:
    return 10.0 ** (db / 20.0)


def beat_time(bpm: float) -> float:
    return 60.0 / bpm


def bar_time(bpm: float) -> float:
    return beat_time(bpm) * 4.0


def new_buf(seconds: float) -> np.ndarray:
    return np.zeros((int(round(seconds * SR)), 2), dtype=np.float32)


def pan_gains(pan: float) -> tuple[float, float]:
    x = (pan + 1.0) * math.pi / 4.0
    return math.cos(x), math.sin(x)


def adsr(n: int, attack: float, decay: float, sustain: float, release: float) -> np.ndarray:
    env = np.ones(n, dtype=np.float32) * sustain
    a = min(n, int(attack * SR))
    d = min(max(0, n - a), int(decay * SR))
    r = min(n, int(release * SR))
    if a > 1:
        env[:a] = np.linspace(0, 1, a, dtype=np.float32)
    if d > 1:
        env[a : a + d] = np.linspace(1, sustain, d, dtype=np.float32)
    if r > 1:
        env[-r:] *= np.linspace(1, 0, r, dtype=np.float32)
    return env


def pluck_env(n: int, decay: float, attack: float = 0.003) -> np.ndarray:
    t = np.arange(n, dtype=np.float32) / SR
    env = np.exp(-decay * t).astype(np.float32)
    a = min(n, int(attack * SR))
    r = min(n, int(0.025 * SR))
    if a > 1:
        env[:a] *= np.linspace(0, 1, a, dtype=np.float32)
    if r > 1:
        env[-r:] *= np.linspace(1, 0, r, dtype=np.float32)
    return env


def tone(instr: str, freq: float, dur: float, velocity: float, name: str) -> np.ndarray:
    n = max(1, int(round(dur * SR)))
    t = np.arange(n, dtype=np.float32) / SR
    r = rng_for(f"{name}:{instr}:{freq:.3f}:{dur:.3f}")
    y = np.zeros(n, dtype=np.float32)

    if instr == "felt_piano":
        for p, a in [(1, 1.0), (2, 0.32), (3, 0.16), (4, 0.07), (5, 0.025)]:
            y += a * np.sin(2 * np.pi * freq * p * t + r.uniform(0, 0.04)).astype(np.float32) * np.exp(
                -(1.4 + 0.2 * p) * t
            ).astype(np.float32)
        y *= pluck_env(n, 1.7, 0.006)
        y += r.normal(0, 1, n).astype(np.float32) * np.exp(-70 * t).astype(np.float32) * 0.012
        return y * 0.62 * velocity

    if instr == "nylon_guitar":
        for p, a in [(1, 1.0), (2, 0.42), (3, 0.2), (4, 0.11), (5, 0.06), (6, 0.03)]:
            y += a * np.sin(2 * np.pi * freq * p * t + r.uniform(0, 2 * np.pi)).astype(np.float32) * np.exp(
                -(1.9 + 0.45 * p) * t
            ).astype(np.float32)
        y *= pluck_env(n, 1.35, 0.002)
        y += r.normal(0, 1, n).astype(np.float32) * np.exp(-45 * t).astype(np.float32) * 0.005
        return y * 0.52 * velocity

    if instr in {"kalimba", "music_box", "celesta", "marimba", "vibraphone", "glass_vibes"}:
        if instr == "kalimba":
            parts = [(1, 1.0), (2.01, 0.42), (3.86, 0.2), (5.1, 0.06)]
            base, decay = 0.50, 2.8
        elif instr == "music_box":
            parts = [(1, 1.0), (2.0, 0.48), (4.01, 0.24), (8.02, 0.08)]
            base, decay = 0.42, 2.4
        elif instr == "celesta":
            parts = [(1, 1.0), (2.0, 0.36), (4.01, 0.23), (8.02, 0.12)]
            base, decay = 0.34, 2.0
        elif instr == "marimba":
            parts = [(1, 1.0), (2.75, 0.22), (3.92, 0.13), (5.4, 0.04)]
            base, decay = 0.55, 1.9
        elif instr == "vibraphone":
            parts = [(1, 1.0), (2.01, 0.5), (3.0, 0.18), (4.2, 0.08)]
            base, decay = 0.42, 0.85
        else:
            parts = [(1, 1.0), (2.01, 0.5), (3.0, 0.18), (4.2, 0.08)]
            base, decay = 0.34, 0.55
        vib = 1.0 + (0.0025 * np.sin(2 * np.pi * 5.1 * t).astype(np.float32) if "vibe" in instr else 0)
        for p, a in parts:
            y += a * np.sin(2 * np.pi * freq * p * vib * t + r.uniform(0, 2 * np.pi)).astype(
                np.float32
            ) * np.exp(-(decay + 0.25 * p) * t).astype(np.float32)
        y *= pluck_env(n, decay, 0.001 if instr != "marimba" else 0.003)
        return y * base * velocity

    if instr in {"ocarina", "recorder", "whistle", "clarinet", "harmonica", "accordion", "hum"}:
        vib = 0.0035 * np.sin(2 * np.pi * (5.4 if instr == "harmonica" else 4.8) * t).astype(np.float32)
        phase = 2 * np.pi * np.cumsum(freq * (1 + vib)) / SR
        if instr == "clarinet":
            y = np.sin(phase) + 0.32 * np.sin(3 * phase) + 0.12 * np.sin(5 * phase)
            gain = 0.26
        elif instr == "accordion":
            y = np.sin(phase) + 0.34 * np.sin(2 * phase + 0.4) + 0.18 * np.sin(3 * phase + 1.1)
            y *= 1 + 0.055 * np.sin(2 * np.pi * 3.2 * t + 0.2)
            gain = 0.24
        elif instr == "harmonica":
            y = np.sin(phase) + 0.25 * np.sin(2 * phase) + 0.18 * np.sin(3 * phase)
            gain = 0.27
        elif instr == "hum":
            y = np.sin(phase) + 0.28 * np.sin(2 * phase) + 0.08 * np.sin(3 * phase)
            y *= 0.88 + 0.12 * np.sin(2 * np.pi * 0.7 * t + 1.1)
            gain = 0.18
        elif instr == "recorder":
            y = np.sin(phase) + 0.18 * np.sin(2 * phase) + 0.07 * np.sin(3 * phase)
            gain = 0.30
        elif instr == "whistle":
            y = np.sin(phase) + 0.08 * np.sin(2 * phase)
            gain = 0.24
        else:
            y = np.sin(phase) + 0.10 * np.sin(2 * phase)
            gain = 0.34
        breath = r.normal(0, 1, n).astype(np.float32)
        if n > 64:
            breath = np.convolve(breath, np.ones(32, dtype=np.float32) / 32, mode="same").astype(np.float32)
        y = y.astype(np.float32) + breath * (0.004 if instr == "whistle" else 0.008)
        y *= adsr(n, 0.08 if instr != "hum" else 0.18, 0.25, 0.86, 0.14 if instr != "hum" else 0.25)
        return y.astype(np.float32) * gain * velocity

    if instr == "pizz_strings":
        for p, a in [(1, 1.0), (2, 0.35), (3, 0.2), (4, 0.08)]:
            y += a * np.sin(2 * np.pi * freq * p * t).astype(np.float32) * np.exp(
                -(2.7 + 0.25 * p) * t
            ).astype(np.float32)
        y *= pluck_env(n, 2.2, 0.002)
        return y * 0.36 * velocity

    return np.sin(2 * np.pi * freq * t).astype(np.float32) * adsr(n, 0.02, 0.1, 0.8, 0.1) * 0.2 * velocity


def add_note(
    buf: np.ndarray, start: float, dur: float, midi: float, instr: str, amp: float = 1.0, pan: float = 0.0, name: str = ""
) -> None:
    if dur <= 0:
        return
    y = tone(instr, midi_to_freq(midi), dur, amp, name)
    i0 = int(round(start * SR))
    if i0 >= len(buf):
        return
    i1 = min(len(buf), i0 + len(y))
    y = y[: i1 - i0]
    left, right = pan_gains(pan)
    buf[i0:i1, 0] += y * left
    buf[i0:i1, 1] += y * right


def add_noise_burst(
    buf: np.ndarray, start: float, dur: float, amp: float, pan: float, kind: str, name: str
) -> None:
    n = max(1, int(round(dur * SR)))
    r = rng_for(f"noise:{kind}:{name}:{start:.3f}:{dur:.3f}")
    y = r.normal(0, 1, n).astype(np.float32)
    if kind == "brush":
        y = np.convolve(y, np.ones(96, dtype=np.float32) / 96, mode="same").astype(np.float32)
        env = np.exp(-np.linspace(0, 5.5, n, dtype=np.float32))
    elif kind == "shaker":
        y = np.convolve(y, np.ones(12, dtype=np.float32) / 12, mode="same").astype(np.float32)
        env = np.exp(-np.linspace(0, 12, n, dtype=np.float32))
    else:
        y = np.convolve(y, np.ones(320, dtype=np.float32) / 320, mode="same").astype(np.float32)
        env = adsr(n, 0.04, 0.1, 0.9, 0.08)
    y *= env * amp
    i0 = int(round(start * SR))
    if i0 >= len(buf):
        return
    i1 = min(len(buf), i0 + n)
    left, right = pan_gains(pan)
    buf[i0:i1, 0] += y[: i1 - i0] * left
    buf[i0:i1, 1] += y[: i1 - i0] * right


def add_air(buf: np.ndarray, amp: float, name: str) -> None:
    n = len(buf)
    r = rng_for(name)
    low_n = max(8, int(n / (SR / 7)))
    x = np.linspace(0, low_n - 1, n, dtype=np.float32)
    idx = np.arange(low_n, dtype=np.float32)
    left = np.interp(x, idx, r.normal(0, 1, low_n).astype(np.float32)).astype(np.float32)
    right = np.interp(x, idx, r.normal(0, 1, low_n).astype(np.float32)).astype(np.float32)
    env = (0.7 + 0.3 * np.sin(2 * np.pi * np.arange(n) / SR / 11.0)).astype(np.float32)
    buf[:, 0] += left * amp * env
    buf[:, 1] += right * amp * env


PROG = [
    [48, 55, 60, 64, 67, 71],
    [47, 55, 59, 62, 67, 71],
    [45, 52, 57, 60, 64, 69],
    [41, 48, 53, 57, 60, 64],
    [38, 45, 50, 57, 62, 65],
    [43, 50, 55, 59, 62, 65],
    [40, 47, 52, 55, 59, 64],
    [41, 48, 53, 57, 60, 67],
]
MOTIF = [72, 76, 79, 81, 79, 76, 74, 72]
MOTIF_DURS = [0.5, 0.5, 0.75, 0.75, 0.5, 0.5, 0.75, 1.0]


def add_chord_pad(buf: np.ndarray, start: float, dur: float, chord: list[int], instr: str, amp: float, name: str) -> None:
    notes = chord[2:]
    for i, midi in enumerate(notes):
        pan = -0.32 + 0.64 * (i / max(1, len(notes) - 1))
        add_note(buf, start, dur, midi, instr, amp / (len(notes) ** 0.65), pan, f"{name}:{midi}")


def render_yard(asset_id: str, variant: str, bpm: float, bars: int, melody_instr: str, melody_shift: int) -> tuple[dict, dict]:
    length = bars * bar_time(bpm)
    stem_names = [(1, "bed"), (2, "melody"), (3, "texture"), (4, "perc"), (5, "lux_a"), (6, "lux_b")]
    stems = {f"{asset_id}__st{i}_{name}": new_buf(length) for i, name in stem_names}
    bt, bd = beat_time(bpm), bar_time(bpm)
    for bar in range(bars):
        t0 = bar * bd
        chord = PROG[bar % len(PROG)]
        bed = stems[f"{asset_id}__st1_bed"]
        melody = stems[f"{asset_id}__st2_melody"]
        texture = stems[f"{asset_id}__st3_texture"]
        perc = stems[f"{asset_id}__st4_perc"]
        lux_a = stems[f"{asset_id}__st5_lux_a"]
        lux_b = stems[f"{asset_id}__st6_lux_b"]

        add_note(bed, t0, bd * 0.95, chord[0], "felt_piano", 0.36, -0.08, f"{asset_id}:bass:{bar}")
        for j, midi in enumerate([chord[2], chord[3], chord[4], chord[5], chord[3], chord[4]]):
            add_note(bed, t0 + [0, 0.55, 1.10, 1.85, 2.55, 3.15][j] * bt, bd * 0.75, midi, "nylon_guitar", 0.25, -0.28 if j % 2 else 0.22, f"{asset_id}:gtr:{bar}:{j}")
        if bar % 2 == 0:
            for j, midi in enumerate(chord[2:5]):
                add_note(bed, t0 + 2 * bt, bd * 0.8, midi, "felt_piano", 0.12, -0.12 + 0.12 * j, f"{asset_id}:pno:{bar}:{j}")

        add_chord_pad(texture, t0, bd * 1.1, chord, "clarinet", 0.16 if variant != "night" else 0.12, f"{asset_id}:tex:{bar}")
        if bar % 2 == 0:
            add_note(texture, t0, bd * 2, chord[1] + 12, "hum" if variant != "night" else "glass_vibes", 0.12 if variant != "night" else 0.08, 0, f"{asset_id}:texlow:{bar}")

        if variant != "night":
            for beat in range(4):
                add_noise_burst(perc, t0 + beat * bt, 0.11, 0.033, -0.15, "brush", f"{asset_id}:br:{bar}:{beat}")
                if beat in (1, 3):
                    add_noise_burst(perc, t0 + (beat + 0.5) * bt, 0.07, 0.020, 0.28, "shaker", f"{asset_id}:sh:{bar}:{beat}")
        elif bar % 2 == 0:
            add_noise_burst(perc, t0 + 2 * bt, 0.18, 0.011, 0.1, "brush", f"{asset_id}:nbr:{bar}")

        for j, midi in enumerate([chord[4] + 12, chord[3] + 12, chord[5] + 12, chord[4] + 12]):
            add_note(lux_a, t0 + (j + 0.25) * bt, 0.55 * bt, midi, "pizz_strings", 0.16, -0.25 + 0.16 * j, f"{asset_id}:pizz:{bar}:{j}")
        if bar % 8 in (6, 7):
            add_note(lux_a, t0 + 1.1 * bt, 1.2 * bt, 76 + melody_shift + (2 if bar % 8 == 7 else 0), "whistle", 0.20, 0.35, f"{asset_id}:wh:{bar}")

        if bar % 2 == 0:
            add_chord_pad(lux_b, t0, bd * 2, chord, "accordion", 0.17, f"{asset_id}:acc:{bar}")
            add_note(lux_b, t0 + bd * 0.55, bd * 1.1, chord[2] + 12, "hum", 0.18, -0.18, f"{asset_id}:hum:{bar}")

        breath = asset_id == "bgm_yard_day" and 20 <= bar < 28
        if bar % 8 in (0, 1, 2, 3) and not breath:
            cur = t0 + (0.25 if variant == "day" else 0.5) * bt
            for idx, midi in enumerate(MOTIF):
                dur_beats = MOTIF_DURS[idx] * (1.15 if variant == "dusk" else (1.45 if variant == "night" else 1.0))
                if variant == "night" and idx % 2 == 1:
                    cur += dur_beats * bt
                    continue
                add_note(melody, cur, max(0.18, dur_beats * bt * 0.92), midi + melody_shift, melody_instr, 0.34 if variant != "night" else 0.24, 0.05, f"{asset_id}:mel:{bar}:{idx}")
                cur += dur_beats * bt

    add_air(stems[f"{asset_id}__st3_texture"], 0.0055 if variant != "night" else 0.004, f"{asset_id}:air")
    return stems, loop_meta(length, bpm, bars)


def loop_meta(length: float, bpm: float, bars: int | None) -> dict:
    return {
        "duration": length,
        "bpm": bpm,
        "bars": bars,
        "time_signature": "4/4",
        "key": "C major / A minor family",
        "loop": True,
        "loop_start": 0,
        "loop_end": int(round(length * SR)),
    }


def render_season(asset_id: str, season: str, variant: str, bpm: float, bars: int) -> tuple[dict, dict]:
    length = bars * bar_time(bpm)
    stem_id = f"{asset_id}__{variant}"
    buf = new_buf(length)
    bt, bd = beat_time(bpm), bar_time(bpm)
    for bar in range(bars):
        t0 = bar * bd
        chord = PROG[bar % len(PROG)]
        if season == "spring":
            if bar % 4 in (0, 2):
                for j, midi in enumerate([76, 79, 81, 79]):
                    add_note(buf, t0 + (0.3 + j * 0.45) * bt, 0.42 * bt, midi, "recorder", 0.14, -0.2 + 0.13 * j, f"{stem_id}:spring:{bar}:{j}")
            add_noise_burst(buf, t0 + 3.2 * bt, 0.16, 0.010, 0.3, "paper", f"{stem_id}:windbell:{bar}")
        elif season == "summer":
            for j, midi in enumerate([chord[3] + 12, chord[4] + 12]):
                add_note(buf, t0 + (0.5 + j) * bt, 0.5 * bt, midi, "marimba", 0.16, -0.22 if j == 0 else 0.24, f"{stem_id}:summer:{bar}:{j}")
            if bar % 2 == 0:
                add_noise_burst(buf, t0 + 2.5 * bt, 0.08, 0.012, 0.1, "shaker", f"{stem_id}:sumshake:{bar}")
        elif season == "autumn":
            if bar % 2 == 0:
                add_note(buf, t0 + 0.2 * bt, bd * 1.4, chord[3] + 12, "accordion", 0.13, -0.1, f"{stem_id}:autacc:{bar}")
                add_note(buf, t0 + 2.3 * bt, 0.8 * bt, chord[4] + 12, "nylon_guitar", 0.14, 0.25, f"{stem_id}:autg:{bar}")
        else:
            if bar % 2 == 0:
                for j, midi in enumerate([chord[2] + 24, chord[4] + 24, chord[5] + 24]):
                    add_note(buf, t0 + (0.4 + j * 0.75) * bt, 1.4 * bt, midi, "celesta", 0.12, -0.25 + 0.25 * j, f"{stem_id}:winter:{bar}:{j}")
                add_chord_pad(buf, t0, bd * 2, [m + 12 for m in chord], "clarinet", 0.055, f"{stem_id}:winterpad:{bar}")
    add_air(buf, 0.0035, f"{stem_id}:air")
    meta = loop_meta(length, bpm, bars)
    meta["season_variant"] = variant
    return {stem_id: buf}, meta


def render_revisit(asset_id: str, variant: str, bpm: float, bars: int) -> tuple[dict, dict]:
    length = bars * bar_time(bpm)
    stem_id = f"{asset_id}__{variant}"
    buf = new_buf(length)
    bt, bd = beat_time(bpm), bar_time(bpm)
    for bar in range(bars):
        if bar % 16 in (0, 1, 2):
            t0 = bar * bd
            for j, midi in enumerate([72, 76, 79, 76, 74, 72]):
                add_note(buf, t0 + (0.2 + j * 0.7) * bt, 0.65 * bt, midi, "harmonica" if j < 4 else "whistle", 0.13, 0.1, f"{stem_id}:rev:{bar}:{j}")
    meta = loop_meta(length, bpm, bars)
    meta["revisit_variant"] = variant
    return {stem_id: buf}, meta


def render_simple_loop(asset_id: str, seconds: float, bpm: float, bars: int, kind: str, stem_names: list[str]) -> tuple[dict, dict]:
    stems = {f"{asset_id}__st{i+1}_{stem_names[i]}": new_buf(seconds) for i in range(len(stem_names))}
    bt, bd = beat_time(bpm), bar_time(bpm)
    for bar in range(bars):
        t0 = bar * bd
        chord = PROG[bar % len(PROG)]
        if kind == "opening":
            if bar < 4 or bar % 2 == 0:
                for j, midi in enumerate([72, 76, 79, 76] if bar % 4 != 3 else [74, 79, 81, 79]):
                    add_note(stems[f"{asset_id}__st1_piano"], t0 + j * 0.9 * bt, 1.4 * bt, midi, "felt_piano", 0.24, -0.1 + 0.08 * j, f"{asset_id}:pno:{bar}:{j}")
            if bar == 0:
                add_air(stems[f"{asset_id}__st2_texture"], 0.0028, f"{asset_id}:air")
            if bar % 3 == 0:
                add_chord_pad(stems[f"{asset_id}__st2_texture"], t0, bd * 2, chord, "clarinet", 0.055, f"{asset_id}:tex:{bar}")
        elif kind == "adoption":
            for j, midi in enumerate([chord[2], chord[3], chord[4], chord[5], chord[4], chord[3]]):
                add_note(stems[f"{asset_id}__st1_guitar"], t0 + [0, 0.45, 0.9, 1.5, 2.25, 3.0][j] * bt, bd * 0.55, midi + 12, "nylon_guitar", 0.21, -0.25 if j % 2 else 0.22, f"{asset_id}:g:{bar}:{j}")
            if bar % 2 == 0:
                for j, midi in enumerate([72, 76, 79, 81, 79]):
                    add_note(stems[f"{asset_id}__st2_kalimba"], t0 + (0.4 + j * 0.55) * bt, 0.42 * bt, midi, "kalimba", 0.21, -0.1 + 0.07 * j, f"{asset_id}:k:{bar}:{j}")
        elif kind == "postcard":
            add_chord_pad(stems[f"{asset_id}__st1_bed"], t0, bd * 1.2, chord, "felt_piano", 0.12, f"{asset_id}:bed:{bar}")
            for j, midi in enumerate([chord[2] + 12, chord[4] + 12, chord[5] + 12, chord[4] + 12]):
                add_note(stems[f"{asset_id}__st1_bed"], t0 + j * 0.8 * bt, bt, midi, "nylon_guitar", 0.13, -0.2 if j % 2 else 0.25, f"{asset_id}:g:{bar}:{j}")
            if bar % 4 in (0, 1):
                for j, midi in enumerate([69, 72, 74, 76, 74, 72]):
                    add_note(stems[f"{asset_id}__st2_melody"], t0 + (0.2 + j * 0.55) * bt, 0.5 * bt, midi, "whistle", 0.17, 0.15, f"{asset_id}:mel:{bar}:{j}")
            if bar % 2 == 0:
                add_chord_pad(stems[f"{asset_id}__st3_accordion"], t0, bd * 2, chord, "accordion", 0.12, f"{asset_id}:acc:{bar}")
        elif kind == "album":
            if bar % 2 == 0:
                for j, midi in enumerate([chord[2] + 12, chord[3] + 12, chord[4] + 12]):
                    add_note(stems[f"{asset_id}__st1_piano"], t0 + j * 1.1 * bt, bd, midi, "felt_piano", 0.13, -0.1 + 0.1 * j, f"{asset_id}:pn:{bar}:{j}")
            add_chord_pad(stems[f"{asset_id}__st2_texture"], t0, bd * 1.4, chord, "vibraphone", 0.08, f"{asset_id}:tex:{bar}")
        elif kind == "shop":
            for j, midi in enumerate([chord[2] + 12, chord[3] + 12, chord[4] + 12, chord[5] + 12]):
                add_note(stems[f"{asset_id}__st1_marimba_whistle"], t0 + (0.2 + j * 0.55) * bt, 0.42 * bt, midi, "marimba", 0.18, -0.2 + 0.13 * j, f"{asset_id}:mar:{bar}:{j}")
            if bar % 4 in (2, 3):
                add_note(stems[f"{asset_id}__st1_marimba_whistle"], t0 + 1.2 * bt, bt, 76, "whistle", 0.12, 0.22, f"{asset_id}:wh:{bar}")
            for beat in (0, 2):
                add_noise_burst(stems[f"{asset_id}__st2_light_perc"], t0 + beat * bt, 0.10, 0.018, 0.1, "brush", f"{asset_id}:br:{bar}:{beat}")
                add_noise_burst(stems[f"{asset_id}__st2_light_perc"], t0 + (beat + 0.5) * bt, 0.08, 0.014, -0.2, "shaker", f"{asset_id}:sh:{bar}:{beat}")
        else:
            add_chord_pad(stems[f"{asset_id}__st1_bed"], t0, bd * 1.5, [m + 12 for m in chord], "vibraphone", 0.075, f"{asset_id}:evt:{bar}")
            if bar % 3 == 0:
                add_note(stems[f"{asset_id}__st1_bed"], t0 + 1.5 * bt, 2 * bt, chord[4] + 24, "glass_vibes", 0.08, 0.25, f"{asset_id}:bell:{bar}")
    for sid, buf in stems.items():
        if kind in {"album", "event"}:
            add_air(buf, 0.0032, f"{sid}:air")
    meta = loop_meta(seconds, bpm, bars)
    if kind == "opening":
        meta["loop"] = True
        meta["loop_start"] = int(round(12 * bd * SR))
    return stems, meta


def render_graduation() -> tuple[dict, dict]:
    asset_id = "bgm_graduation"
    seconds = 170.0
    stems = {
        f"{asset_id}__st1_memory": new_buf(seconds),
        f"{asset_id}__st2_departure": new_buf(seconds),
        f"{asset_id}__st3_farewell": new_buf(seconds),
    }
    bpm, bt, bd = 72, beat_time(72), bar_time(72)
    for bar in range(16):
        t0 = bar * bd
        chord = PROG[bar % len(PROG)]
        for j, midi in enumerate([chord[2] + 12, chord[3] + 12, chord[4] + 12]):
            add_note(stems[f"{asset_id}__st1_memory"], t0 + j * 1.15 * bt, 1.8 * bt, midi, "felt_piano", 0.16, -0.1 + 0.1 * j, f"grad:mem:{bar}:{j}")
        if bar % 4 == 0:
            add_note(stems[f"{asset_id}__st1_memory"], t0 + 2.3 * bt, 2.2 * bt, 72, "hum", 0.08, 0.15, f"grad:hum:{bar}")
    for bar in range(20):
        t0 = 52.0 + bar * bd
        chord = PROG[(bar + 2) % len(PROG)]
        add_note(stems[f"{asset_id}__st2_departure"], t0, bd * 0.9, chord[0] + 12, "felt_piano", 0.18, -0.12, f"grad:depbass:{bar}")
        for j, midi in enumerate([chord[2] + 12, chord[3] + 12, chord[4] + 12, chord[5] + 12]):
            add_note(stems[f"{asset_id}__st2_departure"], t0 + (j * 0.7 + 0.1) * bt, bt, midi, "nylon_guitar", 0.13 + 0.004 * bar, -0.22 + 0.14 * j, f"grad:g:{bar}:{j}")
        add_chord_pad(stems[f"{asset_id}__st2_departure"], t0, bd * 1.2, chord, "clarinet", 0.08 + 0.002 * bar, f"grad:str:{bar}")
        if bar % 4 in (0, 1):
            for j, midi in enumerate([72, 76, 79, 81, 83, 81, 79, 76]):
                add_note(stems[f"{asset_id}__st2_departure"], t0 + (0.2 + j * 0.45) * bt, 0.42 * bt, midi, "kalimba" if bar < 10 else "whistle", 0.14 + 0.004 * bar, 0.08, f"grad:mel:{bar}:{j}")
    for bar in range(15):
        t0 = 120.0 + bar * bd
        chord = PROG[(bar + 4) % len(PROG)]
        add_chord_pad(stems[f"{asset_id}__st3_farewell"], t0, bd * 1.4, chord, "accordion", 0.11, f"grad:acc:{bar}")
        if bar % 2 == 0:
            for j, midi in enumerate([76, 79, 81, 84, 83, 79]):
                add_note(stems[f"{asset_id}__st3_farewell"], t0 + (0.25 + j * 0.55) * bt, 0.55 * bt, midi, "whistle", 0.15, 0.22, f"grad:wh:{bar}:{j}")
        if bar in (12, 13, 14):
            add_bell_swell(stems[f"{asset_id}__st3_farewell"], t0 + 1.2 * bt, 2.4 * bt, 72, 0.15, f"grad:end:{bar}")
    add_air(stems[f"{asset_id}__st1_memory"], 0.0026, "grad:air1")
    add_air(stems[f"{asset_id}__st3_farewell"], 0.0028, "grad:air3")
    return stems, {
        "duration": seconds,
        "bpm": bpm,
        "bars": None,
        "time_signature": "4/4",
        "key": "C major / A minor family",
        "loop": False,
        "loop_start": None,
        "loop_end": None,
    }


def add_bell_swell(buf: np.ndarray, start: float, dur: float, root_midi: int, amp: float, name: str) -> None:
    for off, delay, pan, instr in [(0, 0, -0.25, "felt_piano"), (7, 0.08, 0.2, "kalimba"), (12, 0.16, 0.05, "vibraphone"), (16, 0.24, 0.35, "music_box")]:
        add_note(buf, start + delay, max(0.1, dur - delay), root_midi + off, instr, amp * (0.7 if off else 1.0), pan, f"{name}:{off}")


def render_sting(asset_id: str, seconds: float) -> np.ndarray:
    buf = new_buf(seconds)
    if asset_id == "sting_levelup":
        for i, midi in enumerate([72, 76, 79]):
            add_note(buf, 0.12 + i * 0.22, 0.8, midi, "kalimba", 0.45, -0.15 + i * 0.15, asset_id)
        add_noise_burst(buf, 0.52, 0.35, 0.02, 0, "paper", asset_id)
    elif asset_id.startswith("sting_evolve"):
        root = {"sting_evolve_b": 72, "sting_evolve_c": 74, "sting_evolve_d": 76}[asset_id]
        add_bell_swell(buf, 0.1, seconds * 0.8, root, 0.45, asset_id)
        for i in range(5):
            add_noise_burst(buf, 0.35 + i * 0.38, 0.22, 0.018, -0.3 + 0.15 * i, "paper", f"{asset_id}:wash:{i}")
        if asset_id == "sting_evolve_d":
            for i, midi in enumerate([76, 79, 81, 84]):
                add_note(buf, 1.0 + i * 0.42, 0.9, midi, "whistle", 0.22, 0.2, f"{asset_id}:far:{i}")
    elif asset_id == "sting_graduation_depart":
        for i, midi in enumerate([76, 79, 81, 84, 83, 79, 76]):
            add_note(buf, 0.1 + i * 0.38, 0.75, midi, "whistle", 0.25 * (1 - i * 0.06), 0.15 + i * 0.05, asset_id)
        add_note(buf, 2.9, 1.0, 84, "music_box", 0.18, 0.35, f"{asset_id}:bell")
    elif asset_id == "sting_adoption_welcome":
        for i, midi in enumerate([72, 76, 79, 84]):
            add_note(buf, 0.12 + i * 0.25, 1.0, midi, "music_box", 0.35, -0.15 + i * 0.1, asset_id)
        add_chord_pad(buf, 1.05, 1.1, PROG[0], "felt_piano", 0.32, f"{asset_id}:chord")
    elif asset_id == "sting_achievement":
        add_noise_burst(buf, 0.05, 0.25, 0.045, 0, "paper", f"{asset_id}:stamp")
        for i, midi in enumerate([76, 79]):
            add_note(buf, 0.28 + i * 0.25, 0.8, midi, "ocarina", 0.26, 0.1, asset_id)
    elif asset_id == "sting_achievement_hidden":
        add_note(buf, 0.05, 0.8, 91, "glass_vibes", 0.18, -0.2, asset_id)
        add_bell_swell(buf, 0.65, 1.1, 72, 0.28, f"{asset_id}:resolve")
    elif asset_id == "sting_egg_unlock":
        for i, midi in enumerate([84, 88, 91, 96, 91, 88, 84]):
            add_note(buf, 0.12 + i * 0.28, 0.9, midi, "celesta", 0.24, -0.3 + i * 0.1, asset_id)
        add_chord_pad(buf, 1.5, 1.2, [60, 64, 67, 72, 76], "hum", 0.16, f"{asset_id}:magic")
    elif asset_id == "sting_first_snow":
        add_note(buf, 0.55, 1.5, 91, "glass_vibes", 0.20, 0.0, asset_id)
        add_chord_pad(buf, 0.95, 1.8, [60, 64, 67, 72], "clarinet", 0.10, f"{asset_id}:white")
    elif asset_id == "sting_meteor":
        for i, midi in enumerate([96, 95, 93, 91, 88]):
            add_note(buf, 0.1 + i * 0.16, 0.7, midi, "glass_vibes", 0.18, -0.4 + i * 0.2, asset_id)
        add_note(buf, 1.45, 0.7, 48, "felt_piano", 0.28, 0.0, f"{asset_id}:heart")
    elif asset_id == "sting_fullmoon":
        for i, midi in enumerate([72, 76, 79, 81, 79, 76]):
            add_note(buf, 0.1 + i * 0.38, 0.8, midi, "accordion", 0.20, -0.08, asset_id)
        add_note(buf, 1.0, 1.4, 72, "hum", 0.12, 0.22, f"{asset_id}:hum")
    elif asset_id == "sting_birthday":
        for i, midi in enumerate([72, 72, 74, 72, 77, 76]):
            add_note(buf, 0.12 + i * 0.26, 0.5, midi, "kalimba", 0.25, -0.1 + 0.04 * i, asset_id)
        add_noise_burst(buf, 1.55, 0.35, 0.018, 0, "brush", f"{asset_id}:clap")
    elif asset_id == "sting_rainbow":
        for i, midi in enumerate([72, 74, 76, 77, 79, 81, 83]):
            add_note(buf, 0.1 + i * 0.16, 0.65, midi, "celesta", 0.22, -0.35 + i * 0.12, asset_id)
        add_note(buf, 1.35, 0.8, 86, "glass_vibes", 0.12, 0.3, f"{asset_id}:expect")
    elif asset_id == "sting_bonfire":
        for i in range(7):
            add_noise_burst(buf, 0.05 + i * 0.28, 0.12, 0.018, -0.2 + 0.08 * (i % 5), "shaker", f"{asset_id}:fire:{i}")
        for i, midi in enumerate([69, 72, 74, 76, 74]):
            add_note(buf, 0.42 + i * 0.38, 0.65, midi, "ocarina", 0.19, 0.18, asset_id)
    else:
        add_bell_swell(buf, 0.1, seconds * 0.75, 72, 0.28, asset_id)
    add_air(buf, 0.0018, f"{asset_id}:air")
    return buf


def apply_reverb(audio: np.ndarray, amount: float) -> np.ndarray:
    wet = np.zeros_like(audio)
    for i, (delay, gain) in enumerate([(0.041, 0.28), (0.073, 0.20), (0.117, 0.13), (0.181, 0.08)]):
        n = int(delay * SR)
        if n < len(audio):
            wet[n:, 0] += audio[:-n, 1 if i % 2 else 0] * gain
            wet[n:, 1] += audio[:-n, 0 if i % 2 else 1] * gain
        n2 = n * 2
        if n2 < len(audio):
            wet[n2:] += audio[:-n2] * (gain * 0.35)
    return (audio * (1 - amount) + wet * amount).astype(np.float32)


def make_loopable(audio: np.ndarray, fade_ms: int = 60) -> np.ndarray:
    n = min(len(audio) // 4, int(SR * fade_ms / 1000))
    if n <= 8:
        return audio
    fade = np.linspace(0, 1, n, dtype=np.float32)[:, None]
    blended = audio[:n] * fade + audio[-n:] * (1 - fade)
    audio[:n] = blended
    audio[-n:] = blended
    return audio


def normalize_group(stems: dict[str, np.ndarray], target_lufs: float, peak_db: float, loop: bool) -> tuple[dict[str, np.ndarray], np.ndarray]:
    proc: dict[str, np.ndarray] = {}
    for sid, audio in stems.items():
        amount = 0.07 if "perc" in sid else 0.13
        out = apply_reverb(audio, amount)
        if "perc" in sid:
            out *= 7.5
        if loop:
            out = make_loopable(out)
        else:
            n = min(len(out) // 4, int(0.03 * SR))
            if n > 0:
                fade = np.linspace(0, 1, n, dtype=np.float32)[:, None]
                out[:n] *= fade
                out[-n:] *= fade[::-1]
        proc[sid] = out

    mix = np.zeros_like(next(iter(proc.values())))
    for audio in proc.values():
        mix += audio
    mix = (np.tanh(mix * 1.08) / np.tanh(np.float32(1.08))).astype(np.float32)
    mix -= mix.mean(axis=0, keepdims=True)
    rms = float(np.sqrt(np.mean(mix**2) + 1e-12))
    gain = db_to_amp(target_lufs - 20 * math.log10(rms + 1e-12))
    peak_limit = db_to_amp(peak_db)
    peak = float(np.max(np.abs(mix * gain)))
    if peak > peak_limit:
        gain *= peak_limit / peak
    for key in proc:
        proc[key] = (proc[key] * gain).astype(np.float32)
    return proc, (mix * gain).astype(np.float32)


def metrics(audio: np.ndarray) -> dict:
    rms = float(np.sqrt(np.mean(audio**2) + 1e-12))
    peak = float(np.max(np.abs(audio)) + 1e-12)
    return {"approx_lufs": round(20 * math.log10(rms), 2), "peak_dbfs": round(20 * math.log10(peak), 2)}


def write_wav24(path: Path, audio: np.ndarray, loop_start: int | None = None, loop_end: int | None = None) -> None:
    audio = np.clip(audio, -0.995, 0.995)
    vals = np.round(audio.reshape(-1) * ((1 << 23) - 1)).astype(np.int32)
    vals = np.where(vals < 0, vals + (1 << 24), vals).astype(np.uint32)
    raw = np.empty((vals.size, 3), dtype=np.uint8)
    raw[:, 0] = vals & 0xFF
    raw[:, 1] = (vals >> 8) & 0xFF
    raw[:, 2] = (vals >> 16) & 0xFF
    data = raw.tobytes()
    channels, bits = 2, 24
    block_align = channels * 3
    fmt = struct.pack("<HHIIHH", 1, channels, SR, SR * block_align, block_align, bits)
    chunks = [(b"fmt ", fmt)]
    if loop_start is not None and loop_end is not None:
        sample_period = int(round(1_000_000_000 / SR))
        smpl_header = struct.pack("<IIIIIIIII", 0, 0, sample_period, 60, 0, 0, 0, 1, 0)
        smpl_loop = struct.pack("<IIIIII", 0, 0, int(loop_start), max(int(loop_start), int(loop_end) - 1), 0, 0)
        chunks.append((b"smpl", smpl_header + smpl_loop))
    chunks.append((b"data", data))
    riff_size = 4 + sum(8 + len(payload) + (len(payload) % 2) for _, payload in chunks)
    with path.open("wb") as handle:
        handle.write(b"RIFF")
        handle.write(struct.pack("<I", riff_size))
        handle.write(b"WAVE")
        for chunk_id, payload in chunks:
            handle.write(chunk_id)
            handle.write(struct.pack("<I", len(payload)))
            handle.write(payload)
            if len(payload) % 2:
                handle.write(b"\x00")


def convert_ogg(wav_path: Path, ogg_path: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-y", "-v", "error", "-i", str(wav_path), "-c:a", "vorbis", "-strict", "-2", "-q:a", "6", str(ogg_path)],
        check=True,
    )


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def register(manifest: dict, asset_id: str, category: str, role: str, wav: Path, ogg: Path, audio: np.ndarray, meta: dict) -> None:
    entry = {
        "asset_id": asset_id,
        "category": category,
        "role": role,
        "duration_seconds": round(len(audio) / SR, 3),
        "bpm": meta.get("bpm"),
        "time_signature": meta.get("time_signature"),
        "key": meta.get("key"),
        "loop": bool(meta.get("loop")),
        "loop_start_sample": meta.get("loop_start"),
        "loop_end_sample": meta.get("loop_end"),
        "wav": str(wav.relative_to(ROOT)),
        "ogg": str(ogg.relative_to(ROOT)),
        "metrics": metrics(audio),
        "sha256_wav": sha256(wav),
        "sha256_ogg": sha256(ogg),
    }
    for key in ["bars", "season_variant", "revisit_variant"]:
        if key in meta:
            entry[key] = meta[key]
    manifest["assets"].append(entry)


def save_stem_group(manifest: dict, asset_id: str, stems: dict[str, np.ndarray], meta: dict, write_mix: bool, target: float) -> None:
    loop = bool(meta.get("loop"))
    proc, mix = normalize_group(stems, target, -1.0, loop)
    loop_start = meta.get("loop_start") if loop else None
    loop_end = meta.get("loop_end") if loop else None
    for sid, audio in proc.items():
        wav = BGM_STEM_WAV / f"{sid}.wav"
        ogg = BGM_STEM_OGG / f"{sid}.ogg"
        write_wav24(wav, audio, loop_start, loop_end)
        convert_ogg(wav, ogg)
        register(manifest, sid, "bgm", "stem", wav, ogg, audio, meta)
    if write_mix:
        wav = BGM_MIX_WAV / f"{asset_id}.wav"
        ogg = BGM_MIX_OGG / f"{asset_id}.ogg"
        write_wav24(wav, mix, loop_start, loop_end)
        convert_ogg(wav, ogg)
        register(manifest, asset_id, "bgm", "mix", wav, ogg, mix, meta)
    print(f"generated {asset_id}: {len(proc)} stems" + (" + mix" if write_mix else ""), flush=True)


def save_sting(manifest: dict, asset_id: str, seconds: float) -> None:
    proc, mix = normalize_group({asset_id: render_sting(asset_id, seconds)}, -14.0, -1.0, False)
    wav = STING_WAV / f"{asset_id}.wav"
    ogg = STING_OGG / f"{asset_id}.ogg"
    write_wav24(wav, mix)
    convert_ogg(wav, ogg)
    meta = {
        "duration": seconds,
        "bpm": None,
        "time_signature": None,
        "key": "C major / A minor family motif variant",
        "loop": False,
        "loop_start": None,
        "loop_end": None,
    }
    register(manifest, asset_id, "sting", "one-shot", wav, ogg, mix, meta)
    print(f"generated {asset_id}", flush=True)


def main() -> None:
    ensure_dirs()
    manifest = {
        "project": "Petopia",
        "generated_at_local": time.strftime("%Y-%m-%d %H:%M:%S %Z"),
        "scope": "music only: bgm_* and sting_* assets from docs/spec-audio.md",
        "source_policy": "Programmatic original synthesis. No third-party samples, loops, reference audio, artist-name prompts, or commercial melodies used.",
        "technical_defaults": {
            "sample_rate_hz": SR,
            "wav_codec": "PCM 24-bit little-endian",
            "ogg_codec": "Vorbis q6 via ffmpeg native vorbis encoder",
            "channels": "stereo",
        },
        "assets": [],
    }

    yard_specs = [
        ("bgm_yard_day", "day", 72, 48, "kalimba", 0),
        ("bgm_yard_dusk", "dusk", 68, 40, "ocarina", -2),
        ("bgm_yard_night", "night", 72, 45, "glass_vibes", -12),
    ]
    for spec in yard_specs:
        stems, meta = render_yard(*spec)
        save_stem_group(manifest, spec[0], stems, meta, True, -16.0)

    for season in ["spring", "summer", "autumn", "winter"]:
        for _, variant, bpm, bars, _, _ in yard_specs:
            stems, meta = render_season(f"bgm_yard_stem_{season}", season, variant, bpm, bars)
            save_stem_group(manifest, f"bgm_yard_stem_{season}_{variant}", stems, meta, False, -20.0)

    context_specs = [
        ("bgm_opening", 70.0, 72, 21, "opening", ["piano", "texture"]),
        ("bgm_adoption", 90.0, 80, 30, "adoption", ["guitar", "kalimba"]),
        ("bgm_postcard_read", 110.0, 72, 33, "postcard", ["bed", "melody", "accordion"]),
        ("bgm_album_browse", 130.0, 72, 39, "album", ["piano", "texture"]),
        ("bgm_shop", 100.0, 84, 35, "shop", ["marimba_whistle", "light_perc"]),
        ("bgm_event_special_bed", 80.0, 72, 24, "event", ["bed"]),
    ]
    for asset_id, seconds, bpm, bars, kind, stemspec in context_specs:
        stems, meta = render_simple_loop(asset_id, seconds, bpm, bars, kind, stemspec)
        save_stem_group(manifest, asset_id, stems, meta, True, -16.0)

    stems, meta = render_graduation()
    save_stem_group(manifest, "bgm_graduation", stems, meta, True, -16.0)

    for _, variant, bpm, bars, _, _ in yard_specs:
        stems, meta = render_revisit("bgm_revisit_overlay", variant, bpm, bars)
        save_stem_group(manifest, f"bgm_revisit_overlay_{variant}", stems, meta, False, -20.0)

    stingers = {
        "sting_levelup": 1.5,
        "sting_evolve_b": 3.0,
        "sting_evolve_c": 3.0,
        "sting_evolve_d": 3.5,
        "sting_graduation_depart": 4.0,
        "sting_adoption_welcome": 2.5,
        "sting_achievement": 1.5,
        "sting_achievement_hidden": 2.0,
        "sting_egg_unlock": 3.0,
        "sting_first_snow": 3.0,
        "sting_meteor": 2.5,
        "sting_fullmoon": 3.0,
        "sting_birthday": 2.5,
        "sting_rainbow": 2.0,
        "sting_bonfire": 3.0,
    }
    for asset_id, seconds in stingers.items():
        save_sting(manifest, asset_id, seconds)

    manifest["counts"] = {
        "bgm_entries": sum(1 for asset in manifest["assets"] if asset["category"] == "bgm"),
        "sting_entries": sum(1 for asset in manifest["assets"] if asset["category"] == "sting"),
        "file_pairs": len(manifest["assets"]),
    }
    manifest_path = PROV / "music_provenance_manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {manifest_path.relative_to(ROOT)} with {len(manifest['assets'])} entries", flush=True)


if __name__ == "__main__":
    main()
