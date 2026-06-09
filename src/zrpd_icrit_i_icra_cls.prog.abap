*&---------------------------------------------------------------------*
*&  Include           ZRPD_ICRIT_I_ICRA_CLS
*&---------------------------------------------------------------------*

CLASS lcl_prog DEFINITION.

  PUBLIC SECTION .

    METHODS :
*
      constructor .

    CLASS-METHODS :
*
      set_dates ,
*
      set_last  ,
*
      get_data  "IMPORTING i_pernr TYPE pernr
                CHANGING  t_table TYPE ZRPD_ICRIT_TT_ICRA,
*
      get_text IMPORTING iv_otype TYPE otype
                         iv_objid TYPE any
               EXPORTING ev_stext TYPE any ,
*
      read_payroll   IMPORTING iv_pernr     TYPE pernr-pernr
                               iv_bukrs     TYPE pernr-bukrs
                               iv_werks     TYPE pernr-werks
                               iv_btrtl     TYPE pernr-btrtl
                               iv_fpper     TYPE spmon
                     RETURNING VALUE(rt_rt) TYPE hrpay99_rt ,
*
      show_alv  CHANGING alv_tab TYPE STANDARD TABLE ,
*
      print_form IMPORTING it_table TYPE ZRPD_ICRIT_TT_ICRA
                           iv_formn TYPE salv_de_function,
*
      send_email IMPORTING is_line TYPE ZRPD_ICRIT_S_ICRA  ,
*
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,
*
      on_hotspot
          FOR EVENT link_click OF cl_salv_events_table
        IMPORTING
          row
          column ,

      get_master_data.

  PROTECTED SECTION .
    CLASS-METHODS :
*
      change_col_text IMPORTING r_columns TYPE REF TO cl_salv_columns_table .



ENDCLASS .

CLASS lcl_prog IMPLEMENTATION.

  METHOD constructor .

    APPEND 'IEQ3' TO pnpstat2 .

  ENDMETHOD .

  METHOD set_dates.
*
    CONCATENATE p_spmon '01' INTO pnpbegda .
    pn-begps = pnpbegps = pn-begda = pnpbegda .
*
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = pnpbegda
      IMPORTING
        last_day_of_month = pnpendda
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
*
    pn-endps = pnpendps = pn-endda = pnpendda .

  ENDMETHOD .

  METHOD set_last.

    DEFINE f_last .

      LOOP AT &1 INTO &2 WHERE begda LE pnpendda
                           AND endda GE pnpbegda.
      ENDLOOP.

    END-OF-DEFINITION.

    "- Başlıkları Temizle
    CLEAR : p0000, p0001, p0002, p0770, p9660, p9661 .

    "- Son kaydı başlığa koy
    f_last : p0000[] p0000 ,
             p0001[] p0001 ,
             p0002[] p0002 ,
             p0770[] p0770 .

  ENDMETHOD .

  METHOD get_data.

    DATA : ls_person TYPE person.

    DEFINE f_text .
      get_text( EXPORTING iv_otype = &1
                          iv_objid = &2
                IMPORTING ev_stext = &3 ).
    END-OF-DEFINITION.


    SELECT lgart, lgtxt
      FROM t512t AS t5
      FOR ALL ENTRIES IN @gt_p9660
      WHERE lgart = @gt_p9660-lgart
      INTO TABLE @DATA(lt_t512t).

    "- İcra Sıra No'ya Göre Sırala
    SORT gt_p9660 BY seqno .
    DATA lv_x." eavci 16.01.2020 11:14:35
    CLEAR lv_x." eavci 16.01.2020 11:14:35

    LOOP AT gt_p9660 ASSIGNING FIELD-SYMBOL(<fs_9660>) WHERE begda LE pnpendda
                                                         AND endda GE pnpbegda.

      " eavci 16.01.2020 11:13:09 BEGIN
      IF p_ksnti EQ abap_true.
        lv_x = abap_true.
        LOOP AT gt_p9661 INTO DATA(ls_101) WHERE begda >= pnpbegda AND
                                                 endda <= pnpendda AND
                                                 docnr EQ <fs_9660>-docnr AND
                                                 seqnr EQ <fs_9660>-seqnr.
          lv_x = abap_false.
*          EXIT.
        ENDLOOP.
        IF lv_x EQ abap_true.
          CONTINUE.
        ENDIF.
      ENDIF.
      " eavci 16.01.2020 11:13:10 END

      APPEND INITIAL LINE TO t_table ASSIGNING FIELD-SYMBOL(<fs_table>).

      READ TABLE lt_t512t INTO DATA(ls_t512t) WITH KEY lgart = <fs_9660>-lgart.

      DATA(ls_p0770) = VALUE #( gt_p0770[ pernr = <fs_9660>-pernr ] OPTIONAL ).
      DATA(ls_p0001) = VALUE #( gt_p0001[ pernr = <fs_9660>-pernr ] OPTIONAL ).

      MOVE : ls_p0001-pernr   TO <fs_table>-pernr,
             ls_p0001-ename   TO <fs_table>-ename,
             ls_p0001-orgeh   TO <fs_table>-orgeh,
             ls_p0001-stell   TO <fs_table>-stell,
             ls_p0001-plans   TO <fs_table>-plans,

             ls_p0770-merni   TO <fs_table>-merni,

             <fs_9660>-seqno  TO <fs_table>-seqno,
             <fs_9660>-exebn  TO <fs_table>-exebn,
             <fs_9660>-filno  TO <fs_table>-filno,
             <fs_9660>-eiban  TO <fs_table>-eiban,
             <fs_9660>-ebnkl  TO <fs_table>-ebnkl,
             <fs_9660>-lgart  TO <fs_table>-lgart,
             ls_t512t-lgtxt   TO <fs_table>-lgtxt,
             <fs_9660>-dedam  TO <fs_table>-dedam,
             <fs_9660>-dedwa  TO <fs_table>-dedwa,
             <fs_9660>-intam  TO <fs_table>-intam,
             <fs_9660>-intwa  TO <fs_table>-intwa,
             <fs_9660>-dedex  TO <fs_table>-dedex .

      "- Doküman Numarasına Göre Toplam Kesinleni Al
      LOOP AT gt_p9661 ASSIGNING FIELD-SYMBOL(<fs_9661>)
        WHERE begda LE pnpendda
          AND pernr EQ <fs_9660>-pernr
          AND docnr EQ <fs_9660>-docnr.

        ADD <fs_9661>-dedam TO <fs_table>-payam.

        "- İlgili Ayda Kesilen Tutar
        IF  <fs_9661>-subty EQ '0001' "- Otomatik Kesinti
        AND <fs_9661>-begda LE pnpendda
        AND <fs_9661>-endda GE pnpbegda .
          ADD <fs_9661>-dedam TO <fs_table>-dedcs .
          <fs_table>-spmon = <fs_9661>-begda(6).
        ENDIF.

        f_text : '9' '0001'           <fs_table>-stext .

      ENDLOOP.

      "- Kalan Tutar Hesapla
      <fs_table>-kalan = ( <fs_table>-dedam + <fs_table>-intam ) - <fs_table>-payam .

      CALL FUNCTION 'RP_GET_HIRE_DATE'
        EXPORTING
          persnr          = <fs_9660>-pernr
          check_infotypes = '0041'
          datumsart       = '01'
        IMPORTING
          hiredate        = <fs_table>-hired.
*
      CALL FUNCTION 'RP_GET_FIRE_DATE'
        EXPORTING
          persnr   = <fs_9660>-pernr
        IMPORTING
          firedate = <fs_table>-fired.
*
      IF <fs_table>-fired LT <fs_table>-hired
      OR <fs_table>-fired EQ '99991231'.
        CLEAR <fs_table>-fired .
      ENDIF.
*
      "-Mail Adresi
      LOOP AT gt_p0105[] INTO DATA(ls_p0105)
        WHERE subty EQ '0010' "- Şirket Mail Adresi
          AND pernr EQ <fs_9660>-pernr
          AND endda GE pnpbegda
          AND begda LE pnpendda .
        <fs_table>-email = ls_p0105-usrid_long .
        EXIT.
      ENDLOOP.

      f_text: 'O' <fs_table>-orgeh <fs_table>-orgeh_t ,
              'S' <fs_table>-stell <fs_table>-stell_t ,
              'P' <fs_table>-plans <fs_table>-plans_t .

      CALL FUNCTION 'HR_GET_EMPLOYEE_DATA'
        EXPORTING
          person_id             = <fs_table>-pernr
          selection_begin       = sy-datum
          selection_end         = sy-datum
        IMPORTING
          personal_data         = ls_person
        EXCEPTIONS
          person_not_found      = 1
          no_active_integration = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF ls_person IS NOT INITIAL.
        <fs_table>-srk_kod = ls_person-bukrs.
        <fs_table>-srk_mtn = VALUE #( gt_t001[ bukrs = ls_person-bukrs ]-butxt OPTIONAL ).
        <fs_table>-prs_aln = ls_person-werks.
        <fs_table>-prs_mtn = VALUE #( gt_t500p[ persa = ls_person-werks ]-name1 OPTIONAL ).
        <fs_table>-pal_aln = VALUE #( gt_p0001[ pernr = <fs_9660>-pernr
                                                endda = '99991231' ]-btrtl OPTIONAL )."VALUE #( lt_pa0001[ pernr = ls_person-pernr ]-btrtl OPTIONAL ).
        <fs_table>-pal_mtn = VALUE #( gt_t001p[ werks = ls_person-werks
                                                btrtl = <fs_table>-pal_aln ]-btext OPTIONAL ).
        <fs_table>-plans_t = ls_person-plans_txt.
        <fs_table>-cls_grp = ls_person-persg.
        <fs_table>-cls_mtn = VALUE #( gt_t501t[ persg = ls_person-persg ]-ptext OPTIONAL ).
        <fs_table>-cal_grp = ls_person-persk.
        <fs_table>-cal_mtn = VALUE #( gt_t503t[ persk = ls_person-persk ]-ptext OPTIONAL ).
      ENDIF.

      gv_sira = gv_sira + 1.
      <fs_table>-sirano = gv_sira.

    ENDLOOP.

  ENDMETHOD .


  METHOD get_text.

    CHECK iv_objid IS NOT INITIAL .
    READ TABLE gt_text ASSIGNING FIELD-SYMBOL(<fs_text>)
      WITH KEY otype = iv_otype
               objid = iv_objid .

    IF sy-subrc NE 0 .

      APPEND INITIAL LINE TO gt_text ASSIGNING <fs_text>.
      <fs_text>-otype = iv_otype.
      <fs_text>-objid = iv_objid.

      CASE iv_otype.
        WHEN 'O' OR 'S' OR 'P'.
          SELECT SINGLE stext FROM hrp1000 INTO <fs_text>-stext
            WHERE plvar EQ '01'
              AND otype EQ iv_otype
              AND objid EQ <fs_text>-objid
              AND istat EQ '1'
              AND begda LE sy-datum
              AND endda GE sy-datum
              AND langu EQ sy-langu .

        WHEN '9'.
          SELECT SINGLE stext FROM t591s INTO <fs_text>-stext
              WHERE sprsl EQ sy-langu
                AND infty EQ '9661'
                AND subty EQ <fs_text>-objid .
        WHEN 'B'.
          SELECT SINGLE btext FROM t001p INTO <fs_text>-stext
            WHERE btrtl EQ <fs_text>-objid .
        WHEN 'W'.
          SELECT SINGLE name1 FROM t500p INTO <fs_text>-stext
            WHERE persa EQ <fs_text>-objid .
      ENDCASE .
    ENDIF .

    IF <fs_text> IS ASSIGNED .
      ev_stext = <fs_text>-stext.
    ENDIF.

  ENDMETHOD .

  METHOD read_payroll .

    DATA : lv_subrc  TYPE sy-subrc,
           lv_molga  TYPE molga,
           lt_result TYPE hrpay99_tab_of_results.

    CALL FUNCTION 'HRCM_PAYROLL_RESULTS_GET'
      EXPORTING
        pernr              = iv_pernr
        begda              = pnpbegda
        endda              = pnpendda
      IMPORTING
        subrc              = lv_subrc
        molga              = lv_molga
        payroll_result_tab = lt_result.

    "- İlgili Kaydı Gönder
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      LOOP AT <fs_result>-inter-wpbp ASSIGNING FIELD-SYMBOL(<fs_wpbp>)
        WHERE begda LE pnpendda
          AND endda GE pnpbegda
          AND bukrs EQ iv_bukrs
          AND werks EQ iv_werks
          AND btrtl EQ iv_btrtl .

      ENDLOOP.
      IF sy-subrc EQ 0 .
        rt_rt = <fs_result>-inter-rt .
      ENDIF.

    ENDLOOP.

  ENDMETHOD .

  METHOD show_alv.

    DATA: lr_selections TYPE REF TO cl_salv_selections,
          lr_events     TYPE REF TO cl_salv_events_table,
          lr_columns    TYPE REF TO cl_salv_columns_table,
          lr_functions  TYPE REF TO cl_salv_functions_list,
          lr_layout     TYPE REF TO cl_salv_layout,
          ls_keys       TYPE salv_s_layout_key.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = alv_tab[] ).
      CATCH cx_salv_msg.
    ENDTRY.

    lr_functions = go_alv->get_functions( ).
    lr_functions->set_all( 'X' ).

    go_alv->set_screen_status(
          pfstatus      =  'GUIM'
          report        =  sy-repid
          set_functions = go_alv->c_functions_all ).

    lr_events = go_alv->get_event( ).
    lr_columns = go_alv->get_columns( ).

    lr_columns->set_optimize( 'X' ) .
*
    change_col_text( lr_columns ).

    SET HANDLER on_user_command FOR lr_events.
    SET HANDLER on_hotspot      FOR lr_events.

    lr_selections = go_alv->get_selections( ).
    lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).


    lr_layout = go_alv->get_layout( ).
    ls_keys-report = sy-repid.
    lr_layout->set_key( ls_keys ).
    lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

    IF go_alv IS BOUND.
      go_alv->display( ).
    ENDIF.

  ENDMETHOD .

  METHOD change_col_text.

    DATA : ls_column TYPE REF TO cl_salv_column,
           lr_column TYPE REF TO cl_salv_column_table,
           lv_long   TYPE scrtext_l,
           lv_medium TYPE scrtext_m,
           lv_short  TYPE scrtext_s.

**********************************************************************
    DEFINE c_text.

      TRY .
       ls_column = r_columns->get_column( &1 ).
       lr_column ?= r_columns->get_column( &1 ).

       IF &2 IS NOT INITIAL .
         lv_short = lv_medium = lv_long = &2 .
         ls_column->set_long_text( lv_long ).
         ls_column->set_medium_text( lv_medium ).
         ls_column->set_short_text( lv_short ).
       ENDIF.

       IF &3 CA 'V'.
         ls_column->set_visible( if_salv_c_bool_sap=>false ).
       ENDIF.

       IF &3 CA 'T'.
         ls_column->set_technical( if_salv_c_bool_sap=>true ).
       ENDIF.

       IF &3 CA 'C'.
         ls_column->set_alignment( if_salv_c_alignment=>centered ).
       ENDIF.

       IF &3 CA 'H'.
         lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
       ENDIF.

       IF &3 CA 'B'.
         lr_column->set_cell_type( if_salv_c_cell_type=>checkbox ).
       ENDIF..

       IF &3 CA 'I'.
          lr_column->set_icon( if_salv_c_bool_sap=>true ).
       ENDIF.

      CATCH cx_salv_not_found.

      ENDTRY.

    END-OF-DEFINITION.

    c_text :  'SIRANO'  TEXT-f10 space ,
              'PERNR'   TEXT-f01 space ,
              'ENAME'   TEXT-f02 space ,
              'MERNI'   space    space,
              'HIRED'   space    space,
              'ORGEH'   space    'V',
              'ORGEH_T' TEXT-f03 space,
              'PLANS'   space    'V',
              'PLANS_T' TEXT-f04 space,
              'STELL'   space    'V',
              'STELL_T' TEXT-f05 space,
              'EMAIL'   space    space,
              'SPMON'   space    space,
              'SEQNO'   TEXT-f06 space,
              'EXEBN'   space    space,
              'FILNO'   space    space,
              'EIBAN'   space    space,
              'EBNKL'   space    space,
              'DEDAM'   TEXT-f07 space,
              'DEDWA'   space    space,
              'INTAM'   space    space,
              'INTWA'   space    space,
              'DEDCS'   space    space,
              'STEXT'   TEXT-f08 space,
              'DEDEX'   space    space,
              'PAYAM'   TEXT-f09 space,
              'KALAN'   space    space,
              'DIGER'   space    'T'  .

  ENDMETHOD .

  METHOD on_user_command.

    DATA: lr_selections TYPE REF TO cl_salv_selections,
          lt_rows       TYPE salv_t_row,
          l_row         TYPE i,
          lt_table      TYPE ZRPD_ICRIT_TT_ICRA,
          lv_desc       TYPE text100.

    lr_selections = go_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).


    CASE e_salv_function.
      WHEN 'FRM01'  "- Kesilmeye Başlanacak
        OR 'FRM03'  "- İşten Ayrıldı
        OR 'FRM04'. "- İcra Bitti

        "- Eğer tek satır kontrolü istenirse aşağısı açılabilir !
*        IF lines( lt_rows ) GT 1 .
*          MESSAGE TEXT-e02 TYPE 'I' DISPLAY LIKE 'E'. EXIT .
*        ENDIF.

        IF lt_rows IS INITIAL .
          MESSAGE TEXT-e02 TYPE 'I' DISPLAY LIKE 'E'. EXIT .
        ENDIF.

        LOOP AT lt_rows INTO l_row .
          READ TABLE gt_alv ASSIGNING FIELD-SYMBOL(<fs_alv>) INDEX l_row .
          CHECK sy-subrc EQ 0 .

          CASE e_salv_function.
            WHEN 'FRM01'. "- Kesilmeye Başlanacak
              "- Eğer İşten Ayrılmışsa
              IF <fs_alv>-fired IS NOT INITIAL .
                CONCATENATE lv_desc TEXT-d01 INTO lv_desc SEPARATED BY '/'.
                CONTINUE .
              ENDIF.

              "- Eğer Kalan Tutar 0'sa
              IF <fs_alv>-kalan EQ 0 .
                CONCATENATE lv_desc TEXT-d02 INTO lv_desc SEPARATED BY '/'.
                CONTINUE .
              ENDIF.

              "- Eğer Kesilmeye Başlanmamışsa
              IF e_salv_function NE 'FRM01'." eavci 16.01.2020 14:47:15
                IF ( <fs_alv>-dedam + <fs_alv>-intam ) EQ <fs_alv>-kalan .
                  CONCATENATE lv_desc TEXT-d04 INTO lv_desc SEPARATED BY '/'.
                  CONTINUE .
                ENDIF.
              ENDIF. " eavci 16.01.2020 14:47:13


            WHEN 'FRM03'. "- İşten Ayrıldı
              " Bu durum için yeniden sor

            WHEN 'FRM04'. "- İcra Bitti
              "- Eğer İşten Ayrılmışsa
              IF <fs_alv>-fired IS NOT INITIAL .
                CONCATENATE lv_desc TEXT-d01 INTO lv_desc SEPARATED BY '/'.
                CONTINUE .
              ENDIF.

              "- Eğer Kalan Tutar 0'dan farklıysa
              IF <fs_alv>-kalan NE 0 .
                CONCATENATE lv_desc TEXT-d03 INTO lv_desc SEPARATED BY '/'.
                CONTINUE .
              ENDIF.
          ENDCASE.

          "-Yine de ekle
          APPEND <fs_alv> TO lt_table.

        ENDLOOP .

        IF lv_desc IS NOT INITIAL .
          SHIFT lv_desc LEFT DELETING LEADING '/' IN CHARACTER MODE.
          CONCATENATE TEXT-d99 lv_desc INTO lv_desc SEPARATED BY space .
          MESSAGE lv_desc TYPE 'I'.
          CHECK 1 = 2.
        ENDIF.

        gv_prog->print_form( EXPORTING it_table = lt_table
                                       iv_formn = e_salv_function ).

      WHEN 'FRM02'. "- Sıraya Alınacak

        IF lt_rows IS INITIAL .
          MESSAGE TEXT-e02 TYPE 'I' DISPLAY LIKE 'E'. EXIT .
        ENDIF.

        "--> Add by ebas 13.02.2020 14:35:11 BEGIN
        REFRESH: lt_table.
        LOOP AT gt_alv ASSIGNING <fs_alv>.
          REFRESH: <fs_alv>-diger.
        ENDLOOP.
        "<-- Add by ebas 13.02.2020 14:35:11 END

        LOOP AT lt_rows INTO l_row .
          READ TABLE gt_alv ASSIGNING <fs_alv> INDEX l_row .
          CHECK sy-subrc EQ 0 .

          LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<fs_alv_2>)
            WHERE pernr EQ <fs_alv>-pernr .

            CHECK sy-tabix LT l_row . "- Aynı Sırada  Olmayan

            "--> Add by ebas 13.02.2020 17:23:29 BEGIN
            CHECK <fs_alv_2>-kalan IS NOT INITIAL. "Boşsa/Pasifse gelmesin
            "<-- Add by ebas 13.02.2020 17:23:29 END

            APPEND INITIAL LINE TO <fs_alv>-diger ASSIGNING FIELD-SYMBOL(<fs_diger>).
            <fs_diger>-filno = <fs_alv_2>-filno .
            <fs_diger>-exebn = <fs_alv_2>-exebn .
            IF <fs_alv_2>-kalan IS NOT INITIAL .
              <fs_diger>-durum  = TEXT-drm.
            ELSE .
*              <fs_diger>-durum  = |{ <fs_alv_2>-seqno }. sırada beklemede.|.
              <fs_diger>-durum  = 'Pasif'.
            ENDIF.

            "- 15'den Fazla olursa Yenisini Oluştur
            IF lines( <fs_alv>-diger ) EQ 15.
              APPEND <fs_alv> TO lt_table .
              CLEAR <fs_alv>-diger .
            ENDIF.

          ENDLOOP.

          APPEND <fs_alv> TO lt_table .

        ENDLOOP .


        gv_prog->print_form( EXPORTING it_table = lt_table
                                       iv_formn = e_salv_function ).


      WHEN 'FRM05'. "- Mail Gönder
        IF lt_rows IS INITIAL .
          MESSAGE TEXT-e02 TYPE 'I' DISPLAY LIKE 'E'. EXIT .
        ENDIF.

        LOOP AT lt_rows INTO l_row .
          READ TABLE gt_alv ASSIGNING <fs_alv> INDEX l_row .
          CHECK sy-subrc EQ 0 .


          gv_prog->send_email( EXPORTING is_line = <fs_alv> ).

        ENDLOOP .


    ENDCASE.

    go_alv->refresh( EXPORTING s_stable = VALUE lvc_s_stbl( row = abap_true col = abap_true ) ).

  ENDMETHOD.

  METHOD on_hotspot.

  ENDMETHOD.

  METHOD print_form .

    DATA: lv_formname     TYPE tdsfname,
          lv_fname        TYPE rs38l_fnam,
          ls_docparams    TYPE sfpdocparams,
          ls_output       TYPE fpformoutput,
          ls_outputparams TYPE sfpoutputparams,
          lx_fp_api       TYPE REF TO cx_fp_api,
          ls_formoutput   TYPE fpformoutput,
          error_string    TYPE string.


    CONCATENATE 'ZHR_ICRA_' iv_formn INTO lv_formname.

    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_formname
          IMPORTING
            e_funcname = lv_fname.
      CATCH cx_fp_api INTO lx_fp_api.
*         exception handling
        MESSAGE ID lx_fp_api->msgid TYPE lx_fp_api->msgty
          NUMBER lx_fp_api->msgno
            WITH lx_fp_api->msgv1 lx_fp_api->msgv2
                 lx_fp_api->msgv3 lx_fp_api->msgv4 .
        EXIT.
    ENDTRY.

    IF lv_fname IS NOT INITIAL .

      ls_outputparams-reqimm = 'X'.
      ls_outputparams-reqnew = 'X'.

      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = ls_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      ls_docparams-langu   = 'T'.
      ls_docparams-country = 'TR'.

      DATA: it_table_c LIKE it_table.
      CLEAR: it_table_c.

      it_table_c[] = it_table[].

*      " eavci 16.01.2020 14:55:02 BEGIN
*      LOOP AT it_table_c INTO DATA(ls_table). "ASSIGNING FIELD-SYMBOL(<fs>).
*        IF ls_table-diger IS NOT INITIAL .
*          SORT ls_table-diger BY exebn filno durum.
*          DELETE ADJACENT DUPLICATES FROM ls_table-diger COMPARING ALL FIELDS.
*        ENDIF.
*        MODIFY it_table_c FROM ls_table.
*      ENDLOOP.
*      " eavci 16.01.2020 14:55:04 END

      CALL FUNCTION lv_fname
        EXPORTING
          /1bcdwb/docparams  = ls_docparams
          it_data            = it_table_c[]
        IMPORTING
          /1bcdwb/formoutput = ls_output
        EXCEPTIONS
          usage_error        = 1
          system_error       = 2
          internal_error     = 3
          OTHERS             = 4.

      CALL FUNCTION 'FP_JOB_CLOSE'
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.

    ENDIF.

  ENDMETHOD .

  METHOD send_email .



  ENDMETHOD .
  METHOD get_master_data.
    SELECT bukrs, butxt
      FROM t001
      INTO CORRESPONDING FIELDS OF TABLE @gt_t001.

    SELECT name1, persa
      FROM t500p
      INTO CORRESPONDING FIELDS OF TABLE @gt_t500p.

    SELECT btext, werks, btrtl
      FROM t001p
      INTO CORRESPONDING FIELDS OF TABLE @gt_t001p.

    SELECT ptext, persg
      FROM t501t
      WHERE sprsl EQ @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @gt_t501t.

    SELECT ptext, persk, sprsl
      FROM t503t
      WHERE sprsl EQ @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @gt_t503t.
  ENDMETHOD.
ENDCLASS .
