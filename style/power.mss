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
  [power = 'tower'] {
    [zoom >= 13] {
      marker-file: url('symbols/man_made/power_tower_small.svg');
      marker-width: 3;
    }
    [zoom >= 14] {
      marker-file: url('symbols/man_made/power_tower.svg');
      marker-width: 4;
    }
    [zoom >= 16] {
      marker-width: 7;
    }
  }
  [power = 'pole'] {
//    marker-file: url('symbols/square.svg');
	[zoom >= 14] { marker-width: 2; }
	[zoom >= 16] { marker-width: 3; }
  }
  marker-fill: @power-line-color
}
