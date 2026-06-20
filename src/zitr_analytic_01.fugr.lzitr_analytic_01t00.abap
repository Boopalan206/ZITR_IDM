*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZITR_ANALYTIC_01................................*
DATA:  BEGIN OF STATUS_ZITR_ANALYTIC_01              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZITR_ANALYTIC_01              .
CONTROLS: TCTRL_ZITR_ANALYTIC_01
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZITR_ANALYTIC_01              .
TABLES: ZITR_ANALYTIC_01               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
