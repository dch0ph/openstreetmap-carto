/*

3. Fallback fonts:

Hanazono covers almost all CJK characters, even in Unicode Plane 2.
*/

/* Use vendored fonts. This allows for more recent versions and better coverage */
Map {
  font-directory: url('fonts');
}

/*
A regular style.
*/
@book-fonts:    "Gillius ADF Regular",
                "HanaMinA Regular", "HanaMinB Regular";

/*
Bold text is heavier than regular text and can be used for emphasis. Fallback is a regular style.
*/
@bold-fonts:    "Gillius ADF Bold",
                @book-fonts;

/*
Italics are only available for the (Latin-Greek-Cyrillic) base font, not the other scripts.
For a considerable number of labels this style will make no difference to the regular style.
*/
@oblique-fonts: "Gillius ADF Italic", @book-fonts;

/* @monospace-fonts: "Ubuntu Mono Regular"; */

