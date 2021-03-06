! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license
USING: pango alien.syntax alien.c-types
kernel ;
IN: pango.fonts

LIBRARY: pango

FUNCTION: void
pango_font_map_list_families ( PangoFontMap* fontmap, PangoFontFamily*** families, int* n_families ) ;

FUNCTION: char*
pango_font_family_get_name ( PangoFontFamily* family ) ;

FUNCTION: int
pango_font_family_is_monospace ( PangoFontFamily* family ) ;

FUNCTION: void
pango_font_family_list_faces ( PangoFontFamily* family, PangoFontFace*** faces, int* n_faces ) ;

FUNCTION: char*
pango_font_face_get_face_name ( PangoFontFace* face ) ;

FUNCTION: void
pango_font_face_list_sizes ( PangoFontFace* face, int** sizes, int* n_sizes ) ;

: list-families ( PangoFontMap* -- PangoFontFamily*-seq )
    0 <int> 0 <int> [ pango_font_map_list_families ] 2keep
    *int swap *void* [ swap c-void*-array> ] [ g_free ] bi ;

: list-faces ( PangoFontFamily* -- PangoFontFace*-seq )
    0 <int> 0 <int> [ pango_font_family_list_faces ] 2keep
    *int swap *void* [ swap c-void*-array> ] [ g_free ] bi ;

: list-sizes ( PangoFontFace* -- ints )
    0 <int> 0 <int> [ pango_font_face_list_sizes ] 2keep
    *int swap *void* [ swap c-int-array> ] [ g_free ] bi ;

: monospace? ( PangoFontFamily* -- ? )
    pango_font_family_is_monospace 1 = ;
