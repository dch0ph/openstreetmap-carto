@water-text: @water-line-color;
// Darken rivers and streams
@water-smooth: 0.3;
@glacier: #ddecec;
@glacier-line: #9cf;

@tunnel-color: #505050;
@stream-width-z13: 0.75;
@stream-width-z14: 1.0;
@stream-width-z15plus: 1.4;

@wastewater-color: desaturate(@water-color, 40%);

@waterway-text-repeat-distance: 200;

#water-areas {
  [natural = 'glacier']::natural {
    [zoom >= 5] {
      line-width: 1.0;
      line-color: @glacier-line;
      polygon-fill: @glacier;
      [zoom >= 10] {
        line-dasharray: 4,2;
        line-width: 1.5;
      }
    }
  }

  [waterway = 'dock'],
  [landuse = 'basin'],
  [natural = 'water'][water != 'river'],
  [natural = 'water'][tidal = 'yes'],
  [natural = 'water'][zoom >= 11],
  [landuse = 'reservoir'] {
    [int_intermittent = 'no'] {
	  [ water = 'wastewater'] { polygon-fill: @wastewater-color; }
	  [ water != 'wastewater'] {
        polygon-fill: @water-color;
		[zoom < 18] { 
			polygon-smooth: @water-smooth;
			[zoom >= 12][water != 'lock'] { line/line-smooth: @water-smooth; }
		}
	  }
	  [water = 'lock'][zoom >= 16] {
		polygon-pattern-file: url('patterns/generic_fine_hatch.svg');
		polygon-pattern-opacity: 0.6;
		polygon-pattern-comp-op: color-dodge;
	  }
	  [zoom >= 11] {
		line/line-width: 0.4;
		line/line-color: @water-line-color;
	  }
	  [zoom >= 13] { line/line-width: 0.8; }
	  [zoom >= 17] { line/line-width: 1.3; }
      [way_pixels >= 4] { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.6; }
	  [zoom < 12] { line/line: none; }
    }
    [int_intermittent = 'yes'] {
      polygon-pattern-file: url('patterns/intermittent_water.svg');
      [way_pixels >= 4] { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.6; }
    }
  }
}

#water-lines-low-zoom {
  [waterway = 'river'][zoom >= 8][zoom < 12] {
    [int_intermittent = 'yes'] {
      line-dasharray: 8,4;
      line-cap: butt;
      line-join: round;
      line-clip: false;
    }
    line-color: mix(@water-line-color, @water-color, 50%);
    line-width: 1.2;
 //   [zoom >= 9] { line-width: 1.2; }
 //   [zoom >= 10] { line-width: 1.6; }
  }
}

#water-lines::casing {
  [waterway = 'stream'],
  [waterway = 'ditch'][zoom >= 14],
  [waterway = 'drain'][zoom >= 14] {
    [zoom >= 13],
    [int_intermittent = 'yes'][zoom >= 15] {
      // the additional line of land color is used to provide a background for dashed casings
		  [int_tunnel = 'yes'] {
		    background/line-color: @land-color;
		    background/line-width: 2;
		    background/line-cap: round;
		    background/line-join: round;
		    [waterway = 'stream'][zoom >= 15] { background/line-width: 3; }
	    }
    }
  }
}

// reduced width to reflect narrower waters overall. Not clear why casing needed if not intermittent

#water-lines,
#waterway-bridges {
  [waterway = 'canal'][zoom >= 12],
  [waterway = 'river'][zoom >= 12] {
    // the additional line of land color is used to provide a background for dashed casings

    [int_tunnel = 'yes'][zoom >= 14] {
      background/line-color: @land-color;
      background/line-width: 3;
      background/line-cap: round;
      background/line-join: round;
      [zoom >= 15] { background/line-width: 5; }
      [zoom >= 17] { background/line-width: 8; }
      [zoom >= 18] { background/line-width: 11; }

      tunnelcasing/line-color: @tunnel-color;
      tunnelcasing/line-join: round;
      tunnelcasing/line-width: 3;
      tunnelcasing/line-dasharray: 4,2;
      [zoom >= 15] { tunnelcasing/line-width: 5; }
      [zoom >= 17] { tunnelcasing/line-width: 8; }
      [zoom >= 18] { tunnelcasing/line-width: 11; }
    }

    [bridge = 'yes'][zoom >= 14] {
      bridgecasing/line-color: black;
      bridgecasing/line-join: round;
	  bridgecasing/line-cap: square;
      bridgecasing/line-width: 3;
      [zoom >= 15] { bridgecasing/line-width: 5; }
      [zoom >= 17] { bridgecasing/line-width: 8; }
      [zoom >= 18] { bridgecasing/line-width: 11; }
    }

    water/line-color: @water-line-color;
    water/line-width: 1.5;
    water/line-cap: round;
    water/line-join: round;
    [bridge != 'yes'][int_tunnel != 'yes'][zoom < 18] { water/line-smooth: @water-smooth; }

    [int_intermittent = 'yes'] {
      [bridge = 'yes'][zoom >= 14] {
        bridgefill/line-color: white;
        bridgefill/line-join: round;
        bridgefill/line-width: 2;
        [zoom >= 13] { water/line-width: 2; }
        [zoom >= 15] { bridgefill/line-width: 3; }
        [zoom >= 17] { bridgefill/line-width: 6; }
        [zoom >= 18] { bridgefill/line-width: 9; }
      }
      water/line-dasharray: 4,3;
	  [bridge != 'yes'][int_tunnel != 'yes'][zoom < 18] { water/line-smooth: @water-smooth; }
      water/line-cap: butt;
      water/line-join: round;
      water/line-clip: false;
    }

// reduced slightly
    [zoom >= 13] { water/line-width: 2; }
//    [zoom >= 14] { water/line-width: 3; }
    [zoom >= 15] { water/line-width: 3; }
    [zoom >= 17] { water/line-width: 6; }
    [zoom >= 18] { water/line-width: 9; }

/*    [int_tunnel = 'yes'] {
      [zoom >= 13] { background/line-width: 2; }
//      [zoom >= 14] { background/line-width: 3; }
      [zoom >= 15] { background/line-width: 3; }
      [zoom >= 17] { background/line-width: 6; }
      [zoom >= 18] { background/line-width: 9; }

      water/line-dasharray: 4,2;
      background/line-cap: butt;
      background/line-join: miter;
      water/line-cap: butt;
      water/line-join: miter;
      tunnelfill/line-color: #f3f7f7;
      tunnelfill/line-width: 1;
//      [zoom >= 14] { tunnelfill/line-width: 1.5; }
      [zoom >= 15] { tunnelfill/line-width: 2.0; }
      [zoom >= 17] { tunnelfill/line-width: 7; }
      [zoom >= 18] { tunnelfill/line-width: 8; }
    }*/
	
	[int_intermittent != 'yes'] {
		[zoom >= 14] {
			marker-file: url('symbols/oneway.svg');
			marker-fill: @water-line-color;
			marker-max-error: 0.3;
			marker-placement: line;
			marker-spacing: 150;
			marker-transform: translate(0,-4);
		}
		[zoom >= 16] { marker-spacing: 600; }
	}
  }

  [waterway = 'stream'][zoom >= 13],
  [waterway = 'ditch'][zoom >= 14],
  [waterway = 'drain'][zoom >= 14] {
    [int_intermittent != 'yes'],
    [zoom >= 15] {
		[int_tunnel = 'yes'] {
		  tunnelcasing/line-color: @tunnel-color;
		  tunnelcasing/line-join: round;
		  tunnelcasing/line-width: 3;
		  tunnelcasing/line-dasharray: 4,2;
		  [waterway = 'stream'][zoom >= 15] { tunnelcasing/line-width: 4; }
		}

// Combination of bridge unreviewed
      [bridge = 'yes'] {
        bridgecasing/line-color: black;
        bridgecasing/line-join: round;
		bridgecasing/line-cap: square;
        bridgecasing/line-width: 3;
        [waterway = 'stream'][zoom >= 15], [zoom >= 17] { bridgecasing/line-width: 3; }
        bridgeglow/line-color: white;
        bridgeglow/line-join: round;
        bridgeglow/line-width: 3;
        [waterway = 'stream'][zoom >= 15], [zoom >= 17] { bridgeglow/line-width: 3; }
      }

	  [int_tunnel = 'yes'] {
		tunnelfill/line-color: white;
		tunnelfill/line-join: round;
		tunnelfill/line-width: 1.5;
        [waterway = 'stream'][zoom >= 15], [zoom >= 17] { tunnelfill/line-width: 2.5; }			
	  }
	  water/line-cap: round;
	  [int_intermittent = 'yes'] {
        water/line-dasharray: 4,3;
        water/line-cap: butt;
        water/line-join: round;
        water/line-clip: false;
      }
      water/line-width: @stream-width-z14;
	  [zoom < 14],[waterway != 'stream'] { water/line-width: @stream-width-z13; }
      water/line-color: @water-line-color;
	  [int_tunnel = 'yes'] { water/line-color: lighten(@water-line-color, 20%); }
	  [bridge != 'yes'][int_tunnel != 'yes'][waterway != 'drain'][zoom < 18] { water/line-smooth: @water-smooth; }

      [waterway = 'stream'][zoom >= 15],
	  [zoom >= 17] { water/line-width: @stream-width-z15plus; }

	  [int_intermittent != 'yes'][zoom >= 14] {
		marker-file: url('symbols/oneway.svg');
		marker-fill: @water-line-color;
		marker-max-error: 0.5;
		marker-placement: line;
		marker-spacing: 300;
		marker-transform: translate(0,-4);
	  }
    }
  }

}

#water-lines-text {
  [lock = 'yes'][zoom >= 17] {
      text-name: "[lock_name]";
      text-face-name: @oblique-fonts;
      text-placement: line;
      text-fill: @water-text;
      text-spacing: 400;
      text-size: 10;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
  }

  [lock != 'yes'][int_tunnel != 'yes'] {
    [waterway = 'river'][zoom >= 12] {
      text-name: "[name]";
      text-size: 8;
      text-face-name: @oblique-fonts;
      text-fill: @water-text;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-spacing: 400;
      text-placement: line;
      text-repeat-distance: @waterway-text-repeat-distance;
      [zoom >= 13] { text-size: 10; }
      [zoom >= 14] { text-size: 11; }
	  [zoom >= 16] { text-size: 12; }
	  [zoom >= 17] { text-size: 13.5; }
	  [zoom >= 18] { text-size: 15; }
    }

    [waterway = 'canal'][zoom >= 12] {
      text-name: "[name]";
      text-size: 8;
      text-face-name: @oblique-fonts;
      text-fill: @water-text;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-placement: line;
      text-repeat-distance: @waterway-text-repeat-distance;
    }

// Combined stream into drain and ditch, shrunk text slightly
    [waterway = 'drain'],
    [waterway = 'ditch'],
	[waterway = 'stream'] {
      [zoom >= 14] {
        text-name: "[name]";
        text-face-name: @oblique-fonts;
        text-size: 8;
		text-wrap-width: 48; // 6.0 em
		text-line-spacing: -0.4; // -0.05 em
		[zoom >= 16] {
			text-size: 10;
			text-wrap-width: 60; // 6.0 em
			text-line-spacing: -0.5; // -0.05 em
		}
		text-placement-type: simple;
		text-placements: "N,S,E,W,NE,SE,NW,SW";
        text-fill: @water-text;
        text-halo-radius: @standard-halo-radius;
        text-halo-fill: @standard-halo-fill;
        text-placement: line;
        text-vertical-alignment: middle;
        text-dy: 8;
        text-repeat-distance: @waterway-text-repeat-distance;
      }
    }
  }
  [natural = 'bay'][zoom >= 14],
  [natural = 'strait'][zoom >= 14] {
    text-name: "[name]";
    text-size: 10;
    text-face-name: @oblique-fonts;
    text-fill: @water-text;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-max-char-angle-delta: 15;
    text-spacing: 400;
    text-placement: line;
    [zoom >= 15] {
      text-size: 12;
    }
  }
}


#text-poly-low-zoom[zoom < 10],
#text-point[zoom >= 10] {
  [feature = 'natural_water'],
  [feature = 'landuse_reservoir'],
  [feature = 'landuse_basin'],
  [feature = 'waterway_dock'] {
    [zoom >= 5][way_pixels > 3000][way_pixels <= 768000],
    [zoom >= 17][way_pixels <= 768000] {
      text-name: "[name]";
      text-size: 10;
      text-wrap-width: 25; // 2.5 em
      text-line-spacing: -1.5; // -0.15 em
      [way_pixels > 12000] {
        text-size: 12;
        text-wrap-width: 37; // 3.1 em
        text-line-spacing: -1.6; // -0.13 em
      }
      [way_pixels > 48000] {
        text-size: 15;
        text-wrap-width: 59; // 3.9 em
        text-line-spacing: -1.5; // -0.10 em
      }
      [way_pixels > 192000] {
        text-size: 19;
        text-wrap-width: 95; // 5.0 em
        text-line-spacing: -0.95; // -0.05 em
      }
      text-fill: @water-text;
      text-face-name: @oblique-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-placement: interior;
    }
  }
}

#text-point[zoom >= 14] {
  [feature = 'natural_bay'],
  [feature = 'natural_strait'] {
    text-name: "[name]";
    text-size: 10;
    text-wrap-width: 25; // 2.5 em
    text-line-spacing: -1.5; // -0.15 em
    text-fill: @water-text;
    text-face-name: @oblique-fonts;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-placement: interior;
    [zoom >= 15] {
      text-size: 12;
      text-wrap-width: 37; // 3.1 em
      text-line-spacing: -1.6; // -0.13 em
    }
  }
}
