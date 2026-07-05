#!/usr/bin/env python3
"""Generate placeholder icons for the sysadmin-poc mod."""

import os
import struct
import zlib

def create_png(width, height, color):
    """Create a simple solid-color PNG image."""
    r, g, b = color

    def make_chunk(chunk_type, data):
        chunk = chunk_type + data
        crc = zlib.crc32(chunk) & 0xffffffff
        return struct.pack('>I', len(data)) + chunk + struct.pack('>I', crc)

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'

    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = make_chunk(b'IHDR', ihdr_data)

    # IDAT chunk (image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # filter type: none
        for x in range(width):
            raw_data += bytes([r, g, b])

    compressed = zlib.compress(raw_data, 9)
    idat = make_chunk(b'IDAT', compressed)

    # IEND chunk
    iend = make_chunk(b'IEND', b'')

    return signature + ihdr + idat + iend

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    icons_dir = os.path.join(base_dir, 'graphics', 'icons')
    signals_dir = os.path.join(icons_dir, 'signals')

    os.makedirs(icons_dir, exist_ok=True)
    os.makedirs(signals_dir, exist_ok=True)

    # Define icons with colors (RGB)
    icons = {
        'data-packet.png': (0, 200, 255),      # Cyan - data
        'data-sensor.png': (100, 200, 100),    # Green - sensor
        'network-cable.png': (200, 150, 50),   # Orange - cable
        'basic-server.png': (100, 100, 200),   # Blue - server
        'circuit-bridge.png': (200, 100, 200), # Purple - bridge
    }

    signals = {
        'signal-throughput.png': (0, 255, 128),   # Bright green
        'signal-data-rate.png': (0, 200, 255),    # Cyan
        'signal-utilization.png': (255, 200, 0),  # Yellow
    }

    # Create main icons (32x32)
    for filename, color in icons.items():
        filepath = os.path.join(icons_dir, filename)
        png_data = create_png(32, 32, color)
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f"Created: {filepath}")

    # Create signal icons (32x32)
    for filename, color in signals.items():
        filepath = os.path.join(signals_dir, filename)
        png_data = create_png(32, 32, color)
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f"Created: {filepath}")

    print("\nAll placeholder icons created successfully!")

if __name__ == '__main__':
    main()
