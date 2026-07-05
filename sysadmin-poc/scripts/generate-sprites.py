#!/usr/bin/env python3
"""
Generate entity sprites for Sysadmin POC mod.
Run this script to regenerate all entity graphics with proper programmatic sprites.

Entity sprites are larger than icons (64x64 or more) and include:
- Main entity graphics
- Shadow layers (optional)
- Different states/directions where applicable

Requires: pip install Pillow
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import math

# Sprite sizes for different entity types
SPRITE_SIZE = 64  # Standard entity size
SHADOW_OFFSET = (4, 4)  # Shadow offset
SHADOW_COLOR = (0, 0, 0, 80)  # Semi-transparent black

# Color palette (matching entities.lua COLORS table)
COLORS = {
    'sensor': (102, 204, 255),      # Cyan - data collection
    'cable': (255, 153, 51),        # Orange - network cables
    'server': (77, 255, 128),       # Green - server LEDs
    'bridge': (255, 255, 102),      # Yellow - circuit color
    'dashboard': (178, 102, 255),   # Purple - monitoring
    'packet': (51, 153, 255),       # Blue - data packets
    'metal_dark': (50, 55, 65),     # Dark metal
    'metal_mid': (70, 75, 85),      # Medium metal
    'metal_light': (90, 95, 105),   # Light metal
}


def create_base_sprite(size=SPRITE_SIZE):
    """Create a transparent base image."""
    return Image.new('RGBA', (size, size), (0, 0, 0, 0))


def add_shadow_layer(img, shape_mask, offset=SHADOW_OFFSET):
    """Add a shadow layer beneath the main shape."""
    shadow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)

    # Draw shadow using the mask offset
    for y in range(shape_mask.size[1]):
        for x in range(shape_mask.size[0]):
            if shape_mask.getpixel((x, y))[3] > 0:
                sx, sy = x + offset[0], y + offset[1]
                if 0 <= sx < shadow.size[0] and 0 <= sy < shadow.size[1]:
                    shadow.putpixel((sx, sy), SHADOW_COLOR)

    # Blur the shadow slightly
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=2))

    # Composite shadow behind main image
    result = Image.new('RGBA', img.size, (0, 0, 0, 0))
    result.paste(shadow, (0, 0))
    result.paste(img, (0, 0), img)
    return result


def darken(color, factor=0.7):
    """Darken a color by a factor."""
    return tuple(int(c * factor) for c in color[:3]) + (color[3] if len(color) > 3 else 255,)


def lighten(color, factor=1.3):
    """Lighten a color by a factor."""
    return tuple(min(255, int(c * factor)) for c in color[:3]) + (color[3] if len(color) > 3 else 255,)


def draw_data_sensor_sprite(img):
    """
    Data Sensor sprite - Industrial data collector with antenna.
    Based on iron chest appearance but with IT elements.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['sensor']
    color_dark = darken(color)
    color_light = lighten(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']

    # Main body (chest-like container)
    body_left = cx - 18
    body_right = cx + 18
    body_top = cy - 8
    body_bottom = cy + 16

    # Body shadow/depth
    draw.rectangle([body_left + 2, body_top + 2, body_right + 2, body_bottom + 2],
                   fill=metal_dark)

    # Main body
    draw.rectangle([body_left, body_top, body_right, body_bottom],
                   fill=color, outline=color_dark, width=2)

    # Body panel detail
    draw.rectangle([body_left + 4, body_top + 4, body_right - 4, body_bottom - 4],
                   fill=color_dark, outline=None)
    draw.rectangle([body_left + 6, body_top + 6, body_right - 6, body_bottom - 6],
                   fill=color, outline=None)

    # Antenna mast
    mast_x = cx
    mast_bottom = body_top
    mast_top = cy - 26
    draw.rectangle([mast_x - 3, mast_top, mast_x + 3, mast_bottom],
                   fill=metal, outline=metal_dark, width=1)

    # Antenna dish/receiver
    dish_cx = mast_x
    dish_cy = mast_top - 2
    draw.ellipse([dish_cx - 10, dish_cy - 6, dish_cx + 10, dish_cy + 6],
                 fill=metal, outline=metal_dark, width=1)
    draw.ellipse([dish_cx - 6, dish_cy - 3, dish_cx + 6, dish_cy + 3],
                 fill=color_light, outline=color, width=1)

    # Signal waves emanating from antenna
    for i, radius in enumerate([8, 14, 20]):
        alpha = 200 - i * 60
        wave_color = (*color[:3], alpha)
        # Draw arc
        draw.arc([dish_cx - radius, dish_cy - radius, dish_cx + radius, dish_cy + radius],
                 start=200, end=340, fill=color_light, width=2)

    # Status LEDs on front
    led_y = body_top + 8
    draw.ellipse([cx - 12, led_y, cx - 8, led_y + 4], fill=(0, 255, 100))  # Green - active
    draw.ellipse([cx + 8, led_y, cx + 12, led_y + 4], fill=(100, 200, 255))  # Cyan - data

    # Data port on side
    draw.rectangle([body_right - 6, body_top + 12, body_right - 2, body_top + 20],
                   fill=metal_dark)

    return img


def draw_basic_server_sprite(img):
    """
    Basic Server sprite - Server rack unit with LEDs and drive bays.
    Based on assembler appearance but styled as server hardware.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['server']
    color_dark = darken(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']
    metal_light = COLORS['metal_light']

    # Server chassis
    chassis_left = cx - 22
    chassis_right = cx + 22
    chassis_top = cy - 18
    chassis_bottom = cy + 18

    # Chassis shadow
    draw.rectangle([chassis_left + 3, chassis_top + 3, chassis_right + 3, chassis_bottom + 3],
                   fill=(30, 30, 35))

    # Main chassis body
    draw.rectangle([chassis_left, chassis_top, chassis_right, chassis_bottom],
                   fill=metal_dark, outline=(40, 45, 55), width=2)

    # Front bezel
    bezel_margin = 3
    draw.rectangle([chassis_left + bezel_margin, chassis_top + bezel_margin,
                    chassis_right - bezel_margin, chassis_bottom - bezel_margin],
                   fill=metal, outline=metal_dark, width=1)

    # Top ventilation grille
    vent_top = chassis_top + 5
    vent_height = 8
    for x in range(chassis_left + 6, chassis_right - 6, 4):
        draw.rectangle([x, vent_top, x + 2, vent_top + vent_height], fill=metal_dark)

    # Status LED row
    led_y = vent_top + vent_height + 4
    led_colors = [
        (0, 255, 100),   # Power - green
        (0, 255, 100),   # Status - green
        color,           # Activity - server color
        color,           # Activity - server color
        (100, 100, 110), # Off
        (255, 200, 50),  # Warning - amber (dim)
    ]
    led_x = chassis_left + 8
    for i, led_color in enumerate(led_colors):
        draw.ellipse([led_x + i * 6, led_y, led_x + i * 6 + 4, led_y + 4], fill=led_color)

    # Drive bays (2x2 grid)
    bay_start_y = led_y + 8
    bay_width = 16
    bay_height = 10
    bay_gap = 2

    for row in range(2):
        for col in range(2):
            bx = chassis_left + 6 + col * (bay_width + bay_gap)
            by = bay_start_y + row * (bay_height + bay_gap)

            # Drive bay slot
            draw.rectangle([bx, by, bx + bay_width, by + bay_height],
                           fill=metal_dark, outline=(30, 35, 45), width=1)

            # Drive activity LED
            activity_color = color if (row + col) % 2 == 0 else (60, 65, 75)
            draw.ellipse([bx + bay_width - 5, by + 2, bx + bay_width - 1, by + 6],
                         fill=activity_color)

    # Side cooling fan (visible)
    fan_cx = chassis_right - 8
    fan_cy = cy + 4
    draw.ellipse([fan_cx - 6, fan_cy - 6, fan_cx + 6, fan_cy + 6],
                 fill=metal_dark, outline=metal, width=1)
    # Fan blades hint
    for angle in range(0, 360, 60):
        rad = math.radians(angle)
        x1 = fan_cx + int(2 * math.cos(rad))
        y1 = fan_cy + int(2 * math.sin(rad))
        x2 = fan_cx + int(5 * math.cos(rad))
        y2 = fan_cy + int(5 * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=metal_light, width=1)

    # Power connector on back (subtle)
    draw.rectangle([chassis_right - 3, cy - 4, chassis_right, cy + 4],
                   fill=(40, 40, 50))

    return img


def draw_advanced_server_sprite(img):
    """
    Advanced Server sprite - Tier 2 server with blue accents and more LEDs.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = (50, 150, 255)  # Blue accent
    color_dark = darken(color)
    color_light = lighten(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']
    metal_light = COLORS['metal_light']

    # Server chassis (slightly different styling)
    chassis_left = cx - 22
    chassis_right = cx + 22
    chassis_top = cy - 18
    chassis_bottom = cy + 18

    # Chassis shadow
    draw.rectangle([chassis_left + 3, chassis_top + 3, chassis_right + 3, chassis_bottom + 3],
                   fill=(25, 30, 40))

    # Main chassis body (darker, more premium)
    draw.rectangle([chassis_left, chassis_top, chassis_right, chassis_bottom],
                   fill=(45, 55, 70), outline=(35, 45, 60), width=2)

    # Blue accent stripe at top
    draw.rectangle([chassis_left, chassis_top, chassis_right, chassis_top + 4],
                   fill=color)

    # Front bezel
    bezel_margin = 3
    draw.rectangle([chassis_left + bezel_margin, chassis_top + bezel_margin + 4,
                    chassis_right - bezel_margin, chassis_bottom - bezel_margin],
                   fill=metal, outline=metal_dark, width=1)

    # Enhanced ventilation grille
    vent_top = chassis_top + 9
    vent_height = 6
    for x in range(chassis_left + 6, chassis_right - 6, 3):
        draw.rectangle([x, vent_top, x + 1, vent_top + vent_height], fill=(35, 45, 55))

    # Status LED row (more active LEDs)
    led_y = vent_top + vent_height + 4
    led_colors = [
        (0, 255, 100),   # Power - green
        color,           # Activity - blue
        color,           # Activity - blue
        color_light,     # Activity - bright blue
        color,           # Activity - blue
        (0, 255, 100),   # Status - green
    ]
    led_x = chassis_left + 7
    for i, led_color in enumerate(led_colors):
        draw.ellipse([led_x + i * 6, led_y, led_x + i * 6 + 4, led_y + 4], fill=led_color)

    # High-density drive bays (3 rows)
    bay_start_y = led_y + 8
    bay_width = 15
    bay_height = 7
    bay_gap = 2

    for row in range(3):
        for col in range(2):
            bx = chassis_left + 6 + col * (bay_width + bay_gap + 2)
            by = bay_start_y + row * (bay_height + bay_gap)

            # Drive bay slot
            draw.rectangle([bx, by, bx + bay_width, by + bay_height],
                           fill=(35, 40, 50), outline=(28, 33, 43), width=1)

            # Drive activity LED (blue)
            activity_color = color if row < 2 else (60, 65, 75)
            draw.ellipse([bx + bay_width - 5, by + 1, bx + bay_width - 1, by + 5],
                         fill=activity_color)

    # Cooling system (visible blue accent)
    fan_cx = chassis_right - 8
    fan_cy = cy + 6
    draw.ellipse([fan_cx - 6, fan_cy - 6, fan_cx + 6, fan_cy + 6],
                 fill=metal_dark, outline=color, width=1)

    return img


def draw_hp_server_sprite(img):
    """
    High-Performance Server sprite - Tier 3 server with gold accents and premium design.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = (255, 200, 50)   # Gold accent
    color_dark = darken(color)
    color_light = lighten(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']
    metal_light = COLORS['metal_light']

    # Server chassis (premium finish)
    chassis_left = cx - 22
    chassis_right = cx + 22
    chassis_top = cy - 18
    chassis_bottom = cy + 18

    # Chassis shadow
    draw.rectangle([chassis_left + 3, chassis_top + 3, chassis_right + 3, chassis_bottom + 3],
                   fill=(20, 20, 25))

    # Main chassis body (very dark, premium)
    draw.rectangle([chassis_left, chassis_top, chassis_right, chassis_bottom],
                   fill=(35, 38, 48), outline=(28, 30, 40), width=2)

    # Gold accent stripes (top and bottom)
    draw.rectangle([chassis_left, chassis_top, chassis_right, chassis_top + 3],
                   fill=color)
    draw.rectangle([chassis_left, chassis_bottom - 3, chassis_right, chassis_bottom],
                   fill=color)

    # Front bezel (premium)
    bezel_margin = 3
    draw.rectangle([chassis_left + bezel_margin, chassis_top + bezel_margin + 3,
                    chassis_right - bezel_margin, chassis_bottom - bezel_margin - 3],
                   fill=(45, 48, 58), outline=metal_dark, width=1)

    # Premium ventilation with gold trim
    vent_top = chassis_top + 8
    vent_height = 5
    for x in range(chassis_left + 6, chassis_right - 6, 3):
        draw.rectangle([x, vent_top, x + 1, vent_top + vent_height], fill=(30, 33, 43))

    # Premium LED display (gold themed)
    led_y = vent_top + vent_height + 3
    led_colors = [
        color,           # Gold
        color,           # Gold
        color,           # Gold
        color_light,     # Bright gold
        color,           # Gold
        color,           # Gold
        (0, 255, 100),   # Power - green
    ]
    led_x = chassis_left + 6
    for i, led_color in enumerate(led_colors):
        draw.ellipse([led_x + i * 5, led_y, led_x + i * 5 + 3, led_y + 3], fill=led_color)

    # High-density NVMe drive array (4 rows, compact)
    bay_start_y = led_y + 6
    bay_width = 14
    bay_height = 5
    bay_gap = 1

    for row in range(4):
        for col in range(2):
            bx = chassis_left + 6 + col * (bay_width + bay_gap + 4)
            by = bay_start_y + row * (bay_height + bay_gap)

            # Drive bay slot
            draw.rectangle([bx, by, bx + bay_width, by + bay_height],
                           fill=(28, 30, 40), outline=(22, 24, 34), width=1)

            # All drives active (gold LEDs)
            draw.ellipse([bx + bay_width - 4, by + 1, bx + bay_width - 1, by + 4],
                         fill=color_light)

    # Dual cooling fans
    for offset in [-5, 5]:
        fan_cx = chassis_right - 8
        fan_cy = cy + offset
        draw.ellipse([fan_cx - 4, fan_cy - 4, fan_cx + 4, fan_cy + 4],
                     fill=metal_dark, outline=color, width=1)

    return img


def draw_circuit_bridge_sprite(img):
    """
    Circuit Bridge sprite - Combinator-style device that bridges IT and circuit networks.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['bridge']
    color_dark = darken(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']

    # Main body (wider than tall, combinator-like)
    body_left = cx - 22
    body_right = cx + 22
    body_top = cy - 12
    body_bottom = cy + 12

    # Shadow
    draw.rectangle([body_left + 3, body_top + 3, body_right + 3, body_bottom + 3],
                   fill=(30, 30, 35))

    # Main body
    draw.rectangle([body_left, body_top, body_right, body_bottom],
                   fill=metal, outline=metal_dark, width=2)

    # Circuit board surface
    pcb_margin = 4
    draw.rectangle([body_left + pcb_margin, body_top + pcb_margin,
                    body_right - pcb_margin, body_bottom - pcb_margin],
                   fill=(40, 80, 40), outline=(30, 60, 30), width=1)

    # Circuit traces
    trace_color = color
    # Horizontal traces
    draw.line([(body_left + 8, cy - 4), (body_right - 8, cy - 4)], fill=trace_color, width=1)
    draw.line([(body_left + 8, cy + 4), (body_right - 8, cy + 4)], fill=trace_color, width=1)
    # Vertical traces
    draw.line([(cx - 8, body_top + 6), (cx - 8, body_bottom - 6)], fill=trace_color, width=1)
    draw.line([(cx + 8, body_top + 6), (cx + 8, body_bottom - 6)], fill=trace_color, width=1)

    # Central chip/processor
    chip_size = 10
    draw.rectangle([cx - chip_size//2, cy - chip_size//2, cx + chip_size//2, cy + chip_size//2],
                   fill=(20, 20, 25), outline=color_dark, width=1)
    # Chip pins
    for i in range(-3, 4, 2):
        draw.rectangle([cx - chip_size//2 - 2, cy + i - 1, cx - chip_size//2, cy + i + 1],
                       fill=metal)
        draw.rectangle([cx + chip_size//2, cy + i - 1, cx + chip_size//2 + 2, cy + i + 1],
                       fill=metal)

    # Wire connection points (left - red wire, right - green wire)
    # Left connector
    draw.rectangle([body_left - 6, cy - 6, body_left, cy + 6],
                   fill=metal_dark, outline=(40, 40, 50), width=1)
    draw.ellipse([body_left - 5, cy - 3, body_left - 1, cy + 3], fill=(255, 80, 80))

    # Right connector
    draw.rectangle([body_right, cy - 6, body_right + 6, cy + 6],
                   fill=metal_dark, outline=(40, 40, 50), width=1)
    draw.ellipse([body_right + 1, cy - 3, body_right + 5, cy + 3], fill=(80, 255, 80))

    # Status indicator
    draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=color)

    return img


def draw_dashboard_terminal_sprite(img):
    """
    Dashboard Terminal sprite - Monitor/display screen on a stand.
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['dashboard']
    color_dark = darken(color)
    color_light = lighten(color)
    metal = COLORS['metal_mid']
    metal_dark = COLORS['metal_dark']

    # Monitor stand base
    base_width = 24
    base_height = 6
    base_y = cy + 20
    draw.rectangle([cx - base_width//2, base_y, cx + base_width//2, base_y + base_height],
                   fill=metal_dark, outline=(40, 45, 55), width=1)

    # Stand neck
    neck_width = 8
    neck_top = cy + 10
    draw.rectangle([cx - neck_width//2, neck_top, cx + neck_width//2, base_y],
                   fill=metal, outline=metal_dark, width=1)

    # Monitor frame
    frame_left = cx - 24
    frame_right = cx + 24
    frame_top = cy - 20
    frame_bottom = cy + 12

    # Frame shadow
    draw.rectangle([frame_left + 3, frame_top + 3, frame_right + 3, frame_bottom + 3],
                   fill=(30, 30, 35))

    # Monitor bezel
    draw.rectangle([frame_left, frame_top, frame_right, frame_bottom],
                   fill=metal_dark, outline=(40, 45, 55), width=2)

    # Screen area
    screen_margin = 4
    screen_left = frame_left + screen_margin
    screen_right = frame_right - screen_margin
    screen_top = frame_top + screen_margin
    screen_bottom = frame_bottom - screen_margin

    # Screen background (dark)
    draw.rectangle([screen_left, screen_top, screen_right, screen_bottom],
                   fill=(20, 15, 30), outline=color_dark, width=1)

    # Screen content - dashboard elements
    content_margin = 3

    # Title bar
    draw.rectangle([screen_left + content_margin, screen_top + content_margin,
                    screen_right - content_margin, screen_top + content_margin + 4],
                   fill=color_dark)

    # Metric bars (vertical bar chart)
    bar_bottom = screen_bottom - content_margin - 2
    bar_heights = [18, 12, 20, 8, 15]
    bar_colors = [(100, 255, 150), (255, 220, 100), (100, 200, 255), (255, 100, 100), color_light]
    bar_width = 6
    bar_gap = 2
    bar_start_x = screen_left + content_margin + 2

    for i, (height, bar_color) in enumerate(zip(bar_heights, bar_colors)):
        bx = bar_start_x + i * (bar_width + bar_gap)
        draw.rectangle([bx, bar_bottom - height, bx + bar_width, bar_bottom],
                       fill=bar_color)

    # Small status indicators on right side
    indicator_x = screen_right - content_margin - 6
    for i, ind_color in enumerate([(0, 255, 100), (255, 200, 50), (100, 150, 255)]):
        iy = screen_top + content_margin + 8 + i * 6
        draw.ellipse([indicator_x, iy, indicator_x + 4, iy + 4], fill=ind_color)

    # Power LED on bezel
    draw.ellipse([frame_right - 8, frame_bottom - 6, frame_right - 4, frame_bottom - 2],
                 fill=(0, 255, 100))

    return img


def draw_network_cable_sprite(img, direction='horizontal'):
    """
    Network Cable sprite - Fiber optic / ethernet cable conduit.
    Static sprite designed to tile seamlessly.

    direction: 'horizontal' or 'vertical'
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['cable']
    color_dark = darken(color)
    color_light = lighten(color)

    # Fiber optic blue core
    fiber_core = (0, 150, 255)
    fiber_glow = (100, 200, 255)

    # Conduit colors
    conduit_outer = (60, 65, 75)
    conduit_inner = (40, 45, 55)

    if direction == 'horizontal':
        # Horizontal cable conduit (fills tile edge to edge)
        conduit_height = 20

        # Outer conduit shell
        draw.rectangle([0, cy - conduit_height//2, size, cy + conduit_height//2],
                       fill=conduit_outer)

        # Inner conduit channel
        draw.rectangle([0, cy - conduit_height//2 + 3, size, cy + conduit_height//2 - 3],
                       fill=conduit_inner)

        # Main fiber cable (orange outer jacket)
        draw.rectangle([0, cy - 6, size, cy + 6],
                       fill=color)

        # Fiber core (glowing blue center)
        draw.rectangle([0, cy - 3, size, cy + 3],
                       fill=fiber_core)

        # Data flow glow effect (center line)
        draw.line([(0, cy), (size, cy)], fill=fiber_glow, width=2)

        # Cable jacket segments (subtle)
        for x in range(4, size, 12):
            draw.line([(x, cy - 5), (x, cy + 5)], fill=color_dark, width=1)

    else:  # vertical
        # Vertical cable conduit
        conduit_width = 20

        # Outer conduit shell
        draw.rectangle([cx - conduit_width//2, 0, cx + conduit_width//2, size],
                       fill=conduit_outer)

        # Inner conduit channel
        draw.rectangle([cx - conduit_width//2 + 3, 0, cx + conduit_width//2 - 3, size],
                       fill=conduit_inner)

        # Main fiber cable
        draw.rectangle([cx - 6, 0, cx + 6, size],
                       fill=color)

        # Fiber core
        draw.rectangle([cx - 3, 0, cx + 3, size],
                       fill=fiber_core)

        # Data flow glow
        draw.line([(cx, 0), (cx, size)], fill=fiber_glow, width=2)

        # Cable jacket segments
        for y in range(4, size, 12):
            draw.line([(cx - 5, y), (cx + 5, y)], fill=color_dark, width=1)

    return img


def draw_network_cable_corner_sprite(img, corner='ne'):
    """
    Network Cable corner sprite.
    corner: 'ne', 'nw', 'se', 'sw' (direction the corner turns)
    """
    draw = ImageDraw.Draw(img)
    size = img.size[0]
    cx, cy = size // 2, size // 2

    color = COLORS['cable']
    color_dark = darken(color)
    fiber_core = (0, 150, 255)
    fiber_glow = (100, 200, 255)
    conduit_outer = (60, 65, 75)
    conduit_inner = (40, 45, 55)

    conduit_size = 20
    cable_size = 12
    core_size = 6

    # Draw corner based on direction
    # For simplicity, draw a simple corner piece
    if corner == 'ne':  # comes from west, goes north
        # Horizontal part (left to center)
        draw.rectangle([0, cy - conduit_size//2, cx + conduit_size//2, cy + conduit_size//2], fill=conduit_outer)
        # Vertical part (center to top)
        draw.rectangle([cx - conduit_size//2, 0, cx + conduit_size//2, cy + conduit_size//2], fill=conduit_outer)
        # Inner
        draw.rectangle([0, cy - cable_size//2, cx + cable_size//2, cy + cable_size//2], fill=color)
        draw.rectangle([cx - cable_size//2, 0, cx + cable_size//2, cy + cable_size//2], fill=color)
        # Core
        draw.rectangle([0, cy - core_size//2, cx, cy + core_size//2], fill=fiber_core)
        draw.rectangle([cx - core_size//2, 0, cx + core_size//2, cy], fill=fiber_core)
        # Glow
        draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=fiber_glow)

    return img


def generate_hr_version(sprite_func, scale=2):
    """Generate high-resolution version of a sprite."""
    hr_size = SPRITE_SIZE * scale
    hr_img = create_base_sprite(hr_size)
    # Would need to redraw at higher resolution
    # For now, just upscale
    base_img = create_base_sprite(SPRITE_SIZE)
    sprite_func(base_img)
    return base_img.resize((hr_size, hr_size), Image.Resampling.LANCZOS)


def generate_shadow(img):
    """Generate a shadow version of an image."""
    shadow_only = Image.new('RGBA', img.size, (0, 0, 0, 0))
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            pixel = img.getpixel((x, y))
            if pixel[3] > 50:  # Has some opacity
                sx = min(img.size[0] - 1, x + 3)
                sy = min(img.size[1] - 1, y + 3)
                shadow_only.putpixel((sx, sy), (0, 0, 0, min(100, pixel[3] // 2)))
    return shadow_only.filter(ImageFilter.GaussianBlur(radius=2))


def main():
    # Get the script directory to find the graphics folder
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sprites_dir = os.path.join(script_dir, '..', 'graphics', 'entity')

    # Ensure directories exist
    os.makedirs(sprites_dir, exist_ok=True)

    # Entity sprites to generate
    sprites = {
        'data-sensor.png': draw_data_sensor_sprite,
        'basic-server.png': draw_basic_server_sprite,
        'advanced-server.png': draw_advanced_server_sprite,
        'hp-server.png': draw_hp_server_sprite,
        'circuit-bridge.png': draw_circuit_bridge_sprite,
        'dashboard-terminal.png': draw_dashboard_terminal_sprite,
    }

    print("Generating entity sprites...")
    print(f"Output directory: {os.path.abspath(sprites_dir)}")
    print()

    for filename, draw_func in sprites.items():
        # Generate standard resolution
        img = create_base_sprite(SPRITE_SIZE)
        draw_func(img)
        filepath = os.path.join(sprites_dir, filename)
        img.save(filepath, 'PNG')
        print(f"Generated: {filename} ({SPRITE_SIZE}x{SPRITE_SIZE})")

        # Generate shadow version
        shadow_img = create_base_sprite(SPRITE_SIZE)
        draw_func(shadow_img)
        shadow_only = generate_shadow(shadow_img)
        shadow_filename = filename.replace('.png', '-shadow.png')
        shadow_filepath = os.path.join(sprites_dir, shadow_filename)
        shadow_only.save(shadow_filepath, 'PNG')
        print(f"Generated: {shadow_filename} (shadow layer)")

    # Generate network cable sprites (horizontal - main sprite used for all directions)
    print()
    print("Generating network cable sprites...")

    # Horizontal cable (main sprite)
    img = create_base_sprite(SPRITE_SIZE)
    draw_network_cable_sprite(img, 'horizontal')
    filepath = os.path.join(sprites_dir, 'network-cable.png')
    img.save(filepath, 'PNG')
    print(f"Generated: network-cable.png (horizontal)")

    shadow_only = generate_shadow(img)
    shadow_filepath = os.path.join(sprites_dir, 'network-cable-shadow.png')
    shadow_only.save(shadow_filepath, 'PNG')
    print(f"Generated: network-cable-shadow.png")

    # Vertical cable
    img = create_base_sprite(SPRITE_SIZE)
    draw_network_cable_sprite(img, 'vertical')
    filepath = os.path.join(sprites_dir, 'network-cable-vertical.png')
    img.save(filepath, 'PNG')
    print(f"Generated: network-cable-vertical.png")

    print()
    print("All entity sprites generated successfully!")
    print()
    print("Network cable uses static fiber optic conduit design.")
    print("Data flow is instant (max belt speed) - no animation needed.")


if __name__ == '__main__':
    main()
