import fontforge
import os

regular = "NIS-JTC-Win-M9.ttf"
condensed = "NIS-JTC-Win-M9-Condensed.ttf"

def changefamily(fontpath):
    font = fontforge.open(fontpath)
    font.familyname = fontpath[:-4]
    font.fontname = fontpath[:-4]
    font.fullname = fontpath[:-4]
    font.generate(fontpath)
    print(f"Corrected {fontpath}")

changefamily(regular)
changefamily(condensed)