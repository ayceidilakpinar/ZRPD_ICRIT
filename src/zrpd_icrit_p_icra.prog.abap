*&---------------------------------------------------------------------*
*& Report ZRPD_ICRIT_P_ICRA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPD_ICRIT_P_ICRA.


INCLUDE : ZRPD_ICRIT_i_ICRA_top ,
          ZRPD_ICRIT_i_ICRA_cls ,
          ZRPD_ICRIT_i_ICRA_frm .

INITIALIZATION .
  CREATE OBJECT gv_prog .

START-OF-SELECTION .
  gv_prog->set_dates( ) .

  gv_prog->get_master_data( ).

  CLEAR: gv_sira,
         gt_p9660,
         gt_p9661,
         gt_p0105,
         gt_p0770,
         gt_p0001.


  GET pernr .

*  rp-provide-from-last p9660 space pnpbegda pnpendda.
*  rp-provide-from-last p9660 0010  sy-datum sy-datum.
*
*  gv_prog->set_last( ).

  APPEND LINES OF: p9660 TO gt_p9660,
                   p9661 TO gt_p9661,
                   p0105 TO gt_p0105,
                   p0770 TO gt_p0770,
                   p0001 TO gt_p0001.

*  gv_prog->get_data( EXPORTING i_pernr = pernr
*                      CHANGING t_table = gt_alv ).

END-OF-SELECTION .

  gv_prog->get_data( CHANGING  t_table = gt_alv ).

  IF gt_alv IS NOT INITIAL .
    gv_prog->show_alv( CHANGING alv_tab = gt_alv ) .
  ELSE .
    MESSAGE TEXT-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
