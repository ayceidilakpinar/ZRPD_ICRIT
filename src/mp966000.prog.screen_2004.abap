PROCESS BEFORE OUTPUT.
  MODULE status_0110.

  MODULE tc_kesinti_change_tc_attr.
  LOOP AT   gt_kesinti
       INTO gs_kesinti
       WITH CONTROL tc_kesinti
       CURSOR tc_kesinti-current_line.
    MODULE tc_kesinti_get_lines.
  ENDLOOP.

PROCESS AFTER INPUT.

  LOOP AT gt_kesinti.
    CHAIN.
      FIELD gs_kesinti-stext.
      FIELD gs_kesinti-seqno.
      FIELD gs_kesinti-dedam.
      FIELD gs_kesinti-dedwa.
    ENDCHAIN.
  ENDLOOP.
