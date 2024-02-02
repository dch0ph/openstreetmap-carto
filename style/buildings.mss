@building-fill: #d9d0c9;  // Lch(84, 5, 68)
@building-line: #444;
// #444 is same level of black as railway
@building-low-zoom: #444;
//darken(@building-fill, 4%);

@building-major-fill: darken(@building-fill, 15%); 
//@building-major-line: darken(@building-major-fill, 15%);  // Lch(61, 13, 65)
//@building-major-z15: darken(@building-major-fill, 5%);  // Lch(70, 9, 66)
//@building-major-z14: darken(@building-major-fill, 10%);  // Lch(66, 11, 65)

@entrance-normal: #666;
@entrance-permissive: darken(@entrance-normal, 15%);

#buildings {
	[building != 'ruins' ] {
		polygon-clip: false;
		polygon-fill: @building-fill;
		[building = 'roof' ] {
			polygon-fill: lighten(@building-fill, 8%);
		}
		[amenity = 'place_of_worship'],
		[aeroway = 'terminal'],
		[aerialway = 'station'],
		[building = 'train_station'],
		[public_transport = 'station'],
		[is_listed = 'yes'] {
			polygon-fill: @building-major-fill;
		}
		[way_pixels < 75][zoom < 16] { polygon-fill: @building-low-zoom; }
	}
	[building = 'ruins'] {
		polygon-fill: white;
		polygon-opacity: 0.8;
		casing/line-width: 0.8;
		casing/line-color: white;
		casing/line-opacity: 0.8;
	}
	line/line-color: @building-line;
	[way_pixels < 75][zoom < 16] { line/line-color: @building-low-zoom; }
	line/line-width: 0.8;
	[building = 'ruins'] { line/line-dasharray: 1.5,1; }  
	line/line-clip: false;
}

#bridge {
  [zoom >= 12] {
    polygon-fill: #B8B8B8;
  }
}

#entrances {
  [zoom >= 18][entrance = "main"],
  [zoom >= 19] {
    marker-fill: @entrance-normal;
    marker-allow-overlap: true;
    marker-ignore-placement: true;
    marker-file: url('symbols/rect.svg');
    marker-width: 4;
    marker-height: 4;
    ["entrance" = "main"] {
      marker-file: url('symbols/square.svg');
    }
	  [zoom >= 19] {
		 marker-width: 6;
		 marker-height: 6;
		 ["entrance" = "service"] {
			marker-file: url('symbols/corners.svg');
		 }
		["access" = "yes"],
		["access" = "permissive"] {
		  marker-fill: @entrance-permissive;
		}
		["access" = "no"] {
		  marker-file: url('symbols/rectdiag.svg');
		}
	  }
   }
/*  [zoom >= 20]["entrance" != null] {
    marker-width: 8.0;
    marker-height: 8.0;
  }*/
}
