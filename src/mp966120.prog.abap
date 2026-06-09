*----------------------------------------------------------------------*
*                                                                      *
*       Output-modules for infotype 9661                               *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       MODULE  P9661 OUTPUT                                           *
*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE P9661 OUTPUT.
  IF PSYST-NSELC EQ YES.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
*   PERFORM RExxxx.
    IF PSYST-IINIT = YES AND PSYST-IOPER = INSERT.
* generate default values; do this the very first time on insert only:
*     PERFORM GET_DEFAULT.
    ENDIF.
  ENDIF.

   CASE psyst-ioper .
    WHEN insert.

      IF P9661-docnr IS NOT INITIAL.
        CALL FUNCTION 'ZRPD_ICRIT_FM_SABIT'
          EXPORTING
            iv_mode  = 'I'
            iv_docnr = P9661-docnr
            iv_waers = P9661-dedwa.
      ELSE.
        CALL FUNCTION 'ZRPD_ICRIT_FM_SABIT'
          EXPORTING
            iv_mode  = 'E'
          IMPORTING
            ev_docnr = P9661-docnr
            ev_waers = P9661-dedwa.
      ENDIF.

      IF P9661-docnr IS INITIAL .
        MESSAGE i001(zhr_icra) WITH TEXT-grs DISPLAY LIKE 'E'.
        LEAVE TO SCREEN 0 .
      ELSE .
        "- Doküman Numarası ile sıradaki kaydı bul
        SELECT COUNT(*) FROM PA9661 INTO P9661-seqno
           WHERE pernr EQ P9661-pernr
             AND docnr EQ P9661-docnr .
        ADD 1 TO P9661-seqno .
      ENDIF.
       ENDCASE.
ENDMODULE.
*----------------------------------------------------------------------*
*       MODULE  P9661L OUTPUT                                          *
*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE P9661L OUTPUT.
* PERFORM RExxxx.
ENDMODULE.

MODULE P9661_change_data INPUT.
  IF (  psyst-ioper EQ 'INS' OR psyst-ioper EQ 'MOD' OR psyst-ioper EQ 'COP' ).
    P9661-endda = P9661-begda.

    SELECT SINGLE dedam FROM PA9660
      INTO @DATA(lv_dedam)
      WHERE pernr EQ @P9661-pernr
        AND docnr EQ @P9661-docnr.

    "INTAM 9002058918
    "faiz eklendi 03.12.2020
    SELECT SINGLE intam FROM PA9660
      INTO @DATA(lv_faiz)
      WHERE pernr EQ @P9661-pernr
        AND docnr EQ @P9661-docnr.

    lv_dedam = lv_dedam + lv_faiz .

    "INTAM 9002058918

    SELECT SUM( dedam ) AS dedam
      FROM PA9661 INTO @DATA(lv_odenen)
      WHERE pernr EQ @P9661-pernr
        AND docnr EQ @P9661-docnr.


    lv_odenen = lv_odenen + P9661-dedam.

    IF lv_odenen GT lv_dedam.
      CLEAR: P9661-dedam.
      MESSAGE e003(zhr_icra) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.
ENDMODULE.
