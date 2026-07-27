"""
Generate PDF Tutorial — E-Learning SMAN 2 Sidoarjo
Run: /usr/bin/python3 generate_tutorial_pdf.py
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm, mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import (
    HexColor, white, black
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph,
    Spacer, Table, TableStyle, PageBreak, HRFlowable,
    KeepTogether
)
from reportlab.platypus.flowables import Flowable
from reportlab.graphics.shapes import (
    Drawing, Rect, String, Line, Polygon, Circle,
    Group
)
from reportlab.graphics import renderPDF
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import os
import datetime

# ── Warna ────────────────────────────────────────────────────────────────────
C_PRIMARY      = HexColor("#0f766e")   # teal
C_PRIMARY_DARK = HexColor("#042f2e")
C_ACCENT       = HexColor("#2dd4bf")
C_ADMIN        = HexColor("#7c3aed")
C_ADMIN_BG     = HexColor("#ede9fe")
C_STAFF        = HexColor("#0369a1")
C_STAFF_BG     = HexColor("#e0f2fe")
C_GURU         = HexColor("#15803d")
C_GURU_BG      = HexColor("#dcfce7")
C_SISWA        = HexColor("#b45309")
C_SISWA_BG     = HexColor("#fef3c7")
C_MUTED        = HexColor("#64748b")
C_BORDER       = HexColor("#e2e8f0")
C_BG           = HexColor("#f8fafc")
C_WARNING_BG   = HexColor("#fffbeb")
C_WARNING_BOR  = HexColor("#fbbf24")
C_TIP_BG       = HexColor("#f0fdf4")
C_TIP_BOR      = HexColor("#86efac")
C_INFO_BG      = HexColor("#eff6ff")
C_INFO_BOR     = HexColor("#93c5fd")
C_DARK         = HexColor("#0f172a")
C_GRAY1        = HexColor("#f1f5f9")

BULAN_ID = {
    1: "Januari", 2: "Februari", 3: "Maret", 4: "April", 5: "Mei", 6: "Juni",
    7: "Juli", 8: "Agustus", 9: "September", 10: "Oktober", 11: "November", 12: "Desember",
}

PAGE_W, PAGE_H = A4

# ── Styles ────────────────────────────────────────────────────────────────────
def build_styles():
    base = getSampleStyleSheet()

    def P(name, **kw):
        return ParagraphStyle(name, **kw)

    return {
        "h1": P("h1", fontSize=22, leading=28, fontName="Helvetica-Bold",
                 textColor=C_DARK, spaceBefore=16, spaceAfter=6),
        "h2": P("h2", fontSize=15, leading=20, fontName="Helvetica-Bold",
                 textColor=C_PRIMARY, spaceBefore=14, spaceAfter=4),
        "h3": P("h3", fontSize=12, leading=17, fontName="Helvetica-Bold",
                 textColor=C_DARK, spaceBefore=10, spaceAfter=3),
        "body": P("body", fontSize=10, leading=15, fontName="Helvetica",
                  textColor=C_DARK, spaceAfter=6, alignment=TA_JUSTIFY),
        "body_l": P("body_l", fontSize=10, leading=15, fontName="Helvetica",
                    textColor=C_DARK, spaceAfter=4, alignment=TA_LEFT),
        "caption": P("caption", fontSize=8.5, leading=12, fontName="Helvetica",
                     textColor=C_MUTED, spaceAfter=4),
        "bullet": P("bullet", fontSize=10, leading=14, fontName="Helvetica",
                    textColor=C_DARK, leftIndent=14, spaceBefore=1, spaceAfter=2,
                    bulletText="•"),
        "code": P("code", fontSize=8.5, leading=13, fontName="Courier",
                  textColor=C_DARK, backColor=C_GRAY1, leftIndent=8, rightIndent=8,
                  spaceAfter=4),
        "step_title": P("step_title", fontSize=10.5, leading=14, fontName="Helvetica-Bold",
                        textColor=C_DARK, spaceAfter=2),
        "step_body": P("step_body", fontSize=10, leading=14, fontName="Helvetica",
                       textColor=C_DARK, leftIndent=6),
        "toc_item": P("toc_item", fontSize=11, leading=18, fontName="Helvetica",
                      textColor=C_PRIMARY),
        "toc_title": P("toc_title", fontSize=14, leading=20, fontName="Helvetica-Bold",
                       textColor=C_DARK, spaceAfter=10),
        "table_header": P("th", fontSize=9, leading=12, fontName="Helvetica-Bold",
                          textColor=C_DARK),
        "table_cell": P("td", fontSize=9, leading=13, fontName="Helvetica",
                        textColor=C_DARK),
        "faq_q": P("faq_q", fontSize=10.5, leading=15, fontName="Helvetica-Bold",
                   textColor=C_DARK, spaceAfter=4, spaceBefore=2),
        "faq_a": P("faq_a", fontSize=10, leading=14, fontName="Helvetica",
                   textColor=HexColor("#374151"), spaceAfter=6),
        "footer": P("footer", fontSize=8, leading=10, fontName="Helvetica",
                    textColor=C_MUTED, alignment=TA_CENTER),
        "section_desc": P("section_desc", fontSize=10, leading=14, fontName="Helvetica",
                          textColor=C_MUTED, spaceAfter=10, alignment=TA_LEFT),
        "diag_label": P("diag_label", fontSize=8, leading=11, fontName="Helvetica",
                        textColor=C_MUTED, alignment=TA_CENTER, spaceAfter=0),
    }


# ── Custom Flowables ──────────────────────────────────────────────────────────

class SectionHeader(Flowable):
    """Judul bab dengan garis bawah berwarna."""
    def __init__(self, text, color=C_PRIMARY):
        super().__init__()
        self.text = text
        self.color = color
        self.width = PAGE_W - 4*cm
        self.height = 36

    def draw(self):
        c = self.canv
        c.setFont("Helvetica-Bold", 18)
        c.setFillColor(C_DARK)
        c.drawString(0, 18, self.text)
        c.setStrokeColor(self.color)
        c.setLineWidth(3)
        c.line(0, 10, self.width, 10)

    def wrap(self, *args):
        return self.width, self.height + 8


class StepItem(Flowable):
    """Satu langkah bernomor dengan lingkaran warna."""
    def __init__(self, number, title, body_lines, color=C_PRIMARY, width=None):
        super().__init__()
        self.number = str(number)
        self.title = title
        self.body_lines = body_lines  # list of strings
        self.color = color
        self._width = width or (PAGE_W - 4*cm)
        line_h = 14
        self.height = 36 + len(body_lines) * line_h

    def draw(self):
        c = self.canv
        # Lingkaran nomor
        c.setFillColor(self.color)
        c.circle(13, self.height - 22, 12, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont("Helvetica-Bold", 10)
        w = c.stringWidth(self.number, "Helvetica-Bold", 10)
        c.drawString(13 - w/2, self.height - 26, self.number)
        # Judul
        c.setFillColor(C_DARK)
        c.setFont("Helvetica-Bold", 11)
        c.drawString(32, self.height - 26, self.title)
        # Body
        c.setFont("Helvetica", 10)
        c.setFillColor(HexColor("#374151"))
        y = self.height - 40
        for line in self.body_lines:
            c.drawString(32, y, line)
            y -= 14

    def wrap(self, *args):
        return self._width, self.height + 4


class AlertBox(Flowable):
    """Kotak tip / warning / info."""
    TYPES = {
        "tip":     (C_TIP_BG,     C_TIP_BOR,     "✓  "),
        "warning": (C_WARNING_BG,  C_WARNING_BOR,  "⚠  "),
        "info":    (C_INFO_BG,     C_INFO_BOR,     "i  "),
    }

    def __init__(self, text, kind="tip", width=None):
        super().__init__()
        self.text = text
        self.kind = kind
        self._width = width or (PAGE_W - 4*cm)
        # Estimasi tinggi
        chars_per_line = int(self._width / 5.5)
        lines = max(1, len(text) // chars_per_line + text.count("\n") + 1)
        self.height = 14 * lines + 22

    def draw(self):
        c = self.canv
        bg, border, icon = self.TYPES.get(self.kind, self.TYPES["info"])
        h = self.height
        c.setFillColor(bg)
        c.setStrokeColor(border)
        c.setLineWidth(1.2)
        c.roundRect(0, 0, self._width, h, 6, fill=1, stroke=1)
        # Left accent bar
        c.setFillColor(border)
        c.roundRect(0, 0, 4, h, 3, fill=1, stroke=0)
        # Text
        c.setFillColor(C_DARK)
        c.setFont("Helvetica", 9.5)
        margin = 14
        text = icon + self.text
        # Simple word-wrap
        words = text.split()
        lines_out = []
        cur = ""
        char_w = 5.5
        max_chars = int((self._width - margin * 2) / char_w)
        for w in words:
            if len(cur) + len(w) + 1 <= max_chars:
                cur = (cur + " " + w).strip()
            else:
                if cur:
                    lines_out.append(cur)
                cur = w
        if cur:
            lines_out.append(cur)
        y = h - 14
        for line in lines_out:
            c.drawString(margin, y, line)
            y -= 13

    def wrap(self, *args):
        return self._width, self.height + 8


class RoleCard(Flowable):
    """Kartu peran berwarna."""
    def __init__(self, title, items, bg_color, border_color, width=None):
        super().__init__()
        self.title = title
        self.items = items
        self.bg = bg_color
        self.border = border_color
        self._width = width or ((PAGE_W - 4*cm - 0.4*cm) / 2)
        self.height = 28 + len(items) * 15 + 10

    def draw(self):
        c = self.canv
        h = self.height
        c.setFillColor(self.bg)
        c.setStrokeColor(self.border)
        c.setLineWidth(1.5)
        c.roundRect(0, 0, self._width, h, 8, fill=1, stroke=1)
        # Title
        c.setFont("Helvetica-Bold", 10.5)
        c.setFillColor(self.border)
        c.drawString(12, h - 18, self.title)
        # Items
        c.setFont("Helvetica", 9)
        c.setFillColor(C_DARK)
        y = h - 32
        for item in self.items:
            c.drawString(18, y, "• " + item)
            y -= 15

    def wrap(self, *args):
        return self._width, self.height + 6


class FlowDiagram(Flowable):
    """Diagram alur sederhana digambar dengan ReportLab."""
    def __init__(self, nodes, width=None):
        """
        nodes: list of dicts with keys:
          - label: str
          - x, y: posisi (0–1 relative)
          - shape: 'rect' | 'diamond' | 'pill'
          - color: HexColor
          - text_color: HexColor (optional)
        arrows: list of (from_idx, to_idx, label)
        """
        super().__init__()
        self.nodes = nodes
        self._width = width or (PAGE_W - 4*cm)
        # Cari bounding box dari y tertinggi
        max_y = max(n["y"] for n in nodes)
        self.height = max_y + 60

    def _draw_shape(self, c, shape, x, y, w, h, fill, stroke):
        c.setFillColor(fill)
        c.setStrokeColor(stroke)
        c.setLineWidth(1)
        if shape == "diamond":
            hw, hh = w/2, h/2
            p = c.beginPath()
            p.moveTo(x, y + hh)
            p.lineTo(x + hw, y + h)
            p.lineTo(x + w, y + hh)
            p.lineTo(x + hw, y)
            p.close()
            c.drawPath(p, fill=1, stroke=1)
        elif shape == "pill":
            c.roundRect(x, y, w, h, h/2, fill=1, stroke=1)
        else:
            c.roundRect(x, y, w, h, 4, fill=1, stroke=1)

    def draw(self):
        c = self.canv
        box_w, box_h = 130, 30

        # Draw nodes
        for node in self.nodes:
            fill = node.get("color", C_STAFF_BG)
            stroke = node.get("stroke", C_STAFF)
            text_col = node.get("text_color", C_DARK)
            shape = node.get("shape", "rect")
            x = node["x"] - box_w / 2
            y = self.height - node["y"] - box_h
            self._draw_shape(c, shape, x, y, box_w, box_h, fill, stroke)
            c.setFont("Helvetica", 8.5)
            c.setFillColor(text_col)
            label = node.get("label", "")
            tw = c.stringWidth(label, "Helvetica", 8.5)
            c.drawString(x + (box_w - tw) / 2, y + 9, label)

    def wrap(self, *args):
        return self._width, self.height + 8


class SimpleFlowChart(Flowable):
    """Flowchart dengan boxes dan panah teks."""
    def __init__(self, steps, color=C_PRIMARY, width=None):
        """steps: list of strings"""
        super().__init__()
        self.steps = steps
        self.color = color
        self._width = width or (PAGE_W - 4*cm)
        self.height = len(steps) * 42 + 8

    def draw(self):
        c = self.canv
        box_w = self._width - 40
        box_h = 26
        x_start = 20
        y = self.height - 34

        for i, step in enumerate(self.steps):
            # Box
            c.setFillColor(HexColor("#f0fdf4") if self.color == C_GURU else
                           HexColor("#e0f2fe") if self.color == C_STAFF else
                           HexColor("#ede9fe") if self.color == C_ADMIN else
                           HexColor("#fef3c7"))
            c.setStrokeColor(self.color)
            c.setLineWidth(1.2)
            c.roundRect(x_start, y, box_w, box_h, 5, fill=1, stroke=1)
            # Number circle
            c.setFillColor(self.color)
            c.circle(x_start + 14, y + 13, 10, fill=1, stroke=0)
            c.setFillColor(white)
            c.setFont("Helvetica-Bold", 8)
            num = str(i + 1)
            nw = c.stringWidth(num, "Helvetica-Bold", 8)
            c.drawString(x_start + 14 - nw/2, y + 9, num)
            # Text
            c.setFillColor(C_DARK)
            c.setFont("Helvetica", 9)
            c.drawString(x_start + 30, y + 9, step)
            # Arrow ke bawah
            if i < len(self.steps) - 1:
                ax = x_start + box_w / 2
                c.setStrokeColor(C_MUTED)
                c.setLineWidth(1.2)
                c.line(ax, y, ax, y - 12)
                # Arrow head
                c.setFillColor(C_MUTED)
                p = c.beginPath()
                p.moveTo(ax, y - 16)
                p.lineTo(ax - 4, y - 10)
                p.lineTo(ax + 4, y - 10)
                p.close()
                c.drawPath(p, fill=1, stroke=0)
            y -= 42

    def wrap(self, *args):
        return self._width, self.height + 4


class HierarchyDiagram(Flowable):
    """Diagram hierarki sederhana untuk relasi data."""
    def __init__(self, root, children, grandchildren=None, width=None):
        super().__init__()
        self.root = root
        self.children = children
        self.grandchildren = grandchildren or {}
        self._width = width or (PAGE_W - 4*cm)
        max_gc = max((len(v) for v in self.grandchildren.values()), default=0)
        self.height = 180 + max_gc * 18

    def _box(self, c, text, x, y, w=90, h=22, fill=C_STAFF_BG, stroke=C_STAFF):
        c.setFillColor(fill)
        c.setStrokeColor(stroke)
        c.setLineWidth(1)
        c.roundRect(x - w/2, y - h/2, w, h, 4, fill=1, stroke=1)
        c.setFillColor(C_DARK)
        c.setFont("Helvetica", 8)
        tw = c.stringWidth(text, "Helvetica", 8)
        c.drawString(x - tw/2, y - 4, text)

    def draw(self):
        c = self.canv
        cx = self._width / 2
        h = self.height
        # Root
        self._box(c, self.root, cx, h - 20, w=120, fill=C_PRIMARY, stroke=C_PRIMARY_DARK)
        c.setFillColor(white)
        c.setFont("Helvetica-Bold", 8.5)
        tw = c.stringWidth(self.root, "Helvetica-Bold", 8.5)
        c.drawString(cx - tw/2, h - 24, self.root)

        # Children
        n = len(self.children)
        if n == 0:
            return
        step = self._width / (n + 1)
        child_y = h - 80
        xs = [(i + 1) * step for i in range(n)]

        for i, (child, x) in enumerate(zip(self.children, xs)):
            # Line from root
            c.setStrokeColor(C_MUTED)
            c.setLineWidth(0.8)
            c.line(cx, h - 32, x, child_y + 11)
            self._box(c, child, x, child_y, w=85,
                      fill=C_STAFF_BG, stroke=C_STAFF)

            # Grandchildren
            gcs = self.grandchildren.get(child, [])
            gc_y = child_y - 44
            for j, gc in enumerate(gcs):
                c.setStrokeColor(C_MUTED)
                c.setLineWidth(0.6)
                c.line(x, child_y - 11, x, gc_y + 11)
                self._box(c, gc, x, gc_y, w=90, h=18,
                          fill=C_GURU_BG, stroke=C_GURU)
                gc_y -= 26

    def wrap(self, *args):
        return self._width, self.height + 8


class SequenceDiagram(Flowable):
    """Sequence diagram sederhana."""
    def __init__(self, actors, messages, width=None):
        """
        actors: list of str
        messages: list of (from_idx, to_idx, label, is_return=False)
        """
        super().__init__()
        self.actors = actors
        self.messages = messages
        self._width = width or (PAGE_W - 4*cm)
        self.height = 60 + len(messages) * 30

    def draw(self):
        c = self.canv
        n = len(self.actors)
        margin = 40
        avail = self._width - 2 * margin
        step = avail / (n - 1) if n > 1 else avail
        h = self.height
        actor_y = h - 28
        xs = [margin + i * step for i in range(n)]

        # Actor boxes
        for i, (actor, x) in enumerate(zip(self.actors, xs)):
            bw = min(step * 0.8, 90)
            c.setFillColor(C_PRIMARY)
            c.setStrokeColor(C_PRIMARY_DARK)
            c.setLineWidth(1)
            c.roundRect(x - bw/2, actor_y - 10, bw, 22, 4, fill=1, stroke=1)
            c.setFillColor(white)
            c.setFont("Helvetica-Bold", 8)
            tw = c.stringWidth(actor, "Helvetica-Bold", 8)
            c.drawString(x - tw/2, actor_y - 2, actor)

        # Lifelines
        line_top = actor_y - 14
        line_bot = 20
        for x in xs:
            c.setStrokeColor(C_BORDER)
            c.setLineWidth(0.8)
            c.setDash(4, 3)
            c.line(x, line_top, x, line_bot)
        c.setDash()  # reset

        # Messages
        msg_y = actor_y - 30
        for msg in self.messages:
            from_i, to_i, label = msg[0], msg[1], msg[2]
            is_ret = len(msg) > 3 and msg[3]
            x1, x2 = xs[from_i], xs[to_i]
            # Arrow line
            c.setStrokeColor(C_STAFF if not is_ret else C_MUTED)
            c.setLineWidth(1 if not is_ret else 0.8)
            if is_ret:
                c.setDash(3, 2)
            c.line(x1, msg_y, x2, msg_y)
            c.setDash()
            # Arrowhead
            c.setFillColor(C_STAFF if not is_ret else C_MUTED)
            direction = 1 if x2 > x1 else -1
            p = c.beginPath()
            p.moveTo(x2, msg_y)
            p.lineTo(x2 - direction * 7, msg_y + 4)
            p.lineTo(x2 - direction * 7, msg_y - 4)
            p.close()
            c.drawPath(p, fill=1, stroke=0)
            # Label
            mid_x = (x1 + x2) / 2
            c.setFillColor(C_DARK)
            c.setFont("Helvetica", 7.5)
            tw = c.stringWidth(label, "Helvetica", 7.5)
            c.drawString(mid_x - tw/2, msg_y + 3, label)
            msg_y -= 30

    def wrap(self, *args):
        return self._width, self.height + 8


# ── Page Templates ────────────────────────────────────────────────────────────

def cover_page(c, doc):
    """Halaman cover formal."""
    w, h = PAGE_W, PAGE_H
    # Background gelap
    c.setFillColor(C_PRIMARY_DARK)
    c.rect(0, 0, w, h, fill=1, stroke=0)
    # Gradien simulasi: overlay kotak di kanan
    c.setFillColor(HexColor("#0f2744"))
    c.rect(w * 0.5, 0, w * 0.5, h, fill=1, stroke=0)
    # Garis aksen horizontal
    c.setStrokeColor(C_ACCENT)
    c.setLineWidth(3)
    c.line(2*cm, h - 3.2*cm, w - 2*cm, h - 3.2*cm)
    # Garis bawah
    c.setStrokeColor(C_ACCENT)
    c.setLineWidth(1.5)
    c.line(2*cm, 3.5*cm, w - 2*cm, 3.5*cm)

    # Logo / ikon sekolah (kotak teal)
    c.setFillColor(C_ACCENT)
    c.roundRect(2*cm, h - 2.8*cm, 1.1*cm, 1.1*cm, 4*mm, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont("Helvetica-Bold", 18)
    c.drawString(2*cm + 3*mm, h - 2.8*cm + 3*mm, "E")

    # Nama sekolah (header)
    c.setFillColor(white)
    c.setFont("Helvetica-Bold", 13)
    c.drawString(3.4*cm, h - 2.3*cm, "E-Learning SMAN 2 Sidoarjo")
    c.setFont("Helvetica", 10)
    c.setFillColor(HexColor("#94a3b8"))
    c.drawString(3.4*cm, h - 2.8*cm, "Portal Akademik Resmi")

    # Judul utama
    c.setFillColor(white)
    c.setFont("Helvetica-Bold", 32)
    c.drawString(2*cm, h/2 + 2.5*cm, "Panduan Penggunaan")
    c.drawString(2*cm, h/2 + 2.5*cm - 1.1*cm, "Sistem E-Learning")

    # Garis pendek di bawah judul
    c.setStrokeColor(C_ACCENT)
    c.setLineWidth(4)
    c.line(2*cm, h/2 + 1.1*cm, 8*cm, h/2 + 1.1*cm)

    # Subtitle
    c.setFillColor(HexColor("#cbd5e1"))
    c.setFont("Helvetica", 11)
    c.drawString(2*cm, h/2 + 0.6*cm,
                 "Dokumen resmi untuk Admin, Staff Kurikulum,")
    c.drawString(2*cm, h/2 + 0.6*cm - 0.5*cm, "Guru, dan Siswa")

    # Badge roles
    roles = [("Admin", C_ADMIN), ("Staff", C_STAFF),
             ("Guru", C_GURU), ("Siswa", C_SISWA)]
    bx = 2*cm
    by = h/2 - 0.8*cm
    for label, color in roles:
        bw = c.stringWidth(label, "Helvetica-Bold", 8) + 14
        c.setFillColor(color)
        c.roundRect(bx, by, bw, 16, 4, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont("Helvetica-Bold", 8)
        c.drawString(bx + 7, by + 4, label)
        bx += bw + 8

    # Metadata bawah
    year = datetime.date.today().year
    c.setFillColor(HexColor("#64748b"))
    c.setFont("Helvetica", 9)
    c.drawString(2*cm, 2.8*cm, f"Versi 1.0  ·  {year}  ·  SMAN 2 Sidoarjo")
    c.drawString(2*cm, 2.2*cm, "Dokumen ini bersifat resmi untuk keperluan internal sekolah.")

    # Nomor halaman (tidak perlu di cover)
    c.showPage()


def normal_page(c, doc):
    """Header & footer halaman biasa."""
    w, h = PAGE_W, PAGE_H
    # Header tipis
    c.setFillColor(C_PRIMARY)
    c.rect(0, h - 1.1*cm, w, 1.1*cm, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont("Helvetica-Bold", 9)
    c.drawString(1.5*cm, h - 0.75*cm, "E-Learning SMAN 2 Sidoarjo")
    c.setFont("Helvetica", 8)
    c.setFillColor(HexColor("#a5f3fc"))
    c.drawRightString(w - 1.5*cm, h - 0.75*cm, "Panduan Penggunaan Sistem")
    # Footer
    c.setStrokeColor(C_BORDER)
    c.setLineWidth(0.5)
    c.line(1.5*cm, 1.4*cm, w - 1.5*cm, 1.4*cm)
    c.setFillColor(C_MUTED)
    c.setFont("Helvetica", 8)
    c.drawString(1.5*cm, 0.9*cm, "SMAN 2 Sidoarjo — Dokumen Resmi Internal")
    c.drawRightString(w - 1.5*cm, 0.9*cm, f"Halaman {doc.page - 1}")


# ── PDF Builder ───────────────────────────────────────────────────────────────

def build_pdf(output_path):
    S = build_styles()
    content_frame = Frame(
        1.5*cm, 1.8*cm,
        PAGE_W - 3*cm, PAGE_H - 3.5*cm,
        leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0
    )
    doc = BaseDocTemplate(
        output_path,
        pagesize=A4,
        author="SMAN 2 Sidoarjo",
        title="Panduan Penggunaan Sistem E-Learning SMAN 2 Sidoarjo",
        subject="Tutorial E-Learning",
        creator="E-Learning SMAN 2 Sidoarjo",
    )
    cover_template = PageTemplate(id="cover", frames=[content_frame],
                                   onPage=cover_page)
    main_template  = PageTemplate(id="main",  frames=[content_frame],
                                   onPage=normal_page)
    doc.addPageTemplates([cover_template, main_template])

    story = []

    # ── COVER (kosong — digambar oleh onPage) ─────────────────────────────────
    story.append(NextPageTemplate("main"))
    story.append(PageBreak())

    # ── DAFTAR ISI ────────────────────────────────────────────────────────────
    story.append(Paragraph("Daftar Isi", S["toc_title"]))
    toc_items = [
        ("1.", "Gambaran Umum Sistem", "3"),
        ("2.", "Masuk ke Sistem (Login)", "4"),
        ("3.", "Panduan Admin", "5"),
        ("4.", "Panduan Staff Kurikulum", "7"),
        ("5.", "Panduan Guru", "10"),
        ("6.", "Panduan Siswa", "13"),
        ("7.", "Diagram Alur Lengkap", "15"),
        ("8.", "Pertanyaan Umum (FAQ)", "17"),
    ]
    toc_data = [
        [Paragraph(f"<b>{num}</b>", S["toc_item"]),
         Paragraph(title, S["toc_item"]),
         Paragraph(f"<b>{pg}</b>", S["toc_item"])]
        for num, title, pg in toc_items
    ]
    toc_table = Table(toc_data, colWidths=[1*cm, None, 1.5*cm])
    toc_table.setStyle(TableStyle([
        ("ROWBACKGROUNDS", (0, 0), (-1, -1), [white, C_GRAY1]),
        ("TOPPADDING",    (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
        ("LEFTPADDING",   (0, 0), (-1, -1), 8),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 8),
        ("LINEBELOW", (0, 0), (-1, -1), 0.3, C_BORDER),
        ("VALIGN",    (0, 0), (-1, -1), "MIDDLE"),
    ]))
    story.append(toc_table)
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 1. GAMBARAN UMUM
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("1.  Gambaran Umum Sistem"))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Sistem E-Learning SMAN 2 Sidoarjo adalah platform berbasis web yang "
        "mengintegrasikan seluruh proses akademik — dari pengelolaan data kurikulum "
        "hingga pengumpulan tugas dan penilaian ujian — dalam satu dasbor berbasis "
        "peran (<i>role-based</i>). Setiap pengguna hanya melihat fitur yang relevan "
        "dengan perannya.", S["body"]))
    story.append(Spacer(1, 10))

    story.append(Paragraph("Empat Peran Pengguna", S["h2"]))
    # Role cards — 2 kolom
    card_w = (PAGE_W - 3*cm - 0.5*cm) / 2
    rc1 = RoleCard("🛡️  Admin", [
        "Kelola akun staff kurikulum",
        "Pantau log aktivitas sistem",
        "Kelola data siswa",
        "Reset password & identifier user",
    ], C_ADMIN_BG, C_ADMIN, width=card_w)
    rc2 = RoleCard("📋  Staff Kurikulum", [
        "Kelola guru, siswa, kelas, mapel",
        "Atur jadwal akademik & pelajaran",
        "Buat rubrik & range nilai",
        "Rekap seluruh nilai akademik",
    ], C_STAFF_BG, C_STAFF, width=card_w)
    rc3 = RoleCard("👨‍🏫  Guru", [
        "Lihat kelas yang diampu",
        "Upload materi & buat tugas",
        "Buat & nilai ujian (PG / Esai)",
        "Kelola kelompok belajar",
    ], C_GURU_BG, C_GURU, width=card_w)
    rc4 = RoleCard("🎓  Siswa", [
        "Lihat kelas & jadwal pelajaran",
        "Baca materi & unduh file",
        "Kumpulkan tugas online",
        "Kerjakan ujian & pantau nilai",
    ], C_SISWA_BG, C_SISWA, width=card_w)

    role_table = Table(
        [[rc1, rc2], [rc3, rc4]],
        colWidths=[card_w, card_w],
        rowHeights=None,
    )
    role_table.setStyle(TableStyle([
        ("LEFTPADDING",  (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING",   (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(role_table)
    story.append(Spacer(1, 8))

    story.append(Paragraph("Hierarki Data Akademik", S["h2"]))
    story.append(HierarchyDiagram(
        root="Tahun Ajaran (2025/2026)",
        children=["Semester", "Kelas", "Mata Pelajaran"],
        grandchildren={
            "Semester": ["Ganjil", "Genap"],
            "Kelas": ["X-IPA-1", "XI-IPS-2", "XII-IPA-3"],
            "Mata Pelajaran": ["Matematika", "Fisika", "B.Indonesia"],
        }
    ))
    story.append(Spacer(1, 6))

    story.append(Paragraph("Komponen Utama Sistem", S["h2"]))
    comp_data = [
        [Paragraph("<b>Komponen</b>", S["table_header"]),
         Paragraph("<b>Fungsi</b>", S["table_header"]),
         Paragraph("<b>Dikelola Oleh</b>", S["table_header"])],
        [Paragraph("Tahun Ajaran", S["table_cell"]),
         Paragraph("Periode akademik (mis. 2025/2026)", S["table_cell"]),
         Paragraph("Staff", S["table_cell"])],
        [Paragraph("Kelas", S["table_cell"]),
         Paragraph("Grup siswa per jenjang dan jurusan", S["table_cell"]),
         Paragraph("Staff", S["table_cell"])],
        [Paragraph("Mata Pelajaran", S["table_cell"]),
         Paragraph("Definisi mapel per jenjang/jurusan", S["table_cell"]),
         Paragraph("Staff", S["table_cell"])],
        [Paragraph("Kelas-Mapel", S["table_cell"]),
         Paragraph("Relasi kelas + mapel + guru pengampu", S["table_cell"]),
         Paragraph("Staff", S["table_cell"])],
        [Paragraph("Jadwal Pelajaran", S["table_cell"]),
         Paragraph("Hari, waktu, ruang per kelas-mapel", S["table_cell"]),
         Paragraph("Staff", S["table_cell"])],
        [Paragraph("Rubrik", S["table_cell"]),
         Paragraph("Lingkup materi & tujuan pembelajaran (TP)", S["table_cell"]),
         Paragraph("Staff / Guru", S["table_cell"])],
        [Paragraph("Materi", S["table_cell"]),
         Paragraph("Konten belajar + file lampiran", S["table_cell"]),
         Paragraph("Guru", S["table_cell"])],
        [Paragraph("Tugas", S["table_cell"]),
         Paragraph("Pengumpulan & penilaian per siswa", S["table_cell"]),
         Paragraph("Guru", S["table_cell"])],
        [Paragraph("Ujian", S["table_cell"]),
         Paragraph("Soal pilihan ganda / esai online", S["table_cell"]),
         Paragraph("Guru", S["table_cell"])],
    ]
    comp_table = Table(comp_data, colWidths=[3.8*cm, None, 3*cm])
    comp_table.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_PRIMARY),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_GRAY1]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 6),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(comp_table)
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 2. LOGIN
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("2.  Masuk ke Sistem (Login)"))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Semua pengguna menggunakan halaman login yang sama. Sistem akan "
        "mengarahkan pengguna ke dashboard sesuai peran secara otomatis setelah "
        "login berhasil.", S["body"]))
    story.append(Spacer(1, 8))

    story.append(SimpleFlowChart([
        "Buka URL aplikasi e-learning di browser",
        "Klik tombol 'Masuk' di halaman beranda",
        "Isi Identifier (NIP/NUPTK/NISN) dan Password",
        "Klik tombol 'Masuk' untuk proses verifikasi",
        "Sistem mengarahkan ke Dashboard sesuai peran",
    ], color=C_PRIMARY))
    story.append(Spacer(1, 10))

    story.append(Paragraph("Identifier Login per Peran", S["h2"]))
    login_data = [
        [Paragraph("<b>Peran</b>", S["table_header"]),
         Paragraph("<b>Identifier Login</b>", S["table_header"]),
         Paragraph("<b>Password Default</b>", S["table_header"])],
        [Paragraph("Admin", S["table_cell"]),
         Paragraph("Ditetapkan oleh sistem / IT", S["table_cell"]),
         Paragraph("Diberikan oleh admin IT", S["table_cell"])],
        [Paragraph("Staff Kurikulum", S["table_cell"]),
         Paragraph("NIP/NUPTK atau identifier khusus", S["table_cell"]),
         Paragraph("Diberikan oleh Admin", S["table_cell"])],
        [Paragraph("Guru", S["table_cell"]),
         Paragraph("NIP/NUPTK", S["table_cell"]),
         Paragraph("password (ubah segera)", S["table_cell"])],
        [Paragraph("Siswa", S["table_cell"]),
         Paragraph("NISN", S["table_cell"]),
         Paragraph("password (ubah segera)", S["table_cell"])],
    ]
    login_table = Table(login_data, colWidths=[3.5*cm, None, 4.5*cm])
    login_table.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_PRIMARY),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_GRAY1]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "MIDDLE"),
    ]))
    story.append(login_table)
    story.append(Spacer(1, 10))
    story.append(AlertBox(
        "Jika lupa password, gunakan fitur Lupa Password di halaman login. "
        "Masukkan identifier atau email yang terdaftar. "
        "Jika tidak berhasil, hubungi Admin atau Staff untuk reset password manual.",
        kind="tip"))
    story.append(AlertBox(
        "Segera ubah password default 'password' setelah pertama kali login "
        "untuk menjaga keamanan akun Anda.", kind="warning"))
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 3. ADMIN
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("3.  Panduan Admin", color=C_ADMIN))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Admin bertanggung jawab atas keamanan sistem, pengelolaan akun staff, "
        "dan pemantauan seluruh aktivitas pengguna.", S["body"]))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Menu yang Tersedia", S["h2"]))
    admin_menu = [
        [Paragraph("<b>Menu</b>", S["table_header"]),
         Paragraph("<b>Fungsi</b>", S["table_header"])],
        [Paragraph("Beranda (Dashboard)", S["table_cell"]),
         Paragraph("Ringkasan: jumlah guru, siswa, kelas-mapel, tugas. "
                   "Jadwal akademik & log aktivitas terbaru.", S["table_cell"])],
        [Paragraph("Daftar Staff", S["table_cell"]),
         Paragraph("Lihat, tambah, ubah, dan nonaktifkan akun staff kurikulum.", S["table_cell"])],
        [Paragraph("Log Aktivitas", S["table_cell"]),
         Paragraph("Histori semua aksi di sistem — siapa melakukan apa dan kapan.", S["table_cell"])],
        [Paragraph("Data Siswa", S["table_cell"]),
         Paragraph("Lihat dan edit data seluruh siswa.", S["table_cell"])],
        [Paragraph("Manajemen User", S["table_cell"]),
         Paragraph("Reset password, ubah identifier, aktifkan/nonaktifkan akun.", S["table_cell"])],
    ]
    admin_table = Table(admin_menu, colWidths=[4*cm, None])
    admin_table.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_ADMIN),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_ADMIN_BG]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(admin_table)
    story.append(Spacer(1, 12))

    story.append(Paragraph("Cara Menambah Akun Staff", S["h2"]))
    story.append(SimpleFlowChart([
        "Buka menu Daftar Staff di sidebar kiri",
        "Klik tombol '+ Tambah Staff'",
        "Isi data: Nama, NIP/NUPTK, Email, Telepon, Alamat",
        "Klik Simpan — akun dibuat, password default: 'password'",
        "Minta staff segera ubah password lewat Manajemen User",
    ], color=C_ADMIN))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Cara Reset Password Pengguna", S["h2"]))
    story.append(SimpleFlowChart([
        "Buka menu Manajemen User",
        "Cari nama pengguna dengan kotak pencarian",
        "Klik tombol 'Reset Password' pada baris pengguna",
        "Masukkan password baru (minimal 6 karakter)",
        "Simpan dan informasikan password baru ke pengguna",
    ], color=C_ADMIN))
    story.append(Spacer(1, 8))
    story.append(AlertBox(
        "Admin TIDAK dapat mengubah status akun miliknya sendiri. "
        "Ini adalah fitur keamanan untuk mencegah terkuncinya akses sistem.",
        kind="warning"))
    story.append(AlertBox(
        "Untuk keamanan, seluruh aksi admin tercatat otomatis di Log Aktivitas "
        "dan tidak dapat dihapus.",
        kind="info"))
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 4. STAFF KURIKULUM
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("4.  Panduan Staff Kurikulum", color=C_STAFF))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Staff adalah pengatur utama data akademik — mulai dari guru, siswa, kelas, "
        "mata pelajaran, jadwal, hingga rekap nilai seluruh siswa.", S["body"]))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Urutan Setup Awal Tahun Ajaran", S["h2"]))
    story.append(AlertBox(
        "Ikuti urutan berikut saat memulai tahun ajaran baru agar semua data "
        "saling terhubung dengan benar.", kind="info"))
    story.append(Spacer(1, 6))
    story.append(SimpleFlowChart([
        "1. Buat Tahun Ajaran Baru (format: 2025/2026, tandai Aktif)",
        "2. Daftarkan Kelas (jenjang, jurusan, ruang, wali kelas)",
        "3. Perbarui/Tambah Data Guru",
        "4. Import atau Daftarkan Siswa ke Kelas",
        "5. Buat Mata Pelajaran per jenjang & jurusan",
        "6. Buat Jadwal Pelajaran (Kelas + Mapel + Guru + Waktu)",
        "7. Tentukan Range Nilai Kategori (mis. 90-100 = Sangat Baik)",
        "8. Buat Rubrik Mapel (Lingkup Materi + Tujuan Pembelajaran)",
    ], color=C_STAFF))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Import Siswa via File CSV", S["h2"]))
    story.append(Paragraph(
        "Fitur impor memungkinkan pendaftaran massal siswa tanpa input manual satu per satu.",
        S["body"]))
    story.append(Spacer(1, 4))
    story.append(Paragraph("Langkah impor:", S["h3"]))
    story.append(Paragraph("1. Buka menu Data Siswa, klik tombol 'Impor'.", S["body_l"]))
    story.append(Paragraph("2. Siapkan file CSV dengan header berikut:", S["body_l"]))
    story.append(Paragraph(
        "   Wajib: nis, nisn, nama, email, kelas", S["code"]))
    story.append(Paragraph(
        "   Opsional: no_telp, jenis_kelamin, agama, alamat", S["code"]))
    story.append(Paragraph("Contoh isi file CSV:", S["h3"]))
    story.append(Paragraph(
        "nis,nisn,nama,email,kelas\n"
        "20001,0001234567,Budi Santoso,budi@email.com,X-IPA-1\n"
        "20002,0001234568,Ani Rahayu,ani@email.com,X-IPA-1",
        S["code"]))
    story.append(Paragraph(
        "3. Pilih file dan konfirmasi. Sistem melewati data yang sudah ada "
        "(berdasarkan NISN) dan melaporkan jumlah yang berhasil diimpor.", S["body_l"]))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Menu Rekap Nilai", S["h2"]))
    nilai_data = [
        [Paragraph("<b>Menu Nilai</b>", S["table_header"]),
         Paragraph("<b>Isi / Keterangan</b>", S["table_header"])],
        [Paragraph("Nilai Latihan Soal", S["table_cell"]),
         Paragraph("Rekapitulasi nilai ujian bertipe Latihan Soal", S["table_cell"])],
        [Paragraph("Nilai Tugas", S["table_cell"]),
         Paragraph("Nilai dari pengumpulan tugas per kelas-mapel", S["table_cell"])],
        [Paragraph("Sumatif LM", S["table_cell"]),
         Paragraph("Nilai sumatif per lingkup materi", S["table_cell"])],
        [Paragraph("Nilai Ujian Sumatif", S["table_cell"]),
         Paragraph("Nilai ujian sumatif tengah / akhir semester", S["table_cell"])],
        [Paragraph("Nilai Akhir", S["table_cell"]),
         Paragraph("Rekap nilai akhir seluruh komponen per siswa", S["table_cell"])],
    ]
    nt = Table(nilai_data, colWidths=[4.5*cm, None])
    nt.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_STAFF),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_STAFF_BG]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(nt)
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 5. GURU
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("5.  Panduan Guru", color=C_GURU))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Guru mengelola konten pembelajaran, tugas, ujian, dan penilaian di "
        "kelas-mapel yang diampu. Semua aktivitas dilakukan di dalam halaman "
        "detail kelas.", S["body"]))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Tab di Halaman Detail Kelas", S["h2"]))
    tab_data = [
        [Paragraph("<b>Tab</b>", S["table_header"]),
         Paragraph("<b>Fungsi</b>", S["table_header"]),
         Paragraph("<b>Akses</b>", S["table_header"])],
        [Paragraph("Materi", S["table_cell"]),
         Paragraph("Upload materi + file, diskusi komentar", S["table_cell"]),
         Paragraph("Guru (kelola) & Siswa (baca)", S["table_cell"])],
        [Paragraph("Tugas", S["table_cell"]),
         Paragraph("Buat tugas, deadline, nilai pengumpulan", S["table_cell"]),
         Paragraph("Guru (kelola) & Siswa (kumpul)", S["table_cell"])],
        [Paragraph("Ujian", S["table_cell"]),
         Paragraph("Buat soal PG/Esai, nilai jawaban", S["table_cell"]),
         Paragraph("Guru (kelola) & Siswa (kerjakan)", S["table_cell"])],
        [Paragraph("Daftar Siswa", S["table_cell"]),
         Paragraph("Lihat semua siswa di kelas", S["table_cell"]),
         Paragraph("Guru saja", S["table_cell"])],
        [Paragraph("Kelompok", S["table_cell"]),
         Paragraph("Atur kelompok belajar siswa", S["table_cell"]),
         Paragraph("Guru saja", S["table_cell"])],
        [Paragraph("Rubrik", S["table_cell"]),
         Paragraph("Lihat & edit rubrik mapel", S["table_cell"]),
         Paragraph("Guru & Siswa", S["table_cell"])],
        [Paragraph("Nilai", S["table_cell"]),
         Paragraph("Rekap nilai per siswa di kelas ini", S["table_cell"]),
         Paragraph("Guru & Siswa", S["table_cell"])],
    ]
    tab_t = Table(tab_data, colWidths=[2.8*cm, None, 4*cm])
    tab_t.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_GURU),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_GURU_BG]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 6),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(tab_t)
    story.append(Spacer(1, 12))

    story.append(Paragraph("Mengelola Materi Pembelajaran", S["h2"]))
    story.append(SimpleFlowChart([
        "Menu Kelas → pilih kartu kelas-mapel → klik 'Buka Kelas'",
        "Buka tab 'Materi' → klik '+ Tambah Materi'",
        "Isi Judul, Lingkup Materi, Status, Deskripsi",
        "Upload file lampiran (PDF, Word, PPT — maks 25 MB/file, hingga 10 file)",
        "Klik Simpan. Ubah status ke Visible agar siswa bisa membaca",
    ], color=C_GURU))
    story.append(Spacer(1, 6))
    story.append(Paragraph("Siklus Status Konten", S["h3"]))
    story.append(Paragraph(
        "Semua konten (materi, tugas, ujian) memiliki tiga status:", S["body_l"]))
    status_data = [
        [Paragraph("<b>Status</b>", S["table_header"]),
         Paragraph("<b>Arti</b>", S["table_header"]),
         Paragraph("<b>Siswa Bisa Lihat?</b>", S["table_header"])],
        [Paragraph("Draft", S["table_cell"]),
         Paragraph("Belum selesai, disimpan sementara", S["table_cell"]),
         Paragraph("Tidak", S["table_cell"])],
        [Paragraph("Visible", S["table_cell"]),
         Paragraph("Dipublikasikan ke siswa", S["table_cell"]),
         Paragraph("Ya", S["table_cell"])],
        [Paragraph("Hidden", S["table_cell"]),
         Paragraph("Disembunyikan sementara", S["table_cell"]),
         Paragraph("Tidak", S["table_cell"])],
    ]
    st = Table(status_data, colWidths=[2.5*cm, None, 3.5*cm])
    st.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_GURU),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_GURU_BG]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 6),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "MIDDLE"),
    ]))
    story.append(st)
    story.append(Spacer(1, 12))

    story.append(Paragraph("Membuat dan Menilai Tugas", S["h2"]))
    story.append(SimpleFlowChart([
        "Tab Tugas → klik '+ Tambah Tugas'",
        "Isi Judul, Tujuan Pembelajaran (dari rubrik), Deadline, Status, File",
        "Klik Simpan dan atur status menjadi Visible",
        "Untuk menilai: klik 'Pengumpulan (n)' pada kartu tugas",
        "Pilih siswa → isi nilai (0-100) dan feedback → klik Nilai",
    ], color=C_GURU))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Membuat Ujian (Pilihan Ganda & Esai)", S["h2"]))
    story.append(SimpleFlowChart([
        "Tab Ujian → klik '+ Tambah Ujian'",
        "Isi info ujian: Judul, Tipe (Latihan/Sumatif/STS/SAS), Tanggal & Jam",
        "Klik '+ Soal' untuk menambah pertanyaan",
        "Pilih tipe soal: Pilihan Ganda (opsi A-D, jawaban benar, bobot) atau Esai",
        "Ubah Status Ujian menjadi Visible agar bisa dikerjakan siswa",
        "Nilai jawaban: klik 'Pengerjaan (n)' → pilih siswa → isi nilai per soal",
    ], color=C_GURU))
    story.append(Spacer(1, 6))
    story.append(AlertBox(
        "Soal Pilihan Ganda dapat dinilai otomatis oleh sistem berdasarkan kunci "
        "jawaban yang diisi guru. Soal Esai wajib dinilai manual.", kind="tip"))
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 6. SISWA
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("6.  Panduan Siswa", color=C_SISWA))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Siswa dapat mengakses materi, mengumpulkan tugas, mengerjakan ujian, "
        "dan memantau nilai melalui dashboard yang sederhana dan mudah digunakan.",
        S["body"]))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Menu yang Tersedia", S["h2"]))
    siswa_menu = [
        [Paragraph("<b>Menu</b>", S["table_header"]),
         Paragraph("<b>Fungsi</b>", S["table_header"])],
        [Paragraph("Beranda", S["table_cell"]),
         Paragraph("Ringkasan statistik dan jadwal akademik terbaru.", S["table_cell"])],
        [Paragraph("Kelas", S["table_cell"]),
         Paragraph("Daftar kelas-mapel yang diikuti. Klik 'Buka Kelas' untuk masuk.", S["table_cell"])],
        [Paragraph("Jadwal Pelajaran", S["table_cell"]),
         Paragraph("Jadwal pelajaran mingguan sesuai kelas siswa.", S["table_cell"])],
    ]
    siswa_table = Table(siswa_menu, colWidths=[3.5*cm, None])
    siswa_table.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_SISWA),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_SISWA_BG]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(siswa_table)
    story.append(Spacer(1, 12))

    story.append(Paragraph("Mengakses Materi Pelajaran", S["h2"]))
    story.append(SimpleFlowChart([
        "Buka menu Kelas → pilih kartu kelas-mapel → klik 'Buka Kelas'",
        "Buka tab 'Materi' untuk melihat semua materi yang dipublikasikan",
        "Klik tombol unduh pada lampiran untuk mengambil file",
        "Klik 'Komentar (n)' untuk membaca atau menulis diskusi dengan guru",
    ], color=C_SISWA))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Mengumpulkan Tugas", S["h2"]))
    story.append(SimpleFlowChart([
        "Buka tab 'Tugas' di detail kelas",
        "Periksa status dan deadline tugas yang tersedia",
        "Klik 'Kumpulkan' pada tugas yang ingin dikumpulkan",
        "Pilih file jawaban (PDF, Word, gambar — maks 25 MB per file)",
        "Klik 'Kirim' — status berubah menjadi Terkirim",
        "Setelah guru menilai, nilai dan feedback akan tampil di kartu tugas",
    ], color=C_SISWA))
    story.append(Spacer(1, 6))
    story.append(AlertBox(
        "Pastikan mengumpulkan tugas sebelum deadline. Pengumpulan masih bisa "
        "diubah sebelum deadline dengan klik 'Ubah Pengumpulan'.", kind="warning"))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Mengerjakan Ujian", S["h2"]))
    story.append(SimpleFlowChart([
        "Buka tab 'Ujian' di detail kelas",
        "Klik 'Kerjakan / Lihat Soal' pada ujian yang berstatus Visible",
        "Jawab setiap soal: Pilihan Ganda (klik A/B/C/D) atau Esai (ketik jawaban)",
        "Pastikan semua soal sudah dijawab sebelum mengirim",
        "Klik 'Kirim Jawaban' — jawaban tidak bisa diubah setelah dikirim",
        "Nilai tampil otomatis (PG) atau setelah guru menilai (Esai)",
    ], color=C_SISWA))
    story.append(Spacer(1, 6))
    story.append(AlertBox(
        "Jawaban ujian yang sudah dikirim tidak dapat diubah. "
        "Baca semua soal dengan teliti sebelum menekan 'Kirim Jawaban'.", kind="warning"))
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 7. DIAGRAM ALUR LENGKAP
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("7.  Diagram Alur Sistem Lengkap"))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "Bagian ini menyajikan gambaran menyeluruh alur interaksi antara semua "
        "peran dalam sistem dari awal tahun ajaran hingga penilaian akhir.",
        S["body"]))
    story.append(Spacer(1, 10))

    story.append(Paragraph("Alur Proses Pembelajaran (End-to-End)", S["h2"]))
    seq_actors = ["Staff", "Guru", "Siswa", "Sistem"]
    seq_msgs = [
        (0, 3, "Buat tahun ajaran, kelas, mapel, jadwal"),
        (0, 3, "Buat rubrik (lingkup materi + TP)"),
        (1, 3, "Upload materi (status Visible)"),
        (3, 2, "Materi tersedia di kelas", True),
        (2, 3, "Baca materi & tulis komentar"),
        (1, 3, "Buat tugas + deadline"),
        (2, 3, "Upload file jawaban tugas"),
        (1, 3, "Nilai pengumpulan (0-100 + feedback)"),
        (3, 2, "Nilai & feedback tersedia", True),
        (1, 3, "Buat soal ujian, set Visible"),
        (2, 3, "Kerjakan ujian online"),
        (1, 3, "Nilai jawaban esai"),
        (3, 2, "Nilai ujian tampil di dashboard", True),
    ]
    story.append(SequenceDiagram(seq_actors, seq_msgs))
    story.append(Spacer(1, 12))

    story.append(Paragraph("Alur Manajemen Akun & Keamanan", S["h2"]))
    acc_data = [
        [Paragraph("<b>Aktor</b>", S["table_header"]),
         Paragraph("<b>Dapat Membuat Akun</b>", S["table_header"]),
         Paragraph("<b>Dapat Reset Password</b>", S["table_header"]),
         Paragraph("<b>Dapat Nonaktifkan</b>", S["table_header"])],
        [Paragraph("Admin", S["table_cell"]),
         Paragraph("Staff, Guru, Siswa", S["table_cell"]),
         Paragraph("Semua user", S["table_cell"]),
         Paragraph("Semua user (kecuali diri sendiri)", S["table_cell"])],
        [Paragraph("Staff", S["table_cell"]),
         Paragraph("Guru, Siswa", S["table_cell"]),
         Paragraph("Guru, Siswa", S["table_cell"]),
         Paragraph("Guru, Siswa", S["table_cell"])],
        [Paragraph("Guru", S["table_cell"]),
         Paragraph("-", S["table_cell"]),
         Paragraph("-", S["table_cell"]),
         Paragraph("-", S["table_cell"])],
        [Paragraph("Siswa", S["table_cell"]),
         Paragraph("-", S["table_cell"]),
         Paragraph("-", S["table_cell"]),
         Paragraph("-", S["table_cell"])],
    ]
    acc_t = Table(acc_data, colWidths=[2.5*cm, 4*cm, 4*cm, None])
    acc_t.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_PRIMARY),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [white, C_GRAY1]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(acc_t)
    story.append(Spacer(1, 12))

    story.append(Paragraph("Alur Komponen Nilai Akhir", S["h2"]))
    val_data = [
        [Paragraph("<b>Komponen Nilai</b>", S["table_header"]),
         Paragraph("<b>Sumber Data</b>", S["table_header"]),
         Paragraph("<b>Penanggung Jawab</b>", S["table_header"])],
        [Paragraph("Nilai Latihan Soal (LS)", S["table_cell"]),
         Paragraph("Ujian tipe Latihan Soal", S["table_cell"]),
         Paragraph("Guru + Sistem (PG otomatis)", S["table_cell"])],
        [Paragraph("Nilai Tugas", S["table_cell"]),
         Paragraph("Penilaian pengumpulan tugas siswa", S["table_cell"]),
         Paragraph("Guru", S["table_cell"])],
        [Paragraph("Sumatif Lingkup Materi (SLM)", S["table_cell"]),
         Paragraph("Ujian per lingkup materi", S["table_cell"]),
         Paragraph("Guru + Sistem", S["table_cell"])],
        [Paragraph("Sumatif Tengah Semester (STS)", S["table_cell"]),
         Paragraph("Ujian tipe STS", S["table_cell"]),
         Paragraph("Guru + Sistem", S["table_cell"])],
        [Paragraph("Sumatif Akhir Semester (SAS)", S["table_cell"]),
         Paragraph("Ujian tipe SAS", S["table_cell"]),
         Paragraph("Guru + Sistem", S["table_cell"])],
        [Paragraph("NILAI AKHIR", S["table_header"]),
         Paragraph("Rekap semua komponen di atas", S["table_cell"]),
         Paragraph("Staff Kurikulum", S["table_cell"])],
    ]
    val_t = Table(val_data, colWidths=[5*cm, None, 4.5*cm])
    val_t.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0), C_PRIMARY),
        ("TEXTCOLOR",    (0, 0), (-1, 0), white),
        ("BACKGROUND",   (0, -1), (-1, -1), HexColor("#fef3c7")),
        ("FONTNAME",     (0, -1), (0, -1), "Helvetica-Bold"),
        ("ROWBACKGROUNDS",(0, 1), (-1, -2), [white, C_GRAY1]),
        ("GRID",         (0, 0), (-1, -1), 0.4, C_BORDER),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 8),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(val_t)
    story.append(PageBreak())

    # ══════════════════════════════════════════════════════════════════════════
    # 8. FAQ
    # ══════════════════════════════════════════════════════════════════════════
    story.append(SectionHeader("8.  Pertanyaan Umum (FAQ)"))
    story.append(Spacer(1, 6))

    faqs = [
        ("Saya lupa password, apa yang harus dilakukan?",
         "Gunakan fitur Lupa Password di halaman login. Masukkan identifier atau email "
         "yang terdaftar. Jika tidak berhasil, hubungi Admin atau Staff untuk reset "
         "password secara manual.", "tip"),
        ("Materi tidak muncul di kelas siswa, kenapa?",
         "Materi mungkin masih berstatus Draft. Guru perlu mengubah status materi "
         "menjadi Visible agar dapat dilihat oleh siswa.", "info"),
        ("Saya tidak bisa mengumpulkan tugas.",
         "Periksa: (1) Status tugas harus Visible — bukan Draft atau Hidden. "
         "(2) Format file yang didukung: PDF, DOC/DOCX, JPG, PNG, PPT/PPTX. "
         "(3) Ukuran file maks 25 MB per file, hingga 10 file.", "warning"),
        ("Ujian sudah selesai tapi nilai belum muncul.",
         "Untuk soal Pilihan Ganda, nilai dihitung otomatis. Untuk soal Esai, guru "
         "perlu menilai secara manual — harap tunggu hingga guru selesai mengoreksi.", "info"),
        ("Siswa tidak muncul di kelas yang dikelola guru.",
         "Pastikan data siswa sudah dimasukkan ke kelas yang benar oleh Staff. "
         "Cek di menu Data Siswa — kolom Kelas.", "info"),
        ("Bagaimana cara menambah mata pelajaran baru?",
         "Hanya Staff Kurikulum yang bisa menambah mata pelajaran. Buka menu Mata "
         "Pelajaran → klik Tambah Mapel → isi judul, jenjang, jurusan, dan koordinator.", "info"),
        ("Apakah siswa bisa mengerjakan ujian lebih dari sekali?",
         "Tidak. Jawaban yang sudah dikirim tidak dapat diulang. Jika ada kendala "
         "teknis, siswa perlu menghubungi guru untuk penanganan lebih lanjut.", "warning"),
        ("Siapa yang bisa melihat Log Aktivitas?",
         "Hanya Admin yang memiliki akses ke menu Log Aktivitas. Semua aksi penting "
         "di sistem tercatat otomatis dan tidak dapat dihapus.", "info"),
        ("Bagaimana cara membuat kelompok belajar?",
         "Guru membuka Tab Kelompok di detail kelas → klik Tambah Kelompok → isi "
         "nama kelompok dan centang anggota dari daftar siswa → klik Simpan.", "tip"),
        ("Apa perbedaan Sumatif Lingkup Materi, STS, dan SAS?",
         "Sumatif Lingkup Materi (SLM) adalah ujian per topik materi. "
         "STS (Sumatif Tengah Semester) adalah ujian di pertengahan semester. "
         "SAS (Sumatif Akhir Semester) adalah ujian di akhir semester.", "info"),
    ]

    for q_text, a_text, kind in faqs:
        faq_block = [
            Paragraph(f"❓  {q_text}", S["faq_q"]),
            AlertBox(a_text, kind=kind),
            Spacer(1, 6),
        ]
        story.append(KeepTogether(faq_block))

    # Footer dokumen
    story.append(Spacer(1, 20))
    story.append(HRFlowable(width="100%", thickness=1, color=C_BORDER))
    story.append(Spacer(1, 8))
    story.append(Paragraph(
        "E-Learning SMAN 2 Sidoarjo  ·  Panduan Penggunaan Sistem  ·  "
        f"Versi 1.0  ·  {BULAN_ID[datetime.date.today().month]} {datetime.date.today().year}",
        S["footer"]))
    story.append(Paragraph(
        "Untuk bantuan teknis, hubungi admin sistem sekolah.",
        S["footer"]))

    doc.build(story)
    print(f"PDF berhasil dibuat: {output_path}")


# ── Helper: NextPageTemplate ──────────────────────────────────────────────────
from reportlab.platypus import ActionFlowable

class NextPageTemplate(ActionFlowable):
    def __init__(self, pt):
        ActionFlowable.__init__(self, ('nextPageTemplate', pt))


if __name__ == "__main__":
    out = "/Users/nambisembilu/Project/Web/fullstack/elearning.sman2sidoarjo/tutorial.pdf"
    build_pdf(out)
