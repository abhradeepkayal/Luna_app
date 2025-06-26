

# Luna – Mental Wellness, Reimagined

**Luna** is your AI-powered companion designed to support mental well-being, communication growth, and daily productivity. Built with love and empathy for neurodiverse users (specially made for ADHD, autism, dyslexia), Luna is here to help you thrive—whether you're navigating speech challenges, organizing your thoughts, or simply needing a space to unwind.

## Features Overview

### 🗣️ AI-Powered Speech Therapy
- **Picture-to-Word:**  
  Generates a random object tag via Gemini AI, searches for a relevant image online, and challenges you to correctly identify and spell the item.
- **Scenario-Based Practice:**  
  Engage with fixed video scenarios where your spoken responses are analyzed by AI. Receive contextual, confidence-boosting feedback and a structured conversation summary with suggestions for improvement.

### ✅ Smart To-Do List (with AI Task Breakdown)
- Plan your day by adding tasks and having them automatically broken down using AI.
- The task breakdown adapts based on the complexity of the task and your custom slider input, helping you manage tasks in manageable chunks.

### 🧠 Mood-Based Chatbots
- **Choose Your Vibe:**  
  Chat with Chill Bot, Wise Bot, or Funny Bot—each offering a unique personality to match your current mood.  
- Get interactive support, advice, or simply a laugh.

### 📓 Journaling Tools
- **Mind Dump:**  
  Offload your thoughts freely with the option to add images, emojis, and personalized touches.
- **Swifty Journal:**  
  Write with real-time AI support and guidance.
- **Daily Journal:**  
  Enjoy a structured journaling space with mood tracking, markdown-rich formatting, and daily reflections.

### 💬 Community Circles
- Connect with like-minded or neurodiverse individuals in safe, supportive community spaces.
- Share experiences, ask for help, or simply find people who understand you.

### 🧩 Jumbled Words Game (AI-Generated)
- Challenge yourself with 30 levels of jumbled word puzzles generated and validated by Gemini AI.
- Each level is unlocked sequentially after completing the previous one, keeping your brain active and engaged.

### 🌊 Calming Sounds & Visuals
- Relax with curated calming soundscapes paired with soothing visuals.
- Perfect for resetting, focusing, or drifting peacefully into mindfulness.

### 📝 Quick Quiz (Inspired by DSM-5)
- Take a quiz that provides results and solutions to help you better understand your mental wellness.

## Tech Stack
- **Frontend:** Flutter  
- **Backend:** Firebase  
- **AI:** Gemini API, Vertex AI  

## What's Next?
- **Forum Integration:**  
  Groups and communities for deeper connection.
- **Additional Puzzles:**  
  More brain-engaging games.
- **And More:**  
  Stay tuned for continuous improvements and new features.

Below is the exact "How to Install" section you can copy and paste directly into your `README.md`:

```markdown
## Installation

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- A Firebase account for backend setup.
- Gemini API and Vertex AI credentials.

### Steps

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/abhradeepkayal/Luna_app.git
   cd Luna_app
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set Up Environment Variables:**
   - Create a file named `.env` in the root directory of the project.
   - Add your API keys and credentials in the `.env` file. For example:
     ```env
     GEMINI_API_KEY="Your gemini api key"
     ```
   - Ensure your project is configured to read the `.env` file (using a package like [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) is recommended).

4. **Configure Firebase:**
   - Follow the Firebase setup instructions for Flutter to connect your project to your Firebase account.

5. **Run the App:**
   ```bash
   flutter run
   ```
``` 

