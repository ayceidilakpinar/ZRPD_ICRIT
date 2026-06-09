PROCESS BEFORE OUTPUT.
  MODULE before_output.

  MODULE icra_tab_active_tab_set.
  CALL SUBSCREEN :icra_sub_tab1 INCLUDING sy-repid  '2001',
                  icra_sub_tab2 INCLUDING sy-repid  '2002',
                  icra_sub_tab3 INCLUDING sy-repid  '2003',
                  icra_sub_tab4 INCLUDING sy-repid  '2004'.

  CALL SUBSCREEN subscreen_empl   INCLUDING empl_prog empl_dynnr.
  CALL SUBSCREEN subscreen_header INCLUDING header_prog header_dynnr.
*         infotype specific operations

  MODULE p9660.
  MODULE hidden_data.

PROCESS AFTER INPUT.

*---------------------------------------------------------------------*
*  process exit commands
*---------------------------------------------------------------------*
  MODULE exit AT EXIT-COMMAND.


  CALL SUBSCREEN: icra_sub_tab1 ,
                  icra_sub_tab2 ,
                  icra_sub_tab3 ,
                  icra_sub_tab4 .




*---------------------------------------------------------------------*
*         processing after input
*---------------------------------------------------------------------*
*
*         check and mark if there was any input: all fields that
*         accept input HAVE TO BE listed here
*---------------------------------------------------------------------*
  CHAIN.
    FIELD p9660-begda.
    FIELD p9660-endda.
    FIELD p9660-docnr.
    MODULE input_status ON CHAIN-REQUEST.
  ENDCHAIN.
*---------------------------------------------------------------------*
*      process functioncodes before input-checks                      *
*---------------------------------------------------------------------*
  MODULE pre_input_checks.
*---------------------------------------------------------------------*
*         input-checks:                                               *
*---------------------------------------------------------------------*

*   insert check modules here:

*  ...
  MODULE icra_tab_active_tab_get.

*---------------------------------------------------------------------*
*     process function code: ALL fields that appear on the
*      screen HAVE TO BE listed here (including output-only fields)
*---------------------------------------------------------------------*
  CHAIN.
    FIELD p9660-begda.
    FIELD p9660-endda.
    FIELD p9660-docnr.
    MODULE post_input_checks.
  ENDCHAIN.
*
