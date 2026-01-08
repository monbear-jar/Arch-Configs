Use the ``fontfixer.sh`` tool to download the fonts, fix the font family names, and setup the fonts automatically.

## Why?

The default font family names for these fonts is ``TT-JTCE'EE'CE'i`M9P``. The issue with this is that some programs (like kitty) don't like the random apostrophies in the font name. This tool fixes those issues (changes font family names to ``NIS-JTC-Win-M9`` and ``NIS-JTC-Win-M9-Condensed``) and makes the fonts very easy to install.

## Dependencies

``fontforge``: font modification tool used to change font family names

## Steps

1. Install dependencies

```
sudo pacman -S fontforge
```

2. Run ``fontfixer.sh`` to automatically download and place the fonts in the right directory

The fonts should work now