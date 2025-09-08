# IOS-ESP-AutoUpdate
IOS ESP Unity AutoUpdate

<img width="1080" height="701" alt="photo_2025-09-09_00-35-35" src="https://github.com/user-attachments/assets/7f8b2e68-4c45-48f6-a3eb-d8a3a04805f9" />


# ESPConfig.h - ESP Configuration for Different Games

This file contains the most important settings to adapt ESP (Extra Sensory Perception) to your game.

## Most Important Settings

### 1. Player Class (MOST IMPORTANT!)

```cpp
// Main player class - YOU MUST FIND THE CORRECT NAME
#define PLAYER_CLASS_NAME "CombatMaster.Battle.Gameplay.Player.PlayerRoot"
#define PLAYER_ASSEMBLY_NAME "_CombatMaster.Battle.dll"
```

**Example:**
```cpp
// Example player class name
#define PLAYER_CLASS_NAME "MyGame.Player.PlayerController"
#define PLAYER_ASSEMBLY_NAME "MyGame.dll"
```


### 2. Skeleton Components

```cpp
// SkinnedMeshRenderer (usually don't change)
#define SKINNED_MESH_RENDERER_CLASS_NAME "UnityEngine.SkinnedMeshRenderer"
```

## What You Need to Do

1. **Find player class** - this is most important!
2. **Check assembly name** - must be exact
3. **Test** - if ESP works
---

**Note:** For educational purposes. Use responsibly.
