PROCESS BEFORE OUTPUT.
*         general infotype-independent operations
  MODULE BEFORE_OUTPUT.
  CALL SUBSCREEN subscreen_empl   INCLUDING empl_prog empl_dynnr.
  CALL SUBSCREEN subscreen_header INCLUDING header_prog header_dynnr.
*         infotype specific operations
  MODULE P9661.
*
  MODULE HIDDEN_DATA.
*
PROCESS AFTER INPUT.
*---------------------------------------------------------------------*
*  process exit commands
*---------------------------------------------------------------------*
  MODULE EXIT AT EXIT-COMMAND.
*---------------------------------------------------------------------*
*         processing after input
*---------------------------------------------------------------------*
*
*         check and mark if there was any input: all fields that
*         accept input HAVE TO BE listed here
*---------------------------------------------------------------------*
  CHAIN.
    FIELD P9661-BEGDA.
    FIELD P9661-ENDDA.
    FIELD P9661-DEDWA.
    FIELD P9661-DEDAM.
    FIELD P9661-SEQNO.
    FIELD P9661-DOCNR.
     MODULE p9661_change_data ON CHAIN-REQUEST.
    MODULE INPUT_STATUS ON CHAIN-REQUEST.
  ENDCHAIN.
*---------------------------------------------------------------------*
*      process functioncodes before input-checks                      *
*---------------------------------------------------------------------*
  MODULE PRE_INPUT_CHECKS.
*---------------------------------------------------------------------*
*         input-checks:                                               *
*---------------------------------------------------------------------*

*   insert check modules here:

*  ...

*---------------------------------------------------------------------*
*     process function code: ALL fields that appear on the
*      screen HAVE TO BE listed here (including output-only fields)
*---------------------------------------------------------------------*
  CHAIN.
    FIELD P9661-BEGDA.
    FIELD P9661-ENDDA.
    FIELD RP50M-SPRTX.
    FIELD P9661-DEDWA.
    FIELD P9661-DEDAM.
    FIELD P9661-SEQNO.
    FIELD P9661-DOCNR.
    MODULE POST_INPUT_CHECKS.
  ENDCHAIN.
*





