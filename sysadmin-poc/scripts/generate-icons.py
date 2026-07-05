#!/usr/bin/env python3
"""
Generate icons for Sysadmin POC mod entities.
Run this script to regenerate all placeholder icons with proper programmatic graphics.

Requires: pip install Pillow
"""

from PIL import Image, ImageDraw
import os

# Icon size for Factorio
ICON_SIZE = 32

# Color palette (matching entities.lua COLORS table)
COLORS = {
    'sensor': (102, 204, 255),      # Cyan - data collection
    'cable': (255, 153, 51),        # Orange - network cables
    'server': (77, 255, 128),       # Green - server LEDs
    'bridge': (255, 255, 102),      # Yellow - circuit color
    'dashboard': (178, 102, 255),   # Purple - monitoring
    'packet': (51, 153, 255),       # Blue - data packets
    'signal_t': (255, 200, 50),     # Gold - throughput
    'signal_d': (50, 200, 255),     # Cyan - data rate
    'signal_u': (50, 255, 100),     # Green - utilization
}

def create_base_icon():
    """Create a transparent 32x32 base image."""
    return Image.new('RGBA', (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))

def add_shadow(draw, shape_func, offset=1):
    """Add a subtle shadow to a shape."""
    # Shadow is drawn first, slightly offset
    pass  # Skip shadows for simplicity

def draw_data_packet(img):
    """Data packet - folded document/envelope shape."""
    draw = ImageDraw.Draw(img)
    color = COLORS['packet']

    # Main document body
    draw.rectangle([6, 4, 26, 28], fill=color, outline=(30, 100, 180), width=1)

    # Folded corner
    draw.polygon([(20, 4), (26, 10), (20, 10)], fill=(30, 100, 180))

    # Data lines
    line_color = (200, 230, 255)
    draw.rectangle([9, 14, 23, 16], fill=line_color)
    draw.rectangle([9, 19, 20, 21], fill=line_color)
    draw.rectangle([9, 24, 17, 26], fill=line_color)

    return img

def draw_data_sensor(img):
    """Data sensor - antenna/radar dish shape."""
    draw = ImageDraw.Draw(img)
    color = COLORS['sensor']
    darker = (60, 150, 200)

    # Base/body (chest-like)
    draw.rectangle([8, 16, 24, 28], fill=color, outline=darker, width=1)

    # Antenna mast
    draw.rectangle([14, 6, 18, 18], fill=darker)

    # Signal waves (arcs)
    draw.arc([4, 2, 20, 14], start=220, end=320, fill=(150, 220, 255), width=2)
    draw.arc([8, 4, 24, 12], start=220, end=320, fill=(180, 235, 255), width=2)

    # LED indicator
    draw.ellipse([10, 20, 14, 24], fill=(0, 255, 128))

    return img

def draw_network_cable(img):
    """Network cable - dark cable/belt segment with orange data indicator."""
    draw = ImageDraw.Draw(img)
    dark = (30, 30, 35)  # Dark/black cable body
    accent = COLORS['cable']  # Orange accent

    # Cable body (horizontal segment) - dark/black
    draw.rectangle([2, 12, 30, 20], fill=dark, outline=(20, 20, 25), width=1)

    # Cable texture lines (subtle)
    for x in [6, 12, 18, 24]:
        draw.line([(x, 12), (x, 20)], fill=(40, 40, 45), width=1)

    # Connector ends - dark
    draw.rectangle([2, 10, 6, 22], fill=(40, 40, 50), outline=(25, 25, 35))
    draw.rectangle([26, 10, 30, 22], fill=(40, 40, 50), outline=(25, 25, 35))

    # Orange direction arrow (the data flow indicator)
    draw.polygon([(14, 6), (22, 6), (18, 2)], fill=accent)

    return img


def draw_network_cable_underground(img):
    """Network cable underground - dark cable with underground indicator."""
    draw = ImageDraw.Draw(img)
    dark = (30, 30, 35)
    accent = COLORS['cable']  # Orange

    # Underground entry/exit frame
    draw.rectangle([6, 6, 26, 26], fill=(50, 50, 55), outline=(35, 35, 40), width=1)

    # Dark tunnel opening
    draw.rectangle([8, 8, 24, 24], fill=(20, 20, 25))

    # Cable emerging from underground - dark with orange tip
    draw.rectangle([12, 4, 20, 16], fill=dark, outline=(25, 25, 30), width=1)

    # Orange arrow pointing down (into ground)
    draw.polygon([(12, 18), (20, 18), (16, 26)], fill=accent)

    # Cable end indicator
    draw.rectangle([13, 4, 19, 8], fill=(40, 40, 50))

    return img


def draw_network_cable_splitter(img):
    """Network cable splitter - dark splitter with orange flow indicators."""
    draw = ImageDraw.Draw(img)
    dark = (30, 30, 35)
    accent = COLORS['cable']  # Orange

    # Main body (2x1 splitter shape)
    draw.rectangle([2, 10, 30, 22], fill=dark, outline=(20, 20, 25), width=1)

    # Center divider
    draw.line([(16, 10), (16, 22)], fill=(50, 50, 55), width=2)

    # Input side (left)
    draw.rectangle([2, 12, 8, 20], fill=(40, 40, 50), outline=(25, 25, 35))

    # Output sides (right)
    draw.rectangle([24, 8, 30, 14], fill=(40, 40, 50), outline=(25, 25, 35))
    draw.rectangle([24, 18, 30, 24], fill=(40, 40, 50), outline=(25, 25, 35))

    # Orange flow arrows
    draw.polygon([(10, 16), (14, 13), (14, 19)], fill=accent)  # Input arrow
    draw.polygon([(18, 11), (22, 8), (22, 14)], fill=accent)   # Top output
    draw.polygon([(18, 21), (22, 18), (22, 24)], fill=accent)  # Bottom output

    return img

def draw_basic_server(img):
    """Basic server - server rack/computer shape."""
    draw = ImageDraw.Draw(img)
    color = COLORS['server']
    darker = (40, 180, 80)

    # Server body
    draw.rectangle([6, 4, 26, 28], fill=(60, 70, 80), outline=(40, 50, 60), width=1)

    # Front panel
    draw.rectangle([8, 6, 24, 26], fill=(50, 60, 70))

    # Status LEDs
    draw.ellipse([10, 8, 14, 12], fill=color)  # Green LED
    draw.ellipse([16, 8, 20, 12], fill=color)  # Green LED
    draw.ellipse([22, 8, 26, 12], fill=(100, 100, 100))  # Off LED

    # Drive bays
    draw.rectangle([10, 14, 22, 18], fill=(30, 40, 50))
    draw.rectangle([10, 20, 22, 24], fill=(30, 40, 50))

    # Ventilation
    for y in [15, 17, 21, 23]:
        draw.line([(11, y), (21, y)], fill=(20, 30, 40))

    return img

def draw_advanced_server(img):
    """Advanced server - upgraded server with blue accents (tier 2)."""
    draw = ImageDraw.Draw(img)
    color = (50, 150, 255)  # Blue for advanced
    accent = (100, 180, 255)

    # Server body (slightly different color)
    draw.rectangle([6, 4, 26, 28], fill=(50, 60, 80), outline=(35, 45, 60), width=1)

    # Front panel with blue accent
    draw.rectangle([8, 6, 24, 26], fill=(45, 55, 75))

    # Blue accent stripe
    draw.rectangle([8, 6, 24, 8], fill=color)

    # Status LEDs (more active)
    draw.ellipse([10, 10, 14, 14], fill=color)   # Blue LED
    draw.ellipse([16, 10, 20, 14], fill=color)   # Blue LED
    draw.ellipse([22, 10, 26, 14], fill=accent)  # Blue LED (active)

    # Drive bays
    draw.rectangle([10, 16, 22, 19], fill=(30, 40, 55))
    draw.rectangle([10, 21, 22, 24], fill=(30, 40, 55))

    # Drive activity lights
    draw.ellipse([11, 16, 13, 18], fill=(100, 200, 255))
    draw.ellipse([11, 21, 13, 23], fill=(100, 200, 255))

    # Ventilation
    for y in [17, 22]:
        draw.line([(14, y), (21, y)], fill=(20, 30, 45))

    return img

def draw_hp_server(img):
    """High-Performance server - premium server with gold accents (tier 3)."""
    draw = ImageDraw.Draw(img)
    color = (255, 200, 50)   # Gold for HP
    accent = (255, 220, 100)

    # Server body (premium finish)
    draw.rectangle([6, 4, 26, 28], fill=(40, 45, 55), outline=(30, 35, 45), width=1)

    # Front panel with gold accent
    draw.rectangle([8, 6, 24, 26], fill=(35, 40, 50))

    # Gold accent stripes (double)
    draw.rectangle([8, 6, 24, 8], fill=color)
    draw.rectangle([8, 24, 24, 26], fill=color)

    # Premium status LEDs (all active)
    draw.ellipse([9, 10, 13, 14], fill=color)    # Gold LED
    draw.ellipse([15, 10, 19, 14], fill=color)   # Gold LED
    draw.ellipse([21, 10, 25, 14], fill=color)   # Gold LED

    # High-density drive array
    draw.rectangle([10, 16, 22, 18], fill=(25, 30, 40))
    draw.rectangle([10, 19, 22, 21], fill=(25, 30, 40))
    draw.rectangle([10, 22, 22, 24], fill=(25, 30, 40))

    # All drives active (gold lights)
    for y in [16, 19, 22]:
        draw.ellipse([11, y, 13, y+1], fill=accent)
        draw.ellipse([20, y, 22, y+1], fill=accent)

    return img

def draw_circuit_bridge(img):
    """Circuit bridge - connector/combinator shape."""
    draw = ImageDraw.Draw(img)
    color = COLORS['bridge']
    darker = (200, 180, 50)

    # Main body
    draw.rectangle([8, 8, 24, 24], fill=(70, 70, 80), outline=(50, 50, 60), width=1)

    # Circuit pattern on top
    draw.rectangle([10, 10, 22, 22], fill=color, outline=darker, width=1)

    # Connection points (left and right)
    draw.rectangle([2, 12, 8, 20], fill=(80, 80, 90), outline=(60, 60, 70))
    draw.rectangle([24, 12, 30, 20], fill=(80, 80, 90), outline=(60, 60, 70))

    # Wire connection dots
    draw.ellipse([3, 14, 7, 18], fill=(255, 80, 80))   # Red wire point
    draw.ellipse([25, 14, 29, 18], fill=(80, 255, 80)) # Green wire point

    # Center indicator
    draw.ellipse([13, 13, 19, 19], fill=(255, 255, 200))

    return img

def draw_dashboard_terminal(img):
    """Dashboard terminal - monitor/display shape."""
    draw = ImageDraw.Draw(img)
    color = COLORS['dashboard']
    darker = (130, 60, 200)

    # Monitor frame
    draw.rectangle([4, 4, 28, 22], fill=(50, 50, 60), outline=(30, 30, 40), width=1)

    # Screen
    draw.rectangle([6, 6, 26, 20], fill=color, outline=darker, width=1)

    # Screen content (bar graph)
    draw.rectangle([8, 10, 11, 18], fill=(100, 255, 150))
    draw.rectangle([13, 12, 16, 18], fill=(255, 200, 100))
    draw.rectangle([18, 8, 21, 18], fill=(100, 200, 255))
    draw.rectangle([23, 14, 26, 18], fill=(255, 100, 100))

    # Stand
    draw.rectangle([12, 22, 20, 24], fill=(70, 70, 80))
    draw.rectangle([10, 24, 22, 28], fill=(60, 60, 70))

    return img

def draw_signal_throughput(img):
    """Signal icon for throughput - speedometer/arrow."""
    draw = ImageDraw.Draw(img)
    color = COLORS['signal_t']

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Arrow pointing up-right (throughput/speed)
    draw.polygon([
        (10, 22), (22, 10), (22, 16), (26, 16), (26, 20), (16, 20), (16, 26), (10, 22)
    ], fill=color)

    # "T" letter
    draw.rectangle([12, 8, 20, 10], fill=(255, 255, 255))
    draw.rectangle([15, 10, 17, 18], fill=(255, 255, 255))

    return img

def draw_signal_data_rate(img):
    """Signal icon for data rate - wave/pulse."""
    draw = ImageDraw.Draw(img)
    color = COLORS['signal_d']

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Data wave pattern
    points = [(8, 16), (11, 10), (14, 20), (17, 8), (20, 22), (23, 12), (26, 16)]
    draw.line(points, fill=color, width=2)

    return img

def draw_signal_utilization(img):
    """Signal icon for utilization - percentage/gauge."""
    draw = ImageDraw.Draw(img)
    color = COLORS['signal_u']

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Percentage arc (75% filled)
    draw.arc([8, 8, 24, 24], start=135, end=45, fill=color, width=3)

    # Center percentage text hint
    draw.rectangle([13, 13, 19, 19], fill=color)

    return img

def draw_signal_monitored_count(img):
    """Signal icon for monitored count - multiple dots/entities."""
    draw = ImageDraw.Draw(img)
    color = (100, 200, 255)  # Light blue

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Multiple small squares representing monitored entities
    draw.rectangle([8, 8, 13, 13], fill=color)
    draw.rectangle([15, 8, 20, 13], fill=color)
    draw.rectangle([22, 8, 27, 13], fill=(80, 80, 90))  # Inactive
    draw.rectangle([8, 15, 13, 20], fill=color)
    draw.rectangle([15, 15, 20, 20], fill=color)
    draw.rectangle([8, 22, 13, 27], fill=color)

    return img

def draw_signal_data_backlog(img):
    """Signal icon for data backlog - stacked items/queue."""
    draw = ImageDraw.Draw(img)
    color = (255, 100, 100)  # Red/warning color

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Stacked rectangles (backlog visualization)
    draw.rectangle([10, 20, 22, 24], fill=(150, 80, 80))
    draw.rectangle([10, 15, 22, 19], fill=(180, 90, 90))
    draw.rectangle([10, 10, 22, 14], fill=(210, 100, 100))
    draw.rectangle([10, 5, 22, 9], fill=color)

    # Warning indicator
    draw.polygon([(16, 7), (14, 11), (18, 11)], fill=(255, 255, 200))

    return img

def draw_signal_it_control(img):
    """Signal icon for IT control - power/control switch symbol."""
    draw = ImageDraw.Draw(img)
    color = (255, 200, 50)  # Gold/yellow for control

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Power/control symbol (circle with line through top)
    draw.arc([9, 10, 23, 24], start=45, end=315, fill=color, width=3)
    draw.line([(16, 7), (16, 15)], fill=color, width=3)

    return img

def draw_signal_sensor_id(img):
    """Signal icon for sensor ID - numbered sensor identifier."""
    draw = ImageDraw.Draw(img)
    color = (102, 204, 255)  # Cyan (sensor color)

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Sensor icon (small antenna)
    draw.rectangle([14, 8, 18, 14], fill=color)
    draw.arc([10, 4, 22, 12], start=220, end=320, fill=(180, 235, 255), width=2)

    # ID number "1" below
    draw.rectangle([14, 18, 18, 26], fill=(255, 255, 255))
    draw.rectangle([12, 18, 14, 20], fill=(255, 255, 255))

    return img

def draw_signal_sensor_entities(img):
    """Signal icon for sensor entities count - sensor with entity count."""
    draw = ImageDraw.Draw(img)
    color = (102, 204, 255)  # Cyan (sensor color)

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Small entities (assemblers) being monitored
    draw.rectangle([7, 7, 12, 12], fill=(100, 150, 200))
    draw.rectangle([14, 7, 19, 12], fill=(100, 150, 200))
    draw.rectangle([21, 7, 26, 12], fill=(100, 150, 200))

    # Sensor below
    draw.rectangle([12, 18, 20, 26], fill=color, outline=(60, 150, 200))

    # Connection lines
    draw.line([(9, 12), (14, 18)], fill=color, width=1)
    draw.line([(16, 12), (16, 18)], fill=color, width=1)
    draw.line([(23, 12), (18, 18)], fill=color, width=1)

    return img

def draw_signal_sensor_backlog(img):
    """Signal icon for sensor backlog - sensor with stacked packets."""
    draw = ImageDraw.Draw(img)
    color = (255, 150, 50)  # Orange/warning

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Sensor shape
    draw.rectangle([8, 16, 16, 24], fill=(102, 204, 255), outline=(60, 150, 200))

    # Stacked packets in sensor (backlog)
    draw.rectangle([18, 20, 26, 24], fill=(51, 153, 255))
    draw.rectangle([18, 15, 26, 19], fill=(70, 170, 255))
    draw.rectangle([18, 10, 26, 14], fill=(90, 190, 255))
    draw.rectangle([18, 5, 26, 9], fill=color)

    # Warning indicator
    draw.polygon([(22, 7), (20, 11), (24, 11)], fill=(255, 255, 200))

    return img

def draw_signal_sensor_data_rate(img):
    """Signal icon for sensor data rate - sensor with data flow."""
    draw = ImageDraw.Draw(img)
    color = (50, 200, 255)  # Cyan for data

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Sensor shape
    draw.rectangle([6, 14, 14, 22], fill=(102, 204, 255), outline=(60, 150, 200))

    # Data flow arrow/stream
    draw.polygon([(16, 18), (26, 18), (26, 14), (28, 18), (26, 22), (26, 18)], fill=color)

    # Data packets in stream
    draw.rectangle([17, 16, 20, 20], fill=(51, 153, 255))
    draw.rectangle([22, 16, 25, 20], fill=(51, 153, 255))

    # Antenna on sensor
    draw.rectangle([8, 10, 12, 14], fill=(60, 150, 200))
    draw.arc([4, 6, 16, 12], start=220, end=320, fill=(180, 235, 255), width=1)

    return img

def draw_signal_technical_debt(img):
    """Signal icon for technical debt - cracked/broken circuit trace."""
    draw = ImageDraw.Draw(img)
    color = (220, 60, 60)   # Deep red — more urgent than backlog's lighter red

    # Circle background
    draw.ellipse([4, 4, 28, 28], fill=(40, 40, 50), outline=color, width=2)

    # Circuit trace running left to right — represents accumulated, broken work
    draw.line([(7, 16), (12, 16)], fill=color, width=2)   # left segment
    draw.line([(20, 16), (25, 16)], fill=color, width=2)  # right segment
    # Break/crack in the middle
    draw.line([(13, 11), (19, 21)], fill=color, width=2)  # diagonal crack

    # Stacked debt bars (filling from bottom, like an accumulating gauge)
    draw.rectangle([11, 22, 21, 24], fill=(140, 40, 40))
    draw.rectangle([11, 19, 21, 21], fill=(180, 50, 50))
    draw.rectangle([11,  8, 21, 10], fill=color)

    # Warning dot at top-right
    draw.ellipse([22, 7, 26, 11], fill=(255, 220, 50))

    return img


def main():
    # Get the script directory to find the graphics folder
    script_dir = os.path.dirname(os.path.abspath(__file__))
    graphics_dir = os.path.join(script_dir, '..', 'graphics', 'icons')
    signals_dir = os.path.join(graphics_dir, 'signals')

    # Ensure directories exist
    os.makedirs(graphics_dir, exist_ok=True)
    os.makedirs(signals_dir, exist_ok=True)

    # Generate entity icons
    icons = {
        'data-packet.png': draw_data_packet,
        'data-sensor.png': draw_data_sensor,
        'network-cable.png': draw_network_cable,
        'network-cable-underground.png': draw_network_cable_underground,
        'network-cable-splitter.png': draw_network_cable_splitter,
        'basic-server.png': draw_basic_server,
        'advanced-server.png': draw_advanced_server,
        'hp-server.png': draw_hp_server,
        'circuit-bridge.png': draw_circuit_bridge,
        'dashboard-terminal.png': draw_dashboard_terminal,
    }

    for filename, draw_func in icons.items():
        img = create_base_icon()
        draw_func(img)
        filepath = os.path.join(graphics_dir, filename)
        img.save(filepath, 'PNG')
        print(f"Generated: {filepath}")

    # Generate signal icons
    signal_icons = {
        'signal-throughput.png': draw_signal_throughput,
        'signal-data-rate.png': draw_signal_data_rate,
        'signal-utilization.png': draw_signal_utilization,
        'signal-monitored-count.png': draw_signal_monitored_count,
        'signal-data-backlog.png': draw_signal_data_backlog,
        'signal-it-control.png': draw_signal_it_control,
        # Per-sensor signals
        'signal-sensor-id.png': draw_signal_sensor_id,
        'signal-sensor-entities.png': draw_signal_sensor_entities,
        'signal-sensor-backlog.png': draw_signal_sensor_backlog,
        'signal-sensor-data-rate.png': draw_signal_sensor_data_rate,
        'signal-technical-debt.png':   draw_signal_technical_debt,
    }

    for filename, draw_func in signal_icons.items():
        img = create_base_icon()
        draw_func(img)
        filepath = os.path.join(signals_dir, filename)
        img.save(filepath, 'PNG')
        print(f"Generated: {filepath}")

    print("\nAll icons generated successfully!")
    print(f"Icons location: {os.path.abspath(graphics_dir)}")

if __name__ == '__main__':
    main()
