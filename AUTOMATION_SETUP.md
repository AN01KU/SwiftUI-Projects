# README Automation Setup

This repository includes several automation options to automatically update your README.md whenever you add new SwiftUI projects.

## 🛠️ Available Options

### 1. Manual Script (Easiest)

```bash
# Update README manually
python3 update_readme.py

# Or use the convenient wrapper script
./update.sh

# Update and auto-commit
./update.sh commit
```

### 2. Git Pre-commit Hook (Local Automation)

Automatically updates README before every commit.

**Setup:**

```bash
# Copy the pre-commit hook
cp pre-commit .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit
```

**How it works:**

- Runs `update_readme.py` before each commit
- Automatically adds README.md to your commit if it was updated
- No manual intervention needed!

### 3. GitHub Actions (Full Automation)

Automatically updates README when you push new projects to GitHub.

**Setup:**

- The workflow file is already created at `.github/workflows/update-readme.yml`
- It will automatically run when you push new projects
- No additional setup needed if your repo is on GitHub

## 🔧 How the Automation Works

The automation system:

1. **Scans** your directory for SwiftUI projects (folders with README.txt, .xcodeproj, or Students/ folder)
2. **Detects** app icons from various common locations
3. **Identifies** project types based on folder names and generates descriptions
4. **Updates** the Learning Focus section based on detected project types
5. **Regenerates** the entire README with proper formatting

## 📁 What Gets Detected

### Project Types:

- **ChatBot/Chat** → "A conversational chatbot interface"
- **Grocery/List** → "A grocery shopping list app with SwiftData"
- **Hike/Hiking** → "An outdoor hiking companion app"
- **Paws/Pet** → "A pet management application"
- **Pinch** → "An interactive image viewer with pinch-to-zoom and pan gestures"
- **Restart/Onboard** → "An onboarding and restart experience app"
- **Watchlist/Movie** → "A movie watchlist tracker"
- **Wishlist/Wish** → "A personal wishlist manager"
- **Basic/Fundamental** → "Foundation concepts and basic SwiftUI components"

### App Icon Locations:

- `ProjectName/Resources/AppIcon.png`
- `ProjectName/Resources/Icons/AppIcon.png`
- `ProjectName/Resources/App-Icon/AppIcon.png`
- `ProjectName/Students/*/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `ProjectName/Resources/AppIcon/Icon-60@3x.png`

### Learning Concepts (Auto-generated):

The script automatically adds relevant concepts based on your projects:

- **Data persistence with SwiftData** (for Grocery, Watchlist, Wishlist apps)
- **Gesture handling and touch interactions** (for Pinch app)
- **Onboarding flows and user experience** (for Restart app)
- **Image handling and custom backgrounds** (for Hike app)

## 🚀 Quick Start

1. **For immediate use:**

   ```bash
   python3 update_readme.py
   ```

2. **For convenience:**

   ```bash
   ./update.sh commit
   ```

3. **For automation:** Set up the git hook:
   ```bash
   cp pre-commit .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

## 🎯 Usage Examples

### Adding a New Project

1. Create your new SwiftUI project folder
2. Run `./update.sh commit` or just commit normally (if using git hook)
3. Your README will automatically include the new project!

### Custom Project Descriptions

If the auto-detection doesn't work for your project, you can:

1. Edit the `detect_project_type()` function in `update_readme.py`
2. Add your project pattern and description

### Testing

```bash
# See what projects are detected
python3 update_readme.py

# Preview changes without committing
./update.sh
```

## 🔍 Troubleshooting

**Script not finding app icons?**

- Check if your icon is in one of the supported locations
- Add your icon path to the `find_app_icon()` function

**Project not detected?**

- Ensure your project folder has a README.txt, .xcodeproj, or Students/ folder
- These are the indicators used to identify SwiftUI projects

**Want to customize descriptions?**

- Edit the `detect_project_type()` function in `update_readme.py`
- Add your own patterns and descriptions

---

_This automation setup ensures your README stays up-to-date effortlessly! 🎉_
