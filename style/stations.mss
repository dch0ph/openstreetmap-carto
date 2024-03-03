@station-color: #7981b0;
@station-text: darken(saturate(@station-color, 15%), 10%);

#stations {
  [railway = 'subway_entrance'][zoom >= 18] {
    marker-file: url('symbols/amenity/entrance.svg');
    marker-fill: @transportation-icon;
    marker-clip: false;
    [zoom >= 19] {
      text-name: [ref];
      text-face-name: @book-fonts;
      text-size: 10;
      text-fill: @transportation-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
    }
  }

  [railway = 'station'][zoom >= 11] {
    marker-file: url('symbols/square.svg');
    marker-fill: @station-color;
    marker-clip: false;
    [station != 'subway'] {
      marker-width: 4;
    }
    [zoom >= 12][station != 'subway'],
    [zoom >= 14][station = 'subway'] {
      marker-width: 6;
    }
    [zoom >= 12][station !='subway'],
    [zoom >= 15] {
      text-name: "[name]";
      text-face-name: @bold-fonts;
      text-size: 10;
      text-fill: @station-text;
      text-dy: 8;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 30; // 3 em
      text-line-spacing: -1.5; // -0.15 em
    }
    [zoom >= 14][station != 'subway'],
    [zoom >= 16] {
      marker-width: 9;
      text-size: 12;
      text-wrap-width: 36; // 3 em
      text-line-spacing: -1.8; // -0.15 em
      text-dy: 10;
    }
  }

  [railway = 'halt'] {
    [zoom >= 12] {
      marker-file: url('symbols/square.svg');
      marker-fill: @station-color;
      marker-width: 4;
      marker-clip: false;
      [zoom >= 13] {
        marker-width: 6;
      }
    }
    [zoom >= 13] {
      text-name: "[name]";
      text-face-name: @bold-fonts;
      text-size: @standard-font-size;
      text-fill: @station-text;
      text-dy: 8;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: @standard-wrap-width;
      text-line-spacing: @standard-line-spacing-size;
    }
  }

  [aerialway = 'station']::aerialway {
    [zoom >= 13] {
      marker-file: url('symbols/square.svg');
      marker-fill: @station-color;
      marker-width: 4;
      marker-clip: false;
    }
    [zoom >= 15] {
      marker-width: 6;
    }
    [zoom >= 14] {
      text-name: "[name]";
      text-face-name: @book-fonts;
      text-size: @standard-font-size;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: @standard-wrap-width;
      text-line-spacing: @standard-line-spacing-size;
    }
  }

  [railway = 'tram_stop'] {
    [zoom >= 14] {
      marker-file: url('symbols/square.svg');
      marker-fill: @station-color;
      marker-width: 4;
      marker-clip: false;
      [zoom >= 15] {
        marker-width: 6;
      }
    }
    [zoom >= 16] {
      text-name: "[name]";
      text-face-name: @book-fonts;
      text-size: @standard-font-size;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * @standard-halo-multiplier;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: @standard-wrap-width;
      text-line-spacing: @standard-line-spacing-size;
    }
  }
}
