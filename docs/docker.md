# Arnis with Docker (no local Rust install)

This guide lets you compile and run Arnis in containers on Windows using Docker Desktop.

## 1) Build the CLI image (recommended)

```powershell
docker compose build cli
```

## 2) Run CLI generation (Java world)

Create host folders once:

```powershell
New-Item -ItemType Directory -Force -Path .\docker-data\output | Out-Null
New-Item -ItemType Directory -Force -Path .\docker-data\cache | Out-Null
```

Run a small test generation:

```powershell
docker compose run --rm cli --terrain --output-dir /workspace/output --bbox "22.05,-101.0643,22.2314,-100.8384"
```

Generated world files are written to:

- .\docker-data\output

Cache is persisted at:

- .\docker-data\cache

## 3) Run CLI generation (Bedrock .mcworld)

```powershell
docker compose run --rm cli --bedrock --terrain --output-dir /workspace/output --bbox "22.05,-101.0643,22.2314,-100.8384"
```

When generation finishes, Arnis prints the full `.mcworld` path, for example:

- `Done! Bedrock world saved to: /workspace/output/Arnis <Location>.mcworld`

That file is exported to your host at:

- `./docker-data/output`

On Windows, open that `.mcworld` file with Minecraft Bedrock to import it.

If you see this error:

- `The --bedrock flag requires the 'bedrock' feature`

rebuild the CLI image and run again:

```powershell
docker compose build --no-cache cli
docker compose run --rm cli --bedrock --terrain --output-dir /workspace/output --bbox "22.05,-101.0643,22.2314,-100.8384"
```

## 4) Optional GUI profile (experimental)

This mode runs Tauri on Linux with a virtual display and exposes noVNC in your browser.

Build and start:

```powershell
docker compose --profile gui up --build gui
```

Open:

- http://localhost:6080/vnc.html?autoconnect=1

Important limitations:

- This is slower and more fragile than native GUI.
- It is intended for experimentation, not daily use.
- If the GUI does not render, use CLI mode.

## 5) Useful commands

Show CLI help:

```powershell
docker compose run --rm cli --help
```

Stop GUI profile:

```powershell
docker compose --profile gui down
```

## 6) Notes for Windows paths

Do not pass Windows paths inside container arguments.

Use mounted Linux paths instead:

- Use /workspace/output in Arnis flags.
- Keep host path mapping in docker-compose.yml volumes.

## 7) Bedrock crash on large areas

If Bedrock generation fails near the end with a panic from `rusty-leveldb`
(`attempt to subtract with overflow`), your selected area is too large for a
single `.mcworld` export.

Use one of these workarounds:

- Reduce the bbox size.
- Split the bbox into smaller tiles (recommended).

For the San Luis Potosi example, this smaller bbox is known to complete:

```powershell
docker compose run --rm cli --bedrock --terrain --land-cover=false --aws-only-elevation --scale 0.25 --output-dir /workspace/output --bbox "22.05,-101.0643,22.1407,-100.9513"
```

If you need the full original area, run 4 tiles:

```powershell
docker compose run --rm cli --bedrock --terrain --land-cover=false --aws-only-elevation --scale 0.25 --output-dir /workspace/output --bbox "22.05,-101.0643,22.1407,-100.9513"
docker compose run --rm cli --bedrock --terrain --land-cover=false --aws-only-elevation --scale 0.25 --output-dir /workspace/output --bbox "22.05,-100.9513,22.1407,-100.8384"
docker compose run --rm cli --bedrock --terrain --land-cover=false --aws-only-elevation --scale 0.25 --output-dir /workspace/output --bbox "22.1407,-101.0643,22.2314,-100.9513"
docker compose run --rm cli --bedrock --terrain --land-cover=false --aws-only-elevation --scale 0.25 --output-dir /workspace/output --bbox "22.1407,-100.9513,22.2314,-100.8384"
```
