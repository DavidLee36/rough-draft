# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Roughdraft** is a 3D FPS game built with Godot 4.6 (Forward Plus renderer, Jolt Physics, D3D12 on Windows). Currently using GDScript but may migrate to C# (would require the .NET version of Godot).

## Development Commands

Godot projects are developed through the Godot Editor GUI, not a CLI build system. Key operations:

- **Run the game**: Open `project.godot` in Godot 4.6, then press F5 (run project) or F6 (run current scene)
- **Run a specific scene**: Open the scene in the editor and press F6
- **GDScript has no separate lint step** — the editor surfaces errors in real time

## Architecture

### Core Files

| File | Role |
|------|------|
| `project.godot` | Engine config, input map, renderer settings |
| `Scripts/player.gd` | Player controller (extends `CharacterBody3D`) |
| `Scenes/Characters/player.tscn` | Player scene — CharacterBody3D with AnimationPlayer, collision, mesh |
| `Scenes/Levels/Level1.tscn` | Main level — GridMap-based floor/walls, lighting, WorldEnvironment |
| `World/Tiles/tiles.tres` | MeshLibrary used by Level1's GridMap nodes |

### Player Script Structure (`Scripts/player.gd`)

`_physics_process` → `handle_movement` delegates each frame to:
- `handle_panning()` — mouse look (horizontal rotates CharacterBody3D, vertical rotates Camera3D)
- `handle_direction_movement()` — WASD translation relative to character facing
- `handle_jump_movement(delta)` — gravity and jumping

Animation is driven by an `AnimationTree` (BlendTree root → `Movement` StateMachine). States: `Idle`, `Walking`, `Jump_Idle`. The body meshes use **Cast Shadow = Shadows Only** (invisible to camera, shadow still renders). Weapon/arms are parented to `Camera3D` independently of the skeleton.

### Input Map (defined in `project.godot`)

| Action | Key |
|--------|-----|
| `forward` | W |
| `back` | S |
| `left` | A |
| `right` | D |
| `jump` | Space |
| `sprint` | Left Shift |

### Asset Layout

- `Assets/Animations/` — Pre-imported `.res` animation files (walk, run, jump, dodge, combat, death, etc.)
- `Assets/Characters/` — `Mannequin_Medium.glb` (player mesh) and `Dummy.glb` with textures
- `Assets/Building/` — Building/wall materials
- `World/Tiles/` — GridMap tile mesh library source

### Known Gotchas

- **Movement direction**: The skeleton camera has a 180° Y rotation baked in, so input must be negated — `Vector3(-input_dir.x, 0, -input_dir.y)` — to move the correct direction
- **AnimationTree parameter path**: The state machine is nested inside a BlendTree node named `Movement`, so the playback path is `parameters/Movement/playback` not `parameters/playback`
- **AnimationTree transitions**: Must be set to **Advance Mode: Enabled** (not Auto) for `travel()` to work correctly. Auto causes constant cycling between states
- **Skeleton node name**: Must stay named `Rig_Medium` — all animation tracks reference `Rig_Medium/Skeleton3D` and will fail silently if renamed
- **MeshLibrary collision**: In `tiles.tscn`, `StaticBody3D` must be a child of the `MeshInstance3D` (not a sibling) to be exported into `tiles.tres`

### Level Design

Levels use two `GridMap` nodes (`Floor` and `Wall`) driven by `World/Tiles/tiles.tres`. The floor grid uses 4×0.5×4 cells; the wall grid uses 1×0.5×1 cells.
