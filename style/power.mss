@power-line-color: #333;

#power-line {
  [zoom >= 13] {
    line-width: 0.75;
    line-color: @power-line-color;
    [zoom >= 15] {
      line-width: 0.6;
    }
    [zoom >= 16] {
      line-width: 0.7;
    }
    [zoom >= 18] {
      line-width: 1;
    }
    [zoom >= 19] {
      line-width: 1.2;
    }
  }
}

#power-minorline {
  [zoom >= 14] {
    line-width: 0.3;
    line-color: @power-line-color;
    [zoom >= 15] {
      line-width: 0.4;
    }
    [zoom >= 16] {
      line-width: 0.5;
    }
  }
}

#power-towers {
  [power = 'tower'][zoom >= 13] {
   // marker-file: url('symbols/man_made/power_tower_small.svg');
    marker-file: url('symbols/power-tower-compact.svg');
    marker-width: 3;
    [zoom >= 14] {
      marker-width: 4;
    }
    [zoom >= 16] {
      marker-width: 7;
    }
    marker-fill: white;
	marker-line-color: @power-line-color;
  }
  [power = 'pole'][zoom >= 14] {
	marker-width: 2;
	[zoom >= 16] { marker-width: 3; }
    marker-fill: @power-line-color;
  // allow overlap of poles - common for poles for to be close together and odd if one disappears
	marker-allow-overlap: true;
  }
  // indicate poles with transition to cable with pole of twice area
  [power = 'transitionpole'][zoom >= 13] {
	marker-width: 2.8;
	[zoom >= 16] { marker-width: 4.2; }
    marker-fill: @power-line-color;
	marker-allow-overlap: true;
  }
}
