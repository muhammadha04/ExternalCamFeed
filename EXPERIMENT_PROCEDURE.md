# Experiment details and how to run it

This document describes the setup sequence, software order, logging controls, and the three 15-minute conditions for the ExternalCamFeed study with Quest 3, Unity, MATLAB, and Pupil Neon eye tracking.

## Hardware setup

1. **Mount the camera** on the Quest 3 so it is fixed correctly and will not shift during the session.
2. **Connect cables to the PC**
   - Quest 3 (USB, for Link)
   - External camera (USB, as used by your pipeline)
3. **Eye tracking:** connect the eye-tracking cable to the **Neon phone**.

## Software startup order

### Quest 3 and PC Link

1. On the **Quest 3**, launch **Link** (wired PC VR).
2. On the **PC**, open **Unity** and open the project **ExternalCamFeed**.
3. Wait until the **editor background with emojis** is visible (project fully loaded).
4. Click **Play** in the Unity editor.

### MATLAB server

1. Open **MATLAB**.
2. Open the script **`server`** (your main server `.m` file) and click **Run**.
3. A **popup** appears to choose filter orientation (**Horizontal** or **Oblique**).
4. **No-filter baseline in the popup:** set the degree control to **60** (maximum) and **do not change** the other options—this corresponds to the minimal / no meaningful removal condition for that UI.
5. In the popup, confirm and **start** (e.g. **Play** / **Start Debugging**—whichever your popup shows) so the server streams to Unity.

**Expected result:** Unity shows the **camera feed from MATLAB**; the same view is visible **inside the Quest 3** via Link.

### Neon eye tracking

1. On the **Neon phone**, launch **Neon Player**.

## Participant and condition ID in Unity

In the **Unity settings panel**, set **`participantname_condition_order`** to match the current block, for example:

| Example value | Meaning |
|----------------|---------|
| `Muhammad_Without_1` | Participant Muhammad, **Without** filter, **order 1** (first condition) |
| `Muhammad_oblique_2` | Oblique removal, **order 2** |
| `Muhammad_horizontal_2` | Horizontal removal, **order 2** |

**Order number rule:** the digit is the **sequence index** of that condition in the session (e.g. if you **start with Without**, that run is `_1`; the next condition (oblique or horizontal) is `_2`; the remaining condition is `_3`). Use the actual participant name and the exact condition label your build expects (spelling/case as in your project).

## Synchronized logging (Unity + Neon)

| Action | Unity | Neon Player (phone) |
|--------|--------|----------------------|
| **Start** | Click the Unity **Game** view, then press **F5** | Press **Start logging** at the **same time** as F5 |
| **Stop** | Press **F6** | Press **Stop recording** |

Start both systems together so eye tracking and Unity logs share the same time window.

## Condition durations (one session design)

Each condition runs for **15 minutes**:

1. **15 min** — **Without** filter (popup: degree at 60 / no filter as above).
2. **15 min** — **Horizontal** removal (adjust MATLAB popup / parameters per your protocol for horizontal).
3. **15 min** — **Oblique** removal (adjust MATLAB popup / parameters per your protocol for oblique).

Between runs: press **F6** in Unity to stop logging, **Stop recording** in Neon; files save automatically. Update **`participantname_condition_order`** for the next condition and repeat startup (MATlab orientation choice, F5 + Neon start) for the next 15-minute block.

## After each run

- Unity: **F6** stops logging (data saved per your project settings).
- Neon: **Stop recording** on the phone (data saved automatically).

---
