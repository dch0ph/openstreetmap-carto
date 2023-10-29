#!/usr/bin/env python3

# Generate highway shields as SVG files in symbols/shields.

from __future__ import print_function
import copy, lxml.etree, math, os
import sys
#from generate_road_colours import load_settings, generate_colours
import yaml
from colormath.color_conversions import convert_color
from colormath.color_objects import LabColor, LCHabColor, sRGBColor
from colormath.color_diff import delta_e_cie2000

verbose = True

class Color:
    """A color in the CIE lch color space."""

    def __init__(self, lch_tuple):
        self.m_lch = LCHabColor(*lch_tuple)

    def lch(self):
        return "Lch({:.0f},{:.0f},{:.0f})".format(*(self.m_lch.get_value_tuple()))

    def rgb(self):
        rgb = convert_color(self.m_lch, sRGBColor)
        if (rgb.rgb_r != rgb.clamped_rgb_r or rgb.rgb_g != rgb.clamped_rgb_g or rgb.rgb_b != rgb.clamped_rgb_b):
            raise Exception("Colour {} is outside sRGB".format(self.lch()))
        return rgb.get_rgb_hex()

    def rgb_error(self):
        return delta_e_cie2000(convert_color(self.m_lch, LabColor),
                               convert_color(sRGBColor.new_from_rgb_hex(self.rgb()), LabColor))

def parse_color(a):
    """Return color from string specification (assumed sRGB hex #RRGGBB)"""

    return sRGBColor.new_from_rgb_hex(a)


def parse_mode(d, which):
    """ Search dict for colour modification """

    which += '_'
    modetype = None
    for k, v in d.items():
        if not k.startswith(which):
            continue
        if modetype is not None:
            sys.exit(f"More than one color alteration specified for {which}")
        if v < 1.0:
            sys.exit(f"Invalid color scaling (must be floating point number >=1.0): {v}")
        modetype = k[len(which):]
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

    config['global'] = {}

    config['global']['types'] = list(shieldtypes.keys())
    config['global']['max_width'] = 11
    config['global']['max_height'] = 4
    config['global']['output_dir'] = '../symbols/shields/' # specified relative to the script location
    config['global']['additional_sizes'] = ['base', 'z16', 'z18']

    # specific values overwrite config['base'] ones
    for roadtype, roadvalues in shieldtypes.items():
        config[roadtype] = {}
        try:
            fill = parse_color(roadvalues['fill'])
        except KeyError:
            sys.exit(f"Missing fill color for road type {roadtype}")
        casingmode = parse_mode(roadvalues, 'casing')
        if verbose:
            print(casingmode)

# TODO do colour calculation to determine casing color

        config[roadtype]['fill'] = fill

    # changes for different size versions
    config['z16'] = {}
    config['z18'] = {}

    config['z16']['font_width'] = 6.1
    config['z16']['font_height'] = 14.1
    config['z18']['font_width'] = 6.9
    config['z18']['font_height'] = 15.1

    sys.exit("Stop here")

    if not os.path.exists(os.path.dirname(config['global']['output_dir'])):
        os.makedirs(os.path.dirname(config['global']['output_dir']))

    for height in range(1, config['global']['max_height'] + 1):
        for width in range(1, config['global']['max_width'] + 1):
            for shield_type in config['global']['types']:

                # merge base config and specific styles
                vars = copy.deepcopy(config['base'])
                if shield_type in config:
                    for option in config[shield_type]:
                        vars[option] = config[shield_type][option]

                for shield_size in config['global']['additional_sizes']:

                    if shield_size != 'base':
                        if shield_size in config:
                            for option in config[shield_size]:
                                vars[option] = config[shield_size][option]

                    shield_width = 2 * vars['padding_x'] + math.ceil(vars['font_width'] * width)
                    shield_height = 2 * vars['padding_y'] + math.ceil(vars['font_height'] * height)

                    svg = lxml.etree.Element('svg', nsmap=svgnsmap)
                    svg.set('width', str(shield_width + vars['stroke_width']))
                    svg.set('height', str(shield_height + vars['stroke_width']))
                    svg.set('viewBox', '0 0 ' + str(shield_width + vars['stroke_width']) + ' ' + str(shield_height + vars['stroke_width']))

                    if vars['stroke_width'] > 0:
                        offset_x = vars['stroke_width'] / 2.0
                        offset_y = vars['stroke_width'] / 2.0
                    else:
                        offset_x = 0
                        offset_y = 0

                    shield = lxml.etree.Element(svgns + 'rect')
                    shield.set('x', str(offset_x))
                    shield.set('y', str(offset_y))
                    shield.set('width', str(shield_width))
                    shield.set('height', str(shield_height))
                    if vars['rounded_corners'] > 0:
                        shield.set('rx', str(vars['rounded_corners']))
                        shield.set('ry', str(vars['rounded_corners']))

                    shield.set('fill', vars['fill'])

                    stroke = ''
                    if vars['stroke_width'] > 0:
                        shield.set('stroke', vars['stroke_fill'])
                        shield.set('stroke-width', str(vars['stroke_width']))

                    svg.append(shield)

                    filename = shield_type + '_' + str(width) + 'x' + str(height)
                    if shield_size != 'base':
                        filename = filename + '_' + shield_size

                    filename = filename + '.svg'

                    # save file
                    try:
                        shieldfile = open(os.path.join(os.path.dirname(__file__), config['global']['output_dir'] + filename), 'wb')
                        shieldfile.write(lxml.etree.tostring(svg, encoding='utf-8', xml_declaration=True, pretty_print=True))
                        shieldfile.close()
                    except IOError:
                        print('Could not save file ' + filename + '.')
                        continue

if __name__ == "__main__":
    main()
