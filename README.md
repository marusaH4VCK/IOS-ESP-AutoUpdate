# IOS-ESP-AutoUpdate
IOS ESP Unity AutoUpdate

<img width="1080" height="701" alt="photo_2025-09-09_00-35-35" src="https://github.com/user-attachments/assets/7f8b2e68-4c45-48f6-a3eb-d8a3a04805f9" />


# ESP Configuration & Dynamic Update

This project features an advanced Unity ESP system with **Dynamic Targeting**, allowing you to adapt to different games or game objects without re-compiling.

## Dynamic ESP Targeting (NEW!)

Instead of hardcoding values, you can now use the **In-Game Mod Menu** to select your target in real-time:

1. **Target Assembly**: Select the Unity Assembly (e.g., `_CombatMaster.Battle.dll`) from the dropdown list.
2. **Target Class**: After selecting an assembly, the Class list will automatically update. Choose your player or entity class (e.g., `PlayerRoot`).

The ESP will instantly switch to tracking the selected entities.

## ESPConfig.h - Default Values

While you can change targets in-game, you can also set the default startup values in `ESPConfig.h`.

### 1. Default Player Class
```cpp
// Default target for initialization
#define PLAYER_CLASS_NAME "CombatMaster.Battle.Gameplay.Player.PlayerRoot"
#define PLAYER_ASSEMBLY_NAME "_CombatMaster.Battle.dll"
```

### 2. Skeleton Components
```cpp
// Component used to find bones (usually SkinnedMeshRenderer)
#define SKINNED_MESH_RENDERER_CLASS_NAME "UnityEngine.SkinnedMeshRenderer"
```

## How to use
1. **Launch the game** and open the Mod Menu.
2. **Go to ESP Tab**.
3. **Select Assembly & Class** corresponding to the entities you want to see.
4. **Enable ESP** (Line, Box, Skeleton, etc.).

---
**Note:** For educational purposes. Use responsibly.
