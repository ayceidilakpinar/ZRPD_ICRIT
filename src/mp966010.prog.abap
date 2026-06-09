*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9660                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM MP966000 MESSAGE-ID RP.

TABLES: P9660.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement


TYPES : BEGIN OF ty_kesinti ,
          subty TYPE t591s-subty,
          begda TYPE P9661-begda,
          stext TYPE t591s-stext,
          docnr TYPE P9661-docnr,
          seqno TYPE P9661-seqno,
          dedam TYPE P9661-dedam,
          dedwa TYPE P9661-dedwa,
          change,
          delete,
        END OF   ty_kesinti .

FIELD-SYMBOLS: <pnnnn> STRUCTURE P9660
                       DEFAULT P9660.

DATA: psave LIKE P9660.

CONSTANTS: BEGIN OF c_icra_tab,
             tab1 LIKE sy-ucomm VALUE 'ICRA_TAB_FC1',
             tab2 LIKE sy-ucomm VALUE 'ICRA_TAB_FC2',
             tab3 LIKE sy-ucomm VALUE 'ICRA_TAB_FC3',
             tab4 LIKE sy-ucomm VALUE 'ICRA_TAB_FC4',
           END OF c_icra_tab.

CONTROLS:  icra_tab TYPE TABSTRIP.

DATA: c_molga TYPE molga VALUE '47', "- Türkiye
      c_waers TYPE waers VALUE 'TRY'. "- TRY


DATA: BEGIN OF g_icra_tab,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'MP966000',
        pressed_tab LIKE sy-ucomm VALUE c_icra_tab-tab1,
      END OF g_icra_tab.
DATA:      gv_fcode LIKE sy-ucomm.


DATA : BEGIN OF gv,
         lgart TYPE lgart,
         num   TYPE numc2,
       END OF gv.

DATA : gt_kesinti TYPE TABLE OF ty_kesinti,
       gs_kesinti TYPE ty_kesinti.

DATA : BEGIN OF gs_2001 ,
         lgtxt  TYPE t512t-lgtxt,
         toplam TYPE P9660-dedam,
         kalan  TYPE P9660-dedam,
       END OF   gs_2001 .

DATA : BEGIN OF gs_2002 ,
         lgt01 TYPE t512t-lgtxt,
         lgt02 TYPE t512t-lgtxt,
         lgt03 TYPE t512t-lgtxt,
         lgt04 TYPE t512t-lgtxt,
         lgt05 TYPE t512t-lgtxt,
         lgt06 TYPE t512t-lgtxt,
         lgt07 TYPE t512t-lgtxt,
         lgt08 TYPE t512t-lgtxt,
         lgt09 TYPE t512t-lgtxt,
         lgt10 TYPE t512t-lgtxt,
       END OF   gs_2002 .

CONTROLS: tc_kesinti TYPE TABLEVIEW USING SCREEN 2003.
DATA:     g_tc_kesinti_lines  LIKE sy-loopc.
DATA:     ok_code LIKE sy-ucomm.
