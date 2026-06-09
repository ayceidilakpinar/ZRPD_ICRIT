*&---------------------------------------------------------------------*
*& Report ZRPD_ICRIT_P_ICRA_INFTY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRPD_ICRIT_P_ICRA_INFTY.

PARAMETERS: p_pernr like p0001-pernr,
             lv_oper      TYPE pspar-actio.
data : ls_9661 type p9661.

  DATA  : ls_return TYPE bapireturn1.
  data: lv_mem(16).
  CONCATENATE 'ZHR_ICRA' p_pernr into lv_mem.
import ls_9661 from MEMORY id lv_mem.

CALL FUNCTION 'HR_INFOTYPE_OPERATION'
            EXPORTING
              infty         = ls_9661-infty
              number        = ls_9661-pernr
              subtype       = ls_9661-subty
              validityend   = ls_9661-endda
              validitybegin = ls_9661-begda
              record        = ls_9661
              operation     = lv_oper
*             nocommit      = abap_true
            IMPORTING
              return        = ls_return.
