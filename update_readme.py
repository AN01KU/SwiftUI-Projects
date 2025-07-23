#!/usr/bin/env python3
"""
Automatic README updater for SwiftUI Learning Repository
Scans for new projects and updates README.md automatically
"""

import os
import re
import json
from pathlib import Path


def find_app_icon(project_path):
    """Find the app icon for a project"""
    possible_paths = [
        f"{project_path}/Resources/AppIcon.png",
        f"{project_path}/Resources/Icons/AppIcon.png",
        f"{project_path}/Resources/App-Icon/AppIcon.png",
        f"{project_path}/Students/*/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png",
        f"{project_path}/Students/*/*/Resources/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png",
        f"{project_path}/Resources/AppIcon/Icon-60@3x.png",
    ]

    for pattern in possible_paths:
        if "*" in pattern:
            import glob

            matches = glob.glob(pattern)
            if matches:
                return matches[0]
        elif os.path.exists(pattern):
            return pattern

    return None


def detect_project_type(project_path):
    """Detect what type of app this is based on files and folder structure"""
    project_name = os.path.basename(project_path).lower()

    # Check for specific files or patterns
    if "chatbot" in project_name or "chat" in project_name:
        return "A conversational chatbot interface"
    elif "grocery" in project_name or "list" in project_name:
        return "A grocery shopping list app with SwiftData"
    elif "hike" in project_name or "hiking" in project_name:
        return "An outdoor hiking companion app"
    elif "paws" in project_name or "pet" in project_name:
        return "A pet management application"
    elif "pinch" in project_name:
        return "An interactive image viewer with pinch-to-zoom and pan gestures"
    elif "restart" in project_name or "onboard" in project_name:
        return "An onboarding and restart experience app"
    elif "watchlist" in project_name or "movie" in project_name:
        return "A movie watchlist tracker"
    elif "wishlist" in project_name or "wish" in project_name:
        return "A personal wishlist manager"
    elif "basic" in project_name or "fundamental" in project_name:
        return "Foundation concepts and basic SwiftUI components"
    else:
        return "A SwiftUI application"


def get_swiftui_concepts(projects):
    """Generate learning focus based on detected projects"""
    base_concepts = [
        "Declarative UI development",
        "State management",
        "Navigation and routing",
        "Custom components and views",
        "Animations and transitions",
        "App architecture patterns",
    ]

    additional_concepts = []
    project_names = [p["name"].lower() for p in projects]

    # Add concepts based on project types
    if any(
        "grocery" in name or "watchlist" in name or "wishlist" in name
        for name in project_names
    ):
        additional_concepts.append("Data persistence with SwiftData")

    if any("pinch" in name for name in project_names):
        additional_concepts.append("Gesture handling and touch interactions")

    if any("restart" in name for name in project_names):
        additional_concepts.append("Onboarding flows and user experience")

    if any("hike" in name for name in project_names):
        additional_concepts.append("Image handling and custom backgrounds")

    # Insert additional concepts in logical order
    all_concepts = base_concepts.copy()
    for concept in additional_concepts:
        if concept not in all_concepts:
            if "Data persistence" in concept:
                all_concepts.insert(3, concept)  # After navigation
            elif "Gesture handling" in concept:
                all_concepts.insert(-1, concept)  # Before app architecture
            else:
                all_concepts.insert(-1, concept)  # Before app architecture

    return all_concepts


def scan_projects():
    """Scan current directory for SwiftUI projects"""
    projects = []

    for item in os.listdir("."):
        if os.path.isdir(item) and not item.startswith(".") and item != "__pycache__":
            # Skip if it's clearly not a project directory
            if item in ["README.md", ".git"]:
                continue

            # Check if it has project indicators (README.txt, .xcodeproj, etc.)
            has_readme = os.path.exists(f"{item}/README.txt")
            has_xcodeproj = any(
                ".xcodeproj" in f
                for f in os.listdir(item)
                if os.path.isdir(f"{item}/{f}")
            )
            has_students = os.path.exists(f"{item}/Students")

            if has_readme or has_xcodeproj or has_students:
                app_icon = find_app_icon(item)
                description = detect_project_type(item)

                projects.append(
                    {
                        "name": item,
                        "description": description,
                        "icon_path": app_icon,
                        "link": f"./{item.replace(' ', '%20')}/",
                    }
                )

    return sorted(projects, key=lambda x: x["name"])


def generate_readme_content(projects):
    """Generate the complete README content"""

    # Header
    content = """# SwiftUI Learning Journey

<div align="center">
  <img src="./Hike-App/Resources/Images/image-1.png" width="300" alt="SwiftUI Learning">
  <br>
  <em>A collection of SwiftUI projects showcasing iOS development skills</em>
</div>

This repository contains all the projects I completed while learning SwiftUI. Each project explores different aspects of SwiftUI development, from basic concepts to more advanced features.

## Projects Overview

### 📱 Core Apps

<div align="center">
"""

    # App icons gallery
    for project in projects:
        if project["icon_path"] and "basic" not in project["name"].lower():
            icon_path = project["icon_path"].replace(" ", "%20")
            content += f'  <img src="{icon_path}" width="60" alt="{project["name"]}">\n'

    content += "</div>\n\n"

    # Project list
    basics_projects = []
    core_projects = []

    for project in projects:
        if (
            "basic" in project["name"].lower()
            or "fundamental" in project["name"].lower()
        ):
            basics_projects.append(project)
        else:
            core_projects.append(project)

    # Core apps
    for project in core_projects:
        icon_html = ""
        if project["icon_path"]:
            icon_path = project["icon_path"].replace(" ", "%20")
            icon_html = f' <img src="{icon_path}" width="20" alt="{project["name"]}">'

        content += f"- **[{project['name']}]({project['link']})**{icon_html} - {project['description']}\n"

    # Fundamentals section
    if basics_projects:
        content += "\n### 🎯 Fundamentals\n\n"
        for project in basics_projects:
            content += f"- **[{project['name']}]({project['link']})** - {project['description']}\n"

    # Structure section
    content += """
## Structure

Each project folder contains:

- **Students/** - Working/learning versions
- **Completed/** - Final implementations
- **Resources/** - Assets, icons, and supporting materials
- **README.txt** - Project-specific documentation

## Learning Focus

These projects cover key SwiftUI concepts including:

"""

    # Add learning concepts
    concepts = get_swiftui_concepts(projects)
    for concept in concepts:
        content += f"- {concept}\n"

    # Footer
    content += """
## Getting Started

Each project is self-contained and can be opened independently in Xcode. Navigate to any project's `.xcodeproj` file to get started.

---

*Built with SwiftUI for iOS development learning*
"""

    return content


def main():
    """Main function to update README"""
    print("🔍 Scanning for SwiftUI projects...")
    projects = scan_projects()

    print(f"📱 Found {len(projects)} projects:")
    for project in projects:
        icon_status = "✅" if project["icon_path"] else "❌"
        print(f"  {icon_status} {project['name']}")

    print("\n📝 Generating README content...")
    readme_content = generate_readme_content(projects)

    print("💾 Writing README.md...")
    with open("README.md", "w") as f:
        f.write(readme_content)

    print("✅ README.md updated successfully!")

    # Show what changed
    print(f"\n📊 Summary:")
    print(
        f"   • {len([p for p in projects if 'basic' not in p['name'].lower()])} core apps"
    )
    print(
        f"   • {len([p for p in projects if 'basic' in p['name'].lower()])} fundamental projects"
    )
    print(f"   • {len([p for p in projects if p['icon_path']])} projects with icons")


if __name__ == "__main__":
    main()
