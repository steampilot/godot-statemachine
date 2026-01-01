"""
Caprica Paperdoll - Placeholder Asset Generator
Mercury Mission 0 - Quick Start

Erstellt 15 farbige Placeholder-PNGs für sofortiges Testing
"""
from PIL import Image, ImageDraw
import os

# Body part definitions: (name, width, height, color)
body_parts = [
    ("Head", 64, 64, (255, 0, 0)),           # Red
    ("Torso", 64, 96, (255, 128, 0)),        # Orange
    ("HipPelvis", 64, 48, (255, 200, 0)),    # Yellow-Orange

    ("ArmUpper_L", 32, 64, (255, 255, 0)),   # Yellow
    ("ArmLower_L", 32, 64, (200, 200, 0)),   # Dark Yellow
    ("Hand_L", 32, 32, (150, 150, 0)),       # Darker Yellow

    ("ArmUpper_R", 32, 64, (255, 255, 0)),   # Yellow
    ("ArmLower_R", 32, 64, (200, 200, 0)),   # Dark Yellow
    ("Hand_R", 32, 32, (150, 150, 0)),       # Darker Yellow

    ("LegUpper_L", 48, 64, (0, 255, 0)),     # Green
    ("LegLower_L", 48, 64, (0, 200, 0)),     # Dark Green
    ("Foot_L", 48, 32, (0, 150, 0)),         # Darker Green

    ("LegUpper_R", 48, 64, (0, 255, 0)),     # Green
    ("LegLower_R", 48, 64, (0, 200, 0)),     # Dark Green
    ("Foot_R", 48, 32, (0, 150, 0)),         # Darker Green
]

output_dir = "res/Assets/Characters/Paperdolls/Caprica"

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

print("Creating Caprica Paperdoll Placeholder Assets...")
print("=" * 50)

for name, width, height, color in body_parts:
    # Create image with transparency
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw colored rectangle with white border
    draw.rectangle([(2, 2), (width-3, height-3)], fill=color, outline=(255, 255, 255))

    # Add pivot marker (small blue circle at top-center)
    pivot_x = width // 2
    pivot_y = 4
    draw.ellipse([(pivot_x-2, pivot_y-2), (pivot_x+2, pivot_y+2)], fill=(0, 0, 255))

    # Save
    filepath = f"{output_dir}/{name}.png"
    img.save(filepath)
    print(f"✓ Created {name}.png ({width}x{height})")

print("=" * 50)
print(f"\n✅ All 15 placeholder assets created in: {output_dir}")
print("\nNext Steps:")
print("1. Open Godot Editor")
print("2. Navigate to res://Assets/Characters/Paperdolls/Caprica/")
print("3. Verify all PNGs are imported")
print("4. Continue with Bone2D Scene Setup (see MERCURY_0_IMPLEMENTATION.md)")
