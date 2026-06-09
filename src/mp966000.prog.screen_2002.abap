PROCESS BEFORE OUTPUT.
  MODULE status_0110.
*
PROCESS AFTER INPUT.
* MODULE USER_COMMAND_0110.

  CHAIN .
    FIELD p9660-per10.
    FIELD p9660-lga10.
    FIELD p9660-per09.
    FIELD p9660-lga09.
    FIELD p9660-per08.
    FIELD p9660-lga08.
    FIELD p9660-per07.
    FIELD p9660-lga07.
    FIELD p9660-per06.
    FIELD p9660-lga06.
    FIELD p9660-per05.
    FIELD p9660-lga05.
    FIELD p9660-per04.
    FIELD p9660-lga04.
    FIELD p9660-per03.
    FIELD p9660-lga03.
    FIELD p9660-per02.
    FIELD p9660-lga02.
    FIELD p9660-per01.
    FIELD p9660-lga01.
    FIELD p9660-dedcn.
    FIELD p9660-dedcs.
    FIELD p9660-dat01.
    FIELD p9660-bet01.
    FIELD p9660-dat02.
    FIELD p9660-bet02.
    FIELD p9660-dat03.
    FIELD p9660-bet03.
    FIELD p9660-dat04.
    FIELD p9660-bet04.
    FIELD p9660-dat05.
    FIELD p9660-bet05.
    FIELD p9660-dat06.
    FIELD p9660-bet06.
    FIELD p9660-dat07.
    FIELD p9660-bet07.
    FIELD p9660-dat08.
    FIELD p9660-bet08.
    FIELD p9660-dat09.
    FIELD p9660-bet09.
    FIELD p9660-dat10.
    FIELD p9660-bet10.
    FIELD p9660-dat11.
    FIELD p9660-bet11.
    FIELD p9660-dat12.
    FIELD p9660-bet12.
    FIELD p9660-dat13.
    FIELD p9660-bet13.
    FIELD p9660-dat14.
    FIELD p9660-bet14.
    FIELD p9660-dat15.
    FIELD p9660-bet15.
*    MODULE input_status ON CHAIN-REQUEST.
  ENDCHAIN.

  CHAIN.
    FIELD p9660-per10.
    FIELD p9660-lga10.
    FIELD p9660-per09.
    FIELD p9660-lga09.
    FIELD p9660-per08.
    FIELD p9660-lga08.
    FIELD p9660-per07.
    FIELD p9660-lga07.
    FIELD p9660-per06.
    FIELD p9660-lga06.
    FIELD p9660-per05.
    FIELD p9660-lga05.
    FIELD p9660-per04.
    FIELD p9660-lga04.
    FIELD p9660-per03.
    FIELD p9660-lga03.
    FIELD p9660-per02.
    FIELD p9660-lga02.
    FIELD p9660-per01.
    FIELD p9660-lga01.
    FIELD p9660-dedcn.
    FIELD p9660-dedcs.
    FIELD p9660-dat01.
    FIELD p9660-bet01.
    FIELD p9660-dat02.
    FIELD p9660-bet02.
    FIELD p9660-dat03.
    FIELD p9660-bet03.
    FIELD p9660-dat04.
    FIELD p9660-bet04.
    FIELD p9660-dat05.
    FIELD p9660-bet05.
    FIELD p9660-dat06.
    FIELD p9660-bet06.
    FIELD p9660-dat07.
    FIELD p9660-bet07.
    FIELD p9660-dat08.
    FIELD p9660-bet08.
    FIELD p9660-dat09.
    FIELD p9660-bet09.
    FIELD p9660-dat10.
    FIELD p9660-bet10.
    FIELD p9660-dat11.
    FIELD p9660-bet11.
    FIELD p9660-dat12.
    FIELD p9660-bet12.
    FIELD p9660-dat13.
    FIELD p9660-bet13.
    FIELD p9660-dat14.
    FIELD p9660-bet14.
    FIELD p9660-dat15.
    FIELD p9660-bet15.

*    MODULE post_input_checks.
  ENDCHAIN.
