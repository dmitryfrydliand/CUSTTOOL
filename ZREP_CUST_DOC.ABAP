*&---------------------------------------------------------------------*
*& Report ZREP_CUST_DOC
*&---------------------------------------------------------------------*
*& Report generating the customizing documendation
*& from customizing transport request(s) based on the template
*& provided.
*&---------------------- Version History ------------------------------*
*&
*&
*&
*&
*&
*&
*&
*&---------------------------------------------------------------------*

REPORT zrep_cust_doc.





CONSTANTS:

  "   Maximum column quality

  gc_quantity_columns        TYPE i VALUE 10,



  "   POPUP for choosing path and template

  gc_default_file_ext        TYPE string VALUE 'docx' ##NO_TEXT,

  gc_templ_extension         TYPE string VALUE 'dotx' ##NO_TEXT,

  gc_templ_popup_title       TYPE string VALUE 'Select template' ##NO_TEXT,



  "   Define Customizing released and modifieble requests

  gc_all_users               LIKE sy-uname                VALUE '*',

  gc_req_organizer_type      TYPE trwbo_calling_organizer VALUE 'C',

  gc_req_reqfunctions        LIKE trpari-w_longstat       VALUE 'W',

  gc_req_reqstatus           LIKE trpari-w_longstat       VALUE 'RNODL',

  gc_req_taskfunctions       LIKE trpari-w_longstat       VALUE 'QRSX',

  gc_req_taskstatus          LIKE trpari-w_longstat       VALUE 'LDRNO',

  gc_req_freetasks_f         LIKE trpari-w_longstat       VALUE 'QRSX',

  gc_req_freetasks_s         LIKE trpari-w_longstat       VALUE 'LDRNO',



  "   Names of selection screen fields

  gc_sel_screen_input_title  TYPE string VALUE 'Input' ##NO_TEXT,

  gc_sel_screen_output_title TYPE string VALUE 'Output' ##NO_TEXT,

  gc_sel_screen_so_req       TYPE string VALUE 'Transport requests' ##NO_TEXT,

  gc_sel_screen_p_templ      TYPE string VALUE 'Сust. Doc. template' ##NO_TEXT,

  gc_sel_screen_p_path       TYPE string VALUE 'Cust. Doc. result' ##NO_TEXT,

  gc_sel_screen_p_lang       TYPE string VALUE 'Language' ##NO_TEXT,



  gc_default_lang            TYPE spras   VALUE 'E' ##NO_TEXT,

  gc_spro_documentation      TYPE string  VALUE 'SPRO Documentation' ##NO_TEXT.







CLASS zloc_cl_spro_doc_loader DEFINITION

  FINAL

  CREATE PRIVATE .



  PUBLIC SECTION.



    TYPES ty_t_tline TYPE TABLE OF tline.



    TYPES: BEGIN OF ty_s_itf_lines,

             format TYPE tdformat,

             line   TYPE string,

           END OF ty_s_itf_lines.



    TYPES ty_t_itf_lines TYPE TABLE OF ty_s_itf_lines.





    CLASS-METHODS get_instance

      RETURNING

        VALUE(ro_instance) TYPE REF TO zloc_cl_spro_doc_loader .

    METHODS get_documentation

      IMPORTING

        !iv_obj_name      TYPE trobj_name

        !iv_lang          TYPE spras DEFAULT 'E'

      EXPORTING

        !es_head          TYPE thead

        !et_documentation TYPE ty_t_itf_lines.

    METHODS set_tr_request

      IMPORTING

        !ir_transport_req TYPE rseloption .

  PROTECTED SECTION.

  PRIVATE SECTION.



    DATA mv_current_lang TYPE spras .

    DATA mt_tr_request TYPE rseloption .

    CLASS-DATA mo_instance TYPE REF TO zloc_cl_spro_doc_loader .



    METHODS remove_links

      CHANGING

        !ct_documentation TYPE ty_t_itf_lines.

    METHODS get_listalpha

      CHANGING

        !cv_count TYPE sytabix

        !cv_alpha TYPE c .

    METHODS get_list_number

      CHANGING

        !cv_number_count TYPE sytabix

        !cv_number       TYPE c .

    METHODS prepare_itf

      IMPORTING

        !is_header_txt TYPE thead

      CHANGING

        !ct_itf_text   TYPE ty_t_tline .

    METHODS remove_lz_in_tables

      CHANGING

        !ct_lines TYPE ty_t_tline .

    METHODS transform_new_old

      IMPORTING

        !iv_doc_class  TYPE doku_class

        !iv_doc_name   TYPE doku_obj

      CHANGING

        !cv_doc_id     TYPE doku_id

        !cv_doc_object TYPE doku_obj

        !cv_doc_type   TYPE doku_typ .

    METHODS constructor .

ENDCLASS.



CLASS cl_word DEFINITION FINAL.





  PUBLIC SECTION.

    CONSTANTS :

      c_true                         TYPE i VALUE 1,

      c_false                        TYPE i VALUE 0,

* Predefined fields that can be added

      c_field_pagecount              TYPE string VALUE '##FIELD#PAGE##',    " MS Word current page counter

      c_field_pagetotal              TYPE string VALUE '##FIELD#NUMPAGES##', " MS Word total page counter

      c_field_title                  TYPE string VALUE '##FIELD#TITLE##',

      c_field_author                 TYPE string VALUE '##FIELD#AUTHOR##',

      c_field_authorlastmod          TYPE string VALUE '##FIELD#LASTSAVEDBY##',

      c_field_comments               TYPE string VALUE '##FIELD#COMMENTS##',

      c_field_keywords               TYPE string VALUE '##FIELD#KEYWORDS##',

      c_field_category               TYPE string VALUE '##FIELD#DOCPROPERTY CATEGORY##',

      c_field_subject                TYPE string VALUE '##FIELD#SUBJECT##',

      c_field_revision               TYPE string VALUE '##FIELD#REVNUM##',

      c_field_creationdate           TYPE string VALUE '##FIELD#CREATEDATE##',

      c_field_moddate                TYPE string VALUE '##FIELD#SAVEDATE##',

      c_field_todaydate              TYPE string VALUE '##FIELD#DATE##',

      c_field_filename               TYPE string VALUE '##FIELD#FIELNAME##',

* Anchor for label

      c_label_anchor                 TYPE string VALUE '##LABEL##',

* Prefix for SAPWR url

      c_sapwr_prefix(6)              TYPE c VALUE 'SAPWR:',

* Predefined fonts

      c_font_arial                   TYPE string VALUE 'Arial', "#EC NOTEXT

      c_font_times                   TYPE string VALUE 'Times New Roman', "#EC NOTEXT

      c_font_comic                   TYPE string VALUE 'Comic Sans MS', "#EC NOTEXT

      c_font_calibri                 TYPE string VALUE 'Calibri', "#EC NOTEXT

      c_font_cambria                 TYPE string VALUE 'Cambria', "#EC NOTEXT

      c_font_courier                 TYPE string VALUE 'Courier New', "#EC NOTEXT

      c_font_symbol                  TYPE string VALUE 'Wingdings', "#EC NOTEXT

* Predefined Styles

* Regarding your document la  nguage, style could be named differently

* For example, in french ms document, title1 is labelled "Titre1"

      c_style_title                  TYPE string VALUE 'Title', "#EC NOTEXT

      c_style_title1                 TYPE string VALUE 'Title1', "#EC NOTEXT

      c_style_title2                 TYPE string VALUE 'Title2', "#EC NOTEXT

      c_style_title3                 TYPE string VALUE 'Title3', "#EC NOTEXT

      c_style_title4                 TYPE string VALUE 'Title4', "#EC NOTEXT

      c_style_normal                 TYPE string VALUE 'Normal', "#EC NOTEXT

* Predefined break types

      c_breaktype_line               TYPE i VALUE 6,

      c_breaktype_page               TYPE i VALUE 7,

      c_breaktype_column             TYPE i VALUE 1, "NOT MANAGED

      c_breaktype_section            TYPE i VALUE 2,

      c_breaktype_section_continuous TYPE i VALUE 3,

* Predefined symbols

      c_symbol_checkbox_checked      TYPE string VALUE 'ю', "#EC NOTEXT

      c_symbol_checkbox              TYPE string VALUE 'o', "#EC NOTEXT

* Draw objects

      c_draw_image                   TYPE i VALUE 0,

      c_draw_rectangle               TYPE i VALUE 1,

* Text alignment

      c_align_left                   TYPE string VALUE 'left', "#EC NOTEXT

      c_align_center                 TYPE string VALUE 'center', "#EC NOTEXT

      c_align_right                  TYPE string VALUE 'right', "#EC NOTEXT

      c_align_justify                TYPE string VALUE 'both', "#EC NOTEXT

* Vertical alignment

      c_valign_top                   TYPE string VALUE 'top', "#EC NOTEXT

      c_valign_middle                TYPE string VALUE 'center', "#EC NOTEXT

      c_valign_bottom                TYPE string VALUE 'bottom', "#EC NOTEXT

* Types for header/footer

      c_type_header                  TYPE string VALUE 'header', "#EC NOTEXT

      c_type_footer                  TYPE string VALUE 'footer', "#EC NOTEXT

* Style type

      c_type_paragraph               TYPE string VALUE 'paragraph',

      c_type_character               TYPE string VALUE 'character',

      c_type_table                   TYPE string VALUE 'table',

      c_type_numbering               TYPE string VALUE 'numbering',

* Image type

      c_type_image                   TYPE string VALUE 'image',

* Page orientation

      c_orient_landscape             TYPE i VALUE 1, " Landscape

      c_orient_portrait              TYPE i VALUE 0, " Portrait

* Note type

      c_notetype_foot                TYPE i VALUE 1, "foot note

      c_notetype_end                 TYPE i VALUE 2, "end note

* Predefined colors

      c_color_black                  TYPE string VALUE '000000',

      c_color_blue                   TYPE string VALUE '0000FF',

      c_color_turquoise              TYPE string VALUE '00FFFF',

      c_color_brightgreen            TYPE string VALUE '00FF00',

      c_color_pink                   TYPE string VALUE 'FF00FF',

      c_color_red                    TYPE string VALUE 'FF0000',

      c_color_yellow                 TYPE string VALUE 'FFFF00',

      c_color_white                  TYPE string VALUE 'FFFFFF',

      c_color_darkblue               TYPE string VALUE '000080',

      c_color_teal                   TYPE string VALUE '008080',

      c_color_green                  TYPE string VALUE '008000',

      c_color_violet                 TYPE string VALUE '800080',

      c_color_darkred                TYPE string VALUE '800000',

      c_color_darkyellow             TYPE string VALUE '808000',

      c_color_gray                   TYPE string VALUE '808080',

      c_color_lightgray              TYPE string VALUE 'C0C0C0',

* Predefined border style

      c_border_simple                TYPE string VALUE 'single',

      c_border_double                TYPE string VALUE 'double',

      c_border_triple                TYPE string VALUE 'triple',

      c_border_dot                   TYPE string VALUE 'dotted',

      c_border_dash                  TYPE string VALUE 'dashed',

      c_border_wave                  TYPE string VALUE 'wave',

* Predefined font highlight color

      c_highlight_yellow             TYPE string VALUE 'yellow',

      c_highlight_green              TYPE string VALUE 'green',

      c_highlight_cyan               TYPE string VALUE 'cyan',

      c_highlight_magenta            TYPE string VALUE 'magenta',

      c_highlight_blue               TYPE string VALUE 'blue',

      c_highlight_red                TYPE string VALUE 'red',

      c_highlight_darkblue           TYPE string VALUE 'darkBlue',

      c_highlight_darkcyan           TYPE string VALUE 'darkCyan',

      c_highlight_darkgreen          TYPE string VALUE 'darkGreen',

      c_highlight_darkmagenta        TYPE string VALUE 'darkMagenta',

      c_highlight_darkred            TYPE string VALUE 'darkRed',

      c_highlight_darkyellow         TYPE string VALUE 'darkYellow',

      c_highlight_darkgray           TYPE string VALUE 'darkGray',

      c_highlight_lightgray          TYPE string VALUE 'lightGray',

      c_highlight_black              TYPE string VALUE 'black'

      .



    TYPES:

      BEGIN OF ty_border,

* Border width

* Integer: 8 = 1pt

* Default: no border

        width TYPE i,



* Space between border and content

* Integer

* Default: document default

        space TYPE i,



* Border color

* You can use the predefined font color constants or specify any rgb hexa color code

* Default : document default

        color TYPE string,



* Border style

* You can use the predefined border style constants

* Default : document default

        style TYPE string, "border style

      END OF ty_border,



      BEGIN OF ty_character_style_effect,

* Font name to use for the character text fragment

* You can use the predefined font constants

* Default : document default

        font      TYPE string,



* Size of the font in pt

* Default : document default

        size      TYPE i,



* Font color to apply to the character text fragment

* You can use the predefined font color constants or specify any rgb hexa color code

* Default : document default

        color     TYPE string,



* Background color to apply to the character text fragment

* You can use the predefined font color constants or specify any rgb hexa color code

* Default : document default

        bgcolor   TYPE string,



* Highlight color to apply to the character text fragment

* You must use the predefined highlight color constants (limited color choice)

* If you want to use other color, please use bgcolor instead of highlight

* Default : document default

        highlight TYPE string,



* Set character text fragment as bold (boolean)

* You must use predefined true/false constants

* Default : not bold

        bold      TYPE i,



* Set character text fragment as italic (boolean)

* You must use predefined true/false constants

* Default : not italic

        italic    TYPE i,



* Set character text fragment as underline (boolean)

* You must use predefined true/false constants

* Default : not underline

        underline TYPE i,



* Set character text fragment as strike (boolean)

* You must use predefined true/false constants

* Default : not strike

        strike    TYPE i,



* Set character text fragment as exponent (boolean)

* You must use predefined true/false constants

* Default : not exponent

        sup       TYPE i,



* Set character text fragment as subscript (boolean)

* You must use predefined true/false constants

* Default : not subscript

        sub       TYPE i,



* Set character text fragment as upper case (boolean)

* You must use predefined true/false constants

* Default : not upper case

        caps      TYPE i,



* Set character text fragment as small upper case (boolean)

* You must use predefined true/false constants

* Default : not small upper case

        smallcaps TYPE i,



* Letter spacing to apply to the character text fragment

* 0 = normal, +20 = expand 1pt, -20 = condense 1pt

* Default : document default

        spacing   TYPE string,



* Name of the label to use for this text fragment

* Be carefull that if c_label_anchor is not found in text fragment,

* this attribute is ignored

        label     TYPE string,

      END OF ty_character_style_effect,



      BEGIN OF ty_paragraph_style_effect,

* Set alignment for the paragraph (left, right, center, justify)

* Use the predefined alignment constants

* Default : document default

        alignment           TYPE string,



* Set spacing before paragraph to "auto" (boolean)

* Use the predefined true/false constants

* Default : document default

        spacing_before_auto TYPE i, "boolean



* Set spacing before paragraph

* Integer value, 20 = 1pt

* Default : document default

        spacing_before      TYPE string,



* Set spacing after paragraph to "auto" (boolean)

* Use the predefined true/false constants

* Default : document default

        spacing_after_auto  TYPE i, "boolean



* Set spacing after paragraph

* Integer value: 20 = 1pt

* Default : document default

        spacing_after       TYPE string,



* Set interline in paragraph

* Integer value: 240 = normal interline, 120 = multiple x0.5, 480 = multiple x2

* Default : document default

        interline           TYPE i,



* Set left indentation in paragraph

* Integer value: 567 = 1cm

* Default : document default

        leftindent          TYPE string,



* Set right indentation in paragraph

* Integer value: 567 = 1cm

* Default : document default

        rightindent         TYPE string,



* Set left indentation for first line in paragraph

* Integer value: 567 = 1cm. Negative value allowed

* Default : document default

        firstindent         TYPE string,



* Add a breakpage before paragraph (boolean)

* Use the predefined true/false constants

* Default : no breakpage

        break_before        TYPE i,



* Set the hierarchical title level of the paragraph

* 1 for title1, 2 for title2...

* Default : not a hierarchical title

        hierarchy_level     TYPE i,



* Set the left border of the paragraph

* See class type ty_border for details

* Default : No border

        border_left         TYPE ty_border,



* Set the top border of the paragraph

* See class type ty_border for details

* Default : No border

        border_top          TYPE ty_border,



* Set the right border of the paragraph

* See class type ty_border for details

* Default : No border

        border_right        TYPE ty_border,



* Set the bottom border of the paragraph

* See class type ty_border for details

* Default : No border

        border_bottom       TYPE ty_border,



* Background color to apply to the paragraph

* You can use the predefined font color constants or specify any rgb hexa color code

* Default : document default

        bgcolor             TYPE string,

      END OF ty_paragraph_style_effect,



      BEGIN OF ty_list_style,

        type TYPE string,

        name TYPE string,

      END OF ty_list_style,

      ty_list_style_table TYPE STANDARD TABLE OF ty_list_style,

      BEGIN OF ty_list_object,

        id   TYPE string,

        type TYPE string,

        path TYPE string,

      END OF ty_list_object,

      ty_list_object_table TYPE STANDARD TABLE OF ty_list_object,



      BEGIN OF ty_table_style_field,

* Content of the cell

        textline          TYPE string,

* Character style name

        style             TYPE string,

* Direct character style effect

        style_effect      TYPE ty_character_style_effect,

* Paragraph style name

        line_style        TYPE string,

* Direct paragraph style effect

        line_style_effect TYPE ty_paragraph_style_effect,

* Cell background color in hexa RGB

        bgcolor           TYPE string,

* Set vertical alignment for cell

        valign            TYPE string,

* Set number of horizontal cell merged

* Start from 2 to merge the next cell with current

* Next cell will be completely ignored

* 0 or 1 to ignore this parameter

        merge             TYPE i,

* Instead of text, insert an image in the cell

* textline, style, style_effect are ignored

        image_id          TYPE string,

* For complex cell content, insert xml paragraph fragment

* You cannot insert xml fragment that are not in a (or many) paragraph

* textline, style, style_effect, line_style, line_style_effect, image_id are ignored

        xml               TYPE string,

      END OF ty_table_style_field,



      BEGIN OF ty_style_table,

        firstcol TYPE i, "boolean, first col is different

        firstrow TYPE i, "boolean, first row is different

        lastcol  TYPE i, "boolean, last col is different

        lastrow  TYPE i, "boolean, last row is different

        nozebra  TYPE i, "boolean, no line zebra

        novband  TYPE i, "boolean, no column zebra

      END OF ty_style_table.



    METHODS:

*****************************************************************************

* Method constructor

* Constructor method create the word objet and initialize some general data

* - tpl : Empty document to use as a template (docx, dotx, docm, dotm)

*         You could use template in SAPWR instead

*         Use this syntax : SAPWR:<objname>

* - keep_tpl_content:keep the template content as begin of document content

*         (boolean)

*         Default : false

*****************************************************************************

      constructor

        IMPORTING

          tpl              TYPE string OPTIONAL

          keep_tpl_content TYPE i DEFAULT c_false,



*****************************************************************************

* Method write_text

* Write any text fragment

* You can specify which character style apply to this fragment

* You can also specify detailed style effect to apply to this fragment

* - textline  : the text fragment

* - style     : Style name for the text fragment

*               Use only "character" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - style_effect:Detailed style effect to apply to text fragment

*               Check documentation of class type ty_character_style_effect

* - line_style: If filled, close the paragraph and apply given paragraph

*               style. Be carrefull, you must use "internal" name of the

*               style. Generaly, it's the same as external without space

* - virtual   : Get generated XML fragment instead of buffer it into document

*               If you ask this parameter, no xml is written to document

* - invalid_style:Character style name given in importing parameter does not

*               exist in document (boolean)

* - invalid_line_style:Paragraph style name given in importing parameter does

*               not exist in document (boolean)

*****************************************************************************

      write_text

        IMPORTING

          textline           TYPE string

          style              TYPE string OPTIONAL

          style_effect       TYPE ty_character_style_effect OPTIONAL

          line_style         TYPE string OPTIONAL

        EXPORTING

          virtual            TYPE string

          invalid_style      TYPE i

          invalid_line_style TYPE i,



      write_spro_documentation

        IMPORTING

          it_documentation TYPE zloc_cl_spro_doc_loader=>ty_t_itf_lines,



*****************************************************************************

* Method write_line

* Close a paragraph (equivalent to use ENTER in MS Word)

* - style     : Style name for the paragraph

*               Use only "paragraph" style here.

*               you can use predefined style constants

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - style_effect:Detailed style effect to apply to paragraph

*               Check documentation of class type ty_paragraph_style_effect

* - invalid_style:Paragraph style name given in importing parameter does not

*               exist in document (boolean)

* - virtual (input):If filled, given XML fragment is used to write a

*               paragraph instead of buffered XML fragment

* - virtual (output):Get generated XML paragraph instead of buffer it into

*               document

*               If you ask this parameter, no xml is written to document

*****************************************************************************

      write_line

        IMPORTING

          style         TYPE string OPTIONAL

          style_effect  TYPE ty_paragraph_style_effect OPTIONAL

        EXPORTING

          invalid_style TYPE i

        CHANGING

          virtual       TYPE string OPTIONAL,



*****************************************************************************

* Method write_break

* Insert a break

* - breaktype : Define the type of break to insert (line, page, section)

*               Use the predefined breaktype constants

*               Default : linebreak

* - write_line: Close current paragraph (boolean)

*               Default : false for break line, true for other breaks

*****************************************************************************

      write_break

        IMPORTING

          breaktype  TYPE i DEFAULT c_breaktype_line

          write_line TYPE i OPTIONAL,



*****************************************************************************

* Method write_symbol

* Insert a symbol

* - symbol : Define the symbol to insert

*            Use the predefined symbol constants

*****************************************************************************

      write_symbol

        IMPORTING

          symbol TYPE string,



*****************************************************************************

* Method write_table

* Write a MS Word table from an abap table

* - content   : Datatable to write

*               Structure of the table fields can be plain text or like

*               ty_table_style_field

* - style     : Style name to apply to the table

*               Use only "table" style here.

*               You can use predefined style constants

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - style_overwrite:Allow you to redefine some style parameters

*               Structure of the parameter : ty_style_table

*               You can redefine if first/last line/column is different and

*               if there is zebra or vertical band

* - border    : Boolean. If no table style is given, display basic border

*               Default : true

* - tblwidth  : Width of the table

*               9300 correspond to full size for classic portrait page

*               Default : min required width for table content

* - invalid_style:Table style name given in importing parameter does not

*               exist in document (boolean)

*****************************************************************************

      write_table

        IMPORTING

          content         TYPE STANDARD TABLE

          style           TYPE string OPTIONAL

          style_overwrite TYPE ty_style_table OPTIONAL

          border          TYPE i DEFAULT c_true

          tblwidth        TYPE i DEFAULT 0

        EXPORTING

          invalid_style   TYPE i,



*****************************************************************************

      write_table_enh

        IMPORTING

          content    TYPE STANDARD TABLE

          table_name TYPE  ddobjname,

*****************************************************************************



*****************************************************************************

* Method write_headerfooter

* Create a new header footer. You could define where use this new

* header/footer or use it manually with his ID

* - type     : Header or Footer

*              You must use the predefined type constants

*              Default : header

* - textline : Header/footer content

* - usenow_default:Boolean to define if created header/footer is used in

*              current section.

*              Default : true

* - usenow_first:Boolean to define if created header/footer is used in

*              current section (first page).

*              Default : true

* - style    : Character style name

*              Use only "character" style here.

*              Be carrefull, you must use "internal" name of the style

*              Generaly, it's the same as external without space

*              Default : document default

* - style_effect:Detailed style effect to apply

*              Check documentation of class type ty_character_style_effect

* - line_style:Paragraph style name

*              Use only "paragraph" style here.

*              Be carrefull, you must use "internal" name of the style

*              Generaly, it's the same as external without space

*              Default : document default

* - line_style_effect:Detailed style effect to apply

*              Check documentation of class type ty_paragraph_style_effect

* - ID       : ID of the new header/footer

* - invalid_style:Character style name given in importing parameter does not

*              exist in document (boolean)

* - invalid_line_style:Paragraph style name given in importing parameter does

*              not exist in document (boolean)

*****************************************************************************

      write_headerfooter

        IMPORTING

          type               TYPE string DEFAULT c_type_header

          textline           TYPE string

          usenow_default     TYPE i DEFAULT c_true

          usenow_first       TYPE i DEFAULT c_true

          style              TYPE string OPTIONAL

          style_effect       TYPE ty_character_style_effect OPTIONAL

          line_style         TYPE string OPTIONAL

          line_style_effect  TYPE ty_paragraph_style_effect OPTIONAL

        EXPORTING

          id                 TYPE string

          invalid_style      TYPE i

          invalid_line_style TYPE i,



*****************************************************************************

* Method set_title        #### Obsolete method, please use set_properties ###

* Define title for the document

* - title : title of the document

*****************************************************************************

      set_title "obsolete, kept for compatibility

        IMPORTING

          title TYPE string,



*****************************************************************************

* Method write_newpage       #### Obsolete method, please use write_break ###

* Insert a page break

*****************************************************************************

      write_newpage, "obsolete, kept for compatibility



*****************************************************************************

* Method write_toc

* Insert a table of content (list of titles in document) or a table of label

* (list of a given specific label in document [figure, table,...])

* Please note that it is the old word 97-2003 toc object

* - default : Default text displayed instead of TOC content

* - label   : Name of the label to display toc

*             Default : Main document TOC

*****************************************************************************

      write_toc

        IMPORTING

          default TYPE string OPTIONAL

          label   TYPE string OPTIONAL,



*****************************************************************************

* Method write_note

* Insert a note at end of the page (foot note)

* or at end of the document (end note)

* - text      : note to insert.

* - type      : foot note or end note

*               You must use the predefined note type constant

*               Default : foot note

* - style     : Style name for the note

*               Use only "character" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - style_effect:Detailed style effect to apply to the note

*               Check documentation of class type ty_character_style_effect

* - line_style: Style name for the note

*               Use only "paragraph" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - line_style_effect:Detailed style effect to apply to the note

*               Check documentation of class type ty_paragraph_style_effect

* - link_style: Style name for the note link in document

*               Use only "character" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - link_style_effect:Detailed style effect to apply to the note link in document

*               Check documentation of class type ty_character_style_effect

* - invalid_style:Character style name given in importing parameter does not

*              exist in document (boolean)

* - invalid_link_style:Character style name given in importing parameter does

*              not exist in document (boolean)

* - invalid_line_style:Paragraph style name given in importing parameter does

*              not exist in document (boolean)

*****************************************************************************

      write_note

        IMPORTING

          text               TYPE string

          type               TYPE i DEFAULT c_notetype_foot

          style              TYPE string OPTIONAL

          style_effect       TYPE ty_character_style_effect OPTIONAL

          line_style         TYPE string OPTIONAL

          line_style_effect  TYPE ty_paragraph_style_effect OPTIONAL

          link_style         TYPE string OPTIONAL

          link_style_effect  TYPE ty_character_style_effect OPTIONAL

        EXPORTING

          invalid_style      TYPE i

          invalid_link_style TYPE i

          invalid_line_style TYPE i,



*****************************************************************************

* Method write_comment

* Insert a comment at the rigth side of the document

* - text      : comment to insert

* - style     : Style name for the comment

*               Use only "character" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - style_effect:Detailed style effect to apply to the comment

*               Check documentation of class type ty_character_style_effect

* - line_style: Style name for the comment

*               Use only "paragraph" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - line_style_effect:Detailed style effect to apply to the comment

*               Check documentation of class type ty_paragraph_style_effect

* - head_style: Style name for the comment header

*               Use only "character" style here.

*               Be carrefull, you must use "internal" name of the style

*               Generaly, it's the same as external without space

*               Default : document default

* - head_style_effect:Detailed style effect to apply to the comment header

*               Check documentation of class type ty_character_style_effect

* - datum     : Date of the comment

*               Default : Current date

* - uzeit     : Time of the comment

*               Default : Current server time

* - author    : Author name of the comment

*               Default : document author name

* - initials  : Initials of the author

*               Default : author name

* - invalid_style:Character style name given in importing parameter does not

*              exist in document (boolean)

* - invalid_head_style:Character style name given in importing parameter does

*              not exist in document (boolean)

* - invalid_line_style:Paragraph style name given in importing parameter does

*              not exist in document (boolean)

*****************************************************************************

      write_comment

        IMPORTING

          text               TYPE string

          style              TYPE string OPTIONAL

          style_effect       TYPE ty_character_style_effect OPTIONAL

          line_style         TYPE string OPTIONAL

          line_style_effect  TYPE ty_paragraph_style_effect OPTIONAL

          head_style         TYPE string OPTIONAL

          head_style_effect  TYPE ty_character_style_effect OPTIONAL

          datum              TYPE d DEFAULT sy-datum

          uzeit              TYPE t DEFAULT sy-uzeit

          author             TYPE string OPTIONAL

          initials           TYPE string OPTIONAL

        EXPORTING

          invalid_style      TYPE i

          invalid_link_style TYPE i

          invalid_line_style TYPE i,



*****************************************************************************

* Method draw_init

* Initialize draw canvas (the paperboard). All further drawed objects are

* included in this canvas. No one can overflow his size.

* - left    : Left position to start the canvas (in pt)

* - top     : Top position to start the canvas (in pt)

* - width   : Length of the canvas

* - height  : Height of the canvas

* - bgcolor : Background color of the canvas

*             You can use the predefined font color constants

*             or specify any rgb hexa color code

*             Default : transparent

* - bdcolor : Border color of the canvas

*             You can use the predefined font color constants

*             or specify any rgb hexa color code

*             You must specify both bdcolor & bdwidth to have effect applied

*             Default : transparent

* - bdwidth : Border width of the canvas in pt

*             You must specify both bdcolor & bdwidth to have effect applied

*             Default : none

*****************************************************************************

      draw_init

        IMPORTING

          left    TYPE i

          top     TYPE i

          width   TYPE i

          height  TYPE i

          bgcolor TYPE string OPTIONAL

          bdcolor TYPE string OPTIONAL

          bdwidth TYPE f OPTIONAL,



*****************************************************************************

* Method draw

* Draw an object in a canvas (you must create it before with draw_init)

* - object  : Type of object to draw

* - left    : Left position to start the canvas (in pt)

* - top     : Top position to start the canvas (in pt)

* - width   : Length of the canvas

* - height  : Height of the canvas

* - url     : In case of image, url of the picture to load

*             You could use image in SAPWR instead

*             Use this syntax : SAPWR:<objname>

* - bgcolor : Background color of the object

*             You can use the predefined font color constants

*             or specify any rgb hexa color code

*             Default : transparent for image, white for other objects

* - bdcolor : Border color of the object

*             You can use the predefined font color constants

*             or specify any rgb hexa color code

*             You must specify both bdcolor & bdwidth to have effect applied

*             Default : transparent for image, black for other objects

* - bdwidth : Border width of the object in pt

*             You must specify both bdcolor & bdwidth to have effect applied

*             Default : none for image, 1px for other objects

* - invalid_image:Image to insert does not exist (boolean)

* - ID (input): You could give ID of an existing image in document instead of

*             url

* - ID (output): ID of the image in document

*****************************************************************************

      draw

        IMPORTING

          object        TYPE i

          left          TYPE i DEFAULT 0

          top           TYPE i DEFAULT 0

          width         TYPE i DEFAULT 0

          height        TYPE i DEFAULT 0

          url           TYPE string OPTIONAL

          bgcolor       TYPE string OPTIONAL

          bdcolor       TYPE string OPTIONAL

          bdwidth       TYPE f OPTIONAL

        EXPORTING

          invalid_image TYPE i

        CHANGING

          id            TYPE string OPTIONAL,



*****************************************************************************

* Method draw_finalize

* Write all the canvas object in document

* Call this method once you have finished your draw all yours objects.

*****************************************************************************

      draw_finalize,



*****************************************************************************

* Method insert_custom_field

* Insert a custom field link in the document.

* It is not required that the field exist

* - field : Name of the custom field to insert

*****************************************************************************

      insert_custom_field

        IMPORTING

          field TYPE string,



*****************************************************************************

* Method insert_virtual_field

* Insert a temporary anchor in the document

* The objective of this anchor is to write something here later

* It is usefull when you dont have the content when you write this part,

* but you will have before end of the document

* Use replace_virtual_field to replace the anchor by a viewable content

* - field : Name of the anchor to insert

*****************************************************************************

      insert_virtual_field

        IMPORTING

          field TYPE string,



*****************************************************************************

* Method replace_virtual_field

* replace an anchor created with insert_virtual_field

* - field : Name of the anchor to replace

* - value : text content to insert

* - style : Character style name

*           Use only "character" style here.

*           Be carrefull, you must use "internal" name of the style

*           Generaly, it's the same as external without space

*           Default : document default

* - style_effect:Detailed style effect to apply to text fragment

*           Check documentation of class type ty_character_style_effect

* - invalid_style:Character style name given in importing parameter does not

*           exist in document (boolean)

*****************************************************************************

      replace_virtual_field

        IMPORTING

          field         TYPE string

          value         TYPE string

          style_effect  TYPE ty_character_style_effect OPTIONAL

          style         TYPE string OPTIONAL

        EXPORTING

          invalid_style TYPE i,



*****************************************************************************

* Method create_custom_field

* Create a custom field in the document properties and assign a value

* - field : Name of the custom field to create

* - value : text content of the field

*****************************************************************************

      create_custom_field

        IMPORTING

          field TYPE string

          value TYPE string,



*****************************************************************************

* Method create_character_style

* Create a character style in document for further usage

* - output_name : Name of character style displayed in word

* - style_effect: Detailed style effect

*                 Check documentation of class type ty_character_style_effect

* - style_ref   : Define an existing character style as reference

* - name        : Internal name of the created style.

*                 You have to use this name to apply style from now

*                 (output name is only usable in word)

* - invalid_style:Character style name given as reference in importing

*                 parameter does not exist in document (boolean)

*****************************************************************************

      create_character_style

        IMPORTING

          output_name   TYPE string

          style_effect  TYPE ty_character_style_effect

          style_ref     TYPE string OPTIONAL

        EXPORTING

          name          TYPE string

          invalid_style TYPE i,



*****************************************************************************

* Method create_paragraph_style

* Create a paragraph style in document for further usage

* - output_name : Name of paragraph style displayed in word

* - style_effect: Detailed character style effect

*                 Check documentation of class type ty_character_style_effect

* - line_style_effect: Detailed paragraph style effect

*                 Check documentation of class type ty_paragraph_style_effect

* - style_ref   : Define an existing paragraph style as reference

* - name        : Internal name of the created style.

*                 You have to use this name to apply style from now

*                 (output name is only usable in word)

* - invalid_style:Paragraph style name given as reference in importing

*                 parameter does not exist in document (boolean)

*****************************************************************************

      create_paragraph_style

        IMPORTING

          output_name       TYPE string

          style_effect      TYPE ty_character_style_effect

          line_style_effect TYPE ty_paragraph_style_effect

          style_ref         TYPE string OPTIONAL

        EXPORTING

          name              TYPE string

          invalid_style     TYPE i,



*****************************************************************************

* Method insert_image

* Insert an image as paragraph

* - url         : path+name of the image to insert

*                 You could use image in SAPWR instead

*                 Optional only if ID supplied

*                 Use this syntax : SAPWR:<objname>

* - Zoom        : Zoom value to apply to the image

*                 Example : 2 to extend image to 200%, 0.5 to reduce image to 50%

*                 Default : 1

* - Style       : Paragraph style to apply to the image

*                 Use only "paragraph" style here.

*                 Be carrefull, you must use "internal" name of the style

*                 Generaly, it's the same as external without space

*                 Default : document default

* - style_effect: Detailed style effect to apply

*                 Check documentation of class type ty_paragraph_style_effect

* - virtual     : Get generated XML fragment instead of buffer it into document

*                 If you ask this parameter, no xml is written to document

* - invalid_image:Image to insert does not exist (boolean)

* - invalid_style:Paragraph style name given in importing parameter does

*                 not exist in document (boolean)

* - ID (input)  : You could give ID of an existing image in document instead of

*                 url

* - ID (output) : ID of the image in document

*****************************************************************************

      insert_image

        IMPORTING

          url           TYPE string OPTIONAL

          zoom          TYPE f OPTIONAL

          style         TYPE string OPTIONAL

          style_effect  TYPE ty_paragraph_style_effect OPTIONAL

        EXPORTING

          invalid_image TYPE i

          invalid_style TYPE i

          virtual       TYPE string

        CHANGING

          id            TYPE string OPTIONAL,



*****************************************************************************

* Method set_properties

* Define document properties

* - title       : Title of the document

* - author      : Creator of the document

*                 Default : SAP user name (or SAP ID if no name found)

* - description : Description of the document

* - object      : Object of the document

* - category    : Category of the document

* - keywords    : Keywords of the document

* - status      : Status of the document

* - creationdate: Creation date of the document

*                 Default : date of generation

* - creationtime: Creation time of the document

*                 Default : time of generation

* - revision    : Internal revision number

*                 Default : 1

*****************************************************************************

      set_properties

        IMPORTING

          title        TYPE string OPTIONAL

          author       TYPE string OPTIONAL

          description  TYPE string OPTIONAL

          object       TYPE string OPTIONAL

          category     TYPE string OPTIONAL

          keywords     TYPE string OPTIONAL

          status       TYPE string OPTIONAL

          creationdate TYPE d OPTIONAL

          creationtime TYPE t OPTIONAL

          revision     TYPE i OPTIONAL,



*****************************************************************************

* Method set_params

* Define options

* - orientation : set page orientation

*                 you must use predefined orientation constants

*                 Default : portrait

* - border_left : Set the left border of the section

*                 See class type ty_border for details

*                 Default : No border

* - border_top : Set the top border of the section

*                 See class type ty_border for details

*                 Default : No border

* - border_right : Set the right border of the section

*                 See class type ty_border for details

*                 Default : No border

* - border_bottom : Set the bottom border of the section

*                 See class type ty_border for details

*                 Default : No border

*****************************************************************************

      set_params

        IMPORTING

          orientation   TYPE i DEFAULT c_orient_portrait

          border_left   TYPE ty_border OPTIONAL

          border_top    TYPE ty_border OPTIONAL

          border_right  TYPE ty_border OPTIONAL

          border_bottom TYPE ty_border OPTIONAL

          nospellcheck  TYPE i DEFAULT c_false,



*****************************************************************************

* Method save

* Save created document

* - url   : path+name of the saved document

* - local : url is a local path (boolean)

*           Default : true

*****************************************************************************

      save

        IMPORTING

          local TYPE i DEFAULT c_true,



*****************************************************************************

* Method get_docx_file

* Low level method (for advanced user)

* Get the content of the docx

* - xcontent : content of the docx

*****************************************************************************

      get_docx_file

        EXPORTING

          xcontent TYPE xstring,



*****************************************************************************

* Method header_footer_direct_assign

* Low level method (for advanced user)

* Use existing header/footer directly

* You can get header/footer id with method get_list_headerfooter or when

* creating a new header/footer with method write_headerfooter

* - header       : ID of the header to use

* - header_first : ID of the header to use for the first page of the section

* - footer       : ID of the footer to use

* - footer_first : ID of the footer to use for the first page of the section

* - invalid_header:ID of the header given is invalid (boolean)

* - invalid_footer:ID of the footer given is invalid (boolean)

*****************************************************************************

      header_footer_direct_assign

        IMPORTING

          header         TYPE string OPTIONAL

          header_first   TYPE string OPTIONAL

          footer         TYPE string OPTIONAL

          footer_first   TYPE string OPTIONAL

        EXPORTING

          invalid_header TYPE i

          invalid_footer TYPE i,



*****************************************************************************

* Method get_list_style

* Low level method (for advanced user)

* Get list of existing styles

* - style_list : List of styles in current document

*****************************************************************************

      get_list_style

        EXPORTING

          style_list TYPE ty_list_style_table,



*****************************************************************************

* Method get_list_image

* Low level method (for advanced user)

* Get list of existing images

* - image_list : List of images in current document

*****************************************************************************

      get_list_image

        EXPORTING

          image_list TYPE ty_list_object_table,



*****************************************************************************

* Method get_list_headerfooter

* Low level method (for advanced user)

* Get list of existing header / footer

* - headerfooter_list : List of header / footer in current document

*****************************************************************************

      get_list_headerfooter

        EXPORTING

          headerfooter_list TYPE ty_list_object_table,



*****************************************************************************

* Method insert_xml_fragment

* Low level method (for advanced user)

* If some function is missing, you could inject direct xml fragment in the

* current text line with this method.

* Dont forget you will need to use write_line to write this fragment in

* document

* - xml : XML fragment to insert

*****************************************************************************

      insert_xml_fragment

        IMPORTING

          xml TYPE string,



*****************************************************************************

* Method insert_xml

* Low level method (for advanced user)

* If some function is missing, you could inject direct xml in the document

* with this method.

* Current xml fragment stay untouched and could continue to be builded

* - xml : XML code to insert in document

*****************************************************************************

      insert_xml

        IMPORTING

          xml TYPE string.



  PRIVATE SECTION.

    DATA : mw_docxml   TYPE string,

           mw_fragxml  TYPE string,

           mw_imgmaxid TYPE i VALUE 100,

           mo_zip      TYPE REF TO cl_abap_zip,

           BEGIN OF ms_section,

             landscape     TYPE i,

             continuous    TYPE i,

             header_first  TYPE string,

             header        TYPE string,

             footer_first  TYPE string,

             footer        TYPE string,

             border_left   TYPE ty_border,

             border_top    TYPE ty_border,

             border_right  TYPE ty_border,

             border_bottom TYPE ty_border,

           END OF ms_section,

           mw_section_xml     TYPE string,

           mw_tpl_section_xml TYPE string,

           mt_list_style      TYPE ty_list_style_table,

           mt_list_object     TYPE ty_list_object_table,

           mw_author          TYPE string.



    CONSTANTS : c_basesize             TYPE i VALUE 12700,

                c_spro_text_def_size   TYPE i VALUE 12,

                c_spro_text_title_size TYPE i VALUE 13,

                c_spro_text            TYPE i VALUE 14.



    METHODS :

* Prepare the section xml part

      _write_section,



* Read a zip file and return string content

      _get_zip_file

        IMPORTING

          filename TYPE string

        EXPORTING

          content  TYPE string,



* Replace zip file with string content

      _update_zip_file

        IMPORTING

          filename TYPE string

          content  TYPE string,



* Load a file and return xstring content

      _load_file

        IMPORTING

          filename TYPE string

        EXPORTING

          xcontent TYPE xstring,



* Load an image into docx structure. Give ID, image res and extension

      _load_image

        IMPORTING

          url       TYPE string

        EXPORTING

          imgres_x  TYPE i

          imgres_y  TYPE i

          extension TYPE string

        CHANGING

          id        TYPE string,



* Create a foot/end note

      _create_note

        IMPORTING

          text               TYPE string

          type               TYPE i

          style              TYPE string OPTIONAL

          style_effect       TYPE ty_character_style_effect OPTIONAL

          line_style         TYPE string OPTIONAL

          line_style_effect  TYPE ty_paragraph_style_effect OPTIONAL

          link_style         TYPE string OPTIONAL

          link_style_effect  TYPE ty_character_style_effect OPTIONAL

        EXPORTING

          invalid_style      TYPE i

          invalid_line_style TYPE i

          id                 TYPE string,



* Replace xml reserved character by escaped ones

      _protect_string

        IMPORTING

          in  TYPE string

        EXPORTING

          out TYPE string,



* Replace invalid label character by allowed ones

      _protect_label

        IMPORTING

          in  TYPE string

        EXPORTING

          out TYPE string,



* Write character style xml fragment

      _build_character_style

        IMPORTING

          style         TYPE string OPTIONAL

          style_effect  TYPE ty_character_style_effect OPTIONAL

        EXPORTING

          xml           TYPE string

          invalid_style TYPE i,



* Write paragraph style xml fragment

      _build_paragraph_style

        IMPORTING

          style         TYPE string OPTIONAL

          style_effect  TYPE ty_paragraph_style_effect OPTIONAL

        EXPORTING

          xml           TYPE string

          invalid_style TYPE i,



      _get_xml_ns

        EXPORTING

          xml TYPE string.



ENDCLASS.                    "cl_word DEFINITION



CLASS zloc_cl_req_loader  DEFINITION  FINAL.



  PUBLIC SECTION.

    TYPE-POOLS abap .



    TYPES:

      BEGIN OF ty_e071,

        obj_name TYPE e071-obj_name,

        trkorr   TYPE e071-trkorr,

        activity TYPE e071-activity,

        used     TYPE abap_bool.

    TYPES: END OF ty_e071 .

    TYPES:

      ty_t_e071 TYPE STANDARD TABLE OF ty_e071 .

    TYPES:

      BEGIN OF ty_e071k,

        trkorr     TYPE e071k-trkorr,

        activity   TYPE e071k-activity,

        mastername TYPE e071k-mastername,

        viewname   TYPE e071k-viewname,

        objname    TYPE e071k-objname,

        tabkey     TYPE e071k-tabkey.

    TYPES:   END OF ty_e071k .

    TYPES:

      ty_t_e071k TYPE STANDARD TABLE OF ty_e071k .



    METHODS:



      constructor

        IMPORTING

          io_doc TYPE REF TO cl_word,





      add_object_to_doc

        IMPORTING

          iv_obj_name TYPE trobj_name

          iv_obj_type TYPE trobjtype.



  PROTECTED SECTION.

  PRIVATE SECTION.



    METHODS eject_inf_about_cdat

      IMPORTING

        iv_obj_type TYPE trobjtype.



    METHODS eject_inf_about_tdat

      IMPORTING

        iv_obj_type TYPE trobjtype.



    METHODS eject_inf_about_vdat

      IMPORTING

        iv_obj_type TYPE trobjtype.



    CLASS-METHODS init_plugin

      IMPORTING

        !iv_pgmid      TYPE e071-pgmid DEFAULT 'R3TR'

        !iv_object     TYPE e071-object DEFAULT 'TABU'

        !iv_mastertype TYPE e071-object OPTIONAL

      EXPORTING

        !et_e071       TYPE ty_t_e071

        !et_e071k      TYPE ty_t_e071k.



    CLASS-DATA mo_doc TYPE REF TO cl_word.

    CLASS-DATA t_e071 TYPE ty_t_e071.

    CLASS-DATA t_e071k TYPE ty_t_e071k .

    CLASS-DATA objname TYPE string.

ENDCLASS.



TABLES: sscrfields, e071, e07t.



TYPES: BEGIN OF t_plugin,

         object TYPE ko100-object,

         text   TYPE ko100-text,

       END OF t_plugin.



TYPES: BEGIN OF t_objecttable,

         classname TYPE string,

         object    TYPE ko100-object,

         text      TYPE ko100-text,

       END OF t_objecttable.



TYPES: BEGIN OF t_nuggetobject,

         objtype TYPE string,

         objname TYPE string,

         exists  TYPE flag,

       END OF t_nuggetobject.

*addition of package data

****   Read all objects of the package

TYPES: BEGIN OF t_objects_package,

         select     TYPE char1,

         object     TYPE tadir-object,

         object_txt TYPE string,

         obj_name   TYPE tadir-obj_name,

         srcsystem  TYPE tadir-srcsystem,

         down_flag  TYPE char1,

         status     TYPE char1,

         msg        TYPE string,

       END OF t_objects_package.





DATA tabletypeline TYPE ko105.

DATA tabletypesin TYPE TABLE OF ko105.

DATA tabletypesout TYPE tr_object_texts.

DATA tabletypeoutline TYPE ko100.

DATA lt_fieldcat  TYPE          slis_t_fieldcat_alv.

DATA ls_fieldcat  LIKE LINE OF  lt_fieldcat.

DATA ls_layout    TYPE          slis_layout_alv.

DATA lv_count TYPE i.

DATA lv_pers  TYPE i.



DATA: gv_url       TYPE string,

      gv_file_name TYPE string,

      gv_full_path TYPE string.



TABLES: rlgrap.



DATA: ld_filename TYPE string,

      ld_path     TYPE string,

      ld_fullpath TYPE string,

      ld_result   TYPE i.



*end of data addition for packages

*addition of Transport data

TYPES: BEGIN OF t_requestobject,

         object   TYPE e071-object,

         obj_name TYPE e071-obj_name,

       END OF t_requestobject.





TYPES: tt_requestobject TYPE TABLE OF t_requestobject.



DATA it_requestobject TYPE TABLE OF t_requestobject.

DATA wa_requestobject TYPE t_requestobject.



*end of data addition for transport



DATA pluginline TYPE t_plugin.

DATA pluginlist TYPE TABLE OF t_plugin.

DATA hidid(3) TYPE c.

DATA currenttab TYPE string.

DATA isslinkee(1) TYPE c VALUE ' '.

DATA objecttable TYPE TABLE OF t_objecttable.

DATA objectline TYPE t_objecttable.

DATA _objname TYPE string.

DATA _objtype TYPE string.

DATA errormsg TYPE string.

DATA statusmsg TYPE string.

DATA _pluginexists TYPE flag.

DATA _objectexists TYPE flag.

DATA _flag TYPE flag.





DATA deffilename TYPE string.

DATA retfilename TYPE string.

DATA retpath TYPE string.

DATA retfullpath TYPE string.

DATA retuseract TYPE i.

DATA retfiletable TYPE filetable.

DATA retrc TYPE sysubrc.

DATA retuseraction TYPE i.





DATA stemp TYPE string.



DATA foo TYPE REF TO data.

DATA len TYPE i.



DATA: l_marker       TYPE i,

      l_offset       TYPE i,

      l_total_offset TYPE i.



DATA:

  es_selected_request TYPE trwbo_request_header,

  es_selected_task    TYPE trwbo_request_header,

  iv_organizer_type   TYPE trwbo_calling_organizer,

  is_selection        TYPE trwbo_selection.



DATA: lcl_docx       TYPE REF TO cl_word,

      lcl_req_loader TYPE REF TO zloc_cl_req_loader.



SELECTION-SCREEN BEGIN OF BLOCK sb_input WITH FRAME TITLE sb_name1.



SELECT-OPTIONS  s_req FOR e071-trkorr NO INTERVALS MODIF ID rnm OBLIGATORY.

PARAMETERS      p_templ TYPE string OBLIGATORY LOWER CASE.

PARAMETERS      p_lang  TYPE spras DEFAULT gc_default_lang OBLIGATORY.



SELECTION-SCREEN END OF BLOCK sb_input.



SELECTION-SCREEN BEGIN OF BLOCK sb_output WITH FRAME TITLE sb_name2.



PARAMETERS      p_path  TYPE string LOWER CASE OBLIGATORY.



SELECTION-SCREEN END OF BLOCK sb_output.





DATA: lv_str      TYPE string,

      lv_tmstmp   TYPE string,

      lv_docname  TYPE string,

      lv_path     TYPE string,

      lv_docxsave TYPE string.

*      lv_nugfile TYPE c.



*/----------------------selection screen events-----------------------\

INITIALIZATION.



  sb_name1 = gc_sel_screen_input_title.

  sb_name2 = gc_sel_screen_output_title.

  %_s_req_%_app_%-text = gc_sel_screen_so_req.

  %_p_templ_%_app_%-text = gc_sel_screen_p_templ.

  %_p_path_%_app_%-text = gc_sel_screen_p_path.

  %_p_lang_%_app_%-text = gc_sel_screen_p_lang.





AT SELECTION-SCREEN OUTPUT.

  gv_full_path = p_path.





AT SELECTION-SCREEN ON p_templ.

  DATA lv_correct_path TYPE abap_bool.

  CLEAR: lv_correct_path.



  cl_gui_frontend_services=>file_exist(

    EXPORTING

      file                 =     p_templ

    RECEIVING

      result               =     lv_correct_path " Result

    EXCEPTIONS

      cntl_error           = 1

      error_no_gui         = 2

      wrong_parameter      = 3

      not_supported_by_gui = 4

      OTHERS               = 5 ).

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.



  IF lv_correct_path <> abap_true.

    MESSAGE i208(00) WITH 'Specify the correct template'  ##NO_TEXT.

    STOP.

  ENDIF.







AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.



  cl_gui_frontend_services=>file_save_dialog(

 EXPORTING

   default_extension = gc_default_file_ext

   CHANGING

     filename                  = gv_file_name  " File Name to Save

     path                      = gv_url   " Path to File

     fullpath                  = gv_full_path   " Path + File Name

         EXCEPTIONS

      cntl_error                = 1

      error_no_gui              = 2

      not_supported_by_gui      = 3

      invalid_default_file_name = 4

      OTHERS                    = 5

     ).

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.



  p_path = gv_full_path.











AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_templ.



  DATA: it_tab   TYPE filetable,

        lv_subrc TYPE i.



  cl_gui_frontend_services=>file_open_dialog(

    EXPORTING

      window_title            =  gc_templ_popup_title  " Title Of File Open Dialog

      file_filter             =  gc_templ_extension   " Default Extension

      multiselection          =   abap_false  " Multiple selections poss.

    CHANGING

      file_table              =   it_tab  " Table Holding Selected Files

      rc                      =   lv_subrc  " Return Code, Number of Files or -1 If Error Occurred

).



  IF it_tab[] IS NOT INITIAL.

    p_templ = it_tab[ 1 ]-filename.

  ENDIF.

















AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_req-low.

  iv_organizer_type = 'C'.





  is_selection-reqfunctions = gc_req_reqfunctions.

  is_selection-reqstatus = gc_req_reqstatus.

  is_selection-taskfunctions = gc_req_taskfunctions.

  is_selection-taskstatus = gc_req_taskstatus.

  is_selection-connect_req_task_conditions = abap_true.

  is_selection-singletasks = abap_true.

  is_selection-freetasks_f = gc_req_freetasks_f.

  is_selection-freetasks_s = gc_req_freetasks_s.



  CALL FUNCTION 'TR_PRESENT_REQUESTS_SEL_POPUP'
    EXPORTING
      iv_username         = gc_all_users
      iv_organizer_type   = iv_organizer_type
      is_selection        = is_selection
    IMPORTING
      es_selected_request = es_selected_request
      es_selected_task    = es_selected_task.



  s_req-low = es_selected_request-trkorr.



*/----------------------main------------------------------------------\



START-OF-SELECTION.



  RANGES:

          ra_obj_type FOR e071-object.



  DATA: wa_trkorr        TYPE e070-trkorr,

        it_trkorr        TYPE TABLE OF e070-trkorr,

        lt_sel_opt_table TYPE rseloption,

        wa_reqnugg       TYPE rsdsselopt,

        wa_obj_type      LIKE LINE OF ra_obj_type.





  CREATE OBJECT lcl_docx
    EXPORTING
      tpl              = p_templ
      keep_tpl_content = cl_word=>c_true.



  CREATE OBJECT lcl_req_loader
    EXPORTING
      io_doc = lcl_docx.



  DATA lo_spro_doc_loader TYPE REF TO zloc_cl_spro_doc_loader.



  lo_spro_doc_loader = zloc_cl_spro_doc_loader=>get_instance( ).







  CLEAR: errormsg, statusmsg.



  DATA: reqname TYPE string.



  DATA: l_trkorr  TYPE e07t-trkorr,

        l_as4text TYPE e07t-as4text.



  SELECT SINGLE trkorr FROM e070 INTO l_trkorr

    WHERE trkorr IN s_req.



  IF sy-subrc <> 0.

    MESSAGE s208(00) WITH 'Transport not found' ##NO_TEXT.

    RETURN.

  ENDIF.



  SELECT SINGLE trkorr as4text

  FROM  e07t

  INTO (l_trkorr, l_as4text)

  WHERE  trkorr   IN s_req

    AND  langu    EQ sy-langu.



*     ewH-->retrieve tasks as well as transports



  SELECT trkorr FROM e070 INTO TABLE it_trkorr

    WHERE strkorr IN s_req.



  lt_sel_opt_table[] = s_req[].



  LOOP AT it_trkorr INTO wa_trkorr.

    wa_reqnugg-sign = 'I'.

    wa_reqnugg-option = 'EQ'.

    wa_reqnugg-low = wa_trkorr.

    APPEND wa_reqnugg TO lt_sel_opt_table.

  ENDLOOP.

*     <--ewH



  wa_obj_type-sign = 'I'.

  wa_obj_type-option = 'EQ'.

  wa_obj_type-low = 'CDAT'.

  APPEND wa_obj_type TO ra_obj_type.



  wa_obj_type-sign = 'I'.

  wa_obj_type-option = 'EQ'.

  wa_obj_type-low = 'VDAT'.

  APPEND wa_obj_type TO ra_obj_type.



  wa_obj_type-sign = 'I'.

  wa_obj_type-option = 'EQ'.

  wa_obj_type-low = 'TDAT'.

  APPEND wa_obj_type TO ra_obj_type.







  SELECT object obj_name

  FROM  e071

  INTO TABLE it_requestobject

*      WHERE  TRKORR in s_req.

  WHERE  trkorr IN lt_sel_opt_table "ewH

     AND pgmid = 'R3TR'

     AND object IN ra_obj_type. "ewH: don't need subobjects



  IF sy-subrc = 0.

    reqname = l_trkorr.

  ELSE.

    MESSAGE s208(00) WITH 'No R3TR objects in request' ##NO_TEXT.

    EXIT.

  ENDIF.

  lo_spro_doc_loader->set_tr_request( ir_transport_req = lt_sel_opt_table ).



  LOOP AT it_requestobject ASSIGNING FIELD-SYMBOL(<obj>).



    lcl_req_loader->add_object_to_doc(

      EXPORTING

        iv_obj_name = <obj>-obj_name

        iv_obj_type = <obj>-object

    ).





  ENDLOOP.



  lcl_docx->save( ).



















CLASS zloc_cl_spro_doc_loader IMPLEMENTATION.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->CONSTRUCTOR

* +-------------------------------------------------------------------------------------------------+

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD constructor.

  ENDMETHOD.







  METHOD remove_links.



    DATA: lv_start TYPE i,

          lv_end   TYPE i.





    LOOP AT ct_documentation ASSIGNING FIELD-SYMBOL(<fs_line>).

      DO.

        FIND FIRST OCCURRENCE OF '<' IN <fs_line>-line MATCH OFFSET lv_start.

        IF sy-subrc <> 0.

          EXIT.

        ENDIF.

        FIND FIRST OCCURRENCE OF '>' IN <fs_line>-line+lv_start MATCH OFFSET lv_end.

        IF sy-subrc <> 0.

          EXIT.

        ENDIF.



        lv_end = lv_end + lv_start.

        DATA(lv_len) = lv_end - lv_start + 1.



        DATA(lv_str_del) = <fs_line>-line+lv_start(lv_len).

        REPLACE lv_str_del INTO <fs_line>-line WITH ''.

      ENDDO.

    ENDLOOP.



  ENDMETHOD.







* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Public Method zloc_cl_spro_doc_loader->GET_DOCUMENTATION

* +-------------------------------------------------------------------------------------------------+

* | [--->] IV_OBJ_NAME                    TYPE        TROBJ_NAME

* | [--->] IV_LANG                        TYPE        SPRAS (default ='E')

* | [<---] ET_DOCUMENTATION               TYPE        TY_T_TLINE

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD get_documentation.

    mv_current_lang = iv_lang.



    SELECT SINGLE  e071~activity

       FROM e071

       INTO @DATA(lv_activity)

      WHERE e071~obj_name = @iv_obj_name AND e071~trkorr IN @mt_tr_request.



    IF lv_activity = '' OR sy-subrc <> 0.

      RETURN.

    ENDIF.



    SELECT SINGLE cus_imgach~docu_id

      FROM cus_imgach

      INTO @DATA(lv_docu_id)

      WHERE cus_imgach~activity = @lv_activity.



    IF lv_docu_id = '' OR sy-subrc <> 0.

      RETURN.

    ENDIF.



    DATA(lv_doc_class) = lv_docu_id(4).

    DATA lt_itf_documentation TYPE ty_t_tline.

    DATA lv_id TYPE dokhl-id.

    DATA lv_type TYPE dokhl-typ.

    DATA object TYPE doku_obj.





    me->transform_new_old(

      EXPORTING

        iv_doc_class  = lv_doc_class   " Hypertext: Object Class

        iv_doc_name   = lv_docu_id    " Documentation Object

      CHANGING

        cv_doc_id     = lv_id    " Document class

        cv_doc_object = object    " Documentation Object

        cv_doc_type   = lv_type  " Documentation type

    ).



    IF lv_doc_class NE 'TITL'.



      lv_type = 'X'.

      CALL FUNCTION 'DOCU_EXIST_CHECK'
        EXPORTING
          id       = lv_id
          object   = object
          langu    = mv_current_lang
          typ      = 'M'
        EXCEPTIONS
          ret_code = 1.

      IF sy-subrc EQ 0.

        lv_type = 'M'.

      ELSE.



        CALL FUNCTION 'DOCU_EXIST_CHECK'
          EXPORTING
            id       = lv_id
            object   = object
            langu    = mv_current_lang
            typ      = 'E'
          EXCEPTIONS
            ret_code = 1.

        IF sy-subrc EQ 0 AND lv_id <> 'FU'.

          lv_type = 'E'.

        ELSE.



          CALL FUNCTION 'DOCU_EXIST_CHECK'
            EXPORTING
              id       = lv_id
              object   = object
              langu    = mv_current_lang
              typ      = 'T'
            EXCEPTIONS
              ret_code = 1.

          IF sy-subrc = 0.

            lv_type = 'T'.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.







    DATA ls_xdokil TYPE dokil.



    CALL FUNCTION 'DOCU_INIT'
      EXPORTING
        id     = lv_id
        langu  = mv_current_lang
        object = object
        typ    = lv_type
      IMPORTING
*       FOUND  =
        xdokil = ls_xdokil.





    DATA lv_doktitle TYPE dsyst-doktitle.

    DATA ls_head TYPE thead.

*    DATA lt_line        TYPE TABLE OF tline.



    CALL FUNCTION 'DOCU_READ'
      EXPORTING
        id      = ls_xdokil-id
        langu   = ls_xdokil-langu
        object  = ls_xdokil-object
        typ     = ls_xdokil-typ
        version = ls_xdokil-version
*       SUPPRESS_TEMPLATE       = ' '
*       USE_NOTE_TEMPLATE       = ' '
      IMPORTING
        head    = ls_head
      TABLES
        line    = lt_itf_documentation.



    CALL FUNCTION 'DOCU_GET_SHORTTEXT'
      EXPORTING
        langu    = mv_current_lang
        id       = lv_id
        object   = object
      IMPORTING
        shorttxt = lv_doktitle.



    CALL FUNCTION 'DOCU_UNUSED_TEMPLATE_DELETE'
      TABLES
        txtlines = lt_itf_documentation.



    DATA ls_line LIKE LINE OF lt_itf_documentation.



    IF lv_doktitle NE space AND lv_id NE 'IN'.

      ls_line-tdformat = 'U1'.

      ls_line-tdline   = lv_doktitle.

      INSERT ls_line INTO lt_itf_documentation  INDEX 1.

    ENDIF.



    me->remove_lz_in_tables(

      CHANGING

        ct_lines = lt_itf_documentation

    ).



    me->prepare_itf(

      EXPORTING

        is_header_txt =  ls_head   " SAPscript: Text Header

      CHANGING

        ct_itf_text   = lt_itf_documentation

    ).



    DATA: ls_doc_paragraph    TYPE LINE OF ty_t_itf_lines.





    CLEAR et_documentation.



    LOOP AT lt_itf_documentation ASSIGNING FIELD-SYMBOL(<fs_line>).

      CASE <fs_line>-tdformat.

        WHEN '' OR '='.

*          REPLACE ALL OCCURRENCES OF REGEX '<*>' IN <fs_line>-tdline WITH ''.

          CONDENSE ls_doc_paragraph-line.



          CONCATENATE ls_doc_paragraph-line ' ' <fs_line>-tdline

          INTO ls_doc_paragraph-line RESPECTING BLANKS.

          CONDENSE ls_doc_paragraph-line.



        WHEN '=21'.



        WHEN OTHERS.

          IF ls_doc_paragraph-line <> '' AND ls_doc_paragraph-format <> '/:'.

            APPEND ls_doc_paragraph TO et_documentation.

          ENDIF.

          ls_doc_paragraph-line = <fs_line>-tdline.

          ls_doc_paragraph-format = <fs_line>-tdformat.



      ENDCASE.



    ENDLOOP.

    IF ls_doc_paragraph-line <> '' AND ls_doc_paragraph-format <> '/:'.

      APPEND ls_doc_paragraph TO et_documentation.

    ENDIF.

    remove_links( CHANGING ct_documentation = et_documentation ).





    es_head = ls_head.

  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Static Public Method zloc_cl_spro_doc_loader=>GET_INSTANCE

* +-------------------------------------------------------------------------------------------------+

* | [<-()] RO_INSTANCE                    TYPE REF TO zloc_cl_spro_doc_loader

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD get_instance.

    IF mo_instance IS NOT BOUND.

      mo_instance = NEW #( ).

    ENDIF.



    ro_instance = mo_instance.



  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->GET_LISTALPHA

* +-------------------------------------------------------------------------------------------------+

* | [<-->] CV_COUNT                       TYPE        SYTABIX

* | [<-->] CV_ALPHA                       TYPE        C

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD get_listalpha.



    DATA form_number(4) TYPE c.



    IF cv_count EQ 1.

      MOVE 'a),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 2.

      MOVE 'b),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 3.

      MOVE 'c),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 4.

      MOVE 'd),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 5.

      MOVE 'e),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 6.

      MOVE 'f),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 7.

      MOVE 'g),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 8.

      MOVE 'h),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 9.

      MOVE 'i),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 10.

      MOVE 'j),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 11.

      MOVE 'k),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 12.

      MOVE 'l),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 13.

      MOVE 'm),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 14.

      MOVE 'n),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 15.

      MOVE 'o),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 16.

      MOVE 'p),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 17.

      MOVE 'q),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 18.

      MOVE 'r),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 19.

      MOVE 's),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 20.

      MOVE 't),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 21.

      MOVE 'u),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 22.

      MOVE 'v),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 23.

      MOVE 'w),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 24.

      MOVE 'x),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 25.

      MOVE 'y),,' TO form_number.                           "#EC NOTEXT

    ELSEIF cv_count EQ 26.

      MOVE 'z),,' TO form_number.                           "#EC NOTEXT

    ENDIF.

    MOVE form_number TO cv_alpha.

  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->GET_LIST_NUMBER

* +-------------------------------------------------------------------------------------------------+

* | [<-->] CV_NUMBER_COUNT                TYPE        SYTABIX

* | [<-->] CV_NUMBER                      TYPE        C

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD get_list_number.



    DATA form_counter LIKE sy-tabix.

    DATA: form_number(13) TYPE c,

          lv_length       TYPE i.



    MOVE cv_number_count TO form_counter.

    MOVE form_counter TO form_number.



    DO.

      IF form_number(1) EQ space OR form_number(1) EQ '0'.

        SHIFT form_number LEFT BY 1 PLACES.

      ELSE.

        EXIT.

      ENDIF.

    ENDDO.

    lv_length = strlen( form_number ).

    MOVE '.,,' TO form_number+lv_length(3).

    CONDENSE form_number NO-GAPS.

    MOVE form_number TO cv_number.



  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->PREPARE_ITF

* +-------------------------------------------------------------------------------------------------+

* | [--->] IS_HEADER_TXT                  TYPE        THEAD

* | [<-->] CT_ITF_TEXT                    TYPE        TY_T_TLINE

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD prepare_itf.

    DATA  text_tab_temp TYPE ty_t_tline.

    DATA alpha_count  LIKE sy-tabix.

    DATA number_count LIKE sy-tabix.

    DATA: number(13) TYPE c, "sy-tabix = 10 + 3 for '.,,'

          lv_length  TYPE i.

    DATA alpha(4)  TYPE c.

    DATA form_id         TYPE dokhl-id.

    DATA  form_head TYPE thead.

* interface of text_include_replace

    DATA: form_changed(1).                                  "#EC NEEDED

    DATA: form_error_type LIKE sy-tabix.                    "#EC NEEDED

    DATA wa_text_tab_temp TYPE tline.

    DATA tabix TYPE sy-tabix.



*

    text_tab_temp[] = ct_itf_text[].

    CLEAR ct_itf_text[].

*

* Resolve all includes

*

* create header for documentation

    CLEAR form_head.

*

    form_head = is_header_txt.

*

* get the includes

*

    CALL FUNCTION 'TEXT_INCLUDE_REPLACE'
      EXPORTING
        all_level  = 'X'
        endline    = 99999
        header     = form_head
        startline  = 1
*       PROGRAM    = ' '
      IMPORTING
        changed    = form_changed
        error_type = form_error_type
        newheader  = form_head
      TABLES
        lines      = text_tab_temp.



    LOOP AT text_tab_temp ASSIGNING FIELD-SYMBOL(<fs_line>) WHERE tdline = 'STYLE *'.

      tabix = sy-tabix.

      MOVE-CORRESPONDING <fs_line> TO wa_text_tab_temp.

      DELETE text_tab_temp INDEX tabix.

    ENDLOOP.



    CALL FUNCTION 'DOCU_UNUSED_TEMPLATE_DELETE'
      TABLES
        txtlines = text_tab_temp.

    IF wa_text_tab_temp IS NOT INITIAL.

      APPEND wa_text_tab_temp TO text_tab_temp.

    ENDIF.



* set symbol DEVICE to SCREEN. This is necessary to avoid, that

* lines between IF DEVICE = 'SCREEN' statements are removed

    CALL FUNCTION 'TEXT_SYMBOL_SETVALUE'
      EXPORTING
        name   = 'DEVICE'
        value  = 'SCREEN'
      EXCEPTIONS
        OTHERS = 0.                                           "BCEK02873



    CALL FUNCTION 'TEXT_CONTROL_REPLACE'
      EXPORTING
        header = form_head
      TABLES
        lines  = text_tab_temp
      EXCEPTIONS
        OTHERS = 0.                                           "BCEK02873

*

    LOOP AT text_tab_temp ASSIGNING <fs_line>.

*   check numbering

      IF <fs_line>-tdformat EQ 'B1'.

        CLEAR alpha_count.

      ELSEIF <fs_line>-tdformat EQ 'N1'.

        ADD 1 TO number_count.

        me->get_list_number(

          CHANGING

            cv_number_count =  number_count   " Row Index of Internal Tables

            cv_number       = number

        ).

        MOVE 'X1' TO <fs_line>-tdformat.

        lv_length = strlen( number ).

        IF lv_length > 0.

          SHIFT <fs_line>-tdline RIGHT BY lv_length PLACES.

          MOVE number TO <fs_line>-tdline(lv_length).

        ENDIF.

        CLEAR alpha_count.

      ELSEIF <fs_line>-tdformat EQ 'N2'.

        ADD 1 TO alpha_count.



        me->get_listalpha(

          CHANGING

            cv_count = alpha_count    " Row Index of Internal Tables

            cv_alpha = alpha

        ).



        MOVE 'X2' TO <fs_line>-tdformat.

        SHIFT <fs_line>-tdline RIGHT BY 4 PLACES.

        MOVE alpha TO <fs_line>-tdline(4).

      ELSEIF <fs_line>-tdformat NE 'B1'

         AND <fs_line>-tdformat NE 'UT'

         AND <fs_line>-tdformat NE '= '

         AND <fs_line>-tdformat NE 'B2'

         AND <fs_line>-tdformat NE 'N1'

         AND <fs_line>-tdformat NE 'N2'

         AND <fs_line>-tdformat NE 'AL'

         AND <fs_line>-tdformat NE 'BL'

         AND <fs_line>-tdformat NE 'K1'

         AND <fs_line>-tdformat NE 'K2'

         AND <fs_line>-tdformat NE 'K3'

         AND <fs_line>-tdformat NE 'K4'

         AND <fs_line>-tdformat NE 'K5'

         AND <fs_line>-tdformat NE 'K6'

         AND <fs_line>-tdformat NE 'T1'

         AND <fs_line>-tdformat NE 'T2'

         AND <fs_line>-tdformat NE 'T3'

         AND <fs_line>-tdformat NE 'T4'

         AND <fs_line>-tdformat NE 'T5'

         AND <fs_line>-tdformat NE 'T6'

         AND <fs_line>-tdformat NE '/ '

         AND <fs_line>-tdformat NE '/('

         AND <fs_line>-tdformat NE '/:'

         AND <fs_line>-tdformat NE 'LA'

         AND <fs_line>-tdformat NE 'LZ'

         AND <fs_line>-tdformat NE 'TX'

         AND <fs_line>-tdformat NE 'AS'   "JT 270899-002

         AND <fs_line>-tdformat NE 'PE'   "JT 270899-002

         AND <fs_line>-tdformat NE space

         AND <fs_line>-tdformat NE '* '

         AND <fs_line>-tdformat NE '/*'

         AND ( form_head-tdobject EQ 'HWR3'    "for SCN

               AND (

               <fs_line>-tdformat NE 'NY' AND

               <fs_line>-tdformat NE 'NZ' AND

               <fs_line>-tdformat NE 'E1' AND

               <fs_line>-tdformat NE 'E2' AND

               <fs_line>-tdformat NE 'SS' AND

               <fs_line>-tdformat NE 'G1' ) ).

        CLEAR number_count.

        CLEAR alpha_count.

      ELSEIF     <fs_line>-tdformat EQ '/:'.

        IF <fs_line>-tdline   CS 'RESET N1'.

          CLEAR number_count.

        ELSEIF <fs_line>-tdline   CS 'RESET N2'.

          CLEAR alpha_count.

        ENDIF.

      ENDIF.

*   check format

      IF <fs_line>-tdformat EQ 'U1'.

        MOVE 'U2' TO <fs_line>-tdformat.

      ENDIF.

      IF <fs_line>-tdformat EQ '/='.

        MOVE 'A1' TO <fs_line>-tdformat.

      ENDIF.

      IF form_id EQ 'GL'.

        IF <fs_line>-tdformat EQ 'U3'.

          MOVE 'U2' TO <fs_line>-tdformat.

        ENDIF.

        IF <fs_line>-tdformat EQ 'LZ'.

          CONTINUE.

        ENDIF.

      ENDIF.

      APPEND <fs_line> TO ct_itf_text.

    ENDLOOP.

*

* Korrektur fE Tabellen vor Aufzählungen

*

    DATA: flag_t(1) TYPE c.

    DATA: l_ct_itf_text TYPE tline.

    text_tab_temp[] = ct_itf_text[].

    CLEAR ct_itf_text[].

*

    LOOP AT text_tab_temp ASSIGNING <fs_line>.

      IF ( <fs_line>-tdformat = 'X1' OR

      <fs_line>-tdformat = 'X2' OR

      <fs_line>-tdformat = 'B1' OR

      <fs_line>-tdformat = 'B2' ) AND

      flag_t NE space.

        l_ct_itf_text-tdformat = 'LZ'.

        APPEND l_ct_itf_text TO ct_itf_text.

      ENDIF.



      APPEND  <fs_line> TO ct_itf_text.

      IF <fs_line>-tdformat(1) = 'T'.

        flag_t = 'X'.

      ELSE.

        flag_t = space.

      ENDIF.

    ENDLOOP.

*

* Korrektur fE Folgezeilen in Tabellen.

*

    text_tab_temp[] = ct_itf_text[].

    CLEAR ct_itf_text[].

*

    DATA: iloop             TYPE i,

          table_found(1)    TYPE c,

          table_start_index TYPE i,

          diff              TYPE i,

          ddiff             TYPE i,

          olddiff           TYPE i,

          tdformat          TYPE tdformat.



    LOOP AT text_tab_temp ASSIGNING <fs_line>.

      iloop = iloop + 1.

      IF <fs_line>-tdformat(1) = 'T'.

        table_found = 'X'.

        table_start_index = iloop.

        tdformat = <fs_line>-tdformat.

      ENDIF.

*

      diff = iloop - table_start_index.

      ddiff = diff - olddiff.

*

      IF <fs_line>-tdformat = '/' AND

                           ddiff LE 1 AND

                           table_found = 'X'.

        <fs_line>-tdformat = tdformat.

        olddiff = diff.

      ENDIF.

*

      IF ddiff GE 2.

        table_found = space.

      ENDIF.

*

      APPEND <fs_line> TO ct_itf_text.



    ENDLOOP.



    CALL FUNCTION 'INIT_TEXTSYMBOL'. " initialize symbol maintenance

    CALL FUNCTION 'TEXT_SYMBOL_REPLACE'
      EXPORTING
        header = is_header_txt
      TABLES
        lines  = ct_itf_text.







  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->REMOVE_LZ_IN_TABLES

* +-------------------------------------------------------------------------------------------------+

* | [<-->] CT_LINES                       TYPE        TY_T_TLINE

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD remove_lz_in_tables.



    DATA: lv_listopen TYPE sy-tabix,

          lv_current  TYPE sy-tabix,

          lv_next     TYPE sy-tabix,

          ls_line     TYPE tline.



* search for tables formats :

    LOOP AT ct_lines ASSIGNING FIELD-SYMBOL(<fs_tline>).

      CASE <fs_tline>-tdformat.

        WHEN 'T1' OR 'T2' OR 'T3' OR 'T4' OR 'T5' OR 'T6'

          OR 'K1' OR 'K2' OR 'K3' OR 'K4' OR 'K5' OR 'K6'.



          lv_listopen = sy-tabix.



        WHEN '/ ' OR space.

* do nothing, search the next line

        WHEN 'LZ' OR 'LA' OR '/*'.

          CHECK  NOT lv_listopen IS INITIAL.

          IF <fs_tline>-tdformat NE '/*'.

            lv_current = sy-tabix.

            lv_next = lv_current + 1.

            READ TABLE ct_lines INTO ls_line INDEX lv_next.

            IF sy-subrc = 0 AND

            ( ls_line-tdformat = 'M5' OR ls_line-tdformat = '/(' ).

            ELSE.

              DELETE ct_lines INDEX lv_current.

            ENDIF.

          ELSE.

            DELETE ct_lines INDEX sy-tabix.

          ENDIF.

        WHEN OTHERS.

          CLEAR lv_listopen.

      ENDCASE.

    ENDLOOP.                             " ITF_TEXT-Tabelle

  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Public Method zloc_cl_spro_doc_loader->SET_TR_REQUEST

* +-------------------------------------------------------------------------------------------------+

* | [--->] IR_TRANSPORT_REQ               TYPE        RSELOPTION

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD set_tr_request.

    mt_tr_request = ir_transport_req.

  ENDMETHOD.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Private Method zloc_cl_spro_doc_loader->TRANSFORM_NEW_OLD

* +-------------------------------------------------------------------------------------------------+

* | [--->] IV_DOC_CLASS                   TYPE        DOKU_CLASS

* | [--->] IV_DOC_NAME                    TYPE        DOKU_OBJ

* | [<-->] CV_DOC_ID                      TYPE        DOKU_ID

* | [<-->] CV_DOC_OBJECT                  TYPE        DOKU_OBJ

* | [<-->] CV_DOC_TYPE                    TYPE        DOKU_TYP

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD transform_new_old.

    DATA dokedicl  TYPE tdcld-dokedicl.

    DATA dokparcl  TYPE tdcld-dokparcl.







    DATA ls_tdcld TYPE tdcld.



    SELECT SINGLE *

      FROM tdcld

      INTO ls_tdcld

      WHERE dokclass EQ iv_doc_class.



    IF ls_tdcld-dokparcl NE space.

      cv_doc_id = ls_tdcld-dokparcl.

      cv_doc_object = iv_doc_name.

      EXIT.

    ENDIF.



    IF iv_doc_class EQ space.

      MOVE iv_doc_class TO cv_doc_id.

      MOVE iv_doc_name TO cv_doc_object.

      EXIT.

    ENDIF.



  ENDMETHOD.

ENDCLASS.







*----------------------------------------------------------------------*

*       CLASS cl_word IMPLEMENTATION

*----------------------------------------------------------------------*

CLASS cl_word IMPLEMENTATION.

  METHOD constructor.

    DATA : lw_docx         TYPE xstring,

           lw_extension    TYPE string,

           lw_file         TYPE string,

           lw_string       TYPE string,

           ls_list_style   TYPE ty_list_style,

           ls_list_object  TYPE ty_list_object,

           lt_find_result  TYPE match_result_tab,

           ls_find_result  LIKE LINE OF lt_find_result,

           lw_url_begin(6) TYPE c.



    CREATE OBJECT mo_zip.



    IF tpl IS SUPPLIED AND NOT tpl IS INITIAL.

* Load template document

      CALL METHOD _load_file
        EXPORTING
          filename = tpl
        IMPORTING
          xcontent = lw_docx.

      IF lw_docx IS INITIAL.

        MESSAGE 'Cannot open template, please check'  TYPE 'A' ##NO_TEXT.

      ENDIF.

    ELSE.

* Empty docx creation

      TRY.

          lw_docx = cl_docx_form=>create_form(  ).

        CATCH cx_openxml_not_allowed

              cx_openxml_not_found

              cx_openxml_format

              cx_docx_form_not_unicode.

          MESSAGE 'Cannot create empty doc, please use template' TYPE 'A' ##NO_TEXT.

      ENDTRY.

    ENDIF.



* Load docx into zip object

    CALL METHOD mo_zip->load
      EXPORTING
        zip             = lw_docx
      EXCEPTIONS
        zip_parse_error = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.

      RETURN.

    ENDIF.



* Keep actual content

    IF keep_tpl_content = c_true.

      CALL METHOD _get_zip_file
        EXPORTING
          filename = 'word/document.xml'                    "#EC NOTEXT
        IMPORTING
          content  = lw_file.



      FIND FIRST OCCURRENCE OF '<w:body' IN lw_file

           MATCH OFFSET sy-fdpos IGNORING CASE.

      IF sy-subrc = 0.

        lw_file = lw_file+sy-fdpos.

        FIND FIRST OCCURRENCE OF '>' IN lw_file

             MATCH OFFSET sy-fdpos IGNORING CASE.

      ENDIF.

      IF sy-subrc = 0.

        sy-fdpos = sy-fdpos + 1.

        lw_file = lw_file+sy-fdpos.

        FIND FIRST OCCURRENCE OF '</w:body' IN lw_file

             MATCH OFFSET sy-fdpos IGNORING CASE.

      ENDIF.

      IF sy-subrc = 0.

        mw_docxml = lw_file(sy-fdpos).

        FIND ALL OCCURRENCES OF '<w:sectPr' IN mw_docxml

             MATCH OFFSET sy-fdpos IGNORING CASE.

        IF sy-subrc = 0.

          mw_tpl_section_xml = mw_docxml+sy-fdpos.

          mw_docxml = mw_docxml(sy-fdpos).

        ENDIF.

      ELSE.

        MESSAGE 'Cannot parse template content: empty document created' TYPE 'I' ##NO_TEXT.

      ENDIF.

    ENDIF.



* Remove docx body

    CALL METHOD mo_zip->delete
      EXPORTING
        name            = 'word/document.xml'               "#EC NOTEXT
      EXCEPTIONS
        zip_index_error = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.

      RETURN.

    ENDIF.



* If modele is a template, transform it to document

    IF tpl IS SUPPLIED AND NOT tpl IS INITIAL.

      lw_url_begin = tpl.

      IF lw_url_begin = c_sapwr_prefix.

        SELECT SINGLE value INTO lw_extension

               FROM wwwparams

               WHERE relid = 'MI'

               AND objid = tpl+6

               AND name = 'fileextension'.

        IF NOT lw_extension IS INITIAL AND lw_extension(1) = '.'.

          lw_extension = lw_extension+1.

        ENDIF.

      ELSE.

        FIND ALL OCCURRENCES OF '.' IN tpl MATCH OFFSET sy-fdpos.

        IF sy-subrc = 0.

          sy-fdpos = sy-fdpos + 1.

          lw_extension = tpl+sy-fdpos.

        ENDIF.

      ENDIF.

      TRANSLATE lw_extension TO LOWER CASE.



* Template without macro

      IF lw_extension = 'dotx'.

        CALL METHOD _get_zip_file
          EXPORTING
            filename = '[Content_Types].xml'                "#EC NOTEXT
          IMPORTING
            content  = lw_file.



        REPLACE ALL OCCURRENCES OF 'wordprocessingml.template'

                IN lw_file WITH 'wordprocessingml.document'. "#EC NOTEXT



        CALL METHOD _update_zip_file
          EXPORTING
            filename = '[Content_Types].xml'
            content  = lw_file.

* Template with macro

      ELSEIF lw_extension = 'dotm'.

        CALL METHOD _get_zip_file
          EXPORTING
            filename = '[Content_Types].xml'                "#EC NOTEXT
          IMPORTING
            content  = lw_file.



        REPLACE ALL OCCURRENCES OF 'template.macroEnabledTemplate'

                IN lw_file WITH 'document.macroEnabled'.    "#EC NOTEXT



        CALL METHOD _update_zip_file
          EXPORTING
            filename = '[Content_Types].xml'
            content  = lw_file.

      ENDIF.

    ENDIF.



* Get author name

    CLEAR mw_author.

    SELECT SINGLE name_textc INTO mw_author

           FROM user_addr

           WHERE bname = sy-uname.                          "#EC WARNOK

    IF sy-subrc NE 0.

      mw_author = sy-uname.

    ENDIF.



* Set Author, Creation date and Version number properties

    CALL METHOD set_properties
      EXPORTING
        author       = mw_author
        creationdate = sy-datlo
        creationtime = sy-timlo
        revision     = 1.



* Get style file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/styles.xml'                        "#EC NOTEXT
      IMPORTING
        content  = lw_file.



* Scan style file to search all styles

    FIND ALL OCCURRENCES OF REGEX '<w:style ([^>]*)>'

         IN lw_file RESULTS lt_find_result

         IGNORING CASE.

    LOOP AT lt_find_result INTO ls_find_result.

      CLEAR ls_list_style.

      FIND FIRST OCCURRENCE OF REGEX 'w:styleId="([^"]*)"'

           IN SECTION OFFSET ls_find_result-offset

                      LENGTH ls_find_result-length

                      OF lw_file

           SUBMATCHES lw_string

           IGNORING CASE.

      IF sy-subrc NE 0.

        CONTINUE.

      ENDIF.

      ls_list_style-name = lw_string.

      FIND FIRST OCCURRENCE OF REGEX 'w:type="(paragraph|character|numbering|table)"'

           IN SECTION OFFSET ls_find_result-offset

                      LENGTH ls_find_result-length

                      OF lw_file

           SUBMATCHES lw_string

           IGNORING CASE.

      IF sy-subrc = 0.

        ls_list_style-type = lw_string.

      ENDIF.

      APPEND ls_list_style TO mt_list_style.

    ENDLOOP.

    SORT mt_list_style BY type name.



* Get relation file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/_rels/document.xml.rels'           "#EC NOTEXT
      IMPORTING
        content  = lw_file.



* Scan relation file to get all objects

    FIND ALL OCCURRENCES OF REGEX '<Relationship ([^>]*)/>'

         IN lw_file RESULTS lt_find_result

         IGNORING CASE.

    LOOP AT lt_find_result INTO ls_find_result.

      CLEAR ls_list_object.

* Search id of object

      FIND FIRST OCCURRENCE OF REGEX 'Id="([^"]*)"' ##NO_TEXT

           IN SECTION OFFSET ls_find_result-offset

                      LENGTH ls_find_result-length

                      OF lw_file

           SUBMATCHES lw_string

           IGNORING CASE.

      IF sy-subrc NE 0.

        CONTINUE.

      ENDIF.

      ls_list_object-id = lw_string.

* Search type of object

      FIND FIRST OCCURRENCE OF REGEX 'Type=".*(footer|header|image)"' ##NO_TEXT

           IN SECTION OFFSET ls_find_result-offset

                      LENGTH ls_find_result-length

                      OF lw_file

           SUBMATCHES lw_string

           IGNORING CASE.

      IF sy-subrc NE 0.

        CONTINUE.

      ENDIF.

      ls_list_object-type = lw_string.



* Search path of file

      FIND FIRST OCCURRENCE OF REGEX 'Target="([^"]*)"' ##NO_TEXT

           IN SECTION OFFSET ls_find_result-offset

                      LENGTH ls_find_result-length

                      OF lw_file

           SUBMATCHES lw_string

           IGNORING CASE.

      IF sy-subrc NE 0.

        CONTINUE.

      ENDIF.

      CONCATENATE 'word/' lw_string INTO ls_list_object-path.



      APPEND ls_list_object TO mt_list_object.

    ENDLOOP.

    SORT mt_list_object BY type id.

  ENDMETHOD.                    "constructor



  METHOD write_spro_documentation.



    DATA ls_style TYPE ty_character_style_effect.

    DATA ls_paragraph TYPE zloc_cl_spro_doc_loader=>ty_s_itf_lines.



    LOOP AT it_documentation INTO ls_paragraph.





      ls_style-bold = c_false.

      ls_style-size = c_spro_text_def_size.



      CASE ls_paragraph-format.



        WHEN 'U2'.

          CLEAR ls_style.

          ls_style-bold = c_true.

          ls_style-size = c_spro_text.



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = ls_paragraph-line      ).

          write_line( ).



        WHEN 'K1'.

          ls_style-bold = c_true.



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = ls_paragraph-line      ).

          write_line( ).



        WHEN 'UT'.

          CLEAR ls_style.

          ls_style-bold = c_true.

          ls_style-size = c_spro_text_def_size.



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = ls_paragraph-line       ).

          write_line( ).



        WHEN 'B1' OR 'B2' .



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = | -{ ls_paragraph-line }| ).

          write_line( ).



        WHEN 'X1' OR 'X2'.



          REPLACE  ',,' INTO ls_paragraph-line WITH ''.



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = ls_paragraph-line ).

          write_line( ).



        WHEN OTHERS.



          write_text(

            EXPORTING

              style_effect       = ls_style

              textline           = ls_paragraph-line      ).

          write_line( ).

      ENDCASE.



    ENDLOOP.



    write_newpage( ).



  ENDMETHOD.





  METHOD write_text.

    DATA : lw_style   TYPE string,

           lw_string  TYPE string,

           lw_field   TYPE string,

           lw_intsize TYPE i,

           lw_char6   TYPE c LENGTH 6.

    DATA : lt_find_result TYPE match_result_tab,

           ls_find_result LIKE LINE OF lt_find_result,

           lw_off         TYPE i,

           lw_len         TYPE i.



* Get font style section

    IF style_effect IS SUPPLIED OR NOT style IS INITIAL.

      CALL METHOD _build_character_style
        EXPORTING
          style         = style
          style_effect  = style_effect
        IMPORTING
          xml           = lw_style
          invalid_style = invalid_style.

    ENDIF.



* Escape invalid character

    CALL METHOD _protect_string
      EXPORTING
        in  = textline
      IMPORTING
        out = lw_string.



* Replace fields in content

    IF lw_string CS '##FIELD#'.

* Regex to search all fields to replace

      FIND ALL OCCURRENCES OF REGEX '##FIELD#([A-Z ])*##' IN lw_string RESULTS lt_find_result.

      SORT lt_find_result BY offset DESCENDING.

* For each result, replace

      LOOP AT lt_find_result INTO ls_find_result.

        lw_off = ls_find_result-offset + 8.

        lw_len = ls_find_result-length - 10.

        CASE lw_string+ls_find_result-offset(ls_find_result-length).

          WHEN c_field_pagecount OR c_field_pagetotal.

            lw_field = lw_string+lw_off(lw_len) && ' \* Arabic' ##NO_TEXT.

          WHEN c_field_filename.

            lw_field = lw_string+lw_off(lw_len) && ' \p' ##NO_TEXT.

          WHEN c_field_creationdate OR c_field_moddate OR c_field_todaydate.

            lw_field = lw_string+lw_off(lw_len) && ' \@ &quot;dd/MM/yyyy&quot;' ##NO_TEXT.

          WHEN OTHERS.

            lw_field = lw_string+lw_off(lw_len).

        ENDCASE.

        CONCATENATE '<w:fldSimple w:instr="'

                    lw_field

                    ' \* MERGEFORMAT"/>'

                    INTO lw_field RESPECTING BLANKS.

        REPLACE lw_string+ls_find_result-offset(ls_find_result-length)

                IN lw_string WITH lw_field.

      ENDLOOP.

    ENDIF.



* Replace label anchor by it's value

    IF NOT style_effect-label IS INITIAL AND lw_string CS c_label_anchor.

      CALL METHOD _protect_label
        EXPORTING
          in  = style_effect-label
        IMPORTING
          out = lw_field.

      CONCATENATE '<w:fldSimple w:instr=" SEQ '

                  lw_field

                  ' \* ARABIC "/>'

                  INTO lw_field RESPECTING BLANKS.

      REPLACE c_label_anchor IN lw_string WITH lw_field.

    ENDIF.



    IF virtual IS SUPPLIED.

      CONCATENATE '<w:r>'

                  lw_style

                  '<w:t xml:space="preserve">'

                  lw_string

                  '</w:t>'

                  '</w:r>'

                  INTO virtual RESPECTING BLANKS.

      RETURN.

    ELSE.

      CONCATENATE mw_fragxml

                  '<w:r>'

                  lw_style

                  '<w:t xml:space="preserve">'

                  lw_string

                  '</w:t>'

                  '</w:r>'

                  INTO mw_fragxml RESPECTING BLANKS.



      IF line_style IS SUPPLIED AND line_style IS NOT INITIAL.

        CALL METHOD write_line
          EXPORTING
            style         = line_style
          IMPORTING
            invalid_style = invalid_line_style.

      ENDIF.

    ENDIF.

  ENDMETHOD.                    "write_text



  METHOD write_line.

    DATA : lw_style    TYPE string,

           lw_substyle TYPE string,

           lw_indent   TYPE string.



    CLEAR lw_style.



    CALL METHOD _build_paragraph_style
      EXPORTING
        style         = style
        style_effect  = style_effect
      IMPORTING
        xml           = lw_style
        invalid_style = invalid_style.



    IF virtual IS SUPPLIED.

      IF virtual IS INITIAL.

        CONCATENATE mw_docxml

                    '<w:p>'

                    lw_style

                    mw_fragxml

                    '</w:p>'

                    INTO virtual.

      ELSE.

        CONCATENATE mw_docxml

                    '<w:p>'

                    lw_style

                    virtual

                    '</w:p>'

                    INTO virtual.

      ENDIF.

    ELSE.

      CONCATENATE mw_docxml

                  '<w:p>'

                  lw_style

                  mw_fragxml

                  '</w:p>'

                  INTO mw_docxml.

    ENDIF.

    CLEAR mw_fragxml.



  ENDMETHOD.                    "write_line



  METHOD write_table.

    DATA : ls_content     TYPE REF TO data,

           lw_type(1)     TYPE c,                           "#EC NEEDED

           lw_lines       TYPE i,

           lw_cols        TYPE i,

           lw_col         TYPE i,

           lw_col_inc     TYPE i,

           lw_style_table TYPE i,

           lw_xml         TYPE string,

           lw_tblwidth    TYPE string,

           lw_merge       TYPE string,

           lw_string      TYPE string,

           lw_style       TYPE string,

           lw_stylep      TYPE string.

    FIELD-SYMBOLS <field> TYPE any.

    FIELD-SYMBOLS <field_style> TYPE ty_table_style_field.

    FIELD-SYMBOLS <line> TYPE any.

    CREATE DATA ls_content LIKE LINE OF content.

    ASSIGN ls_content->* TO <line>.

    IF sy-subrc NE 0.

      RETURN.

    ENDIF.



* count number of lines and columns of the table

    DESCRIBE TABLE content LINES lw_lines.

    IF lw_lines = 0.

      RETURN.

    ENDIF.

    DESCRIBE FIELD <line> TYPE lw_type COMPONENTS lw_cols.

    IF lw_cols = 0.

      RETURN.

    ENDIF.



* search if data table is simple or have style infos for each field

    ASSIGN COMPONENT 1 OF STRUCTURE <line> TO <field>.

    IF sy-subrc NE 0.

      RETURN.

    ENDIF.

    DESCRIBE FIELD <field> TYPE lw_type COMPONENTS lw_style_table.



* Write table properties

    CLEAR lw_xml.

    CONCATENATE '<w:tbl>'

                '<w:tblPr>'

                INTO lw_xml.



    " Styled table : define style

    IF style IS SUPPLIED AND NOT style IS INITIAL.

      READ TABLE mt_list_style WITH KEY type = c_type_table

                                        name = style

                               TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        CONCATENATE lw_xml

                    '<w:tblStyle w:val="'

                    style

                    '"/>'

                    INTO lw_xml.

      ELSE.

        invalid_style = c_true.

      ENDIF.



* If defined, overwrite style table layout (no effect without table style defined)

      CLEAR lw_style.

      IF style_overwrite IS SUPPLIED.

        lw_tblwidth = style_overwrite-firstrow.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:firstRow="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.

        lw_tblwidth = style_overwrite-firstcol.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:firstColumn="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.

        lw_tblwidth = style_overwrite-nozebra.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:noHBand="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.

        lw_tblwidth = style_overwrite-novband.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:noVBand="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.

        lw_tblwidth = style_overwrite-lastrow.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:lastRow="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.

        lw_tblwidth = style_overwrite-lastcol.

        CONDENSE lw_tblwidth NO-GAPS.

        CONCATENATE lw_style

                    ' w:lastColumn="'

                    lw_tblwidth

                    '"'

                    INTO lw_style RESPECTING BLANKS.



        CONCATENATE lw_xml

                    '<w:tblLook'

                    lw_style

                    '/>'

                    INTO lw_xml RESPECTING BLANKS.

        CLEAR lw_style.

      ENDIF.

    ENDIF.



* Default not styled table : add border

    IF NOT style IS SUPPLIED.

      IF border = c_true.

        CONCATENATE lw_xml

                    '<w:tblBorders>'

                    '<w:top w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '<w:left w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '<w:bottom w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '<w:right w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '<w:insideH w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '<w:insideV w:color="auto" w:space="0" w:sz="4" w:val="single"/>'

                    '</w:tblBorders>'

                    INTO lw_xml.

      ENDIF.

    ENDIF.



* Define table width

    lw_tblwidth = tblwidth.

    CONDENSE lw_tblwidth NO-GAPS.

    IF tblwidth = 0.

* If no table width given, set it to "auto"

      CONCATENATE lw_xml

                  '<w:tblW w:w="'

                  lw_tblwidth

                  '" w:type="auto"/>'

                  '</w:tblPr>'

                  INTO lw_xml.

    ELSE.

      CONCATENATE lw_xml

                  '<w:tblW w:w="'

                  lw_tblwidth

                  '"/>'

                  '</w:tblPr>'

                  INTO lw_xml.

    ENDIF.



* Fill table content

    LOOP AT content INTO <line>.

      CONCATENATE lw_xml

                  '<w:tr>'

                  INTO lw_xml.

      lw_col = 1.

      DO lw_cols TIMES.

        lw_col_inc = 1.

*--Filling the cell

        IF lw_style_table = 0. "fields are plain text

          CONCATENATE lw_xml

                      '<w:tc>'

                      INTO lw_xml.



          ASSIGN COMPONENT lw_col OF STRUCTURE <line> TO <field>.

          lw_string = <field>.

          CALL METHOD write_text
            EXPORTING
              textline = lw_string
            IMPORTING
              virtual  = lw_string.

          CONCATENATE lw_xml

                      '<w:p>'

                      lw_string

                      '</w:p>'

                      INTO lw_xml.

        ELSE. " fields have ty_table_style_field structure, apply styles

          ASSIGN COMPONENT lw_col OF STRUCTURE <line> TO <field_style>.

          IF sy-subrc NE 0. "Occurs when merged cell

            EXIT. "exit do

          ENDIF.

          CONCATENATE lw_xml

                      '<w:tc>'

                      INTO lw_xml.



          CLEAR : lw_style, lw_stylep.

          IF NOT <field_style>-bgcolor IS INITIAL.

            CONCATENATE lw_style

                        '<w:shd w:fill="'

                        <field_style>-bgcolor

                        '"/>'

                        INTO lw_style.

          ENDIF.

          IF NOT <field_style>-valign IS INITIAL.

            CONCATENATE lw_style

                        '<w:vAlign w:val="'

                        <field_style>-valign

                        '"/>'

                        INTO lw_style.

          ENDIF.

          IF <field_style>-merge > 1.

            lw_col_inc = <field_style>-merge.

            lw_merge = <field_style>-merge.

            CONDENSE lw_merge NO-GAPS.

            CONCATENATE lw_style

                        '<w:gridSpan w:val="'

                        lw_merge

                        '"/>'

                        INTO lw_style.

          ENDIF.



          IF NOT lw_style IS INITIAL.

            CONCATENATE '<w:tcPr>' lw_style '</w:tcPr>' INTO lw_style.

          ENDIF.



          CLEAR lw_string.

          IF <field_style>-image_id IS INITIAL AND <field_style>-xml IS INITIAL.

            CALL METHOD write_text
              EXPORTING
                textline     = <field_style>-textline
                style_effect = <field_style>-style_effect
                style        = <field_style>-style
              IMPORTING
                virtual      = lw_string.



            IF NOT <field_style>-line_style IS INITIAL

            OR NOT <field_style>-line_style_effect IS INITIAL.

              CALL METHOD _build_paragraph_style
                EXPORTING
                  style        = <field_style>-line_style
                  style_effect = <field_style>-line_style_effect
                IMPORTING
                  xml          = lw_stylep.

            ENDIF.



            CONCATENATE lw_xml

                        lw_style

                        '<w:p>'

                        lw_stylep

                        lw_string

                        '</w:p>'

                        INTO lw_xml.

          ELSEIF <field_style>-xml IS INITIAL.

            CALL METHOD insert_image
              EXPORTING
                style        = <field_style>-line_style
                style_effect = <field_style>-line_style_effect
              IMPORTING
                virtual      = lw_string
              CHANGING
                id           = <field_style>-image_id.

* If image not found, write empty cell

            IF lw_string IS INITIAL.

              lw_string = '<w:p></w:p>'.

            ENDIF.

            CONCATENATE lw_xml

                        lw_style

                        lw_string

                        INTO lw_xml.

          ELSE.

            CONCATENATE lw_xml

                        lw_style

                        <field_style>-xml

                        INTO lw_xml.

          ENDIF.

        ENDIF.

        CONCATENATE lw_xml '</w:tc>' INTO lw_xml.

        lw_col = lw_col + lw_col_inc.

      ENDDO.

      CONCATENATE lw_xml '</w:tr>' INTO lw_xml.

    ENDLOOP.



    CONCATENATE mw_docxml

                lw_xml

                '</w:tbl>'

                INTO mw_docxml.



  ENDMETHOD.                    "write_table



  METHOD write_newpage.

    write_break( breaktype = c_breaktype_page ).

  ENDMETHOD.                    "write_newpage



  METHOD write_toc.

    DATA : lw_default TYPE string,

           lw_content TYPE string.



* Classic TOC

    IF label IS INITIAL.

      lw_default = '--== Table of content - please refresh ==--' ##NO_TEXT.

      lw_content = '\o "1-9"' ##NO_TEXT.



* Table of content for specific label (table, figure, ...)

    ELSE.

      CONCATENATE '--== Table of ' ##NO_TEXT

                  label

                  ' - please refresh ==--' ##NO_TEXT

                  INTO lw_default RESPECTING BLANKS.



      CALL METHOD _protect_label
        EXPORTING
          in  = label
        IMPORTING
          out = lw_content.



      CONCATENATE '\h \h \c "' ##NO_TEXT

                  lw_content

                  '"'

                  INTO lw_content.

    ENDIF.



* If specified, use given default text

    IF NOT default IS INITIAL.

      lw_default = default.

    ENDIF.



* Write TOC

    CONCATENATE mw_docxml

                '<w:p>'

                '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'

                '<w:r><w:instrText> TOC '

                lw_content

                ' </w:instrText></w:r>'

                '</w:p>'



* Add a default text for initial TOC value

                '<w:p>'

                '<w:pPr><w:jc w:val="center"/></w:pPr>'

                '<w:r>'

                '<w:fldChar w:fldCharType="separate"/></w:r>'

                '<w:r>'

                '<w:rPr><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr>'

                '<w:t>'

                lw_default

                '</w:t></w:r>'

                '</w:p>'



                '<w:p>'

                '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

                '</w:p>'



                INTO mw_docxml RESPECTING BLANKS.

  ENDMETHOD.                    "write_toc



  METHOD write_note.

    DATA : ls_link_style_effect TYPE ty_character_style_effect,

           ls_line_style_effect TYPE ty_paragraph_style_effect,

           lw_style             TYPE string,

           lw_string            TYPE string,

           lw_id                TYPE string.



* Define a default style for link

    ls_link_style_effect = link_style_effect.

    IF link_style IS INITIAL AND ls_link_style_effect IS INITIAL.

      ls_link_style_effect-sup = c_true.

    ENDIF.



* Define a default style for footnote

    ls_line_style_effect = line_style_effect.

    IF line_style IS INITIAL AND ls_line_style_effect IS INITIAL.

      ls_line_style_effect-spacing_before = '0'.

      ls_line_style_effect-spacing_after = '0'.

      ls_line_style_effect-interline = 240.

    ENDIF.



* Create a new footnote

    CALL METHOD _create_note
      EXPORTING
        text               = text
        type               = type
        style              = style
        style_effect       = style_effect
        line_style         = line_style
        line_style_effect  = ls_line_style_effect
        link_style         = link_style
        link_style_effect  = ls_link_style_effect
      IMPORTING
        invalid_style      = invalid_style
        invalid_line_style = invalid_line_style
        id                 = lw_id.



    IF lw_id IS INITIAL.

      RETURN.

    ENDIF.



* Prepare style for the footnote link

    CALL METHOD _build_character_style
      EXPORTING
        style         = link_style
        style_effect  = ls_link_style_effect
      IMPORTING
        xml           = lw_style
        invalid_style = invalid_link_style.



* Now insert note in document

    IF type = c_notetype_foot.

      lw_string = '<w:footnoteReference w:id="'.

    ELSEIF type = c_notetype_end.

      lw_string = '<w:endnoteReference w:id="'.

    ENDIF.



    CONCATENATE mw_fragxml

                '<w:r>'

                lw_style

                lw_string

                lw_id

                '"/>'

                '</w:r>'

                INTO mw_fragxml.



  ENDMETHOD.                    "write_footnote



  METHOD write_comment.

    DATA : lw_file              TYPE string,

           lw_string            TYPE string,

           lw_id                TYPE string,

           lw_text              TYPE string,

           lw_xmlns             TYPE string,

           lw_head_style        TYPE string,

           lw_line_style        TYPE string,

           ls_head_style_effect TYPE ty_character_style_effect,

           lw_author            TYPE string,

           lw_initials          TYPE string.



    READ TABLE mo_zip->files WITH KEY name = 'word/comments.xml'

               TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

* If comment file exists, load the file

      CALL METHOD _get_zip_file
        EXPORTING
          filename = 'word/comments.xml'
        IMPORTING
          content  = lw_file.

    ELSE.

* If comments file doesnt exist, declare it and create it

* Add comments in content_types

      CALL METHOD _get_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
        IMPORTING
          content  = lw_file.



      CONCATENATE '<Override'

                  ' ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml"' ##NO_TEXT

                  ' PartName="/word/comments.xml"/></Types>'

                  INTO lw_string RESPECTING BLANKS.

      REPLACE '</Types>' WITH lw_string

              INTO lw_file.



      CALL METHOD _update_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
          content  = lw_file.



* Add comments in relation file

      CALL METHOD _get_zip_file
        EXPORTING
          filename = 'word/_rels/document.xml.rels'
        IMPORTING
          content  = lw_file.



* Create comments relation ID

      DO.

        lw_id = 'rId' && sy-index.                          "#EC NOTEXT

        lw_string = 'Id="' && lw_id && '"'.                 "#EC NOTEXT

        FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

        IF sy-subrc NE 0.

          EXIT. "exit do

        ENDIF.

      ENDDO.



* Add relation

      CONCATENATE '<Relationship Target="comments.xml"'

                  ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments"'

                  ' Id="'  ##NO_TEXT

                  lw_id

                  '"/>'

                  '</Relationships>'

                  INTO lw_string RESPECTING BLANKS.

      REPLACE '</Relationships>' WITH lw_string INTO lw_file.



* Update relation file

      CALL METHOD _update_zip_file
        EXPORTING
          filename = 'word/_rels/document.xml.rels'
          content  = lw_file.



      CALL METHOD _get_xml_ns
        IMPORTING
          xml = lw_xmlns.



* Create empty comments file

      CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

                  "cl_abap_char_utilities=>cr_lf

                  cl_abap_char_utilities=>newline

                  '<w:comments '

                  lw_xmlns

                  '>'

                  '</w:comments>'

                  INTO lw_file RESPECTING BLANKS.

    ENDIF.



* Search available comment id

    DO.

      "sy-index = sy-index + 4.

      lw_id = sy-index.

      CONDENSE lw_id NO-GAPS.

      lw_string = 'w:id="' && lw_id && '"'.                 "#EC NOTEXT

      FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Add blank at start of note

    lw_text = text.

    IF lw_text IS INITIAL OR lw_text(1) NE space.

      CONCATENATE space lw_text INTO lw_text RESPECTING BLANKS.

    ENDIF.



    CALL METHOD write_text
      EXPORTING
        textline      = lw_text
        style_effect  = style_effect
        style         = style
      IMPORTING
        virtual       = lw_text
        invalid_style = invalid_style.



* Define default style for comment head

    ls_head_style_effect = head_style_effect.

    IF ls_head_style_effect IS INITIAL AND head_style IS INITIAL.

      ls_head_style_effect-bold = c_true.

    ENDIF.



    CALL METHOD _build_character_style
      EXPORTING
        style        = head_style
        style_effect = ls_head_style_effect
      IMPORTING
        xml          = lw_head_style.



    IF NOT line_style_effect IS INITIAL OR NOT line_style IS INITIAL.

      CALL METHOD _build_paragraph_style
        EXPORTING
          style         = line_style
          style_effect  = line_style_effect
        IMPORTING
          xml           = lw_line_style
          invalid_style = invalid_line_style.

    ENDIF.



* Define author property

    IF author IS INITIAL.

      lw_author = mw_author.

    ELSE.

      lw_author = author.

    ENDIF.



* Define initial property

    IF initials IS INITIAL.

      lw_initials = lw_author.

    ELSE.

      lw_initials = initials.

    ENDIF.



    CONCATENATE '<w:comment w:initials="'

                lw_initials

                '"'

                ' w:date="'

                datum(4)

                '-'

                datum+4(2)

                '-'

                datum+6(2)

                'T'

                uzeit(2)

                ':'

                uzeit+2(2)

                ':'

                uzeit+4(2)

                'Z"'

                ' w:author="'

                lw_author

                '"'

                ' w:id="'

                lw_id

                '">'

                '<w:p>'

                lw_line_style

                '<w:r>'

                lw_head_style

                '<w:annotationRef/>'

                '</w:r>'

                lw_text

                '</w:p>'

                '</w:comment>'

                '</w:comments>'

                INTO lw_string RESPECTING BLANKS.

    REPLACE '</w:comments>' WITH lw_string INTO lw_file.



    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/comments.xml'
        content  = lw_file.



* Finally insert reference to comment in current text fragment

    CONCATENATE mw_fragxml

                '<w:r><w:commentReference w:id="'

                lw_id

                '"/></w:r>'

                INTO mw_fragxml.



  ENDMETHOD.                    "write_comment



  METHOD draw_init.

    DATA : lw_style    TYPE string,

           lw_width    TYPE i,

           lw_string   TYPE string,

           lw_string_x TYPE string,

           lw_string_y TYPE string,

           lw_string_w TYPE string,

           lw_string_h TYPE string

           .



    CLEAR mw_fragxml.

    CLEAR lw_style.

    IF bgcolor IS SUPPLIED AND NOT bgcolor IS INITIAL.

      CONCATENATE lw_style

                  '<wpc:bg>'

                  '<a:solidFill>'

                  '<a:srgbClr val="'

                  bgcolor

                  '" />'

                  '</a:solidFill>'

                  '</wpc:bg>'

                  INTO lw_style.

    ENDIF.



    IF bdcolor IS SUPPLIED AND NOT bdcolor IS INITIAL

    AND bdwidth IS SUPPLIED AND NOT bdwidth IS INITIAL.

      lw_width = c_basesize * bdwidth.

      lw_string = lw_width.

      CONDENSE lw_string NO-GAPS.



      CONCATENATE lw_style

                  '<wpc:whole>'

                  '<a:ln w="'

                  lw_string

                  '">'

                  '<a:solidFill>'

                  '<a:srgbClr val="'

                  bdcolor

                  '" />'

                  '</a:solidFill>'

                  '</a:ln>'

                  '</wpc:whole>'

                  INTO lw_style.

    ENDIF.



    lw_string_x = lw_width = c_basesize * left.

    CONDENSE lw_string_x NO-GAPS.

    lw_string_y = lw_width = c_basesize * top.

    CONDENSE lw_string_y NO-GAPS.

    lw_string_w = lw_width = c_basesize * width.

    CONDENSE lw_string_w NO-GAPS.

    lw_string_h = lw_width = c_basesize * height.

    CONDENSE lw_string_h NO-GAPS.



    CONCATENATE '<w:r>'

                '<mc:AlternateContent>'

                '<mc:Choice Requires="wpc">'

                '<w:drawing>'

                '<wp:anchor distR="0" distL="0" distB="0" distT="0" allowOverlap="0" layoutInCell="1" locked="0" behindDoc="1" relativeHeight="0" simplePos="0">'

                '<wp:simplePos y="0" x="0"/>'

                '<wp:positionH relativeFrom="column">'

                '<wp:posOffset>'

                lw_string_x

                '</wp:posOffset>'

                '</wp:positionH>'

                '<wp:positionV relativeFrom="paragraph">'

                '<wp:posOffset>'

                lw_string_y

                '</wp:posOffset>'

                '</wp:positionV>'

                '<wp:extent cy="'

                lw_string_h

                '" cx="'

                lw_string_w

                '"/>'

                '<wp:wrapNone/>'

                '<wp:docPr name="Draw container" id="3"/>'

                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">'

                '<a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas">'

                '<wpc:wpc>'

                lw_style

                INTO mw_fragxml RESPECTING BLANKS.

  ENDMETHOD.                    "draw_init



  METHOD draw.

    DATA : lw_width    TYPE i,

           lw_string_x TYPE string,

           lw_string_y TYPE string,

           lw_string_w TYPE string,

           lw_string_h TYPE string,

           lw_style    TYPE string,

           lw_string   TYPE string,

           lw_color    TYPE string.



    lw_string_x = lw_width = c_basesize * left.

    CONDENSE lw_string_x NO-GAPS.

    lw_string_y = lw_width = c_basesize * top.

    CONDENSE lw_string_y NO-GAPS.

    lw_string_w = lw_width = c_basesize * width.

    CONDENSE lw_string_w NO-GAPS.

    lw_string_h = lw_width = c_basesize * height.

    CONDENSE lw_string_h NO-GAPS.



    CASE object.

      WHEN c_draw_image.

        invalid_image = c_false.

        CALL METHOD _load_image
          EXPORTING
            url = url
          CHANGING
            id  = id.

        IF id IS INITIAL.

          invalid_image = c_true.

          RETURN.

        ENDIF.

        CLEAR lw_style.

        IF bgcolor IS SUPPLIED AND NOT bgcolor IS INITIAL.

          CONCATENATE lw_style

                      '<a:solidFill>'

                      '<a:srgbClr val="'

                      bgcolor

                      '" />'

                      '</a:solidFill>'

                      INTO lw_style.

        ENDIF.





        IF bdcolor IS SUPPLIED AND NOT bdcolor IS INITIAL

        AND bdwidth IS SUPPLIED AND NOT bdwidth IS INITIAL.

          lw_width = c_basesize * bdwidth.

          lw_string = lw_width.

          CONDENSE lw_string NO-GAPS.



          CONCATENATE lw_style

                      '<a:ln w="'

                      lw_string

                      '">'

                      '<a:solidFill>'

                      '<a:srgbClr val="'

                      bdcolor

                      '" />'

                      '</a:solidFill>'

                      '</a:ln>'

                      INTO lw_style.

        ENDIF.



        CONCATENATE mw_fragxml

                    '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'

                    '<pic:nvPicPr>'

                    '<pic:cNvPr name="Image" id="1"/>'

                    '<pic:cNvPicPr>'

                    '<a:picLocks/>'

                    '</pic:cNvPicPr>'

                    '</pic:nvPicPr>'

                    '<pic:blipFill>'

                    '<a:blip r:embed="'

                    id

                    '">'

                    '</a:blip>'

                    '<a:stretch><a:fillRect/></a:stretch>'

                    '</pic:blipFill>'

                    '<pic:spPr>'

                    '<a:xfrm>'

                    '<a:off y="'

                    lw_string_y

                    '" x="'

                    lw_string_x

                    '"/>'

                    '<a:ext cy="'

                    lw_string_h

                    '" cx="'

                    lw_string_w

                    '"/>'

                    '</a:xfrm>'

                    '<a:prstGeom prst="rect"/>'

                    lw_style

                    '</pic:spPr>'

                    '</pic:pic>'

                    INTO mw_fragxml.



      WHEN c_draw_rectangle.

* Default : white rect with 1pt black border

        CLEAR lw_style.

        IF bgcolor IS SUPPLIED AND NOT bgcolor IS INITIAL.

          lw_color = bgcolor.

        ELSE.

          lw_color = c_color_white.

        ENDIF.

        CONCATENATE lw_style

                    '<a:solidFill>'

                    '<a:srgbClr val="'

                    lw_color

                    '" />'

                    '</a:solidFill>'

                    INTO lw_style.



        IF bdcolor IS SUPPLIED AND NOT bdcolor IS INITIAL.

          lw_color = bdcolor.

        ELSE.

          lw_color = c_color_black.

        ENDIF.

        IF bdwidth IS SUPPLIED AND NOT bdwidth IS INITIAL.

          lw_width = c_basesize * bdwidth.

        ELSE.

          lw_width = c_basesize.

        ENDIF.

        lw_string = lw_width.

        CONDENSE lw_string NO-GAPS.



        CONCATENATE lw_style

                    '<a:ln w="'

                    lw_string

                    '">'

                    '<a:solidFill>'

                    '<a:srgbClr val="'

                    lw_color

                    '" />'

                    '</a:solidFill>'

                    '</a:ln>'

                    INTO lw_style.



        CONCATENATE mw_fragxml

                    '<wps:wsp>'

                    '<wps:cNvPr name="Rectangle" id="1"/>'

                    '<wps:cNvSpPr/>'

                    '<wps:spPr>'

                    '<a:xfrm>'

                    '<a:off y="'

                    lw_string_y

                    '" x="'

                    lw_string_x

                    '"/>'

                    '<a:ext cy="'

                    lw_string_h

                    '" cx="'

                    lw_string_w

                    '"/>'

                    '</a:xfrm>'

                    '<a:prstGeom prst="rect"/>'

                    lw_style

                    '</wps:spPr>'

                    '<wps:bodyPr />'

                    '</wps:wsp>'

                    INTO mw_fragxml RESPECTING BLANKS.

    ENDCASE.

  ENDMETHOD.                    "draw



  METHOD draw_finalize.



    CONCATENATE mw_docxml

                '<w:p>'

                mw_fragxml

                '</wpc:wpc>'

                '</a:graphicData>'

                '</a:graphic>'

                '</wp:anchor>'

                '</w:drawing>'

                '</mc:Choice>'

                '<mc:Fallback><w:t>Canva graphic cannot be loaded</w:t></mc:Fallback>'

                '</mc:AlternateContent>'

                '</w:r>'

                '</w:p>'

                INTO mw_docxml.

    CLEAR mw_fragxml.



  ENDMETHOD.                    "draw_finalize



  METHOD write_break.

    CASE breaktype.

      WHEN c_breaktype_line.

        CONCATENATE mw_fragxml

                    '<w:r><w:br/></w:r>'

                    INTO mw_fragxml.

      WHEN c_breaktype_page.

        CONCATENATE mw_fragxml

                    '<w:br w:type="page"/>'

                    INTO mw_fragxml.

      WHEN c_breaktype_section.

        CALL METHOD _write_section.

      WHEN c_breaktype_section_continuous.

        CALL METHOD _write_section.

        ms_section-continuous = c_true.

      WHEN OTHERS. "invalid breaktype

        sy-subrc = 8.

        RETURN.

    ENDCASE.

* Write line if required

* But also automatically except for simple break line

    IF write_line = c_true

    OR ( NOT write_line IS SUPPLIED AND breaktype NE c_breaktype_line ).

      CALL METHOD write_line.

    ENDIF.

  ENDMETHOD.                    "write_break



  METHOD _write_section.

    DATA : lw_size     TYPE string,

           lw_space    TYPE string,

           lw_substyle TYPE string.



    CLEAR mw_section_xml.



* In case of keep template content, first document section is the last

* template section

    IF NOT mw_tpl_section_xml IS INITIAL.

      mw_section_xml = mw_tpl_section_xml.

      CLEAR mw_tpl_section_xml.

      CLEAR ms_section.

      RETURN.

    ENDIF.



* Define header/footer

    IF NOT ms_section-header IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:headerReference w:type="default" r:id="'

                  ms_section-header

                  '"/>'

                  INTO mw_section_xml.

    ENDIF.

    IF NOT ms_section-footer IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:footerReference w:type="default" r:id="'

                  ms_section-footer

                  '"/>'

                  INTO mw_section_xml.

    ENDIF.

    IF NOT ms_section-header_first IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:headerReference w:type="first" r:id="'

                  ms_section-header_first

                  '"/>'

                  INTO mw_section_xml.

    ENDIF.

    IF NOT ms_section-footer_first IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:footerReference w:type="first" r:id="'

                  ms_section-footer_first

                  '"/>'

                  INTO mw_section_xml.

    ENDIF.



* Define page orientation

    IF ms_section-landscape = c_true.

      CONCATENATE mw_section_xml

                  '<w:pgSz w:w="16838" w:h="11906" w:orient="landscape"/>'

                  INTO mw_section_xml.

    ELSE.

      CONCATENATE mw_section_xml

                  '<w:pgSz w:w="11906" w:h="16838"/>'

                  INTO mw_section_xml.

    ENDIF.



* Border ?

    CLEAR lw_substyle.

    IF NOT ms_section-border_left-style IS INITIAL

    AND NOT ms_section-border_left-width IS INITIAL.

      lw_size = ms_section-border_left-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = ms_section-border_left-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:left w:val="'

                  ms_section-border_left-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  ms_section-border_left-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT ms_section-border_top-style IS INITIAL

    AND NOT ms_section-border_top-width IS INITIAL.

      lw_size = ms_section-border_top-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = ms_section-border_top-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:top w:val="'

                  ms_section-border_top-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  ms_section-border_top-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT ms_section-border_right-style IS INITIAL

    AND NOT ms_section-border_right-width IS INITIAL.

      lw_size = ms_section-border_right-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = ms_section-border_right-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:right w:val="'

                  ms_section-border_right-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  ms_section-border_right-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT ms_section-border_bottom-style IS INITIAL

    AND NOT ms_section-border_bottom-width IS INITIAL.

      lw_size = ms_section-border_bottom-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = ms_section-border_bottom-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:bottom w:val="'

                  ms_section-border_bottom-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  ms_section-border_bottom-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT lw_substyle IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:pgBorders w:offsetFrom="page">'

                  lw_substyle

                  '</w:pgBorders>'

                  INTO mw_section_xml RESPECTING BLANKS.

    ENDIF.



* Default section values / Standard page

    CONCATENATE mw_section_xml

                '<w:cols w:space="708"/>'

                '<w:docGrid w:linePitch="360"/>'

                '<w:pgMar w:top="1417" w:right="1417" w:bottom="1417" w:left="1417" w:header="708" w:footer="708" w:gutter="0"/>'

                INTO mw_section_xml.



    IF ms_section-continuous = c_true.

      CONCATENATE mw_section_xml

                  '<w:type w:val="continuous"/>'

                  INTO mw_section_xml.

    ENDIF.



    IF NOT ms_section-header_first IS INITIAL

    OR NOT ms_section-footer_first IS INITIAL.

      CONCATENATE mw_section_xml

                  '<w:titlePg/>'

                  INTO mw_section_xml.

    ENDIF.



    CONCATENATE '<w:sectPr>'

                mw_section_xml

                '</w:sectPr>'

                INTO mw_section_xml.



    CLEAR ms_section.



  ENDMETHOD.                    "write_section



  METHOD write_symbol.

    DATA lw_style_effect TYPE ty_character_style_effect.

    lw_style_effect-font = c_font_symbol.

    CALL METHOD write_text
      EXPORTING
        textline     = symbol
        style_effect = lw_style_effect.

  ENDMETHOD.                    "write_symbol



  METHOD write_headerfooter.

    DATA : lw_filename    TYPE string,

           lw_string      TYPE string,

           lw_file        TYPE string,

           lw_xml         TYPE string,

           lw_xmlns       TYPE string,

           lw_style       TYPE string,

           ls_list_object LIKE LINE OF mt_list_object.



    IF type NE c_type_header AND type NE c_type_footer.

      RETURN.

    ENDIF.



* Build header/footer xml fragment

    CALL METHOD write_text
      EXPORTING
        textline      = textline
        style_effect  = style_effect
        style         = style
      IMPORTING
        virtual       = lw_xml
        invalid_style = invalid_style.



    CLEAR lw_style.

    IF NOT line_style IS INITIAL OR NOT line_style_effect IS INITIAL.

      CALL METHOD _build_paragraph_style
        EXPORTING
          style         = line_style
          style_effect  = line_style_effect
        IMPORTING
          xml           = lw_style
          invalid_style = invalid_line_style.

    ENDIF.



    CALL METHOD _get_xml_ns
      IMPORTING
        xml = lw_xmlns.



    IF type = c_type_header.

      lw_string = 'hdr'.

    ELSE.

      lw_string = 'ftr'.

    ENDIF.

    CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

                '<w:'

                lw_string

                lw_xmlns

                '>'

                '<w:p>'

                lw_style

                lw_xml

                '</w:p>'

                '</w:'

                lw_string

                '>'

                INTO lw_xml RESPECTING BLANKS.



* Search available header/footer name

    DO.

      lw_filename = sy-index.

      CONCATENATE 'word/'

                  type

                  lw_filename

                  '.xml'

                  INTO lw_filename.

      CONDENSE lw_filename NO-GAPS.



      READ TABLE mo_zip->files WITH KEY name = lw_filename

                 TRANSPORTING NO FIELDS.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Add header/footer file into zip

    CALL METHOD _update_zip_file
      EXPORTING
        filename = lw_filename
        content  = lw_xml.



* Add content type exception for new header/footer

    CALL METHOD _get_zip_file
      EXPORTING
        filename = '[Content_Types].xml'
      IMPORTING
        content  = lw_file.

    CONCATENATE '<Override PartName="/'

                lw_filename

                '" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.'

                type

                '+xml"/>'

                '</Types>'

                INTO lw_string.

    REPLACE '</Types>' WITH lw_string INTO lw_file.



* Update content type file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = '[Content_Types].xml'
        content  = lw_file.



* Get relation file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/_rels/document.xml.rels'
      IMPORTING
        content  = lw_file.



* Create header/footer ID

    DO.

      id = 'rId' && sy-index.                               "#EC NOTEXT

      lw_string = 'Id="' && id && '"'.                      "#EC NOTEXT

      FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Update object list

    ls_list_object-id = id.

    ls_list_object-type = type.

    ls_list_object-path = lw_filename.

    APPEND ls_list_object TO mt_list_object.



* Add relation

    lw_filename = lw_filename+5.

    CONCATENATE '<Relationship Id="'

                id

                '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/'

                type

                '" Target="'

                lw_filename

                '"/>'

                '</Relationships>'

                INTO lw_string.

    REPLACE '</Relationships>' WITH lw_string INTO lw_file.



* Update relation file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/_rels/document.xml.rels'
        content  = lw_file.



    IF usenow_default = c_true AND type = c_type_header.

      CALL METHOD header_footer_direct_assign
        EXPORTING
          header = id.

    ELSEIF usenow_default = c_true AND type = c_type_footer.

      CALL METHOD header_footer_direct_assign
        EXPORTING
          footer = id.

    ENDIF.



    IF usenow_first = c_true AND type = c_type_header.

      CALL METHOD header_footer_direct_assign
        EXPORTING
          header_first = id.

    ELSEIF usenow_first = c_true AND type = c_type_footer.

      CALL METHOD header_footer_direct_assign
        EXPORTING
          footer_first = id.

    ENDIF.





  ENDMETHOD.                    "write_headerfooter



  METHOD set_title.

    set_properties( title = title ).

  ENDMETHOD.                    "set_title



  METHOD insert_custom_field.

    CONCATENATE mw_fragxml

                '<w:fldSimple w:instr=" DOCPROPERTY '

                field

                ' \* MERGEFORMAT "><w:r><w:rPr><w:b/></w:rPr><w:t>Please update field</w:t></w:r></w:fldSimple>'  ##NO_TEXT

                INTO mw_fragxml RESPECTING BLANKS.

  ENDMETHOD.                    "insert_custom_field



  METHOD insert_virtual_field.

    CONCATENATE mw_fragxml

                '<w:virtual>'

                field

                '</w:virtual>'

                INTO mw_fragxml.

  ENDMETHOD.                    "insert_virtual_field



  METHOD replace_virtual_field.

    DATA : lw_field TYPE string,

           lw_value TYPE string.

    CONCATENATE '<w:virtual>'

                field

                '</w:virtual>'

           INTO lw_field.



    CALL METHOD write_text
      EXPORTING
        textline      = value
        style_effect  = style_effect
        style         = style
      IMPORTING
        virtual       = lw_value
        invalid_style = invalid_style.



    REPLACE lw_field IN mw_fragxml WITH lw_value IGNORING CASE.

    IF sy-subrc NE 0.

      REPLACE lw_field IN mw_docxml WITH lw_value IGNORING CASE.

    ENDIF.

  ENDMETHOD.                    "replace_virtual_field



  METHOD create_custom_field. "not managed

    DATA : lw_file   TYPE string,

           lw_string TYPE string,

           lw_id     TYPE string.



* If customproperties does not exist, create it

    READ TABLE mo_zip->files WITH KEY name = 'docProps/custom.xml'

               TRANSPORTING NO FIELDS.

    IF sy-subrc NE 0.



* Declare new file in relations

      CALL METHOD _get_zip_file
        EXPORTING
          filename = '_rels/.rels'
        IMPORTING
          content  = lw_file.

* search available id

      DO.

        lw_id = 'rId' && sy-index.                          "#EC NOTEXT

        lw_string = 'Id="' && lw_id && '"'.                 "#EC NOTEXT

        FIND lw_string IN lw_file IGNORING CASE.

        IF sy-subrc NE 0.

          EXIT. "exit do

        ENDIF.

      ENDDO.



      CONCATENATE '<Relationship Target="docProps/custom.xml"'

                  ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties"'  ##NO_TEXT

                  ' Id="'  ##NO_TEXT

                  lw_id

                  '"/></Relationships>'

                  INTO lw_string RESPECTING BLANKS.

      REPLACE '</Relationships>' IN lw_file WITH lw_string.

      CALL METHOD _update_zip_file
        EXPORTING
          filename = '_rels/.rels'
          content  = lw_file.



* Declare new file in content type

      CALL METHOD _get_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
        IMPORTING
          content  = lw_file.

      REPLACE '</Types>' IN lw_file

              WITH '<Override ContentType="application/vnd.openxmlformats-officedocument.custom-properties+xml" PartName="/docProps/custom.xml"/></Types>'.

      CALL METHOD _update_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
          content  = lw_file.



      CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>'

                  '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"'

                  ' xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'

                  '</Properties>'

                  INTO lw_file RESPECTING BLANKS.

      CALL METHOD _update_zip_file
        EXPORTING
          filename = 'docProps/custom.xml'
          content  = lw_file.

    ENDIF.



* Open custom properties

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'docProps/custom.xml'
      IMPORTING
        content  = lw_file.



* Search available ID

    DO.

      IF sy-index = 1.

        CONTINUE.

      ENDIF.

      lw_id = sy-index.

      CONDENSE lw_id NO-GAPS.

      lw_string = 'pid="' && lw_id && '"'.

      FIND lw_string IN lw_file IGNORING CASE.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Add property

    CONCATENATE '<property fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}"'

                ' pid="'

                lw_id

                '" name="'

                field

                '">'

                '<vt:lpwstr>'

                value

                '</vt:lpwstr>'

                '</property>'

                '</Properties>'

                INTO lw_string RESPECTING BLANKS.

    REPLACE '</Properties>' IN lw_file WITH lw_string.



* Update custopproperties file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'docProps/custom.xml'
        content  = lw_file.





  ENDMETHOD.                    "create_custom_field



  METHOD create_character_style.

    DATA : lw_style      TYPE string,

           lw_file       TYPE string,

           lw_string     TYPE string,

           ls_list_style LIKE LINE OF mt_list_style.



* Build simple style internal name

    name = output_name.

    REPLACE ALL OCCURRENCES OF REGEX '[^A-Za-z0-9]'  IN name WITH space ##NO_TEXT .

    CONDENSE name NO-GAPS.



* Check style internal name is available

    READ TABLE mt_list_style WITH KEY type = c_type_character

                                      name = name

                             TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      CLEAR name.

      RETURN.

    ENDIF.



* Build character style

    CALL METHOD _build_character_style
      EXPORTING
        style_effect = style_effect
      IMPORTING
        xml          = lw_style.



    IF style_ref IS SUPPLIED AND NOT style_ref IS INITIAL.

      READ TABLE mt_list_style WITH KEY type = c_type_character

                                        name = style_ref

                               TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        CONCATENATE '<w:basedOn w:val="'

                    style_ref

                    '"/>'

                    INTO lw_string.

      ELSE.

        invalid_style = c_true.

      ENDIF.

    ENDIF.

    CONCATENATE '<w:style w:type="'

                c_type_character

                '" w:customStyle="1" w:styleId="'

                name

                '">'

                '<w:name w:val="'

                output_name

                '"/>'

                lw_string

                lw_style

                '</w:style>'

                '</w:styles>'

                INTO lw_style.



* Get styles file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/styles.xml'
      IMPORTING
        content  = lw_file.



* Update style file content

    REPLACE '</w:styles>' IN lw_file WITH lw_style.



* Update zipped style file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/styles.xml'
        content  = lw_file.



* Update style list

    CLEAR ls_list_style.

    ls_list_style-type = c_type_character.

    ls_list_style-name = name.

    APPEND ls_list_style TO mt_list_style.

  ENDMETHOD.                    "create_character_style



  METHOD create_paragraph_style.

    DATA : lw_style      TYPE string,

           lw_stylepr    TYPE string,

           lw_file       TYPE string,

           lw_string     TYPE string,

           ls_list_style LIKE LINE OF mt_list_style.



* Build simple style internal name

    name = output_name.

    REPLACE ALL OCCURRENCES OF REGEX '[^A-Za-z0-9]'   IN name WITH space ##NO_TEXT.

    CONDENSE name NO-GAPS.



* Check style internal name is available

    READ TABLE mt_list_style WITH KEY type = c_type_paragraph

                                      name = name

                             TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      CLEAR name.

      RETURN.

    ENDIF.



* Build character style

    CALL METHOD _build_character_style
      EXPORTING
        style_effect = style_effect
      IMPORTING
        xml          = lw_style.



* Build paragraph style

    CALL METHOD _build_paragraph_style
      EXPORTING
        style_effect = line_style_effect
      IMPORTING
        xml          = lw_stylepr.



    IF style_ref IS SUPPLIED AND NOT style_ref IS INITIAL.

      READ TABLE mt_list_style WITH KEY type = c_type_paragraph

                                        name = style_ref

                               TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        CONCATENATE '<w:basedOn w:val="'

                    style_ref

                    '"/>'

                    INTO lw_string.

      ELSE.

        invalid_style = c_true.

      ENDIF.

    ENDIF.

    CONCATENATE '<w:style w:type="'

                c_type_paragraph

                '" w:customStyle="1" w:styleId="'

                name

                '">'

                '<w:name w:val="'

                output_name

                '"/>'

                lw_string

                lw_stylepr

                lw_style

                '</w:style>'

                '</w:styles>'

                INTO lw_style.



* Get styles file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/styles.xml'
      IMPORTING
        content  = lw_file.



* Update style file content

    REPLACE '</w:styles>' IN lw_file WITH lw_style.



* Update zipped style file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/styles.xml'
        content  = lw_file.



* Update style list

    CLEAR ls_list_style.

    ls_list_style-type = c_type_paragraph.

    ls_list_style-name = name.

    APPEND ls_list_style TO mt_list_style.

  ENDMETHOD.                    "create_paragraph_style



  METHOD insert_image.

    DATA : lw_string   TYPE string,

           lw_imgres_x TYPE i,

           lw_imgres_y TYPE i.

    DATA : lw_scalex    TYPE f,

           lw_scaley    TYPE f,

           lw_scale_max TYPE i,

           lw_scale     TYPE i,

           lw_x         TYPE i,

           lw_y         TYPE i,

           lw_x_string  TYPE string,

           lw_y_string  TYPE string,

           lw_style     TYPE string.



    invalid_image = c_false.

    CALL METHOD _load_image
      EXPORTING
        url      = url
      IMPORTING
        imgres_x = lw_imgres_x
        imgres_y = lw_imgres_y
      CHANGING
        id       = id.

    IF id IS INITIAL.

      invalid_image = c_true.

      RETURN.

    ENDIF.



* Add paragraphe style

    IF NOT style IS INITIAL OR NOT style_effect IS INITIAL.

      CALL METHOD _build_paragraph_style
        EXPORTING
          style         = style
          style_effect  = style_effect
        IMPORTING
          xml           = lw_style
          invalid_style = invalid_style.

    ENDIF.



* Calculate image scale

    IF ms_section-landscape = c_true.

* Max X in landscape : 8877300

* Max Y in landscape : 5743575 "could be less... depend of header/footer

      lw_scalex = 8877300 / lw_imgres_x.

      lw_scaley = 5762625 / lw_imgres_y.

    ELSE.

* Max X in portrait : 5762625

* Max Y in portrait : 8886825 "could be less... depend of header/footer

      lw_scalex = 5762625 / lw_imgres_x.

      lw_scaley = 8886825 / lw_imgres_y.

    ENDIF.

    IF lw_scalex < lw_scaley.

      lw_scale_max = floor( lw_scalex ).

    ELSE.

      lw_scale_max = floor( lw_scaley ).

    ENDIF.

* Image is smaler than page

    IF lw_scale_max GT 9525.

      lw_scale = 9525. "no zoom

      IF zoom IS SUPPLIED.

        lw_scale = lw_scale * zoom.

        IF lw_scale GT lw_scale_max.

          lw_scale = lw_scale_max.

        ENDIF.

      ENDIF.

    ELSE.

* Image is greater than page

      lw_scale = lw_scale_max.

      IF zoom IS SUPPLIED AND zoom < 1.

        lw_scale_max = 9525 * zoom.

        IF lw_scale_max LT lw_scale.

          lw_scale = lw_scale_max.

        ENDIF.

      ENDIF.

    ENDIF.

    lw_x = lw_imgres_x * lw_scale.

    lw_y = lw_imgres_y * lw_scale.

    lw_x_string = lw_x.

    CONDENSE lw_x_string NO-GAPS.

    lw_y_string = lw_y.

    CONDENSE lw_y_string NO-GAPS.



* Finally insert image in document

    ADD 1 TO mw_imgmaxid.

    lw_string = mw_imgmaxid.

    CONDENSE lw_string NO-GAPS.



* Prepare image insertion xml fragment

    CONCATENATE

    '<w:p>'

    lw_style

    '<w:r>'

    '<w:drawing>'

    '<wp:inline distT="0" distB="0" distL="0" distR="0">'

    '<wp:extent cx="'

    lw_x_string

    '" cy="'

    lw_y_string

    '"/>'

    "'<wp:effectExtent l="0" t="0" r="0" b="8890"/>'

    '<wp:docPr id="'

    lw_string "mw_imgmaxid

    '" name=""/>'

    '<wp:cNvGraphicFramePr/>'

    '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">'

    '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'

    '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'

    '<pic:nvPicPr>'

    '<pic:cNvPr id="0" name=""/>'

    '<pic:cNvPicPr/>'

    '</pic:nvPicPr>'

    '<pic:blipFill>'

    '<a:blip r:embed="'

    id

    '"/>'

    '<a:stretch>'

    '<a:fillRect/>'

    '</a:stretch>'

    '</pic:blipFill>'

    '<pic:spPr>'

    '<a:xfrm>'

    '<a:off x="0" y="0"/>'

    '<a:ext cx="'

    lw_x_string

    '" cy="'

    lw_y_string

    '"/>'

    '</a:xfrm>'

    '<a:prstGeom prst="rect">'

    '<a:avLst/>'

    '</a:prstGeom>'

    '</pic:spPr>'

    '</pic:pic>'

    '</a:graphicData>'

    '</a:graphic>'

    '</wp:inline>'

    '</w:drawing>'

    '</w:r>'

    '</w:p>'

    INTO virtual.



* Insert image in document

    IF NOT virtual IS SUPPLIED.

      CONCATENATE mw_docxml virtual INTO mw_docxml.

    ENDIF.

  ENDMETHOD.                    "insert_image



  METHOD set_properties.

    DATA : lw_xml    TYPE string,

           lw_string TYPE string.



* Get prperties file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'docProps/core.xml'
      IMPORTING
        content  = lw_xml.



    IF title IS SUPPLIED.

* Replace existing title by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = title
        IMPORTING
          out = lw_string.

      CONCATENATE '<dc:title>'

                  lw_string

                  '</dc:title>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dc:title>(.*)</dc:title>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dc:title\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no title property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF object IS SUPPLIED.

* Replace existing object by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = object
        IMPORTING
          out = lw_string.

      CONCATENATE '<dc:subject>'

                  lw_string

                  '</dc:subject>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dc:subject>(.*)</dc:subject>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dc:subject\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no object property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF author IS SUPPLIED.

* Replace existing author by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = author
        IMPORTING
          out = mw_author.

      CONCATENATE '<dc:creator>'

                  mw_author

                  '</dc:creator>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dc:creator>(.*)</dc:creator>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dc:creator\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no author property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

* Set also last modified property

      CALL METHOD _protect_string
        EXPORTING
          in  = author
        IMPORTING
          out = lw_string.

      CONCATENATE '<cp:lastModifiedBy>'

                  lw_string

                  '</cp:lastModifiedBy>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<cp:lastModifiedBy>(.*)</cp:lastModifiedBy>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<cp:lastModifiedBy\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no lastmodified property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF creationdate IS SUPPLIED.

* Replace existing creation date by new one

      CONCATENATE '<dcterms:created xsi:type="dcterms:W3CDTF">'

                  creationdate(4)

                  '-'

                  creationdate+4(2)

                  '-'

                  creationdate+6(2)

                  'T'

                  creationtime(2)

                  ':'

                  creationtime+2(2)

                  ':'

                  creationtime+2(2)

                  'Z'

                  '</dcterms:created>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dcterms:created(.*)</dcterms:created>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dcterms:created\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no creation date property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

* Replace also last modification date by new one

      CONCATENATE '<dcterms:modified xsi:type="dcterms:W3CDTF">'

                  creationdate(4)

                  '-'

                  creationdate+4(2)

                  '-'

                  creationdate+6(2)

                  'T'

                  creationtime(2)

                  ':'

                  creationtime+2(2)

                  ':'

                  creationtime+2(2)

                  'Z'

                  '</dcterms:modified>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dcterms:modified(.*)</dcterms:modified>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dcterms:modified\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no modification date property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF description IS SUPPLIED.

* Replace existing description by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = description
        IMPORTING
          out = lw_string.

      CONCATENATE '<dc:description>'

                  lw_string

                  '</dc:description>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<dc:description>(.*)</dc:description>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<dc:description\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no description property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF category IS SUPPLIED.

* Replace existing category by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = category
        IMPORTING
          out = lw_string.

      CONCATENATE '<cp:category>'

                  lw_string

                  '</cp:category>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<cp:category>(.*)</cp:category>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<cp:category\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no category property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF keywords IS SUPPLIED.

* Replace existing keywords by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = keywords
        IMPORTING
          out = lw_string.

      CONCATENATE '<cp:keywords>'

                  lw_string

                  '</cp:keywords>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<cp:keywords>(.*)</cp:keywords>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<cp:keywords\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no keywords property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF status IS SUPPLIED.

* Replace existing status by new one

      CALL METHOD _protect_string
        EXPORTING
          in  = status
        IMPORTING
          out = lw_string.

      CONCATENATE '<cp:contentStatus>'

                  lw_string

                  '</cp:contentStatus>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<cp:contentStatus>(.*)</cp:contentStatus>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<cp:contentStatus\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no status property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



    IF revision IS SUPPLIED.

* Replace existing status by new one

      lw_string = revision.

      CONDENSE lw_string NO-GAPS.

      CONCATENATE '<cp:revision>'

                  lw_string

                  '</cp:revision>'

                  INTO lw_string.

      REPLACE FIRST OCCURRENCE OF REGEX '<cp:revision>(.*)</cp:revision>' IN lw_xml WITH lw_string.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF REGEX '<cp:revision\s*/>' IN lw_xml WITH lw_string.

      ENDIF.

* If no revision property found, add it at end of xml

      IF sy-subrc NE 0.

        CONCATENATE lw_string

                    '</cp:coreProperties>'

                    INTO lw_string.

        REPLACE '</cp:coreProperties>'

                WITH lw_string

                INTO lw_xml.

      ENDIF.

    ENDIF.



* Update properties file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'docProps/core.xml'
        content  = lw_xml.



  ENDMETHOD.                    "set_properties



  METHOD set_params.

    DATA : lw_xml   TYPE string,

           lw_xmlns TYPE string.



* Define orientation

    IF orientation = c_orient_landscape.

      ms_section-landscape = c_true.

    ENDIF.



* Define Border

    IF border_left IS SUPPLIED.

      ms_section-border_left = border_left.

    ENDIF.

    IF border_top IS SUPPLIED.

      ms_section-border_top = border_top.

    ENDIF.

    IF border_right IS SUPPLIED.

      ms_section-border_right = border_right.

    ENDIF.

    IF border_bottom IS SUPPLIED.

      ms_section-border_bottom = border_bottom.

    ENDIF.



* Hide spellcheck for this document

    IF nospellcheck NE c_false.

      CALL METHOD _get_zip_file
        EXPORTING
          filename = 'word/settings.xml'
        IMPORTING
          content  = lw_xml.

* File doesnt exist ? create it !

      IF lw_xml IS INITIAL.

        CALL METHOD _get_xml_ns
          IMPORTING
            xml = lw_xmlns.

        CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

                    '<w:settings '

                    lw_xmlns

                    '>'

                    '</w:settings>'

                    INTO lw_xml RESPECTING BLANKS.

      ENDIF.

      FIND 'hideSpellingErrors' IN lw_xml.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF '</w:settings>'

                IN lw_xml

                WITH '<w:hideSpellingErrors/></w:settings>'

                IGNORING CASE.

      ENDIF.

      FIND 'hideGrammaticalErrors' IN lw_xml.

      IF sy-subrc NE 0.

        REPLACE FIRST OCCURRENCE OF '</w:settings>'

                IN lw_xml

                WITH '<w:hideGrammaticalErrors/></w:settings>'

                IGNORING CASE.

      ENDIF.

      CALL METHOD _update_zip_file
        EXPORTING
          filename = 'word/settings.xml'
          content  = lw_xml.

    ENDIF.

  ENDMETHOD.                    "set_params



  METHOD save.

    DATA : lt_data_tab TYPE STANDARD TABLE OF x255,

           lw_lraw     TYPE x255,

           lw_docx     TYPE xstring,

           lw_xlen     TYPE i,

           lw_count    TYPE i,

           lw_off      TYPE i,

           lw_mod      TYPE i.



    CALL METHOD get_docx_file
      IMPORTING
        xcontent = lw_docx.



* Convert docx xString to xTable(255)

    REFRESH lt_data_tab.

    CLEAR   lw_off.

    lw_xlen  = xstrlen( lw_docx ).

    lw_count = lw_xlen DIV 255.

    DO lw_count TIMES.

      lw_lraw = lw_docx+lw_off(255).

      lw_off = lw_off + 255.

      APPEND lw_lraw TO lt_data_tab.

    ENDDO.

    lw_mod = lw_xlen MOD 255.

    IF lw_mod > 0.

      lw_lraw = lw_docx+lw_off(lw_mod).

      APPEND lw_lraw TO lt_data_tab.

    ENDIF.

    CLEAR lw_docx.



* Save document on server

    IF local = c_false.

      OPEN DATASET gv_url FOR OUTPUT IN BINARY MODE.

      IF sy-subrc NE 0.

* Error opening the file

        MESSAGE 'Cannot create remote file' TYPE 'E'  ##NO_TEXT.

        RETURN.

      ENDIF.

      LOOP AT lt_data_tab INTO lw_lraw.

        IF lw_xlen > 255.

          lw_mod = 255.

        ELSE.

          lw_mod = lw_xlen.

        ENDIF.

        TRANSFER lw_lraw TO gv_url LENGTH lw_mod.

        lw_xlen = lw_xlen - lw_mod.

      ENDLOOP.

      CLOSE DATASET gv_url.



* Save document on local computer

    ELSEIF local = c_true.

      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          bin_filesize            = lw_xlen
          filename                = gv_full_path
          filetype                = 'BIN'
          confirm_overwrite       = abap_true
        CHANGING
          data_tab                = lt_data_tab
        EXCEPTIONS
          file_write_error        = 1
          no_batch                = 2
          gui_refuse_filetransfer = 3
          invalid_type            = 4
          no_authority            = 5
          unknown_error           = 6
          header_not_allowed      = 7
          separator_not_allowed   = 8
          filesize_not_allowed    = 9
          header_too_long         = 10
          dp_error_create         = 11
          dp_error_send           = 12
          dp_error_write          = 13
          unknown_dp_error        = 14
          access_denied           = 15
          dp_out_of_memory        = 16
          disk_full               = 17
          dp_timeout              = 18
          file_not_found          = 19
          dataprovider_exception  = 20
          control_flush_error     = 21
          not_supported_by_gui    = 22
          error_no_gui            = 23
          OTHERS                  = 24.

* Error on save

      IF sy-subrc NE 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno.

      ENDIF.

    ENDIF.



  ENDMETHOD.                    "save



  METHOD get_docx_file.

    DATA lw_xmlns TYPE string.



    CLEAR xcontent.



* Add final section info

    CALL METHOD _write_section.

    CONCATENATE mw_docxml mw_section_xml INTO mw_docxml.



    CALL METHOD _get_xml_ns
      IMPORTING
        xml = lw_xmlns.



* Add complete xml header

    CONCATENATE

    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

    '<w:document '

    lw_xmlns

    '>'

    '<w:body>'

    mw_docxml

    '</w:body></w:document>'

    INTO mw_docxml RESPECTING BLANKS.



* Add custom body into docx

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/document.xml'
        content  = mw_docxml.



* Get final docx

    CALL METHOD mo_zip->save
      RECEIVING
        zip = xcontent.



  ENDMETHOD.                    "get_docx_file



  METHOD header_footer_direct_assign.

    invalid_header = c_false.

    invalid_footer = c_false.

    IF header IS SUPPLIED.

      sy-subrc = 0.

      IF NOT header IS INITIAL.

        READ TABLE mt_list_object WITH KEY type = c_type_header

                                           id = header

                                  TRANSPORTING NO FIELDS.

      ENDIF.

      IF sy-subrc = 0.

        ms_section-header = header.

      ELSE.

        invalid_header = c_true.

      ENDIF.

    ENDIF.

    IF footer IS SUPPLIED.

      sy-subrc = 0.

      IF NOT footer IS INITIAL.

        READ TABLE mt_list_object WITH KEY type = c_type_footer

                                           id = footer

                                  TRANSPORTING NO FIELDS.

      ENDIF.

      IF sy-subrc = 0.

        ms_section-footer = footer.

      ELSE.

        invalid_footer = c_true.

      ENDIF.

    ENDIF.

    IF header_first IS SUPPLIED.

      sy-subrc = 0.

      IF NOT header_first IS INITIAL.

        READ TABLE mt_list_object WITH KEY type = c_type_header

                                           id = header_first

                                  TRANSPORTING NO FIELDS.

      ENDIF.

      IF sy-subrc = 0.

        ms_section-header_first = header_first.

      ELSE.

        invalid_header = c_true.

      ENDIF.

    ENDIF.

    IF footer_first IS SUPPLIED.

      sy-subrc = 0.

      IF NOT footer_first IS INITIAL.

        READ TABLE mt_list_object WITH KEY type = c_type_footer

                                           id = footer_first

                                  TRANSPORTING NO FIELDS.

      ENDIF.

      IF sy-subrc = 0.

        ms_section-footer_first = footer_first.

      ELSE.

        invalid_footer = c_true.

      ENDIF.

    ENDIF.

  ENDMETHOD.                    "header_footer_direct_assign



  METHOD get_list_style.

    style_list[] = mt_list_style[].

  ENDMETHOD.                    "get_list_style



  METHOD get_list_image.

    DATA ls_list_object LIKE LINE OF mt_list_object.

    REFRESH image_list.

    LOOP AT mt_list_object INTO ls_list_object WHERE type = c_type_image.

      APPEND ls_list_object TO image_list.

    ENDLOOP.

  ENDMETHOD.                    "get_list_image



  METHOD get_list_headerfooter.

    DATA ls_list_object LIKE LINE OF mt_list_object.

    REFRESH headerfooter_list.

    LOOP AT mt_list_object INTO ls_list_object

         WHERE type = c_type_header OR type = c_type_footer.

      APPEND ls_list_object TO headerfooter_list.

    ENDLOOP.

  ENDMETHOD.                    "get_list_headerfooter



  METHOD insert_xml_fragment.

    CONCATENATE mw_fragxml xml INTO mw_fragxml.

  ENDMETHOD.                    "insert_xml_fragment



  METHOD insert_xml.

    CONCATENATE mw_docxml xml INTO mw_docxml.

  ENDMETHOD.                    "insert_xml



  METHOD _get_zip_file.

    DATA : lw_xmlx        TYPE xstring,

           lw_xmlx_length TYPE i,

           lt_xmlx        TYPE STANDARD TABLE OF x255.



* Get zipped file

    CALL METHOD mo_zip->get
      EXPORTING
        name    = filename
      IMPORTING
        content = lw_xmlx
      EXCEPTIONS
        OTHERS  = 2.

    IF sy-subrc <> 0.

      RETURN.

    ENDIF.



* Transform xstring to string in 2 steps

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lw_xmlx
      IMPORTING
        output_length = lw_xmlx_length
      TABLES
        binary_tab    = lt_xmlx.



    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length = lw_xmlx_length
      IMPORTING
        text_buffer  = content
      TABLES
        binary_tab   = lt_xmlx.



  ENDMETHOD.                    "_get_zip_file



  METHOD _update_zip_file.

    DATA : lw_docx TYPE xstring.



* File content string => xstring

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = content
      IMPORTING
        buffer = lw_docx.



* If target file already exist, remove it

    READ TABLE mo_zip->files WITH KEY name = filename

               TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      CALL METHOD mo_zip->delete
        EXPORTING
          name = filename.

    ENDIF.



* Add modified file into zip

    CALL METHOD mo_zip->add
      EXPORTING
        name    = filename
        content = lw_docx.



  ENDMETHOD.                    "_update_zip_file



  METHOD _load_file.

    DATA : lt_data_tab     TYPE STANDARD TABLE OF x255,

           lw_length       TYPE i,

           lw_url_begin(6) TYPE c.

    DATA : lt_query  TYPE TABLE OF w3query,

           ls_query  TYPE w3query,

           lt_html   TYPE TABLE OF w3html,

           lt_mime   TYPE TABLE OF w3mime,

           lw_return TYPE w3param-ret_code,

           lw_type   TYPE w3param-cont_type.



    CLEAR xcontent.

    lw_url_begin = filename.



* Load image



* For others, read file

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename   = filename
        filetype   = 'BIN'
      IMPORTING
        filelength = lw_length
      CHANGING
        data_tab   = lt_data_tab
      EXCEPTIONS
        OTHERS     = 19.

    IF sy-subrc NE 0.

      RETURN.

    ENDIF.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lw_length
      IMPORTING
        buffer       = xcontent
      TABLES
        binary_tab   = lt_data_tab
      EXCEPTIONS
        OTHERS       = 2.

    IF sy-subrc NE 0.

      RETURN.

    ENDIF.

  ENDMETHOD.                    "_load_file



  METHOD _load_image.

    DATA : lw_filex        TYPE xstring,

           lw_filename     TYPE string,

           lw_string       TYPE string,

           lw_file         TYPE string,

           lw_url_begin(6) TYPE c,

           ls_list_object  LIKE LINE OF mt_list_object.



    CLEAR : extension, imgres_x, imgres_y.



* For existing image (ID given), just get img_res and extension.

    IF NOT id IS INITIAL.

      READ TABLE mt_list_object WITH KEY type = c_type_image

                                         id = id

                                INTO ls_list_object.

      IF sy-subrc NE 0.

        CLEAR id.

        RETURN.

      ENDIF.

      IF extension IS SUPPLIED.

        FIND ALL OCCURRENCES OF '.' IN ls_list_object-path

             MATCH OFFSET sy-fdpos.

        IF sy-subrc = 0.

          sy-fdpos = sy-fdpos + 1.

          extension = ls_list_object-path+sy-fdpos.

          TRANSLATE extension TO LOWER CASE.

          IF extension = 'jpeg'.

            extension = 'jpg'.

          ENDIF.

        ENDIF.

      ENDIF.

      IF imgres_x IS SUPPLIED OR imgres_y IS SUPPLIED.

        CALL METHOD mo_zip->get
          EXPORTING
            name    = ls_list_object-path
          IMPORTING
            content = lw_filex
          EXCEPTIONS
            OTHERS  = 2.

        IF sy-subrc = 0.

          CALL METHOD cl_fxs_image_info=>determine_info
            EXPORTING
              iv_data = lw_filex
            IMPORTING
              ev_xres = imgres_x
              ev_yres = imgres_y.

        ENDIF.

      ENDIF.

      RETURN.

    ENDIF.



* For new image, load image

    lw_url_begin = url.

    TRANSLATE lw_url_begin TO UPPER CASE.

* For image from sapwr, get file extension from DB

    IF lw_url_begin = c_sapwr_prefix.

      SELECT SINGLE value INTO extension

             FROM wwwparams

             WHERE relid = 'MI'

             AND objid = url+6

             AND name = 'fileextension'.

      IF NOT extension IS INITIAL AND extension(1) = '.'.

        extension = extension+1.

      ENDIF.

    ELSE.

* For other image, get file extension from filename

      FIND ALL OCCURRENCES OF '.' IN url MATCH OFFSET sy-fdpos.

      IF sy-subrc = 0.

        sy-fdpos = sy-fdpos + 1.

        extension = url+sy-fdpos.

        TRANSLATE extension TO LOWER CASE.

        IF extension = 'jpeg'.

          extension = 'jpg'.

        ENDIF.

      ENDIF.

    ENDIF.

* Cannot add image other than jpg/png/gif

    IF extension  NE 'jpg'

    AND extension NE 'png'

    AND extension NE 'gif'.

      RETURN.

    ENDIF.



* Load image

    CALL METHOD _load_file
      EXPORTING
        filename = url
      IMPORTING
        xcontent = lw_filex.

    IF lw_filex IS INITIAL.

      RETURN.

    ENDIF.



* Get image resolution

    IF imgres_x IS SUPPLIED OR imgres_y IS SUPPLIED.

      CALL METHOD cl_fxs_image_info=>determine_info
        EXPORTING
          iv_data = lw_filex
        IMPORTING
          ev_xres = imgres_x
          ev_yres = imgres_y.

    ENDIF.



* Search available image name

    DO.

      lw_filename = 'word/media/image' && sy-index && '.' && extension.

      READ TABLE mo_zip->files WITH KEY name = lw_filename

                 TRANSPORTING NO FIELDS.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Add image in ZIP

    CALL METHOD mo_zip->add
      EXPORTING
        name    = lw_filename
        content = lw_filex.



* Get file extension list

    CALL METHOD _get_zip_file
      EXPORTING
        filename = '[Content_Types].xml'
      IMPORTING
        content  = lw_file.



* Search if file extension exist

    CONCATENATE 'extension="' extension '"' INTO lw_string.

    FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

    IF sy-subrc NE 0.

* If extension is not yet declared, it's time !

      CASE extension.

        WHEN 'jpg'.

          REPLACE '</Types>' WITH '<Default ContentType="image/jpeg" Extension="jpg"/></Types>'

                  INTO lw_file.

        WHEN 'png'.

          REPLACE '</Types>' WITH '<Default ContentType="image/png" Extension="png"/></Types>'

                  INTO lw_file.

        WHEN 'gif'.

          REPLACE '</Types>' WITH '<Default ContentType="image/gif" Extension="gif"/></Types>'

                  INTO lw_file.

      ENDCASE.



* Update file extension list

      CALL METHOD _update_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
          content  = lw_file.

    ENDIF.



* Get relation file

    CALL METHOD _get_zip_file
      EXPORTING
        filename = 'word/_rels/document.xml.rels'
      IMPORTING
        content  = lw_file.



* Create Image ID

    DO.

      id = 'rId' && sy-index.                               "#EC NOTEXT

      lw_string = 'Id="' && id && '"'.                      "#EC NOTEXT

      FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Update object list

    CLEAR ls_list_object.

    ls_list_object-id = id.

    ls_list_object-type = c_type_image.

    ls_list_object-path = lw_filename.

    APPEND ls_list_object TO mt_list_object.



* Add relation

    lw_filename = lw_filename+5.

    CONCATENATE '<Relationship Target="'

                lw_filename

                '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Id="'

                id

                '"/>'

                '</Relationships>'

                INTO lw_string.

    REPLACE '</Relationships>' WITH lw_string INTO lw_file.



* Update relation file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = 'word/_rels/document.xml.rels'
        content  = lw_file.

  ENDMETHOD.                    "_load_image



  METHOD _create_note.

    DATA : lw_filename   TYPE string,

           lw_string     TYPE string,

           lw_file       TYPE string,

           lw_link_style TYPE string,

           lw_line_style TYPE string,

           lw_text       TYPE string,

           lw_xmlns      TYPE string,

           lw_id         TYPE string.



* Search if notes file exist

    IF type = c_notetype_foot.

      lw_filename = 'word/footnotes.xml'.

    ELSEIF type = c_notetype_end.

      lw_filename = 'word/endnotes.xml'.

    ELSE.

      RETURN.

    ENDIF.



    READ TABLE mo_zip->files WITH KEY name = lw_filename

               TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

* If foot/end notes exists, load the file

      CALL METHOD _get_zip_file
        EXPORTING
          filename = lw_filename
        IMPORTING
          content  = lw_file.

    ELSE.

* If footnotes doesnt exist, declare it and create it

* Add footnotes in content_types

      CALL METHOD _get_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
        IMPORTING
          content  = lw_file.



      IF type = c_notetype_foot.

        CONCATENATE '<Override'

                    ' ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"'  ##NO_TEXT

                    ' PartName="/word/footnotes.xml"/></Types>'

                    INTO lw_string RESPECTING BLANKS.

      ELSEIF type = c_notetype_end.

        CONCATENATE '<Override'

                    ' ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"'  ##NO_TEXT

                    ' PartName="/word/endnotes.xml"/></Types>'

                    INTO lw_string RESPECTING BLANKS.

      ENDIF.

      REPLACE '</Types>' WITH lw_string

              INTO lw_file.



      CALL METHOD _update_zip_file
        EXPORTING
          filename = '[Content_Types].xml'
          content  = lw_file.



* Add footnotes in relation file

      CALL METHOD _get_zip_file
        EXPORTING
          filename = 'word/_rels/document.xml.rels'
        IMPORTING
          content  = lw_file.



* Create footnotes relation ID

      DO.

        lw_id = 'rId' && sy-index.                          "#EC NOTEXT

        lw_string = 'Id="' && lw_id && '"'.                 "#EC NOTEXT

        FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

        IF sy-subrc NE 0.

          EXIT. "exit do

        ENDIF.

      ENDDO.



* Add relation

      IF type = c_notetype_foot.

        CONCATENATE '<Relationship Target="footnotes.xml"'

                    ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes"'

                    ' Id="'  ##NO_TEXT

                    lw_id

                    '"/>'

                    '</Relationships>'

                    INTO lw_string RESPECTING BLANKS.

      ELSEIF type = c_notetype_end.

        CONCATENATE '<Relationship Target="endnotes.xml"'

                    ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes"'

                    ' Id="'  ##NO_TEXT

                    lw_id

                    '"/>'

                    '</Relationships>'

                    INTO lw_string RESPECTING BLANKS.

      ENDIF.

      REPLACE '</Relationships>' WITH lw_string INTO lw_file.



* Update relation file

      CALL METHOD _update_zip_file
        EXPORTING
          filename = 'word/_rels/document.xml.rels'
          content  = lw_file.



      CALL METHOD _get_xml_ns
        IMPORTING
          xml = lw_xmlns.



* Create notes file

      IF type = c_notetype_foot.

        CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

                    '<w:footnotes '

                    lw_xmlns

                    '>'

                    '<w:footnote w:id="-1" w:type="separator">'

                    '<w:p>'

                    '<w:pPr><w:spacing w:lineRule="auto" w:line="240" w:after="0"/></w:pPr>'

                    '<w:r><w:separator/></w:r>'

                    '</w:p>'

                    '</w:footnote>'

                    '<w:footnote w:id="0" w:type="continuationSeparator">'

                    '<w:p>'

                    '<w:pPr><w:spacing w:lineRule="auto" w:line="240" w:after="0"/></w:pPr>'

                    '<w:r><w:continuationSeparator/></w:r>'

                    '</w:p>'

                    '</w:footnote>'

                    '</w:footnotes>'

                    INTO lw_file RESPECTING BLANKS.

      ELSEIF type = c_notetype_end.

        CONCATENATE '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

                    '<w:endnotes '

                    lw_xmlns

                    '>'

                    '<w:endnote w:id="-1" w:type="separator">'

                    '<w:p>'

                    '<w:pPr><w:spacing w:lineRule="auto" w:line="240" w:after="0"/></w:pPr>'

                    '<w:r><w:separator/></w:r>'

                    '</w:p>'

                    '</w:endnote>'

                    '<w:endnote w:id="0" w:type="continuationSeparator">'

                    '<w:p>'

                    '<w:pPr><w:spacing w:lineRule="auto" w:line="240" w:after="0"/></w:pPr>'

                    '<w:r><w:continuationSeparator/></w:r>'

                    '</w:p>'

                    '</w:endnote>'

                    '</w:endnotes>'

                    INTO lw_file RESPECTING BLANKS.

      ENDIF.

    ENDIF.



* Search available note id

    DO.

      id = sy-index.

      CONDENSE id NO-GAPS.

      lw_string = 'w:id="' && id && '"'.                    "#EC NOTEXT

      FIND FIRST OCCURRENCE OF lw_string IN lw_file IGNORING CASE.

      IF sy-subrc NE 0.

        EXIT. "exit do

      ENDIF.

    ENDDO.



* Add blank at start of note

    lw_text = text.

    IF lw_text IS INITIAL OR lw_text(1) NE space.

      CONCATENATE space lw_text INTO lw_text RESPECTING BLANKS.

    ENDIF.



    CALL METHOD write_text
      EXPORTING
        textline      = lw_text
        style_effect  = style_effect
        style         = style
      IMPORTING
        virtual       = lw_text
        invalid_style = invalid_style.



    IF NOT link_style_effect IS INITIAL OR NOT link_style IS INITIAL.

      CALL METHOD _build_character_style
        EXPORTING
          style        = link_style
          style_effect = link_style_effect
        IMPORTING
          xml          = lw_link_style.

    ENDIF.



    IF NOT line_style_effect IS INITIAL OR NOT line_style IS INITIAL.

      CALL METHOD _build_paragraph_style
        EXPORTING
          style         = line_style
          style_effect  = line_style_effect
        IMPORTING
          xml           = lw_line_style
          invalid_style = invalid_line_style.

    ENDIF.



* Add note

    IF type = c_notetype_foot.

      CONCATENATE '<w:footnote w:id="'

                  id

                  '">'

                  '<w:p>'

                  lw_line_style

                  '<w:r>'

                  lw_link_style

                  '<w:footnoteRef/>'

                  '</w:r>'

                  lw_text

                  '</w:p>'

                  '</w:footnote>'

                  '</w:footnotes>'

                  INTO lw_string RESPECTING BLANKS.

      REPLACE FIRST OCCURRENCE OF '</w:footnotes>' IN lw_file WITH lw_string.

    ELSEIF type = c_notetype_end.

      CONCATENATE '<w:endnote w:id="'

                  id

                  '">'

                  '<w:p>'

                  lw_line_style

                  '<w:r>'

                  lw_link_style

                  '<w:endnoteRef/>'

                  '</w:r>'

                  lw_text

                  '</w:p>'

                  '</w:endnote>'

                  '</w:endnotes>'

                  INTO lw_string RESPECTING BLANKS.

      REPLACE FIRST OCCURRENCE OF '</w:endnotes>' IN lw_file WITH lw_string.

    ENDIF.



* Update footnotes file

    CALL METHOD _update_zip_file
      EXPORTING
        filename = lw_filename
        content  = lw_file.



  ENDMETHOD.                    "_create_footnote



  METHOD _protect_string.

    out = in.

    REPLACE ALL OCCURRENCES OF '&' IN out WITH '&amp;'.

    REPLACE ALL OCCURRENCES OF '<' IN out WITH '&lt;'.

    REPLACE ALL OCCURRENCES OF '>' IN out WITH '&gt;'.

    REPLACE ALL OCCURRENCES OF '"' IN out WITH '&quot;'.

  ENDMETHOD.                    "_protect_string



  METHOD _protect_label.

    out = in.

    TRANSLATE out USING ' _'.

  ENDMETHOD.                    "_protect_label



  METHOD _build_character_style.

    DATA : lw_string   TYPE string,

           lw_char6(6) TYPE c,

           lw_intsize  TYPE i.



    CLEAR xml.



    IF style_effect IS SUPPLIED.

      IF NOT style_effect-color IS INITIAL.

        CONCATENATE xml

                    '<w:color w:val="'

                    style_effect-color

                    '"/>'

                    INTO xml.

      ENDIF.



      IF NOT style_effect-bgcolor IS INITIAL.

        CONCATENATE xml

                    '<w:shd w:val="clear" w:color="auto" w:fill="'

                    style_effect-bgcolor

                    '"/>'

                    INTO xml.

      ENDIF.



      IF style_effect-bold = c_true.

        CONCATENATE xml

                    '<w:b/>'

                    INTO xml.

      ENDIF.



      IF style_effect-italic = c_true.

        CONCATENATE xml

                    '<w:i/>'

                    INTO xml.

      ENDIF.



      IF style_effect-underline = c_true.

        CONCATENATE xml

                    '<w:u w:val="single"/>'

                    INTO xml.

      ENDIF.



      IF style_effect-strike = c_true.

        CONCATENATE xml

                    '<w:strike/>'

                    INTO xml.

      ENDIF.



      IF style_effect-caps = c_true.

        CONCATENATE xml

                    '<w:caps/>'

                    INTO xml.

      ENDIF.



      IF style_effect-smallcaps = c_true.

        CONCATENATE xml

                    '<w:smallCaps/>'

                    INTO xml.

      ENDIF.



      IF NOT style_effect-highlight IS INITIAL.

        CONCATENATE xml

                    '<w:highlight w:val="'

                    style_effect-highlight

                    '"/>'

                    INTO xml.

      ENDIF.



      IF NOT style_effect-spacing IS INITIAL AND style_effect-spacing = '0123456789 -'.

        IF style_effect-spacing GT 0.

          lw_string = style_effect-spacing.

          CONDENSE lw_string NO-GAPS.

        ELSE.

          lw_string = - style_effect-spacing.

          CONDENSE lw_string NO-GAPS.

          CONCATENATE '-' lw_string INTO lw_string.

        ENDIF.

        CONCATENATE xml

                    '<w:spacing w:val="'

                    lw_string

                    '"/>'

                    INTO xml.

      ENDIF.



      IF style_effect-size IS NOT INITIAL.

        lw_intsize = style_effect-size * 2.

        lw_char6 = lw_intsize.

        CONDENSE lw_char6 NO-GAPS.

        CONCATENATE xml

                    '<w:sz w:val="'

                    lw_char6

                    '"/>'

                    '<w:szCs w:val="'

                    lw_char6

                    '"/>'

                    INTO xml.

      ENDIF.



      IF style_effect-sup = c_true.

        CONCATENATE xml

                    '<w:vertAlign w:val="superscript"/>'

                    INTO xml.

      ELSEIF style_effect-sub = c_true.

        CONCATENATE xml

                    '<w:vertAlign w:val="subscript"/>'

                    INTO xml.

      ENDIF.



      IF NOT style_effect-font IS INITIAL.

        CONCATENATE xml

                    '<w:rFonts w:ascii="'

                    style_effect-font

                    '" w:hAnsi="'

                    style_effect-font

                    '"/>'

                    INTO xml.

      ENDIF.

    ENDIF.



    IF style IS SUPPLIED AND style IS NOT INITIAL.

      READ TABLE mt_list_style WITH KEY type = c_type_character

                                        name = style

                               TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        CONCATENATE xml

                    '<w:rStyle w:val="'

                    style

                    '"/>'

                    INTO xml.

      ELSE.

        invalid_style = c_true.

      ENDIF.

    ENDIF.



    IF NOT xml IS INITIAL.

      CONCATENATE '<w:rPr>'

                  xml

                  '</w:rPr>'

                  INTO xml.

    ENDIF.

  ENDMETHOD.                    "_build_character_style



  METHOD _build_paragraph_style.

    DATA : lw_substyle TYPE string,

           lw_size     TYPE string,

           lw_space    TYPE string,

           lw_indent   TYPE string.



    IF style IS SUPPLIED AND NOT style IS INITIAL.

      READ TABLE mt_list_style WITH KEY type = c_type_paragraph

                                        name = style

                               TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        CONCATENATE xml

                    '<w:pStyle w:val="'

                    style

                    '"/>'

                    INTO xml.

      ELSE.

        invalid_style = c_true.

      ENDIF.

    ENDIF.



    IF style_effect-break_before = c_true.

      CONCATENATE xml

                  '<w:pageBreakBefore/>'

                  INTO xml.

    ENDIF.



    IF NOT style_effect-hierarchy_level IS INITIAL.

      lw_size = style_effect-hierarchy_level - 1.

      CONDENSE lw_size NO-GAPS.

      CONCATENATE xml

                  '<w:outlineLvl w:val="'

                  lw_size

                  '"/>'

                  INTO xml.

    ENDIF.



    IF NOT style_effect-alignment IS INITIAL.

      CONCATENATE xml

                  '<w:jc w:val="'

                  style_effect-alignment

                  '"/>'

                  INTO xml.

    ENDIF.



    IF NOT style_effect-bgcolor IS INITIAL.

      CONCATENATE xml

                  '<w:shd w:val="clear" w:color="auto" w:fill="'

                  style_effect-bgcolor

                  '"/>'

                  INTO xml.

    ENDIF.



    CLEAR lw_substyle.

    IF style_effect-spacing_before_auto = c_true.

      lw_substyle = ' w:beforeAutospacing="1"'.

    ELSEIF NOT style_effect-spacing_before IS INITIAL AND style_effect-spacing_before CO '0123456789 '.

      lw_space = style_effect-spacing_before.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  ' w:beforeAutospacing="0" w:before="'  ##NO_TEXT

                  lw_space

                  '"'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.



    IF style_effect-spacing_after_auto = c_true.

      CONCATENATE lw_substyle

                  ' w:afterAutospacing="1"'

                  INTO lw_substyle RESPECTING BLANKS.

    ELSEIF NOT style_effect-spacing_after IS INITIAL AND style_effect-spacing_after CO '0123456789 '.

      lw_space = style_effect-spacing_after.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  ' w:afterAutospacing="0" w:after="' ##NO_TEXT

                  lw_space

                  '"'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.



    IF NOT style_effect-interline IS INITIAL.

      lw_space = style_effect-interline.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  ' w:line="'

                  lw_space

                  '"'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.



    IF NOT lw_substyle IS INITIAL.

      CONCATENATE xml

                  '<w:spacing '

                  lw_substyle

                  '/>'

                  INTO xml RESPECTING BLANKS.

    ENDIF.



    CLEAR lw_substyle.

    IF NOT style_effect-leftindent IS INITIAL AND style_effect-leftindent CO '0123456789 '.

      lw_indent = style_effect-leftindent.

      CONDENSE lw_indent NO-GAPS.

      CONCATENATE ' w:left="'

                  lw_indent

                  '"'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.



    IF NOT style_effect-rightindent IS INITIAL AND style_effect-rightindent CO '0123456789 '.

      lw_indent = style_effect-rightindent.

      CONDENSE lw_indent NO-GAPS.

      CONCATENATE lw_substyle

                  ' w:right="'

                  lw_indent

                  '"'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.



    IF NOT style_effect-firstindent IS INITIAL AND style_effect-firstindent CO '-0123456789 '.

      IF style_effect-firstindent < 0.

        lw_indent = - style_effect-firstindent.

        CONDENSE lw_indent NO-GAPS.

        CONCATENATE lw_substyle

                    ' w:hanging="'

                    lw_indent

                    '"'

                    INTO lw_substyle RESPECTING BLANKS.

      ELSE.

        lw_indent = style_effect-firstindent.

        CONDENSE lw_indent NO-GAPS.

        CONCATENATE lw_substyle

                    ' w:firstLine="'

                    lw_indent

                    '"'

                    INTO lw_substyle RESPECTING BLANKS.

      ENDIF.

    ENDIF.



    IF NOT lw_substyle IS INITIAL.

      CONCATENATE xml

                  '<w:ind '

                  lw_substyle

                  '/>'

                  INTO xml RESPECTING BLANKS.

    ENDIF.



* Borders

    CLEAR lw_substyle.

    IF NOT style_effect-border_left-style IS INITIAL

    AND NOT style_effect-border_left-width IS INITIAL.

      lw_size = style_effect-border_left-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = style_effect-border_left-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:left w:val="'

                  style_effect-border_left-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  style_effect-border_left-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT style_effect-border_top-style IS INITIAL

    AND NOT style_effect-border_top-width IS INITIAL.

      lw_size = style_effect-border_top-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = style_effect-border_top-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:top w:val="'

                  style_effect-border_top-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  style_effect-border_top-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT style_effect-border_right-style IS INITIAL

    AND NOT style_effect-border_right-width IS INITIAL.

      lw_size = style_effect-border_right-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = style_effect-border_right-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:right w:val="'

                  style_effect-border_right-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  style_effect-border_right-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT style_effect-border_bottom-style IS INITIAL

    AND NOT style_effect-border_bottom-width IS INITIAL.

      lw_size = style_effect-border_bottom-width.

      CONDENSE lw_size NO-GAPS.

      lw_space = style_effect-border_bottom-space.

      CONDENSE lw_space NO-GAPS.

      CONCATENATE lw_substyle

                  '<w:bottom w:val="'

                  style_effect-border_bottom-style

                  '" w:sz="'

                  lw_size

                  '" w:space="'

                  lw_space

                  '" w:color="'

                  style_effect-border_bottom-color

                  '"/>'

                  INTO lw_substyle RESPECTING BLANKS.

    ENDIF.

    IF NOT lw_substyle IS INITIAL.

      CONCATENATE xml

                  '<w:pBdr>'

                  lw_substyle

                  '</w:pBdr>'

                  INTO xml RESPECTING BLANKS.

    ENDIF.

* Add section info if required

    IF NOT mw_section_xml IS INITIAL.

      CONCATENATE xml

                  mw_section_xml

                  INTO xml.

      CLEAR mw_section_xml.

    ENDIF.



    IF NOT xml IS INITIAL.

      CONCATENATE '<w:pPr>'

                  xml

                  '</w:pPr>'

                  INTO xml.

    ENDIF.



  ENDMETHOD.                    "_build_paragraph_style



  METHOD _get_xml_ns.

    CLEAR xml.

    CONCATENATE

                ' xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"'

                ' xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"'

                ' xmlns:o="urn:schemas-microsoft-com:office:office"'

                ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'

                ' xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"'

                ' xmlns:v="urn:schemas-microsoft-com:vml"'

                ' xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"'

                ' xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"'

                ' xmlns:w10="urn:schemas-microsoft-com:office:word"'

                ' xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

                ' xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"'

                ' xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"'

                ' xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"'

                ' xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"'

                ' xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"'

                ' mc:Ignorable="w14 wp14" '                 "#EC NOTEXT

                INTO xml RESPECTING BLANKS.

  ENDMETHOD.                    "_get_xml_ns



  METHOD write_table_enh.



    DATA: lt_dd03p        TYPE STANDARD TABLE OF dd03p,

          lt_dd03p_def    TYPE STANDARD TABLE OF dd03p,

          ls_dd02v_wa_a   TYPE dd02v,

          ls_dd02v_wa_def TYPE dd02v,

          lv_textline     TYPE string,

          s_char_style    TYPE cl_word=>ty_character_style_effect,

          ls_cont         LIKE lt_dd03p,

          lr_structdescr  TYPE REF TO cl_abap_structdescr,

          lr_tabledescr   TYPE REF TO cl_abap_tabledescr,

          lt_components   TYPE abap_component_tab,

          ls_component    TYPE LINE OF abap_component_tab,

          lr_itab         TYPE REF TO data,

          lv_columns      TYPE i.





    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = table_name
        langu         = p_lang
      IMPORTING
        dd02v_wa      = ls_dd02v_wa_a
      TABLES
        dd03p_tab     = lt_dd03p
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.



    IF sy-subrc <> 0.

      RETURN.

    ENDIF.



    IF p_lang <> gc_default_lang.

      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name          = table_name
          langu         = gc_default_lang
        IMPORTING
          dd02v_wa      = ls_dd02v_wa_def
        TABLES
          dd03p_tab     = lt_dd03p_def
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.



      IF sy-subrc <> 0.

        RETURN.

      ENDIF.

    ENDIF.









    TYPES: BEGIN OF ty_field_routine,

             field      TYPE string,

             routine(5) TYPE c,

             output_len TYPE i,

           END OF ty_field_routine.



    DATA: lt_field_routine TYPE TABLE OF ty_field_routine,

          ls_field_routine TYPE  ty_field_routine.





    DESCRIBE TABLE lt_dd03p LINES DATA(lv_lines).



    IF lv_lines > gc_quantity_columns.

      lv_columns = gc_quantity_columns.

    ELSE.

      lv_columns = lv_lines.

    ENDIF.





    DO lv_columns TIMES.

      READ TABLE lt_dd03p ASSIGNING FIELD-SYMBOL(<fs_field>) INDEX sy-index.



      IF sy-subrc <> 0.

        CONTINUE.

      ENDIF.





      IF <fs_field>-convexit <> ''.

        ls_field_routine-field = <fs_field>-fieldname.

        ls_field_routine-routine = <fs_field>-convexit.

        ls_field_routine-output_len = <fs_field>-outputlen.



        INSERT ls_field_routine INTO TABLE lt_field_routine.



      ENDIF.





      IF <fs_field>-fieldname  NA '.-' .

        ls_component-name = <fs_field>-fieldname.

        ls_component-type ?= cl_abap_elemdescr=>get_string( ).



        INSERT ls_component INTO TABLE lt_components.

      ENDIF.



    ENDDO.







    lr_structdescr ?= cl_abap_structdescr=>create( lt_components ).



    lr_tabledescr ?= cl_abap_tabledescr=>create( p_line_type  = lr_structdescr ).



    CREATE DATA lr_itab TYPE HANDLE lr_tabledescr.



    FIELD-SYMBOLS <lt_itab> TYPE STANDARD TABLE.



    ASSIGN lr_itab->* TO <lt_itab>.



    APPEND INITIAL LINE TO <lt_itab> ASSIGNING FIELD-SYMBOL(<ls_tab>).



    DATA: newline TYPE c VALUE cl_abap_char_utilities=>cr_lf,

          lv_head TYPE string.



    DATA(lv_cmp) = 1.



    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<fs_tst>).



      READ TABLE lt_dd03p ASSIGNING FIELD-SYMBOL(<fs_ddtxt>) WITH KEY fieldname = <fs_tst>-name.



      ASSIGN COMPONENT lv_cmp OF STRUCTURE <ls_tab> TO FIELD-SYMBOL(<lv_val>).



      IF ( <fs_ddtxt>-ddtext = '' OR sy-subrc <> 0 ) AND p_lang <> gc_default_lang.

        READ TABLE lt_dd03p_def ASSIGNING <fs_ddtxt> WITH KEY fieldname = <fs_tst>-name.

        IF sy-subrc <> 0.

          RETURN.

        ENDIF.

        CONCATENATE <fs_tst>-name <fs_ddtxt>-ddtext INTO lv_head SEPARATED BY newline.

      ELSE.

        CONCATENATE <fs_tst>-name <fs_ddtxt>-ddtext INTO lv_head SEPARATED BY newline.

      ENDIF.



      <lv_val> = lv_head.

      lv_cmp = lv_cmp + 1.

    ENDLOOP.



    DATA(lv_cnt) = lines( lt_components ).



    LOOP AT content ASSIGNING FIELD-SYMBOL(<fs_cont>).

      APPEND INITIAL LINE TO <lt_itab> ASSIGNING <ls_tab>.

      DO lv_cnt TIMES.

        DATA(lv_index) = sy-index.

        ASSIGN COMPONENT lv_index OF STRUCTURE <fs_cont> TO FIELD-SYMBOL(<lv_val2>).

        ASSIGN COMPONENT lv_index OF STRUCTURE <ls_tab> TO FIELD-SYMBOL(<lv_val1>).

        <lv_val1> = <lv_val2>.

      ENDDO.

    ENDLOOP.





    IF lt_field_routine IS NOT INITIAL.

      DATA lv_function_name TYPE string.



      LOOP AT <lt_itab> ASSIGNING <ls_tab>.



        IF sy-tabix = 1.

          CONTINUE.

        ENDIF.



        LOOP AT lt_field_routine INTO ls_field_routine.



          DATA: lo_output_data TYPE REF TO data.

          FIELD-SYMBOLS: <lv_output_data> TYPE any.



          ASSIGN COMPONENT ls_field_routine-field OF STRUCTURE <ls_tab> TO FIELD-SYMBOL(<fs_field_data>).



          CREATE DATA lo_output_data TYPE c LENGTH ls_field_routine-output_len.

          ASSIGN lo_output_data->* TO <lv_output_data>.



          CONCATENATE 'CONVERSION_EXIT_' ls_field_routine-routine '_OUTPUT' INTO lv_function_name.





          CALL FUNCTION lv_function_name
            EXPORTING
              input  = <fs_field_data>
            IMPORTING
              output = <lv_output_data>.



          <fs_field_data> = <lv_output_data>.

        ENDLOOP.

      ENDLOOP.



    ENDIF.





    DATA lv_tabname TYPE string.

    DATA lv_tab_descr TYPE string.



    IF p_lang = gc_default_lang.

      lv_tab_descr = ls_dd02v_wa_a-ddtext.

    ELSE.

      IF ls_dd02v_wa_a-ddtext = ''.

        lv_tab_descr = ls_dd02v_wa_def-ddtext.

      ELSE.

        lv_tab_descr = ls_dd02v_wa_def-ddtext.

      ENDIF.



    ENDIF.



    lv_tabname = ls_dd02v_wa_a-tabname.

    CONDENSE lv_tabname.





    CONCATENATE 'Table ' lv_tabname  ': ' lv_tab_descr

    INTO lv_textline

    RESPECTING BLANKS ##NO_TEXT.



    CLEAR s_char_style.

    s_char_style-color = cl_word=>c_color_red.



    CALL METHOD write_text
      EXPORTING
        textline   = lv_textline
        line_style = 'Heading2' ##NO_TEXT.



    CALL METHOD write_line.





    CALL METHOD write_table
      EXPORTING
        content = <lt_itab>
        style   = 'SAPStandardTable'.



  ENDMETHOD.



ENDCLASS.                    "cl_word IMPLEMENTATION





*







CLASS zloc_cl_req_loader IMPLEMENTATION.





* <SIGNATURE>---------------------------------------------------------------------------------------+

* | Instance Public Method zloc_cl_req_loader->CONSTRUCTOR

* +-------------------------------------------------------------------------------------------------+

* +--------------------------------------------------------------------------------------</SIGNATURE>

  METHOD constructor.



    mo_doc = io_doc.



  ENDMETHOD.



  METHOD  eject_inf_about_tdat.



    TYPES: BEGIN OF ty_tdat,

             name     TYPE dd02v-tabname,

             activity TYPE e071-activity,

           END OF ty_tdat.



    TYPES: BEGIN OF ty_tabu,

             tabname TYPE dd02v-tabname,

           END OF ty_tabu.



    DATA: lv_str           TYPE string,

          lv_objtype       TYPE string,

          lv_from          TYPE sy-tabix,

          lv_len           TYPE i,

          lv_complete_keys TYPE abap_bool,

          lv_charfields    TYPE string,

          lv_keyfields     TYPE string,

          lv_where         TYPE string,



          lr_t_table       TYPE REF TO data,

          lr_s_table       TYPE REF TO data,

          lr_tabkeys       TYPE REF TO data,

          lr_tabkeys2      TYPE REF TO data,



          lt_dd03p         TYPE STANDARD TABLE OF dd03p,

          lt_fields        TYPE cl_abap_structdescr=>component_table,

          lt_keyfields     TYPE abap_keydescr_tab,

          lt_charfields    TYPE abap_keydescr_tab,

          lt_sortfields    TYPE abap_sortorder_tab,



          lo_structdescr   TYPE REF TO cl_abap_structdescr,

          lo_tabledescr    TYPE REF TO cl_abap_tabledescr,

          lo_tabkeydescr   TYPE REF TO cl_abap_typedescr,

          lo_typedescr     TYPE REF TO cl_abap_typedescr,



          lo_tdat_node     TYPE REF TO if_ixml_element,

          lo_tabu_node     TYPE REF TO if_ixml_element,

          lo_datarow_node  TYPE REF TO if_ixml_element,

          ls_tdat          TYPE ty_tdat,

          ls_tabu          TYPE ty_tabu.



    FIELD-SYMBOLS: <fs_e071>       LIKE LINE OF t_e071,

                   <fs_e071k>      LIKE LINE OF t_e071k,

                   <fs_t_table>    TYPE STANDARD TABLE,

                   <fs_s_table>    TYPE any,

                   <fs_t_tabkeys>  TYPE STANDARD TABLE,

                   <fs_t_tabkeys2> TYPE STANDARD TABLE,

                   <fs_s_tabkey>   TYPE any,

                   <fs_field>      LIKE LINE OF lt_fields,

                   <fs_dd03p>      LIKE LINE OF lt_dd03p,

                   <fs_sortfield>  LIKE LINE OF lt_sortfields,

                   <fs_keyfield>   LIKE LINE OF lt_keyfields.



* Get the object type

    lv_objtype = iv_obj_type.



* Look for the first task activity not yet processed

    READ TABLE t_e071 ASSIGNING <fs_e071>

      WITH KEY obj_name = objname

               used     = space

      BINARY SEARCH.



    IF sy-subrc <> 0.

      MESSAGE s208(00) WITH 'No more object(s) of this type found in the request(s) supplied' ##NO_TEXT.

      EXIT.

    ENDIF.



* Position on the first key of the object being processed

    READ TABLE t_e071k TRANSPORTING NO FIELDS WITH KEY trkorr     = <fs_e071>-trkorr

                                                       activity   = <fs_e071>-activity

                                                       mastername = <fs_e071>-obj_name.



    IF sy-subrc = 0.



      lv_from = sy-tabix.



* Process all keys belonging to current object

      LOOP AT t_e071k ASSIGNING <fs_e071k> FROM lv_from.



        AT NEW mastername.



          DATA:

            ev_name     TYPE string,

            ev_activity TYPE string,

            ev_textline TYPE string.



          ev_activity = <fs_e071k>-mastername.



          DATA(ev_ca) = 'View ' ##NO_TEXT.

          CONCATENATE ev_ca ev_activity INTO ev_textline.

          CONCATENATE '(' sy-cprog ')mo_doc' INTO lv_str.



          ASSIGN (lv_str) TO FIELD-SYMBOL(<var>).

          mo_doc = <var>.

          CALL METHOD mo_doc->('WRITE_TEXT')
            EXPORTING
              textline   = ev_textline
              line_style = 'Heading1' ##NO_TEXT.



          DATA lo_spro_doc_loader TYPE REF TO zloc_cl_spro_doc_loader.



          lo_spro_doc_loader = zloc_cl_spro_doc_loader=>get_instance( ).



          DATA lv_object_name TYPE trobj_name.

          lv_object_name = ev_activity.

          DATA lt_spro_docum TYPE zloc_cl_spro_doc_loader=>ty_t_itf_lines.

          DATA lv_document TYPE string.

          DATA ls_head TYPE thead.

          DATA lo_itf_to_xml_convertor TYPE REF TO cl_note_itf2xml.



          lo_itf_to_xml_convertor = NEW #( ).



          lo_spro_doc_loader->get_documentation(

            EXPORTING

              iv_obj_name      = lv_object_name

              iv_lang          = p_lang    " Language Key

            IMPORTING

              et_documentation = lt_spro_docum

              es_head          = ls_head

          ).



          IF lines( lt_spro_docum ) = 0 AND p_lang <> gc_default_lang.



            lo_spro_doc_loader->get_documentation(

              EXPORTING

                  iv_obj_name      = lv_object_name

                  iv_lang          = gc_default_lang    " Language Key

              IMPORTING

                  et_documentation = lt_spro_docum

                  es_head          = ls_head

                  ).

          ENDIF.



          IF lines( lt_spro_docum ) <> 0.

            mo_doc->write_spro_documentation( it_documentation = lt_spro_docum ).

          ENDIF.



        ENDAT.



        AT NEW objname.



* Get information about all fields of the table

          REFRESH lt_dd03p.

          CALL FUNCTION 'DDIF_TABL_GET'
            EXPORTING
              name          = <fs_e071k>-objname
              langu         = sy-langu
            TABLES
              dd03p_tab     = lt_dd03p
            EXCEPTIONS
              illegal_input = 1
              OTHERS        = 2.



          IF sy-subrc <> 0 OR lt_dd03p[] IS INITIAL.



            MESSAGE s208(00) WITH 'Table does not exist in the active state' ##NO_TEXT.

            EXIT.

          ENDIF.



* Create the type object for field E071K-TABKEY

          lo_tabkeydescr = cl_abap_typedescr=>describe_by_name( `E071K-TABKEY` ).



* Loop thru all key fields of the table:

*   1) Building a list of all key fields

*   2) Building a list of all CHARLIKE key fields that fit fields E071K-TABKEY

*   3) Building the WHERE clause for the SELECT to be used for data retrieval, using FOR ALL ENTRIES

*   4) Setting up table LT_FIELDS, with all key fields

          DELETE lt_dd03p WHERE keyflag      = abap_false OR

                                fieldname(1) = '.'.

          CLEAR: lv_keyfields, lv_charfields, lv_where.

          lv_complete_keys = abap_true.

          REFRESH lt_fields.

          LOOP AT lt_dd03p ASSIGNING <fs_dd03p>.



* Build the list of all key fields names

            CONCATENATE lv_keyfields <fs_dd03p>-fieldname INTO lv_keyfields

              SEPARATED BY space.



* Add key field to the key type strucuture of the object keys table

            APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

            <fs_field>-name = <fs_dd03p>-fieldname.

            <fs_field>-type ?= cl_abap_structdescr=>describe_by_name( <fs_dd03p>-rollname ).



            CHECK lv_complete_keys = abap_true.



* Check if structure containing all key fields of the View table is CHARLIKE

            IF <fs_field>-type->type_kind CN 'CNDT'.

              lv_complete_keys = abap_false.

              CONTINUE.

            ENDIF.



* Build the type object for key fields found so far, to help answer the following question below

            lo_structdescr = cl_abap_structdescr=>create( lt_fields ).



* If I add current CHARLIKE key field to key structure,

*   will it make the CHARLIKE key structure larger than field E071K-TABKEY ?

            IF lo_structdescr->length > lo_tabkeydescr->length.

              lv_complete_keys = abap_false.

              CONTINUE.

            ENDIF.



* Build the list of CHARLIKE key fields names

            CONCATENATE lv_charfields <fs_dd03p>-fieldname INTO lv_charfields

              SEPARATED BY space.



* Build the 'FIELDNAME = <FS_T_TAKEYS>-FIELDNAME' WHERE condition

            CONCATENATE '<FS_T_TABKEYS>-' <fs_dd03p>-fieldname INTO lv_str.

            CONCATENATE lv_where 'AND' <fs_dd03p>-fieldname '=' lv_str INTO lv_where SEPARATED BY space.



          ENDLOOP.



* Table has no key fields (?!?)

          IF sy-subrc <> 0.

            lv_str = `Table has no key fields` ##NO_TEXT .

          ENDIF.



* Get rid of the " " at the beginning of key fuields list

          SHIFT lv_keyfields LEFT BY 1 PLACES.



* List of table key fields

          SPLIT lv_keyfields AT space INTO TABLE lt_keyfields.



* Get rid of the " " at the beginning of CHAR key fields list

          SHIFT lv_charfields LEFT BY 1 PLACES.



* List of table CHARLIKE key fields

          SPLIT lv_charfields AT space INTO TABLE lt_charfields.



* Get rid of the " AND " at the beginning of the WHERE clause

          SHIFT lv_where LEFT BY 5 PLACES.



* Creates the dynamic table with key fields of the data table

          lo_structdescr = cl_abap_structdescr=>create( lt_fields ).

          lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                      p_key       = lt_keyfields ).

          CREATE DATA lr_tabkeys TYPE HANDLE lo_tabledescr.

          ASSIGN lr_tabkeys->* TO <fs_t_tabkeys>.



        ENDAT.



* If we are not storing complete keys, get rid of the "*" at the end of key

        CLEAR lv_str.

        DATA lv_str1 TYPE trobj_name.

        lv_len = strlen( <fs_e071k>-tabkey ) - 1.

        IF lv_len >= 0.

          IF lv_complete_keys = abap_false AND

             <fs_e071k>-tabkey+lv_len(1) = '*'.

            lv_str1 = <fs_e071k>-tabkey(lv_len).

          ELSE.

            lv_str1 = <fs_e071k>-tabkey.

            lv_len = lv_len + 1.

          ENDIF.

        ENDIF.





* Creates a new key in the keys table

        APPEND INITIAL LINE TO <fs_t_tabkeys> ASSIGNING <fs_s_tabkey>.

*      <fs_s_tabkey> = lv_str.

        MOVE lv_str1 TO <fs_s_tabkey>+0(lv_len).



        AT END OF objname.



* Get rid of duplicate keys in the keys table

          SORT <fs_t_tabkeys> BY table_line.

          IF lv_complete_keys = abap_true.

            DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys> COMPARING ALL FIELDS.

          ELSEIF lt_charfields[] IS NOT INITIAL.



* Create a table with same fields as LT_TABKEYS, but with CHAR key fields

            lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                        p_key       = lt_charfields ).

            CREATE DATA lr_tabkeys2 TYPE HANDLE lo_tabledescr.

            ASSIGN lr_tabkeys2->* TO <fs_t_tabkeys2>.



* Get rid of all CHARLIKE key duplicates

            <fs_t_tabkeys2>[] = <fs_t_tabkeys>[].

            DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys2>.

            <fs_t_tabkeys>[] = <fs_t_tabkeys2>[].



          ENDIF.



* Only reuse the keys table as data table if data table fields are all key fields and

*   if data table allows storing complete keys in the request

          IF lines( lt_dd03p ) = lines( lt_keyfields ) .

*          and lv_complete_keys = abap_true.



* If not, then create the table that will contain the records to be written

            CREATE DATA lr_t_table TYPE STANDARD TABLE OF (<fs_e071k>-objname) WITH KEY (lt_keyfields).

            ASSIGN lr_t_table->* TO <fs_t_table>.



* And select the desired records from database using CHARLIKE keys table <FS_T_TABKEYS> as the key

            IF <fs_t_tabkeys>[] IS NOT INITIAL.

              SELECT  *

                INTO  TABLE <fs_t_table>

                FROM  (<fs_e071k>-objname)

                CLIENT SPECIFIED

                FOR ALL ENTRIES IN <fs_t_tabkeys>

                WHERE (lv_where).

            ENDIF.



          ELSE.



* If yes, the table <fs_t_tabkeys> already contains all fields that should be written

            ASSIGN <fs_t_tabkeys> TO <fs_t_table>.



          ENDIF.



          IF <fs_t_table>[] IS NOT INITIAL.



* Get rid of duplicate entries in the data table

            REFRESH lt_sortfields.

            LOOP AT lt_keyfields ASSIGNING <fs_keyfield>.

              APPEND INITIAL LINE TO lt_sortfields ASSIGNING <fs_sortfield>.

              <fs_sortfield>-name = <fs_keyfield>.

            ENDLOOP.

            SORT <fs_t_table> BY (lt_sortfields).

            DELETE ADJACENT DUPLICATES FROM <fs_t_table>.







*            CALL METHOD mo_doc->('WRITE_TEXT')

*              EXPORTING

*                textline   = 'Table:'

*                line_style = 'Heading2'.

*            CALL METHOD mo_doc->('WRITE_LINE').

            CALL METHOD mo_doc->('WRITE_TABLE_ENH')
              EXPORTING
                content    = <fs_t_table>
                table_name = <fs_e071k>-objname.

            CALL METHOD mo_doc->('WRITE_NEWPAGE').



          ENDIF.



        ENDAT.



* If it's the last key for current object, exit

        AT END OF mastername.



          EXIT.



        ENDAT.



      ENDLOOP.



    ENDIF.



    <fs_e071>-used = abap_true.



  ENDMETHOD.



  METHOD eject_inf_about_vdat.





    TYPES: BEGIN OF ty_vdat,

             name     TYPE dd02v-tabname,

             activity TYPE e071-activity,

           END OF ty_vdat.



    TYPES: BEGIN OF ty_tabu,

             tabname TYPE dd02v-tabname,

           END OF ty_tabu.



    DATA: lv_str           TYPE string,

          lv_objtype       TYPE string,

          lv_from          TYPE sy-tabix,

          lv_len           TYPE i,

          lv_complete_keys TYPE abap_bool,

          lv_charfields    TYPE string,

          lv_keyfields     TYPE string,

          lv_where         TYPE string,



          lr_t_table       TYPE REF TO data,

          lr_s_table       TYPE REF TO data,

          lr_tabkeys       TYPE REF TO data,

          lr_tabkeys2      TYPE REF TO data,



          lt_dd03p         TYPE STANDARD TABLE OF dd03p,

          lt_fields        TYPE cl_abap_structdescr=>component_table,

          lt_keyfields     TYPE abap_keydescr_tab,

          lt_charfields    TYPE abap_keydescr_tab,

          lt_sortfields    TYPE abap_sortorder_tab,



          lo_structdescr   TYPE REF TO cl_abap_structdescr,

          lo_tabledescr    TYPE REF TO cl_abap_tabledescr,

          lo_tabkeydescr   TYPE REF TO cl_abap_typedescr,



          lo_vdat_node     TYPE REF TO if_ixml_element,

          lo_tabu_node     TYPE REF TO if_ixml_element,

          lo_datarow_node  TYPE REF TO if_ixml_element,

          ls_vdat          TYPE ty_vdat,

          ls_tabu          TYPE ty_tabu.



    FIELD-SYMBOLS: <fs_e071>       LIKE LINE OF t_e071,

                   <fs_e071k>      LIKE LINE OF t_e071k,

                   <fs_t_table>    TYPE STANDARD TABLE,

                   <fs_s_table>    TYPE any,

                   <fs_t_tabkeys>  TYPE STANDARD TABLE,

                   <fs_t_tabkeys2> TYPE STANDARD TABLE,

                   <fs_s_tabkey>   TYPE any,

                   <fs_field>      LIKE LINE OF lt_fields,

                   <fs_dd03p>      LIKE LINE OF lt_dd03p,

                   <fs_sortfield>  LIKE LINE OF lt_sortfields,

                   <fs_keyfield>   LIKE LINE OF lt_keyfields.



    lv_objtype = iv_obj_type.



* Look for the first task activity not yet processed

    READ TABLE t_e071 ASSIGNING <fs_e071>

      WITH KEY obj_name = objname

               used     = space

      BINARY SEARCH.



    IF sy-subrc <> 0.

      EXIT.

    ENDIF.



* Position on the first key of the object being processed

    READ TABLE t_e071k TRANSPORTING NO FIELDS WITH KEY trkorr     = <fs_e071>-trkorr

                                                       activity   = <fs_e071>-activity

                                                       mastername = <fs_e071>-obj_name.



    IF sy-subrc = 0.



      lv_from = sy-tabix.



* Process all keys belonging to current object

      LOOP AT t_e071k ASSIGNING <fs_e071k> FROM lv_from.



        AT NEW mastername.



          DATA:

            lv_obj_name TYPE ddobjname,

            ls_dd25v_wa TYPE dd25v,

            ev_name     TYPE string,

            ev_activity TYPE string,

            ev_textline TYPE string.



          ev_activity = <fs_e071k>-mastername.

          lv_obj_name = me->objname.



          CALL FUNCTION 'DDIF_VIEW_GET'
            EXPORTING
              langu    = p_lang
              name     = lv_obj_name
            IMPORTING
              dd25v_wa = ls_dd25v_wa.



          IF ls_dd25v_wa-ddtext = ''.

            CALL FUNCTION 'DDIF_VIEW_GET'
              EXPORTING
                langu    = gc_default_lang
                name     = lv_obj_name
              IMPORTING
                dd25v_wa = ls_dd25v_wa.

          ENDIF.





          DATA(lv_ca) = 'View ' ##NO_TEXT .



          CONCATENATE lv_ca ev_activity ': ' ls_dd25v_wa-ddtext

          INTO ev_textline RESPECTING BLANKS.



          CALL METHOD mo_doc->('WRITE_TEXT')
            EXPORTING
              textline   = ev_textline
              line_style = 'Heading1' ##NO_TEXT.





          DATA lo_spro_doc_loader TYPE REF TO zloc_cl_spro_doc_loader.



          lo_spro_doc_loader = zloc_cl_spro_doc_loader=>get_instance( ).



          DATA lv_object_name TYPE trobj_name.

          lv_object_name = ev_activity.

          DATA lt_spro_docum TYPE zloc_cl_spro_doc_loader=>ty_t_itf_lines.

          DATA lv_document TYPE string.

          DATA ls_head TYPE thead.

          DATA lo_itf_to_xml_convertor TYPE REF TO cl_note_itf2xml.



          lo_itf_to_xml_convertor = NEW #( ).



          lo_spro_doc_loader->get_documentation(

            EXPORTING

              iv_obj_name      = lv_object_name

              iv_lang          = p_lang    " Language Key

            IMPORTING

              et_documentation = lt_spro_docum

              es_head          = ls_head

          ).



          IF lines( lt_spro_docum ) = 0 AND p_lang <> gc_default_lang.



            lo_spro_doc_loader->get_documentation(

              EXPORTING

                  iv_obj_name      = lv_object_name

                  iv_lang          = gc_default_lang    " Language Key

              IMPORTING

                  et_documentation = lt_spro_docum

                  es_head          = ls_head

                  ).

          ENDIF.



          IF lines( lt_spro_docum ) <> 0.

            mo_doc->write_spro_documentation( it_documentation = lt_spro_docum ).

          ENDIF.



        ENDAT.



        AT NEW objname.



* Get information about all fields of the table

          REFRESH lt_dd03p.

          CALL FUNCTION 'DDIF_TABL_GET'
            EXPORTING
              name          = <fs_e071k>-objname
              langu         = sy-langu
            TABLES
              dd03p_tab     = lt_dd03p
            EXCEPTIONS
              illegal_input = 1
              OTHERS        = 2.



          IF sy-subrc <> 0 OR lt_dd03p[] IS INITIAL.

            MESSAGE s208(00) WITH 'Table does not exist in the active state' ##NO_TEXT.

            EXIT.

          ENDIF.



* Create the type object for field E071K-TABKEY

          lo_tabkeydescr = cl_abap_typedescr=>describe_by_name( `E071K-TABKEY` ).



* Loop thru all key fields of the table:

*   1) Building a list of all key fields

*   2) Building a list of all CHARLIKE key fields that fit fields E071K-TABKEY

*   3) Building the WHERE clause for the SELECT to be used for data retrieval, using FOR ALL ENTRIES

*   4) Setting up table LT_FIELDS, with all key fields

          DELETE lt_dd03p WHERE keyflag      = abap_false OR

                                fieldname(1) = '.'.

          CLEAR: lv_keyfields, lv_charfields, lv_where.

          lv_complete_keys = abap_true.

          REFRESH lt_fields.

          LOOP AT lt_dd03p ASSIGNING <fs_dd03p>.



* Build the list of all key fields names

            CONCATENATE lv_keyfields <fs_dd03p>-fieldname INTO lv_keyfields

              SEPARATED BY space.



* Add key field to the key type strucuture of the object keys table

            APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

            <fs_field>-name = <fs_dd03p>-fieldname.

            <fs_field>-type ?= cl_abap_structdescr=>describe_by_name( <fs_dd03p>-rollname ).



            CHECK lv_complete_keys = abap_true.



* Check if structure containing all key fields of the View table is CHARLIKE

            IF <fs_field>-type->type_kind CN 'CNDT'.

              lv_complete_keys = abap_false.

              CONTINUE.

            ENDIF.



* Build the type object for key fields found so far, to help answer the following question below

            lo_structdescr = cl_abap_structdescr=>create( lt_fields ).



* If I add current CHARLIKE key field to key structure,

*   will it make the CHARLIKE key structure larger than field E071K-TABKEY ?

            IF lo_structdescr->length > lo_tabkeydescr->length.

              lv_complete_keys = abap_false.

              CONTINUE.

            ENDIF.



* Build the list of CHARLIKE key fields names

            CONCATENATE lv_charfields <fs_dd03p>-fieldname INTO lv_charfields

              SEPARATED BY space.



* Build the 'FIELDNAME = <FS_T_TAKEYS>-FIELDNAME' WHERE condition

            CONCATENATE '<FS_T_TABKEYS>-' <fs_dd03p>-fieldname INTO lv_str.

            CONCATENATE lv_where 'AND' <fs_dd03p>-fieldname '=' lv_str INTO lv_where SEPARATED BY space.



          ENDLOOP.



* Table has no key fields (?!?)

          IF sy-subrc <> 0.

            lv_str = `Table has no key fields` ##NO_TEXT.

          ENDIF.



* Get rid of the " " at the beginning of key fuields list

          SHIFT lv_keyfields LEFT BY 1 PLACES.



* List of table key fields

          SPLIT lv_keyfields AT space INTO TABLE lt_keyfields.



* Get rid of the " " at the beginning of CHAR key fields list

          SHIFT lv_charfields LEFT BY 1 PLACES.



* List of table CHARLIKE key fields

          SPLIT lv_charfields AT space INTO TABLE lt_charfields.



* Get rid of the " AND " at the beginning of the WHERE clause

          SHIFT lv_where LEFT BY 5 PLACES.



* Creates the dynamic table with key fields of the data table

          lo_structdescr = cl_abap_structdescr=>create( lt_fields ).

          lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                      p_key       = lt_keyfields ).

          CREATE DATA lr_tabkeys TYPE HANDLE lo_tabledescr.

          ASSIGN lr_tabkeys->* TO <fs_t_tabkeys>.



        ENDAT.



* If we are not storing complete keys, get rid of the "*" at the end of key

        CLEAR lv_str.

        DATA lv_str1 TYPE trobj_name.

        lv_len = strlen( <fs_e071k>-tabkey ) - 1.

        IF lv_len >= 0.

          IF lv_complete_keys = abap_false AND

             <fs_e071k>-tabkey+lv_len(1) = '*'.

            lv_str1 = <fs_e071k>-tabkey(lv_len).

          ELSE.

            lv_str1 = <fs_e071k>-tabkey.

            lv_len = lv_len + 1.

          ENDIF.

        ENDIF.



* Creates a new key in the keys table

        APPEND INITIAL LINE TO <fs_t_tabkeys> ASSIGNING <fs_s_tabkey>.

*      <fs_s_tabkey> = lv_str1.

*       write lv_str1 to <fs_s_tabkey>.

        MOVE lv_str1 TO <fs_s_tabkey>+0(lv_len).



        AT END OF objname.



* Get rid of duplicate keys in the keys table

          SORT <fs_t_tabkeys> BY table_line.

          IF lv_complete_keys = abap_true.

            DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys> COMPARING ALL FIELDS.

          ELSEIF lt_charfields[] IS NOT INITIAL.



* Create a table with same fields as LT_TABKEYS, but with CHAR key fields

            lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                        p_key       = lt_charfields ).

            CREATE DATA lr_tabkeys2 TYPE HANDLE lo_tabledescr.

            ASSIGN lr_tabkeys2->* TO <fs_t_tabkeys2>.



* Get rid of all CHARLIKE key duplicates

            <fs_t_tabkeys2>[] = <fs_t_tabkeys>[].

            DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys2>.

            <fs_t_tabkeys>[] = <fs_t_tabkeys2>[].



          ENDIF.



* Only reuse the keys table as data table if data table fields are all key fields and

*   if data table allows storing complete keys in the request



          DATA length1 TYPE i.

          DATA length2 TYPE i.

          DESCRIBE TABLE lt_dd03p LINES length1.

          DESCRIBE TABLE lt_keyfields LINES length2.



          IF length1 = length2.

*           and lv_complete_keys = abap_true.



* If not, then create the table that will contain the records to be written

            CREATE DATA lr_t_table TYPE STANDARD TABLE OF (<fs_e071k>-objname) WITH KEY (lt_keyfields).

            ASSIGN lr_t_table->* TO <fs_t_table>.



* And select the desired records from database using CHARLIKE keys table <FS_T_TABKEYS> as the key

            IF <fs_t_tabkeys>[] IS NOT INITIAL.

              SELECT  *

                INTO  TABLE <fs_t_table>

                FROM  (<fs_e071k>-objname)

                CLIENT SPECIFIED

                FOR ALL ENTRIES IN <fs_t_tabkeys>

                WHERE (lv_where).

            ENDIF.



          ELSE.



* If yes, the table <fs_t_tabkeys> already contains all fields that should be written

            ASSIGN <fs_t_tabkeys> TO <fs_t_table>.



          ENDIF.



          IF <fs_t_table>[] IS NOT INITIAL.



* Get rid of duplicate entries in the data table

            REFRESH lt_sortfields.

            LOOP AT lt_keyfields ASSIGNING <fs_keyfield>.

              APPEND INITIAL LINE TO lt_sortfields ASSIGNING <fs_sortfield>.

              <fs_sortfield>-name = <fs_keyfield>.

            ENDLOOP.

            SORT <fs_t_table> BY (lt_sortfields).

            DELETE ADJACENT DUPLICATES FROM <fs_t_table>.





            CALL METHOD mo_doc->('WRITE_TABLE_ENH')
              EXPORTING
                content    = <fs_t_table>
                table_name = <fs_e071k>-objname.

            CALL METHOD mo_doc->('WRITE_NEWPAGE').



          ENDIF.



        ENDAT.



* If it's the last key for current object, exit

        AT END OF mastername.



          EXIT.



        ENDAT.



      ENDLOOP.



    ENDIF.



    <fs_e071>-used = abap_true.





  ENDMETHOD.





  METHOD eject_inf_about_cdat.



    TYPES: BEGIN OF ty_cdat,

             name     TYPE vclstruc-vclname,

             activity TYPE e071-activity,

           END OF ty_cdat.



    TYPES: BEGIN OF ty_vdat,

             name     TYPE dd02v-tabname,

             activity TYPE e071-activity,

           END OF ty_vdat.



    TYPES: BEGIN OF ty_tabu,

             tabname TYPE dd02v-tabname,

           END OF ty_tabu.



    DATA: lv_str           TYPE string,

          lv_objtype       TYPE string,

          lv_from          TYPE sy-tabix,

          lv_len           TYPE i,

          lv_complete_keys TYPE abap_bool,

          lv_charfields    TYPE string,

          lv_keyfields     TYPE string,

          lv_where         TYPE string,



          lr_t_table       TYPE REF TO data,

          lr_s_table       TYPE REF TO data,

          lr_tabkeys       TYPE REF TO data,

          lr_tabkeys2      TYPE REF TO data,



          lt_dd03p         TYPE STANDARD TABLE OF dd03p,

          lt_fields        TYPE cl_abap_structdescr=>component_table,

          lt_keyfields     TYPE abap_keydescr_tab,

          lt_charfields    TYPE abap_keydescr_tab,

          lt_sortfields    TYPE abap_sortorder_tab,

          lo_structdescr   TYPE REF TO cl_abap_structdescr,

          lo_tabledescr    TYPE REF TO cl_abap_tabledescr,

          lo_tabkeydescr   TYPE REF TO cl_abap_typedescr,



          lo_cdat_node     TYPE REF TO if_ixml_element,

          lo_vdat_node     TYPE REF TO if_ixml_element,

          lo_tabu_node     TYPE REF TO if_ixml_element,

          lo_datarow_node  TYPE REF TO if_ixml_element,

          ls_cdat          TYPE ty_cdat,

          ls_vdat          TYPE ty_vdat,

          ls_tabu          TYPE ty_tabu.



    FIELD-SYMBOLS: <fs_e071>       LIKE LINE OF t_e071,

                   <fs_e071k>      LIKE LINE OF t_e071k,

                   <fs_t_table>    TYPE STANDARD TABLE,

                   <fs_s_table>    TYPE any,

                   <fs_t_tabkeys>  TYPE STANDARD TABLE,

                   <fs_t_tabkeys2> TYPE STANDARD TABLE,

                   <fs_s_tabkey>   TYPE any,

                   <fs_field>      LIKE LINE OF lt_fields,

                   <fs_dd03p>      LIKE LINE OF lt_dd03p,

                   <fs_sortfield>  LIKE LINE OF lt_sortfields,

                   <fs_keyfield>   LIKE LINE OF lt_keyfields.



* Get the object type

    lv_objtype = iv_obj_type.



* Look for the first task activity not yet processed

    READ TABLE t_e071 ASSIGNING <fs_e071>

      WITH KEY obj_name = objname

               used     = space

      BINARY SEARCH.



    IF sy-subrc <> 0.

      EXIT.

    ENDIF.



* Position on the first key of the object being processed

    READ TABLE t_e071k TRANSPORTING NO FIELDS WITH KEY trkorr     = <fs_e071>-trkorr

                                                       activity   = <fs_e071>-activity

                                                       mastername = <fs_e071>-obj_name.



    IF sy-subrc = 0.



      DATA:

        ev_name     TYPE string,

        ev_activity TYPE string,

        ev_textline TYPE string.



      lv_from = sy-tabix.



      ev_activity = t_e071k[ lv_from ]-mastername.



      DATA(lv_ca) = 'View Cluster ' ##NO_TEXT.

      DATA(lv_separator) = ': ' ##NO_TEXT.



      SELECT SINGLE text FROM vcldirt

        INTO @DATA(lv_view_cluster_descr)

        WHERE vclname = @ev_activity AND spras = @p_lang.



      IF lv_view_cluster_descr = ''.

        SELECT SINGLE text FROM vcldirt

        INTO @lv_view_cluster_descr

        WHERE vclname = @ev_activity AND spras = @gc_default_lang.

      ENDIF.





      CONCATENATE lv_ca ev_activity lv_separator lv_view_cluster_descr

      INTO ev_textline RESPECTING BLANKS.





      CALL METHOD mo_doc->('WRITE_TEXT')
        EXPORTING
          textline   = ev_textline
          line_style = 'Heading1' ##NO_TEXT.



      DATA lo_spro_doc_loader TYPE REF TO zloc_cl_spro_doc_loader.



      lo_spro_doc_loader = zloc_cl_spro_doc_loader=>get_instance( ).



      DATA lv_object_name TYPE trobj_name.

      lv_object_name = ev_activity.

      DATA lt_spro_docum TYPE zloc_cl_spro_doc_loader=>ty_t_itf_lines.

      DATA lv_document TYPE string.

      DATA ls_head TYPE thead.

      DATA lo_itf_to_xml_convertor TYPE REF TO cl_note_itf2xml.



      lo_itf_to_xml_convertor = NEW #( ).



      lo_spro_doc_loader->get_documentation(

        EXPORTING

          iv_obj_name      = lv_object_name

          iv_lang          = p_lang    " Language Key

        IMPORTING

          et_documentation = lt_spro_docum

          es_head          = ls_head

      ).



      IF lines( lt_spro_docum ) = 0 AND p_lang <> gc_default_lang.



        lo_spro_doc_loader->get_documentation(

          EXPORTING

              iv_obj_name      = lv_object_name

              iv_lang          = gc_default_lang    " Language Key

          IMPORTING

              et_documentation = lt_spro_docum

              es_head          = ls_head

              ).

      ENDIF.



      mo_doc->write_spro_documentation( it_documentation = lt_spro_docum ).

    ENDIF.













* Process all keys belonging to current object

    LOOP AT t_e071k ASSIGNING <fs_e071k> FROM lv_from.



      AT NEW viewname.







      ENDAT.



      AT NEW objname.



* Get information about all fields of the table

        REFRESH lt_dd03p.

        CALL FUNCTION 'DDIF_TABL_GET'
          EXPORTING
            name          = <fs_e071k>-objname
          TABLES
            dd03p_tab     = lt_dd03p
          EXCEPTIONS
            illegal_input = 1
            OTHERS        = 2.



        IF sy-subrc <> 0 OR lt_dd03p[] IS INITIAL.

          EXIT.

        ENDIF.



* Create the type object for field E071K-TABKEY

        lo_tabkeydescr = cl_abap_typedescr=>describe_by_name( 'E071K-TABKEY' ).



* Loop thru all key fields of the table:

*   1) Building a list of all key fields

*   2) Building a list of all CHARLIKE key fields that fit fields E071K-TABKEY

*   3) Building the WHERE clause for the SELECT to be used for data retrieval, using FOR ALL ENTRIES

*   4) Setting up table LT_FIELDS, with all key fields

        DELETE lt_dd03p WHERE keyflag      = abap_false OR

                              fieldname(1) = '.'.

        CLEAR: lv_keyfields, lv_charfields, lv_where.

        lv_complete_keys = abap_true.

        REFRESH lt_fields.

        LOOP AT lt_dd03p ASSIGNING <fs_dd03p>.



* Build the list of all key fields names

          CONCATENATE lv_keyfields <fs_dd03p>-fieldname INTO lv_keyfields

            SEPARATED BY space.



* Add key field to the key type strucuture of the object keys table

          APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

          <fs_field>-name = <fs_dd03p>-fieldname.

          <fs_field>-type ?= cl_abap_structdescr=>describe_by_name( <fs_dd03p>-rollname ).



          CHECK lv_complete_keys = abap_true.



* Check if structure containing all key fields of the View table is CHARLIKE

          IF <fs_field>-type->type_kind CN 'CNDT'.

            lv_complete_keys = abap_false.

            CONTINUE.

          ENDIF.



* Build the type object for key fields found so far, to help answer the following question below

          lo_structdescr = cl_abap_structdescr=>create( lt_fields ).



* If I add current CHARLIKE key field to key structure,

*   will it make the CHARLIKE key structure larger than field E071K-TABKEY ?

          IF lo_structdescr->length > lo_tabkeydescr->length.

            lv_complete_keys = abap_false.

            CONTINUE.

          ENDIF.



* Build the list of CHARLIKE key fields names

          CONCATENATE lv_charfields <fs_dd03p>-fieldname INTO lv_charfields

            SEPARATED BY space.



* Build the 'FIELDNAME = <FS_T_TAKEYS>-FIELDNAME' WHERE condition

          CONCATENATE '<FS_T_TABKEYS>-' <fs_dd03p>-fieldname INTO lv_str.

          CONCATENATE lv_where 'AND' <fs_dd03p>-fieldname '=' lv_str INTO lv_where SEPARATED BY space.



        ENDLOOP.



* Table has no key fields (?!?)

        IF sy-subrc <> 0.

          lv_str = `Table has no key fields`  ##NO_TEXT.



        ENDIF.



* Get rid of the " " at the beginning of key fuields list

        SHIFT lv_keyfields LEFT BY 1 PLACES.



* List of table key fields

        SPLIT lv_keyfields AT space INTO TABLE lt_keyfields.



* Get rid of the " " at the beginning of CHAR key fields list

        SHIFT lv_charfields LEFT BY 1 PLACES.



* List of table CHARLIKE key fields

        SPLIT lv_charfields AT space INTO TABLE lt_charfields.



* Get rid of the " AND " at the beginning of the WHERE clause

        SHIFT lv_where LEFT BY 5 PLACES.



* Creates the dynamic table with key fields of the data table

        lo_structdescr = cl_abap_structdescr=>create( lt_fields ).

        lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                    p_key       = lt_keyfields ).

        CREATE DATA lr_tabkeys TYPE HANDLE lo_tabledescr.

        ASSIGN lr_tabkeys->* TO <fs_t_tabkeys>.



      ENDAT.



* If we are not storing complete keys, get rid of the "*" at the end of key

      CLEAR lv_str.

      DATA lv_str1 TYPE trobj_name.

      lv_len = strlen( <fs_e071k>-tabkey ) - 1.

      IF lv_len >= 0.

        IF lv_complete_keys = abap_false AND

           <fs_e071k>-tabkey+lv_len(1) = '*'.

          lv_str1 = <fs_e071k>-tabkey(lv_len).

        ELSE.

          lv_str1 = <fs_e071k>-tabkey.

          lv_len = lv_len + 1.

        ENDIF.

      ENDIF.





* Creates a new key in the keys table

      APPEND INITIAL LINE TO <fs_t_tabkeys> ASSIGNING <fs_s_tabkey>.

*      <fs_s_tabkey> = lv_str.

      MOVE lv_str1 TO <fs_s_tabkey>+0(lv_len).



      AT END OF objname.



* Get rid of duplicate keys in the keys table

        SORT <fs_t_tabkeys> BY table_line.

        IF lv_complete_keys = abap_true.

          DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys> COMPARING ALL FIELDS.

        ELSEIF lt_charfields[] IS NOT INITIAL.



* Create a table with same fields as LT_TABKEYS, but with CHAR key fields

          lo_tabledescr = cl_abap_tabledescr=>create( p_line_type = lo_structdescr

                                                      p_key       = lt_charfields ).

          CREATE DATA lr_tabkeys2 TYPE HANDLE lo_tabledescr.

          ASSIGN lr_tabkeys2->* TO <fs_t_tabkeys2>.



* Get rid of all CHARLIKE key duplicates

          <fs_t_tabkeys2>[] = <fs_t_tabkeys>[].

          DELETE ADJACENT DUPLICATES FROM <fs_t_tabkeys2>.

          <fs_t_tabkeys>[] = <fs_t_tabkeys2>[].



        ENDIF.



* Only reuse the keys table as data table if data table fields are all key fields and

*   if data table allows storing complete keys in the request

        DATA length1 TYPE i.

        DATA length2 TYPE i.

        DESCRIBE TABLE lt_dd03p LINES length1.

        DESCRIBE TABLE lt_keyfields LINES length2.



        IF length1 = length2.

*           and lv_complete_keys = abap_true.



* If not, then create the table that will contain the records to be written

          CREATE DATA lr_t_table TYPE STANDARD TABLE OF (<fs_e071k>-objname) WITH KEY (lt_keyfields).

          ASSIGN lr_t_table->* TO <fs_t_table>.



* And select the desired records from database using CHARLIKE keys table <FS_T_TABKEYS> as the key

          IF <fs_t_tabkeys>[] IS NOT INITIAL.

            SELECT  *

              INTO  TABLE <fs_t_table>

              FROM  (<fs_e071k>-objname)

              CLIENT SPECIFIED

              FOR ALL ENTRIES IN <fs_t_tabkeys>

              WHERE (lv_where).

          ENDIF.



        ELSE.



* If yes, the table <fs_t_tabkeys> already contains all fields that should be written

          ASSIGN <fs_t_tabkeys> TO <fs_t_table>.



        ENDIF.



        IF <fs_t_table>[] IS NOT INITIAL.



* Get rid of duplicate entries in the data table

          REFRESH lt_sortfields.

          LOOP AT lt_keyfields ASSIGNING <fs_keyfield>.

            APPEND INITIAL LINE TO lt_sortfields ASSIGNING <fs_sortfield>.

            <fs_sortfield>-name = <fs_keyfield>.

          ENDLOOP.

          SORT <fs_t_table> BY (lt_sortfields).

          DELETE ADJACENT DUPLICATES FROM <fs_t_table>.



          CALL METHOD mo_doc->('WRITE_TABLE_ENH')
            EXPORTING
              content    = <fs_t_table>
              table_name = <fs_e071k>-objname.

          CALL METHOD mo_doc->('WRITE_NEWPAGE').



        ENDIF.



      ENDAT.



* If it's the last key for current object, exit

      AT END OF viewname.

      ENDAT.



*Remove CDAT NODE

*

** If it's the last key for current object, exit

      AT END OF mastername.

*

** Inserts the CDAT node into the XML document

*        xmldoc->append_child( lo_cdat_node ).

        EXIT.



      ENDAT.



    ENDLOOP.



    <fs_e071>-used = abap_true.



*    ixmldocument = xmldoc.





  ENDMETHOD.



  METHOD add_object_to_doc.



    objname = iv_obj_name.



    CASE iv_obj_type.



      WHEN 'VDAT'.

        CALL METHOD me->init_plugin(
          EXPORTING
            iv_mastertype = 'VDAT'
          IMPORTING
            et_e071       = me->t_e071
            et_e071k      = me->t_e071k
                            ).

        CALL METHOD me->eject_inf_about_vdat
          EXPORTING
            iv_obj_type = iv_obj_type.



      WHEN 'TDAT'.

        CALL METHOD me->init_plugin(
          EXPORTING
            iv_mastertype = 'TDAT'
          IMPORTING
            et_e071       = me->t_e071
            et_e071k      = me->t_e071k
                            ).

        CALL METHOD me->eject_inf_about_vdat
          EXPORTING
            iv_obj_type = iv_obj_type.



      WHEN 'CDAT'.

        CALL METHOD me->init_plugin(
          EXPORTING
            iv_mastertype = 'CDAT'
          IMPORTING
            et_e071       = me->t_e071
            et_e071k      = me->t_e071k
                            ).

        CALL METHOD me->eject_inf_about_cdat
          EXPORTING
            iv_obj_type = iv_obj_type.



    ENDCASE.



  ENDMETHOD.



  METHOD init_plugin.

    TYPES: ty_r_trkorr TYPE RANGE OF e071-trkorr.



    TYPES: BEGIN OF ty_trfunction,

             trkorr     TYPE e070-trkorr,

             trfunction TYPE e070-trfunction.

    TYPES: END OF ty_trfunction.



    DATA: lv_str        TYPE string,

          lt_trkorr     TYPE STANDARD TABLE OF e070-trkorr,

          lt_trfunction TYPE STANDARD TABLE OF ty_trfunction.



    FIELD-SYMBOLS: <fs_nugr>       TYPE c,

                   <fs_nuga>       TYPE c,

                   <fs_r_reqnugg>  TYPE ty_r_trkorr,

                   <fs_trfunction> LIKE LINE OF lt_trfunction,

                   <fs_trkorr>     LIKE LINE OF lt_trkorr.





    REFRESH: et_e071, et_e071k.





* Get the request number from selection screen

    CONCATENATE '(' sy-cprog ')s_req[]' INTO lv_str.

    ASSIGN (lv_str) TO <fs_r_reqnugg>.





* Get type of all requests supplied

    SELECT  trkorr trfunction

      INTO  TABLE lt_trfunction

      FROM  e070

      WHERE trkorr IN <fs_r_reqnugg>.



* Loop thru all requests supplied, looking for their tasks

    LOOP AT lt_trfunction ASSIGNING <fs_trfunction>.



      IF <fs_trfunction>-trfunction CO 'SRXQT'.



        APPEND INITIAL LINE TO lt_trkorr ASSIGNING <fs_trkorr>.

        <fs_trkorr> = <fs_trfunction>-trkorr.



* If it's a request, search for its tasks

      ELSEIF <fs_trfunction>-trfunction = 'W'. " Customizing



        APPEND INITIAL LINE TO lt_trkorr ASSIGNING <fs_trkorr>.

        <fs_trkorr> = <fs_trfunction>-trkorr.

* Get all tasks of the request

        SELECT  trkorr

          APPENDING TABLE lt_trkorr

          FROM  e070

          WHERE strkorr = <fs_trfunction>-trkorr.

      ENDIF.



    ENDLOOP.



    IF lt_trkorr[] IS NOT INITIAL.



      IF et_e071[] IS SUPPLIED.



* Load all R3TR VDAT objects and their keys for all tasks of the request

        SELECT  obj_name trkorr activity

          INTO  TABLE et_e071

          FROM  e071

          FOR ALL ENTRIES IN lt_trkorr

          WHERE trkorr = lt_trkorr-table_line AND

                pgmid  = iv_pgmid AND

                object = iv_mastertype.



        IF sy-subrc <> 0.

          MESSAGE s208(00) WITH 'Transport Request is empty'  ##NO_TEXT.

          EXIT.

        ENDIF.



        SORT et_e071 BY obj_name used trkorr activity.



      ENDIF.



      IF et_e071k[] IS SUPPLIED.



* Get all object keys from all tasks

        SELECT  trkorr activity mastername viewname objname tabkey

          INTO  TABLE et_e071k

          FROM  e071k

          FOR ALL ENTRIES IN lt_trkorr

          WHERE trkorr = lt_trkorr-table_line AND

                pgmid      = iv_pgmid AND

                object     = iv_object AND

                mastertype = iv_mastertype.



        SORT et_e071k BY table_line.

        DELETE ADJACENT DUPLICATES FROM et_e071k

          COMPARING table_line.



      ENDIF.



    ENDIF.



    DATA ls_style TYPE cl_word=>ty_character_style_effect.

    ls_style-bold = cl_word=>c_true.

    ls_style-size = 16.

    ls_style-font = cl_word=>c_font_calibri.



    DATA ls_par_style TYPE cl_word=>ty_paragraph_style_effect.

    ls_par_style-alignment = cl_word=>c_align_center.







  ENDMETHOD.

ENDCLASS.
