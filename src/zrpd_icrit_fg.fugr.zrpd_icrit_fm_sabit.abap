FUNCTION ZRPD_ICRIT_FM_SABIT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MODE) TYPE  CHAR1 DEFAULT 'E'
*"     VALUE(IV_DOCNR) TYPE  P9660-DOCNR OPTIONAL
*"     VALUE(IV_WAERS) TYPE  P9660-DEDWA OPTIONAL
*"  EXPORTING
*"     VALUE(EV_DOCNR) TYPE  P9660-DOCNR
*"     VALUE(EV_WAERS) TYPE  P9660-DEDWA
*"----------------------------------------------------------------------

  CASE iv_mode.
    WHEN 'I'.
*      gv_docnr = iv_docnr.
      EXPORT docnr FROM iv_docnr
             waers FROM iv_waers
             TO MEMORY ID sy-uname.
    WHEN 'E'.
      IMPORT docnr TO ev_docnr
             waers TO ev_waers
             FROM MEMORY ID sy-uname.
*      ev_docnr = gv_docnr.
  ENDCASE.



ENDFUNCTION.
