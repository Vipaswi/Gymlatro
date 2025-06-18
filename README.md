🃏 Gymlatro
A Balatro-style game focused on beating a score within three sets, where your reps act as the chips,
and the sets act as your multiplier. It uses Balatro's shaders and styler, with other UI elements mimicing its user interface.

🎮 Overview
The game consists of five exercises (for now), animations, and interactive controls to make a workout-inspired scoring system. You play "cards" by entering your weight and reps, aiming to beat the score threshold (ante score) each round.

This game runs on Godot Engine and is entirely written in GDScript.

🗃 Project Structure
A clone of this repository will contain everything necessary to run the game. The following is an overview of the structure:

scenes/ – All gameplay and UI scenes.

scripts/ – The primary game logic, including animations, card state, and score updates.

images/ – Card art and exercise icons.

audio/ – Sound effects inspired by Balatro.

exercises/ – Contains fiveExerciseList.txt, the exercise list loaded at runtime.

addons/ – (Optional) Any Godot plugins like version control support.

⚠️Note that many of the files (especially early game files) are unstructured, and aren't in these folders.

📋 Setup Instructions
Install Godot Engine (v4.2 or newer)

Clone the repository:

git clone https://github.com/your_username/gymlatro.git
cd gymlatro
Open the project in Godot.

Run the project in the Godot editor or export to Android using the provided export templates.

✅ Note: All required resources are already included in the repo. No additional setup or dependencies needed.

🧩 Scenes
🏠 Homepage.tscn
Contains two buttons:

Play – Starts the game (functional).

Credits/Decoration – Aesthetic only.

Styled with shaders and animated elements.

🎮 GamePlay.tscn
The heart of the game. Built with the following node structure:

GamePlay (Node2D)
├── TextureRect
├── Control (Card1Control)
│   └── AnimationPlayer
│   └── AudioStreamPlayer2D
│   └── Input Controls (HBoxContainer → WeightWrite, RepWrite, Buttons)
├── Control2 (Card2Control)
│   └── (same as above)
├── TransitionPlayer (AnimationPlayer)
└── LoseScreen (YouLoseControl)
Card controls are handled in duplicate (Card1Control and Card2Control), alternating per round. This is to provide the animation of new cards being slid into the gameplay screen.

🧠 Engineering Decisions
Card Flip Animation Handling
Abstracted via a centralized AnimationPlayer (TransitionPlayer) and per-card AnimationPlayer. Uses await for sequencing and ensuring animations complete before state changes.

Scene Reset & Game State Management
set_initial_conditions() reinitializes all game state, used on startup and replay. Clean separation between UI resets and score logic.

Exercise Loading
Exercises are read from a plain text file (fiveExerciseList.txt) and associated with .png assets by name. Images are preloaded into a dictionary for efficient access.

Audio Feedback
Submission animations are paired with a chip-like sound (proper_chip1.mp3) for tactile feedback.

Cross-platform Readiness
Runs on Android. Uses FileAccess for reading resources, which may be affected by Android file packaging rules—ensure paths use res://.

Submission Logic
User submits reps and weights up to 3 times per card. Game ends early if score exceeds the ante or continues until max attempts reached.

📱 Android Note
If you're building for Android:

Ensure the fiveExerciseList.txt is properly included in res:// and not user:// to avoid permission issues.
Not only that, but also explicitly include it in the resources section (e.g. res://images/*, etc.) to ensure a functional build.

📝Note that a functional build, GymlatroNosignal.apk is already attached in the Github above.

🚀 Features
Animated transitions & card flipping.

Realtime score animation via tweens.

Shader-based visuals on labels and buttons.

Responsive UI input validation and control locking.

Modular design for expanding the number of exercises or cards.

📄 License & Credits
Inspired by Balatro (gameplay & aesthetic).

Some art is custom but stylistically modeled after Balatro.

Sound effects partially adapted (with credit) from Balatro sound design.

❗ This is a personal/fan-made project and is not affiliated with or endorsed by the creators of Balatro.

🧪 Future Improvements
Add exercise images for all entries.

Include more animated transitions.

Add difficulty scaling and random events.

Implement pause, restart, and advanced analytics (e.g., average weight lifted).

Add music

Add a settings scene

Organize folders

🙋‍♂️ Contributing
Feel free to fork the project, open issues, or create PRs for bug fixes and enhancements. No formal contribution rules—just keep it clean and readable.
