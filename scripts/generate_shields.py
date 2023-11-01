#!/usr/bin/env python3

# Generate highway shields as SVG files in symbols/shields.

from __future__ import print_function
import copy, lxml.etree, math, os
import sys
#from generate_road_colours import load_settings, generate_colours
import yaml
from colormath.color_conversions import convert_color
from colormath.color_objects import HSLColor, sRGBColor
#from colormath.color_diff import delta_e_cie2000

verbose = True

# class Color:
#     """A color in the CIE lch color space."""

#     def __init__(self, lch_tuple):
#         self.m_lch = LCHabColor(*lch_tuple)

#     def lch(self):
#         return "Lch({:.0f},{:.0f},{:.0f})".format(*(self.m_lch.get_value_tuple()))

#     def rgb(self):
#         rgb = convert_color(self.m_lch, sRGBColor)
#         if (rgb.rgb_r != rgb.clamped_rgb_r or rgb.rgb_g != rgb.clamped_rgb_g or rgb.rgb_b != rgb.clamped_rgb_b):
#             raise Exception("Colour {} is outside sRGB".format(self.lch()))
#         return rgb.get_rgb_hex()

#     def rgb_error(self):
#         return delta_e_cie2000(convert_color(self.m_lch, LabColor),
#                                convert_color(sRGBColor.new_from_rgb_hex(self.rgb()), LabColor))


def to_rgbhex(a):
    """ Convert (HSL) color to RGB """

    rgb = convert_color(a, sRGBColor)
    if (rgb.rgb_r != rgb.clamped_rgb_r or rgb.rgb_g != rgb.clamped_rgb_g or rgb.rgb_b != rgb.clamped_rgb_b):
        raise Exception("Colour {} is outside sRGB".format(a))
    return rgb.get_rgb_hex()


def scale_HSL(orig, alteration):
    """ Create new HSLColor given an alternation specification. """

    mode, v = alteration
    newobj = copy.copy(orig)
    if mode == 'darken':
        newobj.hsl_l /= v
        if (newobj.hsl_l < 0.0) or (newobj.hsl_l >1.0):
            raise ValueError(f"scale_HSL: darken with {v} generated lightness outside gamut: {newobj.hsl_l}")
    elif mode == 'saturate':
        newobj.hsl_s *= v
        if (newobj.hsl_s < 0.0) or (newobj.hsl_s >1.0):
            raise ValueError(f"scale_HSL: saturate with {v} generated lightness outside gamut: {newobj.hsl_l}")
    elif mode == 'absolute':
        pass
    else:
        raise KeyError(f"Unknown alteration mode: {mode}")
    return newobj


def parse_color(a):
    """Return HSL color from string specification (assumed sRGB hex #RRGGBB)"""

    return convert_color(sRGBColor.new_from_rgb_hex(a), HSLColor)


def parse_mode(d, which):
    """ Search dict for colour modification """

    whichunderscore = which + '_'
    modetype = None
    for k, v in d.items():
        if k == which:
            modetype = 'absolute'
            v = parse_color(v)
            continue
        if not k.startswith(whichunderscore):
            continue
        if modetype is not None:
            sys.exit(f"More than one color specification for {which}")
        if v < 1.0:
            sys.exit(f"Invalid color scaling (must be floating point number >=1.0): {v}")
        modetype = k[len(whichunderscore):]
        if modetype == 'lighten':
            modetype = 'darken'
            v = 1.0/v
        elif modetype == 'desaturate':
            modetype = 'saturate'
            v = 1.0/v
        elif modetype not in ['darken', 'saturate']:
            sys.exit(f"Unknown color alteration: {modetype}")
    return (modetype, v)


def main():

#    settings = load_settings()
    config_file = 'road-colors-override.yaml'
    settings = yaml.safe_load(open(config_file, 'r'))
#    colours = generate_colours(settings, 'shield')

    try:
        shieldtypes = settings['roads']
    except KeyError:
        sys.exit(f"generate_shields: configuration file {config_file} did not"
                 " contain a roads key listing the road types for shield generation.")

    namespace = 'http://www.w3.org/2000/svg'
    svgns = '{' + namespace + '}'
    svgnsmap = {None: namespace}

    config = {}
#    config['base'] = {}
    # Fall back colours used if no colours are defined in road-colours.yaml for a road type.
#    config['base']['fill'] = '#f1f1f1'
#    config['base']['stroke_fill'] = '#c6c6c6'

    max_width = 11
    max_height = 4
    output_dir = '../symbols/shields/' # specified relative to the script location
#    additional_sizes = ['base', 'z16', 'z18']
    output_sizes = ['base']

    # specific values overwrite config['base'] ones
    for roadtype, roadvalues in shieldtypes.items():
        config[roadtype] = {}
        try:
            fill = parse_color(roadvalues['fill'])
        except KeyError:
            sys.exit(f"Missing fill color for road type {roadtype}")
        casingmode = parse_mode(roadvalues, 'casing')

        settings['roads'][roadtype]['fill'] = fill
        settings['roads'][roadtype]['casing'] = scale_HSL(fill, casingmode)

    # changes for different size versions
#    config['z16'] = {}
#    config['z18'] = {}
#    config['z16']['font_width'] = 6.1
#    config['z16']['font_height'] = 14.1
#    config['z18']['font_width'] = 6.9
#    config['z18']['font_height'] = 15.1

    if not os.path.exists(os.path.dirname(output_dir)):
        os.makedirs(os.path.dirname(output_dir))

    vars = settings['shield-geometry']
    if verbose:
        print(vars)
        print(settings['roads'])

    for height in range(1, max_height + 1):
        for width in range(1, max_width + 1):
            for shield_type, roadsettings in shieldtypes.items():

                # merge base config and specific styles
#                if shield_type in config:
#                    for option in config[shield_type]:
#                        vars[option] = config[shield_type][option]

                for shield_size in output_sizes:

#                    if shield_size != 'base':
#                        if shield_size in config:
#                            for option in config[shield_size]:
#                                vars[option] = config[shield_size][option]

                    shield_width = 2 * vars['padding_x'] + math.ceil(vars['font_width'] * width)
                    shield_height = 2 * vars['padding_y'] + math.ceil(vars['font_height'] * height)
                    stroke_width = vars['stroke_width']

                    svg = lxml.etree.Element('svg', nsmap=svgnsmap)
                    svg.set('width', str(shield_width + stroke_width))
                    svg.set('height', str(shield_height + stroke_width))
                    svg.set('viewBox', '0 0 ' + str(shield_width + stroke_width) + ' ' + str(shield_height + stroke_width))

                    if stroke_width > 0:
                        offset_x = stroke_width / 2.0
                        offset_y = stroke_width / 2.0
                    else:
                        offset_x = 0
                        offset_y = 0

                    shield = lxml.etree.Element(svgns + 'rect')
                    shield.set('x', str(offset_x))
                    shield.set('y', str(offset_y))
                    shield.set('width', str(shield_width))
                    shield.set('height', str(shield_height))
                    if vars['rounded_corners'] > 0:
                        asstr = str(vars['rounded_corners'])
                        shield.set('rx', asstr)
                        shield.set('ry', asstr)

                    fillcolor = to_rgbhex(roadsettings['fill'])
                    shield.set('fill', fillcolor)

                    stroke = ''
                    if stroke_width > 0:
                        strokecolor = to_rgbhex(roadsettings['casing'])
                        shield.set('stroke', strokecolor)
                        shield.set('stroke-width', str(stroke_width))

                    svg.append(shield)

                    filename = shield_type + '_' + str(width) + 'x' + str(height)
                    if shield_size != 'base':
                        filename = filename + '_' + shield_size

                    filename = filename + '.svg'

                    # save file
                    try:
                        shieldfile = open(os.path.join(os.path.dirname(__file__), output_dir + filename), 'wb')
                        shieldfile.write(lxml.etree.tostring(svg, encoding='utf-8', xml_declaration=True, pretty_print=True))
                        shieldfile.close()
                    except IOError:
                        print('Could not save file ' + filename + '.')
                        continue

if __name__ == "__main__":
    main()
