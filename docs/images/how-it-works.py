"""Renders docs/images/how-it-works.gif (+ .png, the last frame) — the README flow, for slides.

Usage (Windows, Pillow installed):  python docs/images/how-it-works.py docs/images/how-it-works.gif
Keep the steps in sync with the mermaid diagram in README.md.
"""
import sys
from PIL import Image, ImageDraw, ImageFont

W, H, S = 1280, 720, 2  # output size, supersampling factor
OUT = sys.argv[1]

BG = (13, 17, 28)
CARD = (27, 34, 52)
CARD_DIM = (21, 27, 42)
LINE = (71, 85, 115)
TEXT = (236, 240, 246)
MUTED = (148, 160, 184)
BLUE = (59, 130, 246)
AMBER = (245, 158, 11)
GREEN = (34, 197, 94)
ROSE = (244, 114, 182)

F = "C:/Windows/Fonts/"
def font(name, size): return ImageFont.truetype(F + name, size * S)
TITLE, H1, BODY, SMALL, NUM, CAP = (font("segoeuib.ttf", 30), font("segoeuib.ttf", 17), font("segoeui.ttf", 14),
                                     font("segoeui.ttf", 13), font("segoeuib.ttf", 13), font("segoeui.ttf", 22))

# ---- layout (in output pixels; scaled by S when drawing) ----
M, GAP, N = 32, 16, 8
NW = (W - 2 * M - (N - 1) * GAP) / N
NY, NH = 230, 132
def nx(i): return M + i * (NW + GAP)

NODES = [
    ("Onboarding", "ask “what next?”", "local or own\nworkspace"),
    ("Pick & scaffold", "New-Addon.ps1", "right add-on type,\ncompiles at once"),
    ("Specify", "/speckit.specify", "spec.md —\nyou review it"),
    ("Plan", "/speckit.plan", "plan.md +\nprocess-setup.md"),
    ("Tasks", "/speckit.tasks", "+ analyze for\nconsistency"),
    ("Implement", "/speckit.implement", "reads the SDK\nreference in docs/"),
    ("Build", "Build-Addon.ps1", "→ importable\n.zip package"),
    ("Register", "Designer Studio", "import · Verify\nplugins · run"),
]
CAPTIONS = [
    "Clone the repo and ask your agent “what next?” — a 6-question onboarding saves how you work.",
    "Describe the add-on in your own words. The agent picks the type and scaffolds a project that builds.",
    "Spec-Kit turns your sentence into spec.md. Read it — correcting a spec is cheaper than correcting code.",
    "The plan also writes process-setup.md: everything the process administrator has to prepare.",
    "While the agent breaks the plan into tasks, the administrator configures the process in parallel.",
    "The agent implements against the checked-in SDK reference — signatures are looked up, not recalled.",
    "One script builds and packages it — the same zip SDK Tools would publish. No Visual Studio needed.",
    "Import the zip in Designer Studio and run Verify plugins: code and process meet here.",
    "Something wrong? Fix the spec, not the code — then regenerate. That keeps the add-on reproducible.",
]
ADMIN_Y, ADMIN_H = 452, 78
ADMIN_X0, ADMIN_X1 = nx(3) + NW / 2, nx(7) + NW / 2


def s(v): return int(round(v * S))


def mix(c, a, bg=BG): return tuple(int(bg[k] + (c[k] - bg[k]) * a) for k in range(3))


def arrow(d, pts, color, width=2.5, head=True, dash=None):
    pts = [(s(x), s(y)) for x, y in pts]
    if dash:
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            length = max(abs(x1 - x0), abs(y1 - y0))
            step = s(dash)
            for t in range(0, int(length), step * 2):
                a, b = t / length, min(t + step, length) / length
                d.line([(x0 + (x1 - x0) * a, y0 + (y1 - y0) * a), (x0 + (x1 - x0) * b, y0 + (y1 - y0) * b)],
                       fill=color, width=s(width))
    else:
        d.line(pts, fill=color, width=s(width), joint="curve")
    if head:
        (x0, y0), (x1, y1) = pts[-2], pts[-1]
        h = s(9)
        if abs(x1 - x0) >= abs(y1 - y0):
            sgn = 1 if x1 > x0 else -1
            tri = [(x1, y1), (x1 - sgn * h, y1 - h * 0.6), (x1 - sgn * h, y1 + h * 0.6)]
        else:
            sgn = 1 if y1 > y0 else -1
            tri = [(x1, y1), (x1 - h * 0.6, y1 - sgn * h), (x1 + h * 0.6, y1 - sgn * h)]
        d.polygon(tri, fill=color)


def centered(d, cx, y, text, fnt, color, spacing=3):
    for k, line in enumerate(text.split("\n")):
        w = d.textlength(line, font=fnt)
        d.text((s(cx) - w / 2, s(y) + k * (fnt.size + s(spacing))), line, font=fnt, fill=color)


def node(d, i, alpha, current):
    x, y = nx(i), NY
    accent = AMBER if i == 7 else BLUE
    if current:
        d.rounded_rectangle([s(x - 4), s(y - 4), s(x + NW + 4), s(y + NH + 4)], radius=s(16),
                            fill=mix(accent, 0.22 * alpha))
    d.rounded_rectangle([s(x), s(y), s(x + NW), s(y + NH)], radius=s(13), fill=mix(CARD, alpha),
                        outline=mix(accent if current else LINE, alpha), width=s(2))
    title, cmd, desc = NODES[i]
    d.ellipse([s(x + 10), s(y + 10), s(x + 34), s(y + 34)], fill=mix(accent, alpha))
    centered(d, x + 22, y + 13, str(i + 1), NUM, mix(BG, alpha, BG) if False else mix((255, 255, 255), alpha))
    centered(d, x + NW / 2, y + 42, title, H1, mix(TEXT, alpha))
    centered(d, x + NW / 2, y + 68, cmd, SMALL, mix(accent if current else MUTED, alpha))
    centered(d, x + NW / 2, y + 92, desc, SMALL, mix(MUTED, alpha), spacing=2)


def frame(step, alpha, loop_alpha=0.0):
    """step: index of the node appearing (0..7); alpha: its fade-in; earlier nodes are fully shown."""
    img = Image.new("RGB", (W * S, H * S), BG)
    d = ImageDraw.Draw(img)

    d.text((s(M), s(38)), "WEBCON SDK Composer", font=TITLE, fill=TEXT)
    d.text((s(M), s(82)), "From a sentence to a registered WEBCON add-on — spec-first, with your AI agent",
           font=CAP, fill=MUTED)

    lanes = [("You + your agent", NY - 30, BLUE), ("Process administrator", ADMIN_Y - 30, AMBER)]
    for label, y, color in lanes:
        if label.startswith("Process") and step < 3:
            continue
        a = 1.0 if not (label.startswith("Process") and step == 3) else alpha
        d.text((s(M), s(y)), label.upper(), font=NUM, fill=mix(color, a))

    for i in range(step + 1):
        a = alpha if i == step else 1.0
        if i > 0:
            arrow(d, [(nx(i - 1) + NW + 2, NY + NH / 2), (nx(i) - 3, NY + NH / 2)], mix(LINE, a), width=2)
        node(d, i, a, current=(i == step and loop_alpha == 0))

    # Administrator lane: appears with the plan, joins at register.
    if step >= 3:
        a = alpha if step == 3 else 1.0
        x0, x1 = nx(3) + NW / 2, nx(7) - 10
        arrow(d, [(x0, NY + NH + 4), (x0, ADMIN_Y - 2)], mix(AMBER, a), dash=6)
        d.rounded_rectangle([s(x0 - 40), s(ADMIN_Y), s(x1), s(ADMIN_Y + ADMIN_H)], radius=s(13),
                            fill=mix((44, 34, 16), a), outline=mix(AMBER, a), width=s(2))
        centered(d, (x0 - 40 + x1) / 2, ADMIN_Y + 14, "Prepares the process — in parallel, from process-setup.md",
                 H1, mix(TEXT, a))
        centered(d, (x0 - 40 + x1) / 2, ADMIN_Y + 44,
                 "form fields + types · constants · where the plugin attaches · its configuration", BODY,
                 mix((253, 211, 141), a))
    if step >= 7:
        a = alpha if step == 7 else 1.0
        jx = nx(7) + NW / 2
        arrow(d, [(nx(7) - 10, ADMIN_Y + ADMIN_H / 2), (jx, ADMIN_Y + ADMIN_H / 2), (jx, NY + NH + 4)],
              mix(AMBER, a), dash=6)

    # Feedback loop: implement -> specify, above the row.
    if loop_alpha > 0:
        a = loop_alpha
        x_from, x_to, top = nx(5) + NW / 2, nx(2) + NW / 2, NY - 46
        arrow(d, [(x_from, NY - 4), (x_from, top), (x_to, top), (x_to, NY - 6)], mix(ROSE, a), dash=6)
        label = "wrong result?  fix the spec, not the code"
        w = d.textlength(label, font=SMALL)
        cx = (x_from + x_to) / 2
        d.rectangle([s(cx) - w / 2 - s(8), s(top - 11), s(cx) + w / 2 + s(8), s(top + 11)], fill=BG)
        centered(d, cx, top - 9, label, SMALL, mix(ROSE, a))

    cap = CAPTIONS[8] if loop_alpha > 0 else CAPTIONS[step]
    capa = loop_alpha if loop_alpha > 0 else alpha
    d.rounded_rectangle([s(M), s(588), s(W - M), s(668)], radius=s(14), fill=CARD_DIM)
    color = ROSE if loop_alpha > 0 else (AMBER if step in (3, 4, 7) else BLUE)
    d.rounded_rectangle([s(M), s(588), s(M + 6), s(668)], radius=s(3), fill=mix(color, capa, CARD_DIM))
    d.text((s(M + 26), s(613)), cap, font=CAP, fill=mix(TEXT, capa, CARD_DIM))

    d.text((s(M), s(686)), "github.com/WEBCON-BPS/webcon-sdk-composer", font=SMALL, fill=mix(MUTED, 0.7))
    return img.resize((W, H), Image.LANCZOS)


frames, durations = [], []
FADE = [0.25, 0.5, 0.75, 1.0]
for step in range(8):
    for a in FADE:
        frames.append(frame(step, a)); durations.append(55)
    durations[-1] = 2300
for a in FADE:
    frames.append(frame(7, 1.0, loop_alpha=a)); durations.append(70)
durations[-1] = 4500

frames[-1].save(OUT.replace(".gif", ".png"))
pal = [f.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE) for f in frames]
pal[0].save(OUT, save_all=True, append_images=pal[1:], duration=durations, loop=0, optimize=True)
print(OUT, len(frames), "frames")
