*----------------------------------------------------------------------*
*                                                                      *
*       Output-modules for infotype 9660                               *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       MODULE  P9660 OUTPUT                                           *
*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE p9660 OUTPUT.
  IF psyst-nselc EQ yes.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
*   PERFORM RExxxx.
    IF psyst-iinit = yes AND psyst-ioper = insert.
* generate default values; do this the very first time on insert only:
*     PERFORM GET_DEFAULT.
      CALL FUNCTION 'GUID_CREATE'
        IMPORTING
          ev_guid_32 = p9660-docnr.
      .
    ENDIF.
  ENDIF.
ENDMODULE.
*----------------------------------------------------------------------*
*       MODULE  P9660L OUTPUT                                          *
*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE p9660l OUTPUT.
* PERFORM RExxxx.
ENDMODULE.

MODULE icra_tab_active_tab_set OUTPUT.
  icra_tab-activetab = g_icra_tab-pressed_tab.
  CASE g_icra_tab-pressed_tab.
    WHEN c_icra_tab-tab1. g_icra_tab-subscreen = '2001'.
    WHEN c_icra_tab-tab2. g_icra_tab-subscreen = '2002'.
    WHEN c_icra_tab-tab3. g_icra_tab-subscreen = '2003'.
    WHEN c_icra_tab-tab4. g_icra_tab-subscreen = '2004'.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  PERFORM status_0110 .
  PERFORM get_9661_data .
ENDMODULE.

MODULE tc_kesinti_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_kesinti LINES tc_kesinti-lines.
ENDMODULE.

MODULE tc_kesinti_get_lines OUTPUT.
  g_tc_kesinti_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TC_KESINTI OUTPUT
*&---------------------------------------------------------------------*
MODULE set_tc_kesinti OUTPUT.

  PERFORM set_subty_invisible .

ENDMODULE.
