*----------------------------------------------------------------------*
*                                                                      *
*       Subroutines for infotype 9660                                  *
*                                                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form STATUS_0110
*&---------------------------------------------------------------------*
FORM status_0110 .

  DATA : lv_anzhl TYPE anzhl,
         lv_lgtxt TYPE t512t-lgtxt,
         lv_datum TYPE datum,
         lv_betrg TYPE betrg.

  IF p9660-lgart IS NOT INITIAL .
    SELECT SINGLE lgtxt FROM t512t INTO gs_2001-lgtxt
      WHERE sprsl EQ sy-langu
        AND molga EQ c_molga
        AND lgart EQ p9660-lgart.
  ENDIF.

  IF p9660-dedwa IS INITIAL .
    p9660-dedwa = c_waers .
  ENDIF.

  IF p9660-intwa IS INITIAL .
    p9660-intwa = c_waers .
  ENDIF.

  IF p9660-seqno IS INITIAL .
    SELECT COUNT(*) FROM pA9660 INTO p9660-seqno
      WHERE pernr EQ p9660-pernr .
    ADD 1 TO p9660-seqno .
  ENDIF.

  CASE p9660-dedcn.
    WHEN '00'. "- Orana Göre Kesinti
      "- Diğer Ücret Türü Tanımları
      CLEAR: gv-num, gv-lgart, p9660-dedcs .
      DO 10 TIMES VARYING gv-lgart FROM p9660-lga01 NEXT p9660-lga02 .
        gv-num = sy-index .
        IF gv-lgart IS NOT INITIAL .
          ASSIGN COMPONENT |LGT{ gv-num }| OF STRUCTURE gs_2002 TO FIELD-SYMBOL(<fs_txt>).
          IF <fs_txt> IS ASSIGNED .

            SELECT SINGLE lgtxt FROM t512t INTO <fs_txt>
              WHERE sprsl EQ sy-langu
                AND molga EQ c_molga
                AND lgart EQ gv-lgart.
            UNASSIGN <fs_txt>.
          ENDIF.

        ENDIF.

      ENDDO.

      DO 15 TIMES VARYING lv_datum FROM p9660-DAT01 NEXT p9660-DAT02
                  VARYING lv_betrg FROM p9660-BET01 NEXT p9660-BET02.
        CLEAR : lv_datum,lv_betrg.
      ENDDO.

    WHEN '01'. "- Sabit Kesinti
      DO 10 TIMES VARYING gv-lgart FROM p9660-lga01   NEXT p9660-lga02
                  VARYING lv_anzhl FROM p9660-per01   NEXT p9660-per02
                  VARYING lv_lgtxt FROM gs_2002-lgt01 NEXT gs_2002-lgt02.
        CLEAR : lv_anzhl, lv_lgtxt, gv-lgart .
      ENDDO.

      DO 15 TIMES VARYING lv_datum FROM p9660-DAT01 NEXT p9660-DAT02
                  VARYING lv_betrg FROM p9660-BET01 NEXT p9660-BET02.
        CLEAR : lv_datum,lv_betrg.
      ENDDO.
    WHEN '02'. " değişken kesinti
      CLEAR: p9660-dedcs.
      DO 10 TIMES VARYING gv-lgart FROM p9660-lga01   NEXT p9660-lga02
                  VARYING lv_anzhl FROM p9660-per01   NEXT p9660-per02
                  VARYING lv_lgtxt FROM gs_2002-lgt01 NEXT gs_2002-lgt02 .
        CLEAR : lv_anzhl, lv_lgtxt, gv-lgart .
      ENDDO.

  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group2+0(1) EQ |{ sy-dynnr+3(1) }|.
      screen-input     = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group2 EQ |{ sy-dynnr+3(1) }{ p9660-dedcn }|.
      IF screen-group4 IS INITIAL .
        screen-input     = 1.
      ENDIF.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.

    IF psyst-ioper EQ display
    OR psyst-ioper EQ display_no_list.
      screen-input     = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0110
*&---------------------------------------------------------------------*
FORM user_command_0110 .

  DATA : lv_rcode TYPE pspar-rcode . "- Dönüş Tipi

  CASE sy-ucomm.
    WHEN 'KESINTI'.

      CALL FUNCTION 'ZHR_ICRA_SABIT'
        EXPORTING
          iv_mode  = 'I'
          iv_docnr = p9660-docnr
          iv_waers = p9660-dedwa.

      PERFORM rp_infotyp_internal IN PROGRAM sapfp50g
        USING p9660-pernr
              'INS'
              '9661'
              '0002' "- Manuel Kesinti Oluştur
              space
              sy-datum
              sy-datum
              lv_rcode  IF FOUND .
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_9101_DATA
*&---------------------------------------------------------------------*
FORM get_9661_data.

  DATA : lr_subty TYPE RANGE OF subty .

  CLEAR : gs_2001-toplam, gs_2001-kalan.

  CASE sy-dynnr.
    WHEN '2003'.  "- Ara Ödemeler Ekranı için Alt Tip Belirle
      APPEND 'IEQ0002' TO lr_subty ."- Manuel Kesinti
  ENDCASE.

  "- Alt Tip Tanımlarını Getir
  SELECT subty,
         stext
    FROM t591s INTO TABLE @DATA(lt_subty)
    WHERE sprsl EQ @sy-langu
      AND infty EQ '9661'
      AND subty IN @lr_subty .

  "- Bilgi Tipi Verilerini Getir
  SELECT subty,
         begda,
         docnr,
         seqno,
         dedam,
         dedwa
    FROM pa9661 INTO CORRESPONDING FIELDS OF TABLE @gt_kesinti
      WHERE pernr EQ @p9660-pernr
        AND subty IN @lr_subty
        AND docnr EQ @p9660-docnr .

  LOOP AT gt_kesinti ASSIGNING FIELD-SYMBOL(<fs_kesinti>).

    READ TABLE lt_subty ASSIGNING FIELD-SYMBOL(<fs_subty>) WITH KEY subty = <fs_kesinti>-subty .
    IF sy-subrc EQ 0 .
      <fs_kesinti>-stext = <fs_subty>-stext.
    ENDIF.

    "- Toplam Ödemeyi Hesapla
    ADD <fs_kesinti>-dedam TO gs_2001-toplam.

  ENDLOOP.

  gs_2001-kalan = ( p9660-dedam + p9660-intam ) - gs_2001-toplam .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_SUBTY_INVISIBLE
*&---------------------------------------------------------------------*
FORM set_subty_invisible .

  " kolon ekleme / gizleme screen
  FIELD-SYMBOLS <fs_cols> TYPE ANY TABLE .
  ASSIGN COMPONENT 'COLS' OF STRUCTURE tc_kesinti TO <fs_cols>.

  TRY .

      LOOP AT <fs_cols> ASSIGNING FIELD-SYMBOL(<fs_col>)
        WHERE ('SCREEN-NAME EQ ''GS_KESINTI-SUBTY''').
        ASSIGN COMPONENT 'INVISIBLE' OF STRUCTURE <fs_col> TO FIELD-SYMBOL(<fs_val>).
        IF <fs_val> IS ASSIGNED .
          <fs_val> = 1 . "- SUBTY Colonunu Gösterme
        ENDIF.
      ENDLOOP.

    CATCH cx_root .

  ENDTRY.

ENDFORM.
