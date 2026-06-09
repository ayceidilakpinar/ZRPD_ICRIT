*----------------------------------------------------------------------*
*                                                                      *
*       Input-modules for infotype 9660                                *
*                                                                      *
*----------------------------------------------------------------------*
MODULE icra_tab_active_tab_get INPUT.

  gv_fcode = sy-ucomm.
  CASE gv_fcode.
    WHEN c_icra_tab-tab1. g_icra_tab-pressed_tab = c_icra_tab-tab1.
    WHEN c_icra_tab-tab2. g_icra_tab-pressed_tab = c_icra_tab-tab2.
    WHEN c_icra_tab-tab3. g_icra_tab-pressed_tab = c_icra_tab-tab3.
    WHEN c_icra_tab-tab4. g_icra_tab-pressed_tab = c_icra_tab-tab4.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  PERFORM user_command_0110.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  KESINTI_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE kesinti_data INPUT.
  DATA: lv_rcode TYPE pspar-rcode.

  DATA: ls_9661     TYPE p9661.


  CHECK gs_kesinti-change IS NOT INITIAL OR gs_kesinti-delete IS NOT INITIAL.


  CASE COND #( WHEN gs_kesinti-delete IS NOT INITIAL THEN 'DELETE'
               WHEN gs_kesinti-change IS NOT INITIAL THEN 'CHANGE' ).

    WHEN 'CHANGE'.

      CALL FUNCTION 'ZHR_ICRA_SABIT'
        IMPORTING
          ev_docnr = p9660-docnr
          ev_waers = p9660-dedwa.


      PERFORM rp_infotyp_internal IN PROGRAM sapfp50g
        USING p9660-pernr
              'MOD'
              '9661'
              '0002'
              space
              gs_kesinti-begda
              gs_kesinti-begda
              lv_rcode  IF FOUND.
    WHEN 'DELETE'.
      DELETE FROM pa9661 WHERE pernr EQ @p9660-pernr
                           AND begda EQ @gs_kesinti-begda
                           AND endda EQ @gs_kesinti-begda
                           AND docnr EQ @gs_kesinti-docnr
*                           AND subty EQ @gs_kesinti-subty
                           AND seqno EQ @gs_kesinti-seqno.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        MESSAGE 'Silme Başarılı' TYPE 'S'.
        CLEAR: gs_kesinti.
        DELETE gt_kesinti INDEX sy-loopc.
      ENDIF.
  ENDCASE.


ENDMODULE.
