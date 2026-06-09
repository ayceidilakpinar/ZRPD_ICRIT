*&---------------------------------------------------------------------*
*&  Include           ZRPD_ICRIT_I_ICRA_BORDRO
*&---------------------------------------------------------------------*

INITIALIZATION .
  INFOTYPES : 9660, 9661.



FORM fu_icit.
  "
  TYPES: BEGIN OF ty_9660,
           datum TYPE datum,
           betrg TYPE betrg,
           "07.2022 DOCNR Eklendi Rapidsol
           docnr TYPE ZRPD_ICRIT_de_docnr,
           "07.2022 DOCNR Eklendi Rapidsol
         END OF ty_9660.
  "

  "- Ödenen Tutar
  DATA : lv_odenen        TYPE p9661-dedam, "- Ödenen Tutar
         lv_kalan         TYPE prbetrg, "- Kalan Tutar
         lv_kesilecek     TYPE prbetrg, "- Kesilecek Tutar
         lv_fark          TYPE prbetrg, "- Sonraki İcra'dan Kesilebilecek Tutar
         lv_kesilen       TYPE prbetrg, "- şuana kadar kesilen ücret
         lv_kesilebilecek TYPE prbetrg, "- max kesilebicek tutar
         lv_lgart         TYPE lgart , "- Ücret Türü
         lv_percn         TYPE anzhl , "- Yüzde
         lv_seqnr         TYPE p9661-seqnr,
         lv_oper          TYPE pspar-actio VALUE 'INS', "- Yeni Kayıt
         lv_tabix         TYPE sy-tabix,
         lv_lga_count     TYPE i,
         lv_count         TYPE numc2.

  DATA : lt_9660 TYPE TABLE OF ty_9660. "

  DATA : ls_bapireturn TYPE bapireturn1.

  DATA  : ls_return TYPE bapireturn1 .

  DATA : lt_it TYPE TABLE OF pc207 WITH HEADER LINE.

  DATA : lt_rt TYPE TABLE OF pc207 WITH HEADER LINE.

  " begin >>>>>>>>>>>>>>>>>>
  DATA :
    lv_begda_9660 TYPE d,
    lv_endda_9660 TYPE d.
  DATA: lv_lgart_temp TYPE lgart,
        lt_p9660_temp LIKE TABLE OF p9660.
  " end <<<<<<<<<<<<<<<<<<<<

  "fark bordrosu için 31.01.2021
  DATA : l_check(1).
  CLEAR l_check .
  IF first_activ_cperiod IS NOT INITIAL AND first_activ_cperiod NE pn-paper
    AND pn-paper NE pn-begda(6).
    l_check = 'X'.
  ENDIF.
  CHECK l_check IS INITIAL .
  "31.01.2021


  SORT p9660 BY lgart ASCENDING seqno ASCENDING.


  CLEAR p9661[].

  CALL FUNCTION 'HR_READ_INFOTYPE'       "Added by D_CSAGBILGE AT 13.09.19
    EXPORTING
*     TCLAS     = 'A'
      pernr     = p9660-pernr
      infty     = '9661'
    TABLES
      infty_tab = p9661.


  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT p9661 BY docnr ASCENDING .

  DATA: BEGIN OF lt_fark OCCURS 0,
          lgart TYPE lgart,
          per01 TYPE pa9660-per01,
        END OF lt_fark.
  REFRESH lt_fark[].

  " begin >>>>>>>>>>>>>>>>>>
  lv_begda_9660 = pn-begda(6) && '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_begda_9660
    IMPORTING
      last_day_of_month = lv_endda_9660
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  "  end <<<<<<<<<<<<<<<<<<<<

  "- İcralarda Dön
  DATA lv_stop.
  LOOP AT p9660 WHERE begda LE lv_begda_9660
                  AND endda GE lv_endda_9660
                  AND icdrm EQ 0 ."- Açık Durumdaki İcralarda Dön

*    IF p9100-lgart NE lv_lgart_temp.


    lv_tabix = sy-tabix .

    CLEAR: lv_odenen,
           lv_kalan,
           lv_seqnr,
           lv_kesilecek.
    "- Ödenen Tutarı Hesapla

    DATA: lv_date   TYPE p0001-begda,
          lv_days   TYPE t5a4a-dlydy,
          lv_months TYPE t5a4a-dlymo,
          lv_years  TYPE t5a4a-dlyyr,
          lv_tarih  TYPE p0001-begda,
          lv_docnr  TYPE ZRPD_ICRIT_de_docnr.

    CLEAR: lv_date,
           lv_days,
           lv_months,
           lv_years,
           lv_docnr.


    lv_date   = sy-datum.
    lv_months = '01'.
    lv_days   = '00'.
    lv_years  = '0000'.


    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = lv_date
        days      = lv_days
        months    = lv_months
        years     = lv_years
        signum    = '-'
      IMPORTING
        calc_date = lv_tarih.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_tarih
      IMPORTING
        last_day_of_month = lv_tarih
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*    LOOP AT p9101 WHERE begda LE lv_tarih
    LOOP AT p9661 WHERE begda LT pn-begda   "Changed by D_CSAGBILGE AT 13.09.19
                    AND docnr EQ p9660-docnr.
      ADD p9661-dedam TO lv_odenen .
      ADD 1           TO lv_seqnr  .
    ENDLOOP.

    "- Kalan Üzerinden Hesaplama Yapılacak
    lv_kalan = ( p9660-dedam + p9660-intam ) - lv_odenen .

    CHECK lv_kalan GT 0 . "- Kalan 0'dan Büyükse Devam Et

    DATA: lv_betrg TYPE betrg.

    REFRESH lt_9660.CLEAR: lv_kesilebilecek.
    "- Ödeme Türüne Göre Kesilebilecek Tutar Hesapla
    CASE p9660-dedcn.
      WHEN '00'. "- Orana Göre Kesinti
        "-
        CLEAR: lv_docnr.
        lv_docnr = p9660-docnr.
        CLEAR : lt_it, lt_it[].
        LOOP AT it .
          lt_it-lgart = it-lgart.
          lt_it-betpe = it-betpe.
          lt_it-anzhl = it-anzhl.
          lt_it-betrg = it-betrg.
          COLLECT lt_it. CLEAR lt_it.
        ENDLOOP.

        CLEAR : lt_rt, lt_rt[].
        LOOP AT rt .
*          lt_rt-lgart = rt-lgart .
*          lt_rt-betpe = rt-betpe .
*          lt_rt-anzhl = rt-anzhl .
*          lt_rt-betrg = rt-betrg .
*          COLLECT lt_rt . CLEAR lt_rt .

          lt_it-lgart = rt-lgart.
          lt_it-betpe = rt-betpe.
          lt_it-anzhl = rt-anzhl.
          lt_it-betrg = rt-betrg.
          COLLECT lt_it . CLEAR lt_it .
        ENDLOOP.

        "- 10 Tane Alan Var Dön ve Hesapla
*        DO 10 TIMES VARYING lv_lgart FROM p9100-lga01 NEXT p9100-lga02
*                    VARYING lv_percn FROM p9100-per01 NEXT p9100-per02 .
*
*          "- Split'e Bakılmaksızın Kesilme Durumu
*          LOOP AT lt_it WHERE lgart EQ lv_lgart.
*            lv_kesilecek = lv_kesilecek + ( ( lt_it-betrg / 100 ) * lv_percn ).
*          ENDLOOP.
*
*        ENDDO.

*        - 10 Tane Alan Var Dön ve Hesapla
*        DO 10 TIMES VARYING lv_lgart FROM p9100-lga01 NEXT p9100-lga02
*                    VARYING lv_percn FROM p9100-per01 NEXT p9100-per02.


        CLEAR: lv_count, lv_lga_count.
        DO 10 TIMES.

          ADD 1 TO lv_count.
          CLEAR lv_percn.

          DATA(lv_field) = CONV char50( 'p9660-LGA' && lv_count ).
          ASSIGN (lv_field) TO FIELD-SYMBOL(<fs_lgart>).

          CLEAR lv_field.

          lv_field = CONV char50( 'p9660-PER' && lv_count ).
          ASSIGN (lv_field) TO FIELD-SYMBOL(<fs_percn>).

          "- Split'e Bakılmaksızın Kesilme Durumu
          LOOP AT lt_it WHERE lgart EQ <fs_lgart>.
            lv_kesilecek = lv_kesilecek + ( ( lt_it-betrg / 100 ) * <fs_percn> ).
            lv_kesilebilecek =  lv_kesilecek.


            APPEND VALUE #( lgart = <fs_lgart>
                            per01 = <fs_percn> ) TO lt_fark.
            ADD 1 TO lv_lga_count.

          ENDLOOP.

        ENDDO.

      WHEN '01'. "- Sabit Kesinti
        CLEAR: lv_docnr.
        lv_docnr = p9660-docnr.
        lv_kesilecek = p9660-dedcs . "- Kesilecek Tutarı Doğrudan Al
      WHEN '02'. "değişken kesinti
        " safak sever 28.12.2019 02:00:28
        CLEAR: lv_count ,lv_docnr.
        lv_docnr = p9660-docnr.
        LOOP AT p9660.
          CLEAR: lv_count.
          DO 15 TIMES.
            lv_count = lv_count + 1.

            CLEAR: lv_field.
            lv_field = CONV char50( 'p9660-DAT' && lv_count ).
            ASSIGN (lv_field) TO FIELD-SYMBOL(<fs_datum>).

            CLEAR: lv_field.
            lv_field = CONV char50( 'p9660-BET' && lv_count ).
            ASSIGN (lv_field) TO FIELD-SYMBOL(<fs_betrg>).


            CHECK <fs_datum> IS NOT INITIAL OR <fs_betrg> IS NOT INITIAL.

            APPEND VALUE #( datum = <fs_datum>
                            betrg = <fs_betrg>
                            docnr = p9660-docnr )
                         TO lt_9660[].

          ENDDO.
        ENDLOOP.

        CLEAR: lv_betrg.
        LOOP AT lt_9660 INTO DATA(ls_9660) WHERE datum BETWEEN aper-begda AND aper-endda
                                             AND docnr EQ lv_docnr.
          lv_betrg = lv_betrg + ls_9660-betrg.
        ENDLOOP.

        lv_kesilecek = lv_kesilecek + lv_betrg.
    ENDCASE.


    "- Eğer Fark Varsa Kesilecek Tutara Farkı Ver
    CLEAR: lv_count.


    DO 10 TIMES.

      CLEAR: lv_field, lv_percn.

      ADD 1 TO lv_count.

      lv_field = CONV char50( 'p9660-LGA' && lv_count ).
      ASSIGN (lv_field) TO <fs_lgart>.

      CLEAR lv_field.

      lv_field = CONV char50( 'p9660-PER' && lv_count ).
      ASSIGN (lv_field) TO <fs_percn>.

      DATA(ls_fark) = VALUE #( lt_fark[ lgart = <fs_lgart> per01 = <fs_percn> ] OPTIONAL ).
      IF ls_fark IS INITIAL.
        EXIT.
      ENDIF.

      CLEAR ls_fark.
    ENDDO.

**----2. satıra girildiğinde kaçtane lga olduğunu saydırıp ona göre clear yapılmalı.

    IF lv_count NE lv_lga_count.
      CLEAR lv_fark.
    ENDIF.



    IF lv_fark IS NOT INITIAL .
      "- Eğer Fark Kesilecek Tutardan Büyükse Kesilecek Tutarı Düş
      IF lv_fark GT lv_kesilecek .
        CLEAR lv_fark .
      ELSE .
        "- Kesilecek Tutar Büyükse Farkı Düş
        lv_kesilecek = lv_fark .
      ENDIF .
    ENDIF.

    "- Kesilecek Tutar Kalandan Büyükse
    IF lv_kesilecek GT lv_kalan .
      lv_fark = lv_kesilecek - lv_kalan .
      lv_kesilecek = lv_kalan .
    ELSE .
      CLEAR lv_fark .
    ENDIF.

**Ali
    IF p9660-lgart EQ '4000'.
      CHECK lv_stop NE 'X'.
      IF lv_kesilebilecek GE lv_kesilen + lv_kesilecek.

      ELSE.
        IF p9660-dedcn NE '01'.
          lv_kesilecek = lv_kesilebilecek - lv_kesilen.
          IF lv_kesilecek LT 0.
            lv_kesilecek  = 0.
          ENDIF.
        ENDIF.
      ENDIF.


      lv_kesilen = lv_kesilen + lv_kesilecek.
      IF lv_kalan - lv_kesilecek GT 0.
        lv_stop = 'X'.
      ENDIF.
    ENDIF.
**Ali


    CHECK lv_kesilecek GT 0 . "- Sıfırdan Büyükse Gir Kes

*    LOOP AT p9101 WHERE docnr = p9100-docnr AND begda = aper-begda  AND endda = aper-endda.
    LOOP AT p9661 WHERE docnr = lv_docnr AND begda = aper-begda  AND endda = aper-endda.
      EXIT.
    ENDLOOP.
    "-9101'e Yeni Kayıt Ekle
    "byildiz 9101 de aynı icra sap no ile kayıt yoksa yeni kayıt ekle varsa üstüne yaz
    IF sy-subrc <> 0.
      ADD 1 TO lv_seqnr .
      APPEND INITIAL LINE TO p9661 ASSIGNING FIELD-SYMBOL(<fs_9661>).
      <fs_9661>-pernr = p9660-pernr   . "- Personel No
      <fs_9661>-infty = '9661'        . "- Bilgi Tipi Numarası
      <fs_9661>-subty = '0001'        . "- Otomatik Kayıt
      <fs_9661>-begda = aper-begda    . "- Bordro Dönemi Baş
      <fs_9661>-endda = aper-endda    . "- Bordro Dönemi Bit
*      <fs_9101>-docnr = p9100-docnr   . "- Doküman No
      <fs_9661>-docnr = lv_docnr   . "- Doküman No
      <fs_9661>-seqnr = lv_seqnr      . "- Sıra N3o
      <fs_9661>-dedam = lv_kesilecek  . "- Kesilen Tutar
      <fs_9661>-dedwa = p9660-dedwa   . "- Para Birimi
      lv_oper = 'INS'.
*      <fs_9101>-aedtm = sy-datum      . "- Son Değişim Tarihi
*      <fs_9101>-uname = sy-uname      . "- Son Değiştiren Kullanıcı
    ELSE.
      LOOP AT p9661 ASSIGNING <fs_9661> WHERE pernr = p9660-pernr
                                          AND infty = '9661'
                                          AND subty = '0001'
                                          AND begda = aper-begda
                                          AND endda = aper-endda
*                                          AND docnr = p9100-docnr
                                          AND docnr = lv_docnr.
        EXIT.
      ENDLOOP.
      <fs_9661>-dedam = lv_kesilecek  . "- Kesilen Tutar
      <fs_9661>-dedwa = p9660-dedwa   . "- Para Birimi
      lv_oper = 'MOD'.
    ENDIF.


    "- Eğer Test Modunda Değilse
    IF tst_on NE abap_true .

      CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = <fs_9661>-pernr
        IMPORTING
          return = ls_return.

      IF ls_return-type CA 'EAX'.
        "- Burada Ek Kontroller Yazılacak !
      ELSE .

        DATA : ls_9661 TYPE p9661.
        DATA: lv_mem(16).

        CLEAR : lv_mem , ls_9661.
        MOVE-CORRESPONDING <fs_9661> TO ls_9661.
        CONCATENATE 'ZHR_ICRA' ls_9661-pernr INTO lv_mem.
        FREE MEMORY ID lv_mem .
        EXPORT ls_9661 TO MEMORY ID lv_mem.

        SUBMIT ZRPD_ICRIT_P_ICRA_INFTY WITH p_pernr = ls_9661-pernr WITH lv_oper = lv_oper
        AND RETURN.
*          CALL FUNCTION 'HR_INFOTYPE_OPERATION'
*            EXPORTING
*              infty         = <fs_9101>-infty
*              number        = <fs_9101>-pernr
*              subtype       = <fs_9101>-subty
*              validityend   = <fs_9101>-endda
*              validitybegin = <fs_9101>-begda
*              record        = <fs_9101>
*              operation     = lv_oper
*             nocommit      = abap_true
*            IMPORTING
*              return        = ls_return.
*
        CALL FUNCTION 'HR_EMPLOYEE_DEQUEUE'
          EXPORTING
            number = <fs_9661>-pernr.

      ENDIF.

    ENDIF.

    "- Asgari Ücret Okunup Bilgileri Kullanılacak
*    READ TABLE it WITH KEY lgart = '/AUC'.
    READ TABLE rt WITH KEY lgart = '/AUC'.

    APPEND INITIAL LINE TO it ASSIGNING FIELD-SYMBOL(<fs_it>).
    <fs_it>-abart = rt-abart     . "- /AUC'un ABART'ı
    <fs_it>-apznr = rt-apznr     . "- /AUC'un APZNR'ı
    <fs_it>-anzhl = p9660-seqno  . "- Sıra Numarası
    <fs_it>-v0znr = p9660-seqno  . "-
    <fs_it>-lgart = p9660-lgart  . "- Ücret Türü
    <fs_it>-betrg = lv_kesilecek. "- Doğrudan Yazdık

*      IF lv_fark GT 0 . "- Eğer Fark Varsa Sonraki İcra'dan Kes
**        lv_lgart_temp = p9100-lgart.
*      ELSE .
**      IF p9100-lgart EQ lv_lgart_temp.
*        EXIT. " - Çık
**      ENDIF.
**      lv_lgart_temp = p9100-lgart.
*      ENDIF.
* 2022/07 Rapidsol Commentlendi
    " D_TEGILLI 05/12/2019.
*    ENDIF.
*    lv_lgart_temp = p9100-lgart.
    " D_TEGILLI 05/12/2019.
* 2022/07 Rapidsol Commentlendi
    IF lv_kesilecek GT 0.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM .
