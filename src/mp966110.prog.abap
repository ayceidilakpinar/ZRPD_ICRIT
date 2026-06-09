*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9661                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM MP966100 MESSAGE-ID RP.

TABLES: P9661.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement

FIELD-SYMBOLS: <PNNNN> STRUCTURE P9661
                       DEFAULT P9661.

DATA: PSAVE LIKE P9661.
