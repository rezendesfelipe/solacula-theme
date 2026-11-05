"""Gera icon.png (128x128) só com a stdlib — o Marketplace exige PNG e o repositório guarda apenas texto."""
import pathlib, struct, zlib

S = 128
BG, BORDER = (0x14, 0x2A, 0x36), (0x1E, 0x3A, 0x48)
BARS = [(0x26, 0x8B, 0xD2), (0x2A, 0xA1, 0x98), (0x6C, 0xCF, 0x60), (0xBD, 0x93, 0xF9), (0xFF, 0x79, 0xC6)]

def pixel(x, y):
    r = 22  # cantos arredondados
    cx = min(max(x, r), S - 1 - r); cy = min(max(y, r), S - 1 - r)
    d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
    if d > r:
        return (0, 0, 0, 0)
    if d > r - 4:
        return (*BORDER, 255)
    # cinco barras em degrau: Solarized (azul, ciano) -> Dracula (verde, roxo, rosa)
    for i, c in enumerate(BARS):
        x0 = 24 + i * 17
        top = 92 - i * 12
        if x0 <= x < x0 + 12 and top <= y < 104:
            return (*c, 255)
    return (*BG, 255)

raw = b"".join(b"\x00" + b"".join(bytes(pixel(x, y)) for x in range(S)) for y in range(S))
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", S, S, 8, 6, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
out = pathlib.Path(__file__).parent / "icon.png"
out.write_bytes(png)
print(out)
