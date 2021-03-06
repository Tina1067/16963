DATA: ls_entity TYPE BAPISCUDAT,
      lt_return TYPE TABLE OF BAPIRET2,
      ls_return TYPE BAPIRET2,
      ls_carrid TYPE /IWBEP/S_MGW_NAME_VALUE_PAIR,
      ls_bookid TYPE /IWBEP/S_MGW_NAME_VALUE_PAIR.

"Da der Datensatz lediglich identifiziert werden muss, reicht
"die Abfrage der Schlüssel durch den io_tech_request_context.
CALL METHOD io_tech_request_context->get_converted_keys
  IMPORTING
    es_key_values = ls_entity.
    
READ TABLE IT_KEY_TAB WITH KEY NAME = 'Carrid' into ls_carrid.
READ TABLE IT_KEY_TAB WITH KEY NAME = 'Bookid' into ls_bookid.

IF ls_carrid IS NOT INITIAL.
  SELECT SINGLE customid from sbook
   into ls_entity-customerid
   WHERE carrid = ls_carrid-value AND bookid = ls_bookid-value.
ENDIF.

SELECT SINGLE
     id as customerid name as custname form street postbox as pobox
     postcode city country as countr country as countr_iso region
     telephone as phone email
  FROM scustom INTO CORRESPONDING FIELDS OF er_entity WHERE id = ls_entity-customerid.

IF ls_return IS NOT INITIAL.
   "Ist ls_return gesetzt, werden alle wiedergegebenen Fehler
   "an den Message-Container gegeben und eine Ausnahme
   "geworfen, die all diese Meldungen enthält und die letzte
   "Fehlermeldung als übergeordneten Text anzeigt.
   mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
   RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
    EXPORTING
     message_container = mo_context->get_message_container( )
     message = ls_return-message.
ENDIF.
