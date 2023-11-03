#!/usr/bin/env python3

# Generate highway shields as SVG files in symbols/shields.

from __future__ import print_function
import copy, lxml.etree, math, os
import sys
import yaml
from colormath.color_conversions import convert_color
from colormath.color_objects import HSLColor, sRGBColor

verbose = True

def to_rgbhex(a):
    """ Convert (HSL) color to RGB """

    rgb = convert_color(a, sRGBColor)
    if (rgb.rgb_r != rgb.clamped_rgb_r or rgb.rgb_g != rgb.clamped_rgb_g or rgb.rgb_b != rgb.clamped_rgb_b):
        raise Exception("Colour {} is outside sRGB".format(a))
    return rgb.get_rgb_hex()


def scale_HSL(orig, alteration, relative=False):
    """ Create new HSLColor given an alteration specification. """

    mode, v = alteration
    newobj = copy.copy(orig)
    if mode == 'darken':
        if relative:
            newobj.hsl_l /= v
        else:
            newobj.hsl_l -= v
        if (newobj.hsl_l < 0.0) or (newobj.hsl_l >1.0):
            raise ValueError(f"scale_HSL: darken with {v} generated lightness outside gamut: {newobj.hsl_l}")
    elif mode == 'saturate':
        if relative:
            newobj.hsl_s *= v
        else:
            newobj.hsl_s += v
        if (newobj.hsl_s < 0.0) or (newobj.hsl_s > 1.0):
            raise ValueError(f"scale_HSL: saturate with {v} generated saturation outside gamut: {newobj.hsl_s}")
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
        if (v >= 1.0) or (v <= -1.0):
            sys.exit(f"Invalid color change (must be floating point number between -1 and 1): {v}")
        modetype = k[len(whichunderscore):]
        if modetype == 'lighten':
            modetype = 'darken'
            v = -v
        elif modetype == 'desaturate':
            modetype = 'saturate'
            v = -v
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


    max_width = 11
    max_height = 4
    output_dir = '../symbols/shields/' # specified relative to the script location

    for roadtype, roadvalues in shieldtypes.items():
        try:
            fill = parse_color(roadvalues['fill'])
        except KeyError:
            sys.exit(f"Missing fill color for road type {roadtype}")
        casingmode = parse_mode(roadvalues, 'casing')

        settings['roads'][roadtype]['fill'] = fill
        settings['roads'][roadtype]['casing'] = scale_HSL(fill, casingmode)


    if not os.path.exists(os.path.dirname(output_dir)):
        os.makedirs(os.path.dirname(output_dir))

    storevars = settings['shield-geometry']
    output_sizes = ['base']
    for k in storevars.keys():
        if k[0] == 'z':
            output_sizes.append(k)

    if verbose:
        print(storevars)
        print(settings['roads'])
        print(output_sizes)

    for height in range(1, max_height + 1):
        for width in range(1, max_width + 1):
            for shield_type, roadsettings in shieldtypes.items():

                vars = copy.copy(storevars)
                for shield_size in output_sizes:

                    if (shield_size != 'base') and (shield_size in vars):
                        vars.update(vars[shield_size])

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
