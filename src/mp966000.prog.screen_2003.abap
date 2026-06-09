PROCESS BEFORE OUTPUT.
  MODULE status_0110.

  MODULE tc_kesinti_change_tc_attr.
  LOOP AT   gt_kesinti
       INTO gs_kesinti
       WITH CONTROL tc_kesinti
       CURSOR tc_kesinti-current_line.
    MODULE tc_kesinti_get_lines.
  ENDLOOP.
  MODULE set_tc_kesinti .

*
PROCESS AFTER INPUT.

  LOOP AT gt_kesinti.
    CHAIN.
      FIELD gs_kesinti-subty.
      FIELD gs_kesinti-stext.
      FIELD gs_kesinti-seqno.
      FIELD gs_kesinti-dedam.
      FIELD gs_kesinti-dedwa.
      FIELD gs_kesinti-change.
      FIELD gs_kesinti-delete.
      MODULE kesinti_data.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_0110.
