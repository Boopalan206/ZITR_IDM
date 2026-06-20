*****           Implementation of object type ZIDOC_LIST           *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
      KEY LIKE SWOTOBJID-OBJKEY.
END_DATA OBJECT. " Do not change.. DATA is generated

BEGIN_METHOD IDMIDOCLIST CHANGING CONTAINER.
DATA:
      RETURN LIKE BAPIRET2,
      ETIDOCLIST LIKE ZBAPI_ZST_IDOC_LIST OCCURS 0.
  CALL FUNCTION 'BAPI_ZTEST_IDM_IDOC_LIST'
    IMPORTING
      RETURN = RETURN
    TABLES
      ET_IDOC_LIST = ETIDOCLIST
    EXCEPTIONS
      OTHERS = 01.
  CASE SY-SUBRC.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
  ENDCASE.
  SWC_SET_ELEMENT CONTAINER 'Return' RETURN.
  SWC_SET_TABLE CONTAINER 'EtIdocList' ETIDOCLIST.
END_METHOD.
