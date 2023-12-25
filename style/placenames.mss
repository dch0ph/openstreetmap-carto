@placenames: #222;
@placenames-light: #777777;
@farm-text: darken(@farmyard, 50%);

#placenames-medium::high-importance {
  [category = 1][zoom < 14] {
/*    [zoom >= 4][zoom < 5][score >= 3000000],
    [zoom >= 5][zoom < 8][score >= 400000] {
      shield-file: url('symbols/place/place-4.svg');
      shield-text-dx: 4;
      shield-text-dy: 4;
      shield-name: '[name]';
      shield-face-name: @book-fonts;
      shield-fill: @placenames;
      shield-size: 11;
      shield-wrap-width: 30; // 2.7 em
      shield-line-spacing: -1.65; // -0.15 em
      shield-margin: 7.7; // 0.7 em
      shield-halo-fill: @standard-halo-fill;
      shield-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      shield-placement-type: simple;
      shield-placements: 'S,N,E,W';
      [dir = 1] {
        shield-placements: 'N,S,E,W';
      }
      shield-unlock-image: true;

      [zoom >= 5] {
        shield-wrap-width: 45; // 4.1 em
        shield-line-spacing: -1.1; // -0.10 em
      }
      [zoom >= 6] {
        shield-size: 12;
        shield-wrap-width: 60; // 5.0 em
        shield-line-spacing: -0.6; // -0.05 em
        shield-margin: 8.4; // 0.7 em

        shield-file: url('symbols/place/place-6.svg');
        shield-text-dx: 5;
        shield-text-dy: 5;
      }
      [zoom >= 7] {
        shield-file: url('symbols/place/place-6-z7.svg');
      }
    }*/
    [zoom >= 8][score >= 400000] {
      text-name: '[name]';
      text-face-name: @book-fonts;
      text-fill: @placenames;
      text-size: 13;
      text-wrap-width: 65; // 5.0 em
      text-line-spacing: -0.65; // -0.05 em
      text-margin: 9.1; // 0.7 em
      text-halo-fill: @standard-halo-fill;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;

      [zoom >= 10] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.7; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 11] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.75; // -0.05 em
        text-margin: 10.5; // 0.7 em
      }
    }
  }
}

#placenames-medium::medium-importance {
  [category = 1][score < 400000][zoom < 15] {
/*    [zoom >= 6][zoom < 8][score >= 70000],
    [zoom >= 7][zoom < 8] {
      shield-file: url('symbols/place/place-4.svg');
      shield-text-dx: 4;
      shield-text-dy: 4;
      shield-name: "[name]";
      shield-size: 10;
      shield-fill: @placenames;
      shield-face-name: @book-fonts;
      shield-halo-fill: @standard-halo-fill;
      shield-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      shield-wrap-width: 30; // 3.0 em
      shield-line-spacing: -1.5; // -0.15 em
      shield-margin: 7.0; // 0.7 em
      shield-placement-type: simple;
      shield-placements: 'S,N,E,W';
      [dir = 1] {
        shield-placements: 'N,S,E,W';
      }
      shield-unlock-image: true;
      [zoom >= 7] {
        shield-file: url('symbols/place/place-4-z7.svg');
      }
    }*/
    [zoom >= 8] {
      text-name: "[name]";
      text-size: 10;
      text-fill: @placenames;
      text-face-name: @book-fonts;
      text-halo-fill: @standard-halo-fill;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-wrap-width: 40; // 4.0 em
      text-line-spacing: -1.0; // -0.10 em
      text-margin: 7.0; // 0.7 em
      [zoom >= 9] {
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.6; // -0.05 em
        text-margin: 8.4; // 0.7 em
      }
      [zoom >= 10] {
        text-size: 13;
        text-wrap-width: 65; // 5.0 em
        text-line-spacing: -0.65; // -0.05 em
        text-margin: 9.1; // 0.7 em
      }
      [zoom >= 11] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.7; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 13] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.75; // -0.05 em
        text-margin: 10.5; // 0.7 em
		text-halo-radius: @standard-halo-radius * 2.0;
	  }
      [zoom >= 14] {
        text-size: 17;
        text-wrap-width: 85; // 5.0 em
        text-line-spacing: -0.85; // -0.05 em
        text-margin: 11.9; // 0.7 em
      }
    }
  }
}

#placenames-medium::low-importance {
  [category = 2] {
    [zoom >= 9][zoom < 16] {
      text-name: "[name]";
      text-size: 11;
      text-fill: @placenames;
      text-face-name: @book-fonts;
      text-halo-fill: @standard-halo-fill;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-wrap-width: 50; // 4.5 em
      text-line-spacing: -0.88; // -0.08 em
      text-margin: 7.7; // 0.7 em
      [zoom >= 11] {
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.6; // -0.05 em
        text-margin: 7.2; // 0.7 em
      }
      [zoom >= 12] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.70; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 13] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.75; // -0.05 em
        text-margin: 10.5; // 0.7 em
        text-halo-radius: @standard-halo-radius * 2.0;
      }
      [zoom >= 14] {
        text-size: 17;
        text-wrap-width: 85; // 5.0 em
        text-line-spacing: -0.85; // -0.05 em
        text-margin: 11.9; // 0.7 em
      }
    }
  }
}

/*#placenames-small::suburb {
  [place = 'suburb'][zoom >= 12][zoom < 17] {
    text-name: "[name]";
    text-size: 10;
    text-face-name: @book-fonts;
    text-fill: @placenames-light;
    text-halo-fill: white;
    text-halo-radius: @standard-halo-radius;
    text-wrap-width: 50; // 5.0 em
    text-line-spacing: -0.50; // -0.05 em
    text-margin: 7; // 0.7 em
    [zoom >= 13] {
      text-size: 12;
      text-wrap-width: 60; // 5.0 em
      text-line-spacing: -0.60; // -0.05 em
      text-margin: 8.4; // 0.7 em
    }
    [zoom >= 14] {
      text-size: 12;
      text-wrap-width: 60; // 5.0 em
      text-line-spacing: -0.60; // -0.05 em
      text-margin: 8.4; // 0.7 em
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
    }
    [zoom >= 16] {
      text-size: 14;
      text-wrap-width: 70; // 5.0 em
      text-line-spacing: -0.7; // -0.05 em
      text-margin: 9.8; // 0.7 em
    }
  }
}*/

#placenames-small::village {
  [place = 'village'],
  [place = 'suburb'] {
    [zoom >= 12][zoom < 17] {
      text-name: "[name]";
      text-size: 10;
      text-fill: @placenames;
      text-face-name: @book-fonts;
      text-halo-fill: @standard-halo-fill;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-wrap-width: 50; // 5.0 em
      text-line-spacing: -0.50; // -0.05 em
      text-margin: 7.0; // 0.7 em
      [zoom >= 12] {
        text-size: 11;
        text-wrap-width: 55; // 5.0 em
        text-line-spacing: -0.55; // -0.05 em
        text-margin: 7.7; // 0.7 em
      }
      [zoom >= 14] {
        text-size: 13;
		text-fill: @placenames-light;
		text-halo-fill: white;
        text-wrap-width: 65; // 5.0 em
        text-line-spacing: -0.65; // -0.05 em
        text-margin: 9.1; // 0.7 em
      }
      [zoom >= 15] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.70; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
      [zoom >= 16] {
        text-size: 15;
        text-wrap-width: 75; // 5.0 em
        text-line-spacing: -0.75; // -0.05 em
        text-margin: 10.5; // 0.7 em
      }
    }
  }
}

#placenames-small::hamlet {
  [place = 'quarter'] {
    [zoom >= 14][zoom < 17] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @book-fonts;
      text-halo-fill: @standard-halo-fill;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      [zoom >= 14] {
        text-size: 11;
        text-wrap-width: 55; // 5.0 em
        text-line-spacing: -0.55; // -0.05 em
        text-margin: 7.7; // 0.7 em
      }
      [zoom >= 15] {
        text-halo-fill: white;
        text-fill: @placenames-light;
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.60; // -0.05 em
        text-margin: 8.4; // 0.7 em
      }
      [zoom >= 16] {
        text-size: 14;
        text-wrap-width: 70; // 5.0 em
        text-line-spacing: -0.70; // -0.05 em
        text-margin: 9.8; // 0.7 em
      }
    }
  }
  [place = 'hamlet'],
  [place = 'neighbourhood'] {
    [zoom >= 14][zoom < 18] {
      text-name: "[name]";
      text-fill: @placenames;
      text-face-name: @book-fonts;
      text-halo-fill: white;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
	    text-dy: 10;
	    text-dx: 10;
      [zoom >= 14] {
		    text-placement-type: simple;
		    text-placements: "N,S,E,W,NE,SE,NW,SW,10,8";
        text-size: 9;
        text-wrap-width: 55; // 5.0 em
        text-line-spacing: -0.55; // -0.05 em
        text-margin: 7.7; // 0.7 em
      }
      [zoom >= 15] {
        text-size: 11;
        text-fill: @placenames-light;
        text-halo-fill: @standard-halo-fill;
        text-wrap-width: 45; // 4.5 em
        text-line-spacing: -0.8; // -0.08 em
        text-margin: 7.0; // 0.7 em
      }
      [zoom >= 16] {
        text-size: 12;
        text-wrap-width: 60; // 5.0 em
        text-line-spacing: -0.60; // -0.05 em
        text-margin: 8.4; // 0.7 em
        text-fill: @placenames-light;
        text-halo-fill: white;
      }
    }
  }
}

#placenames-small::locality {
//  [place = 'neighbourhood'][zoom >= 15][zoom < 20],
  [place = 'isolated_dwelling'][zoom >= 14],
  [place = 'locality'][zoom >= 14] {
    text-name: "[name]";
    text-size: 8;
    text-fill: @placenames;
    text-face-name: @book-fonts;
    text-halo-fill: @standard-halo-fill;
    text-halo-radius: @standard-halo-radius;
    text-wrap-width: 36; // 4.5 em
    text-line-spacing: -0.65; // -0.08 em
    text-margin: 5.6; // 0.7 em
	  text-placement-type: simple;
	  text-placements: "N,S,E,W,NE,SE,NW,SW";
	  text-dx: 5;
	  text-dy: 5;
    [zoom >= 16] {
      text-size: 10;
      text-wrap-width: 50; // 5.0 em
      text-line-spacing: -0.50; // -0.05 em
      text-margin: 7.0; // 0.7 em
      text-fill: @placenames-light;
      text-halo-fill: white;
    }
  }
  
  //duplicate landuse_farmyard
  [place = 'farm'][zoom >= 14] {
    text-name: "[name]";
	  text-size: 8;
    text-fill: @farm-text;
    text-face-name: @standard-font;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
	  text-wrap-width: 36; // 4.5 em
    text-line-spacing: -0.65; // -0.08 em
	  [zoom >= 16] {
		  text-size: @standard-font-size;
		  text-wrap-width: @standard-wrap-width;
		  text-line-spacing: @standard-line-spacing-size;
	  }  
  }
}


