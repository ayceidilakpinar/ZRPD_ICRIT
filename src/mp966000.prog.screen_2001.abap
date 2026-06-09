PROCESS BEFORE OUTPUT.
  MODULE status_0110.
*
PROCESS AFTER INPUT.
* MODULE USER_COMMAND_0110.


  CHAIN .
    FIELD p9660-eiban.
    FIELD p9660-ebnkl.
    FIELD p9660-exebn.
    FIELD p9660-filno.
    FIELD p9660-dedex.
    FIELD p9660-intwa.
    FIELD p9660-intam.
    FIELD p9660-dedwa.
    FIELD p9660-dedam.
    FIELD p9660-seqno.
    FIELD p9660-lgart.
*    MODULE input_status ON CHAIN-REQUEST.
  ENDCHAIN.

  CHAIN .
    FIELD p9660-eiban.
    FIELD p9660-ebnkl.
    FIELD p9660-exebn.
    FIELD p9660-filno.
    FIELD p9660-dedex.
    FIELD p9660-intwa.
    FIELD p9660-intam.
    FIELD p9660-dedwa.
    FIELD p9660-dedam.
    FIELD p9660-seqno.
    FIELD p9660-lgart.
*    MODULE post_input_checks.
  ENDCHAIN.
