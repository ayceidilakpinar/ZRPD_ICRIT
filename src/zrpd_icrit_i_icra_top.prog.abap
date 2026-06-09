*&---------------------------------------------------------------------*
*&  Include           ZRPD_ICRIT_I_ICRA_TOP
*&---------------------------------------------------------------------*

*REPORT ZRPD_ICRIT_p_ICRA.
*
TABLES : pernr .
*
INFOTYPES : 0000, 0001, 0002, 0105, 0770, 9660, 9661.
*
TYPES : BEGIN OF ty_text ,
          otype     TYPE otype,
          objid(10),
          stext     TYPE stext,
        END OF   ty_text .

"- Program Tanımlamaları
CLASS lcl_prog DEFINITION DEFERRED .
DATA : gv_prog TYPE REF TO lcl_prog .
*
"- ALV Tanımlamaları
DATA: go_alv    TYPE REF TO cl_salv_table.

" Çıktı Tablosu
DATA : gt_alv  TYPE STANDARD TABLE OF ZRPD_ICRIT_S_ICRA,
       gt_text TYPE TABLE OF ty_text.

" Master Data Tabloları

DATA : gt_t001  TYPE TABLE OF t001,
       gt_t500p TYPE TABLE OF t500p,
       gt_t001p TYPE TABLE OF t001p,
       gt_t501t TYPE TABLE OF t501t,
       gt_t503t TYPE TABLE OF t503t.

DATA : gt_p9660 TYPE TABLE OF p9660,
       gt_p9661 TYPE TABLE OF p9661,
       gt_p0105 TYPE TABLE OF p0105,
       gt_p0770 TYPE TABLE OF p0770,
       gt_p0001 TYPE TABLE OF p0001.

DATA : gv_sira  TYPE int4.

SELECTION-SCREEN BEGIN OF BLOCK bl01 WITH FRAME TITLE TEXT-ttl.
PARAMETERS : p_spmon TYPE ZRPD_ICRIT_S_ICRA-spmon DEFAULT sy-datum+0(6) OBLIGATORY .
PARAMETERS p_ksnti TYPE c AS CHECKBOX. " eavci 16.01.2020 11:04:42
SELECTION-SCREEN END OF BLOCK bl01.
