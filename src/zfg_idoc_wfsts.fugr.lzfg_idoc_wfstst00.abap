*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTITR_IDOC_WFSTS................................*
DATA:  BEGIN OF STATUS_ZTITR_IDOC_WFSTS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTITR_IDOC_WFSTS              .
CONTROLS: TCTRL_ZTITR_IDOC_WFSTS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTITR_IDOC_WFSTS              .
TABLES: ZTITR_IDOC_WFSTS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
