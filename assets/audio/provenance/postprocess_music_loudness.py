#!/usr/bin/env python3
"""Post-process generated Petopia music loudness.

This keeps BGM stem groups phase/level-relative by applying one gain to each
mix group, and uses ffmpeg loudnorm for non-looping stingers.
"""

from __future__ import annotations

import hashlib
import json
import math
import shutil
import struct
import subprocess
import tempfile
import time
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[3]
SR = 48_000
REPORT = ROOT / "assets/audio/provenance/music_qa_loudnorm_report.json"
MANIFEST = ROOT / "assets/audio/provenance/music_provenance_manifest.json"


def db_to_amp(db: float) -> float:
    return 10 ** (db / 20)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_wav24(path: Path) -> tuple[np.ndarray, dict]:
    data = path.read_bytes()
    if data[:4] != b"RIFF" or data[8:12] != b"WAVE":
        raise ValueError(f"not a wav file: {path}")
    chunks: dict[bytes, bytes] = {}
    i = 12
    while i + 8 <= len(data):
        cid = data[i : i + 4]
        size = struct.unpack("<I", data[i + 4 : i + 8])[0]
        payload = data[i + 8 : i + 8 + size]
        chunks[cid] = payload
        i += 8 + size + (size % 2)
    fmt = chunks[b"fmt "]
    audio_format, channels, sample_rate, _, block_align, bits = struct.unpack("<HHIIHH", fmt[:16])
    if audio_format not in (1, 65534) or channels != 2 or sample_rate != SR or bits != 24 or block_align != 6:
        raise ValueError(f"unexpected wav format: {path}")
    raw = np.frombuffer(chunks[b"data"], dtype=np.uint8).reshape(-1, 3)
    vals = raw[:, 0].astype(np.uint32) | (raw[:, 1].astype(np.uint32) << 8) | (raw[:, 2].astype(np.uint32) << 16)
    signed = vals.astype(np.int32)
    signed[vals >= (1 << 23)] -= 1 << 24
    audio = (signed.astype(np.float32) / float((1 << 23) - 1)).reshape(-1, 2)
    loop_start = loop_end = None
    if b"smpl" in chunks:
        smpl = chunks[b"smpl"]
        if len(smpl) >= 60:
            loop_start = struct.unpack("<I", smpl[44:48])[0]
            loop_end_inclusive = struct.unpack("<I", smpl[48:52])[0]
            loop_end = loop_end_inclusive + 1
    return audio, {"loop_start": loop_start, "loop_end": loop_end}


def write_wav24(path: Path, audio: np.ndarray, loop_start: int | None = None, loop_end: int | None = None) -> None:
    audio = np.clip(audio, -0.995, 0.995)
    vals = np.round(audio.reshape(-1) * ((1 << 23) - 1)).astype(np.int32)
    vals = np.where(vals < 0, vals + (1 << 24), vals).astype(np.uint32)
    raw = np.empty((vals.size, 3), dtype=np.uint8)
    raw[:, 0] = vals & 0xFF
    raw[:, 1] = (vals >> 8) & 0xFF
    raw[:, 2] = (vals >> 16) & 0xFF
    payload = raw.tobytes()
    channels, bits = 2, 24
    block_align = channels * 3
    fmt = struct.pack("<HHIIHH", 1, channels, SR, SR * block_align, block_align, bits)
    chunks = [(b"fmt ", fmt)]
    if loop_start is not None and loop_end is not None:
        sample_period = int(round(1_000_000_000 / SR))
        smpl_header = struct.pack("<IIIIIIIII", 0, 0, sample_period, 60, 0, 0, 0, 1, 0)
        smpl_loop = struct.pack("<IIIIII", 0, 0, int(loop_start), max(int(loop_start), int(loop_end) - 1), 0, 0)
        chunks.append((b"smpl", smpl_header + smpl_loop))
    chunks.append((b"data", payload))
    riff_size = 4 + sum(8 + len(chunk) + (len(chunk) % 2) for _, chunk in chunks)
    with path.open("wb") as handle:
        handle.write(b"RIFF")
        handle.write(struct.pack("<I", riff_size))
        handle.write(b"WAVE")
        for chunk_id, chunk in chunks:
            handle.write(chunk_id)
            handle.write(struct.pack("<I", len(chunk)))
            handle.write(chunk)
            if len(chunk) % 2:
                handle.write(b"\x00")


def convert_ogg(wav: Path, ogg: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-y", "-v", "error", "-i", str(wav), "-c:a", "vorbis", "-strict", "-2", "-q:a", "6", str(ogg)],
        check=True,
    )


def approx_metrics(audio: np.ndarray) -> dict:
    rms = float(np.sqrt(np.mean(audio**2) + 1e-12))
    peak = float(np.max(np.abs(audio)) + 1e-12)
    return {"approx_lufs": round(20 * math.log10(rms), 2), "peak_dbfs": round(20 * math.log10(peak), 2)}


def apply_gain_to_wav(wav: Path, gain_db: float) -> None:
    audio, meta = read_wav24(wav)
    write_wav24(wav, audio * db_to_amp(gain_db), meta["loop_start"], meta["loop_end"])


def loudnorm_sting(wav: Path) -> None:
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td) / wav.name
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-v",
                "error",
                "-i",
                str(wav),
                "-af",
                "loudnorm=I=-14:TP=-1:LRA=7",
                "-ar",
                str(SR),
                "-ac",
                "2",
                "-c:a",
                "pcm_s24le",
                str(tmp),
            ],
            check=True,
        )
        shutil.copy2(tmp, wav)


def filter_wav(wav: Path, audio_filter: str) -> None:
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td) / wav.name
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-v",
                "error",
                "-i",
                str(wav),
                "-af",
                audio_filter,
                "-ar",
                str(SR),
                "-ac",
                "2",
                "-c:a",
                "pcm_s24le",
                str(tmp),
            ],
            check=True,
        )
        shutil.copy2(tmp, wav)


def main() -> None:
    report = json.loads(REPORT.read_text(encoding="utf-8"))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    by_id = {item["asset_id"]: item for item in report["items"]}

    # BGM mix groups: center mixes around -16 LUFS, preserving stem balance.
    group_gains: dict[str, float] = {}
    for item in report["items"]:
        if item["category"] == "bgm" and item["role"] == "mix":
            measured = float(item["ffmpeg_loudnorm"]["input_i"])
            true_peak = float(item["ffmpeg_loudnorm"]["input_tp"])
            gain = -16.0 - measured
            peak_cap = -1.0 - true_peak
            gain = min(gain, peak_cap)
            if abs(gain) < 0.15:
                gain = 0.0
            group_gains[item["asset_id"]] = gain

    touched: set[str] = set()
    for entry in manifest["assets"]:
        asset_id = entry["asset_id"]
        group = None
        if entry["category"] == "bgm":
            if entry["role"] == "mix":
                group = asset_id
            else:
                for mix_id in group_gains:
                    if asset_id.startswith(f"{mix_id}__"):
                        group = mix_id
                        break
        if group and group_gains.get(group, 0.0):
            apply_gain_to_wav(ROOT / entry["wav"], group_gains[group])
            convert_ogg(ROOT / entry["wav"], ROOT / entry["ogg"])
            touched.add(asset_id)

    # Stingers are one-shot, so loudnorm can safely remaster each file.
    manual_sting_filters = {
        "sting_evolve_b": "volume=-3.48dB",
        "sting_evolve_c": "volume=-3.47dB",
        "sting_evolve_d": "acompressor=threshold=-16dB:ratio=2:attack=5:release=120:makeup=1,volume=1dB,alimiter=limit=0.70",
    }
    for entry in manifest["assets"]:
        if entry["category"] == "sting":
            loudnorm_sting(ROOT / entry["wav"])
            if entry["asset_id"] in manual_sting_filters:
                filter_wav(ROOT / entry["wav"], manual_sting_filters[entry["asset_id"]])
            convert_ogg(ROOT / entry["wav"], ROOT / entry["ogg"])
            touched.add(entry["asset_id"])

    for entry in manifest["assets"]:
        wav = ROOT / entry["wav"]
        ogg = ROOT / entry["ogg"]
        if entry["asset_id"] in touched:
            audio, _ = read_wav24(wav)
            entry["metrics"] = approx_metrics(audio)
            entry["sha256_wav"] = sha256(wav)
            entry["sha256_ogg"] = sha256(ogg)

    manifest.setdefault("postprocess", []).append(
        {
            "time_local": time.strftime("%Y-%m-%d %H:%M:%S %Z"),
            "source_report": str(REPORT.relative_to(ROOT)),
            "bgm_group_gains_db": {k: round(v, 3) for k, v in sorted(group_gains.items()) if v},
            "stinger_loudnorm": "ffmpeg loudnorm=I=-14:TP=-1:LRA=7",
            "manual_sting_filters": manual_sting_filters,
        }
    )
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"postprocessed {len(touched)} files/assets")


if __name__ == "__main__":
    main()
