#include "TDolphin.ch"
#include "hbclass.ch"

//----------------------------------------------------------------------------//

function Main()

   local oConnection := TDolphinSrv():New( "www.fivetechsoft.com",; // server
                                           "fivetech_orm",;         // username 
                                           "hborm",;                // password 
                                           3306,,;                  // port 
                                           "fivetech_orm" )         // database
   local oUsers := Users():New( oConnection, "users" ) // tableName
   
   ? "Number of invoices for: " + AllTrim( oUsers:oRs:FirstName ) + " " + ;
                                  AllTrim( oUsers:oRs:LastName )
   ? oUsers:Invoices:Count()
   
   for n = 1 to oUsers:Invoices:Count()
      ? "Number of items for invoice: " + Str( oUsers:Invoices:oRs:Id )
      ? oUsers:Invoices:Items:Count()
      oUsers:Invoices:Next()
   next   

   oConnection:End()

return nil

//----------------------------------------------------------------------------//

CLASS Users FROM HbModel

   DATA _Invoices PROTECTED
   
   METHOD New( oConnection, cTableName )

   METHOD Invoices()
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Users

   ::Super:New( oConnection, cTableName )
   
   ::_Invoices = Invoices():New( oConnection, "invoices" ) // tableName
   
return Self

//----------------------------------------------------------------------------//

METHOD Invoices() CLASS Users

return ::_Invoices:Where( "user_id", ::oRs:Id )

//----------------------------------------------------------------------------//

CLASS Invoices FROM HbModel

   DATA _Items PROTECTED
   
   METHOD New( oConnection, cTableName )
   METHOD Items()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS Invoices

   ::Super:New( oConnection, cTableName )
   
   ::_Items = Items():New( oConnection, "items" )   // tableName
   
return Self

//----------------------------------------------------------------------------//

METHOD Items() CLASS Invoices

return ::_Items:Where( "invoice_id", ::oRs:Id )

//----------------------------------------------------------------------------//

CLASS Items FROM HbModel

ENDCLASS

//----------------------------------------------------------------------------//

CLASS HbModel

   DATA   oConnection 
   DATA   cTableName
   DATA   oRs

   METHOD New( oConnection, cTableName )
   
   METHOD Count() INLINE ::oRs:RecCount()
   METHOD Find( nId ) INLINE ( ::oRs:Seek( nId, "id" ), Self )
   METHOD Where( cFieldName, uValue )
   METHOD First() INLINE ( ::oRs:GoTop(), Self )
   METHOD Next()  INLINE ( ::oRs:Skip( 1 ), Self )
   METHOD Last()  INLINE ( ::oRs:GoBottom(), Self )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oConnection, cTableName ) CLASS HbModel

   ::oConnection = oConnection
   ::cTableName  = cTableName
   
   ::oRs = oConnection:Query( "SELECT * FROM " + ::cTableName )
   
return Self   

//----------------------------------------------------------------------------//

METHOD Where( cFieldName, uValue ) CLASS HbModel

   ::oRs := ::oConnection:Query( "SELECT * FROM " + ::cTableName + ;
                                 " WHERE " + cFieldName + "=" + ClipValue2SQL( uValue ) )

return Self
                                     
//----------------------------------------------------------------------------//
      
