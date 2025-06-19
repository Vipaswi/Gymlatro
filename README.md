# 🃏 Gymlatro

**Gymlatro** is a *Balatro*-inspired game for the gym, where your **reps act as chips** and your **sets are your multipliers**. It reuses Balatro-style shaders and UI inspiration while creating an interactive exercise-based score challenge.

🛠 Built with the **Godot Engine** in **GDScript**, playable on desktop and Android.

## 🎮 Overview

The game consists of:

- Five preloaded exercises
- Two animated cards for input
- A "score threshold" (ante score) that increases every round
- Balatro-inspired shaders, UI, and sound effects

You enter your **weight lifted** and **number of reps** to simulate "playing a card." Your goal is to beat the ante score within three tries.

## 🗃 Project Structure

A cloned copy of this repo contains all required files to run the game:
```
gymlatro/
├── audio/ # Sound effects (chip clicks, etc.)
├── images/ # Preloaded PNGs representing exercises
├── scenes/ # Main scenes like homepage and gameplay
├── scripts/ # Main GDScript files for logic & animation
├── exercises/ # fiveExerciseList.txt (the list of exercise names)
├── addons/ # (Optional) plugins for version control, etc.
├── export_presets.cfg # Godot export config
└── project.godot # Godot project file
```

> ⚠️ Note: Some files are still loosely organized from early dev. You may see files outside these folders.

## 📋 Setup Instructions

1. Install [Godot Engine](https://godotengine.org/) (v4.2 or newer)
2. Clone this repository:

```bash
git clone https://github.com/your_username/gymlatro.git
cd gymlatro
```

Open the project in the Godot editor.

Press ▶️ to run it, or export to Android via Project > Export.

✅ Note: No dependencies or assets need to be installed — everything is included.

### 🧩 Scenes

## 🧩 Scenes

### 🏠 `Homepage.tscn`
- Two buttons:
  - `Play`: Starts the game ✅
  - `Credits`: Aesthetic-only 🎨
- Styled with Balatro-style shaders and animation

### 🎮 `GamePlay.tscn`
The gameplay happens here. Two animated card controls are used interchangeably.

#### Node Tree (Simplified)
```
GamePlay (Node2D)
├── TextureRect (background)
├── Card1Control (Control)
│ ├── AnimationPlayer
│ ├── AudioStreamPlayer2D
│ └── Input Containers (HBoxContainers)
├── Card2Control (Control)
│ ├── (same structure as Card1Control)
├── TransitionPlayer (AnimationPlayer)
└── YouLoseControl (Lose screen)
```

- Card switching simulates card animations like Balatro.
- Inputs include `Weight`, `Reps`, and `Submit` buttons per set.

## 🧠 Engineering Decisions

### Card Flip Animation
- Controlled with `AnimationPlayer` + `await animation_finished`
- Global animation transitions are handled by `TransitionPlayer`

### Game Reset
- `set_initial_conditions()` resets variables, states, animations, and UI
- Called on first run and replay

### Exercise Loading
- `fiveExerciseList.txt` is loaded using `FileAccess`
- Exercises are matched to images via `imageDictionary`

### Sound Design
- Submission is paired with `proper_chip1.mp3` (Balatro-like)
- Feedback on each rep × weight submission

### Submission Logic
- 3 submissions per round
- Early win if ante score is exceeded
- Otherwise, lose screen after 3 attempts

## 📱 Android Notes

If you're exporting to Android:

- Ensure `fiveExerciseList.txt` is in the `res://` path
- Android *does not allow* access to `user://` without permissions
- Ensure `res://images/*.png` and other assets are **explicitly included in export settings**

## 🚀 Features

- 🎴 Animated card flipping
- 🔊 Tactile chip sounds
- ✨ Balatro-style shaders for text/buttons
- 📈 Realtime score animation with tweens
- 🧩 Modular design for adding new exercises
- 🎯 Functional on Android

## 📄 License & Credits

- Inspired by **Balatro** (gameplay, sound, visual style)
- Some visuals are custom-made in the same aesthetic
- Sound effects partially adapted with credit

> ❗ This is a **fan project**. Not affiliated with or endorsed by Balatro creators.

## 🧪 Future Improvements

- [ ] Add images for all exercises
- [ ] Add difficulty levels and scaling
- [ ] Implement analytics (avg reps/weight)
- [ ] Add background music 🎵
- [ ] Add settings and pause scenes

## 🙋‍♂️ Contributing

Pull requests and forks are welcome!

- 🐞 Open an issue for bugs
- 🌱 Submit PRs for features or improvements
- ✨ Keep code clean and readable

