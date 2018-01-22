/*
    @Author: Juraj Ciljak
    @CreateDate: 30.09.2017
    @LastModify:  19.10.2017 - Add Error handling
                  15.11.2017 - Add Additional logic for bad data and EL1-SFDC Spec V1.ppt document
    @Description: Webservice for retrieving data from EL1
                  Task: SFBECASE-25 -> https: https://jira.lampiris.be/browse/SFBECASE-25
                  Task: SFBECASE-49 -> https://jira.lampiris.be/browse/SFBECASE-49
    @Version: 1.0.2
*/
@RestResource(urlMapping='/EL1_AccountIntegeration/*')
global with sharing class EL1_AccountRestResource {
    
    public static String ClassName{
        get{
            return EL1_AccountRestResource.class.getName();         
        }
    }
    
    @HttpDelete
    global static String doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;      
        if ( res == null ) res = new RestResponse();  
        res.statusCode = Constants.HTTP_STATUS_CODE_METHOD_NOT_ALLOWED ;
        return Constants.HTTP_EL1_METHOD_NOT_ALLOWED;
    }
  
    @HttpGet
    global static String doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if ( res == null ) res = new RestResponse();
        
        res.statusCode = Constants.HTTP_STATUS_CODE_METHOD_NOT_ALLOWED ;
        return 'This function is not available yet!!!';        
    }
    
    /*
        function doPost is responsible for retrieve data from EL1       
    */
    
    @HttpPost
    global static List<EL1_AccountRequest> doPost( ) {
        
        String objectType = '';
        Account_Reference__c accRefNotSave;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if( res == null ) res = new RestResponse();
            
        /* Collcections */
        List<Account_Reference__c> accReference;
        Map<String, Account> accData;
        Map<String,Account> compareAcc = new Map<String,Account>();
        Map<String,Account_Reference__c> mapAccountReference = new Map<String,Account_Reference__c>();
        Map<String,EL1Account> mapAccEl1 = new Map<String,EL1Account>();
        Map<String,EL1Account> mapAccReference = new Map<String,EL1Account>();
        
        Map<String,EL1_AccountRequest> mapRequest = new Map<String,EL1_AccountRequest>();
        
        /*System object*/
        Database.UpsertResult [] upr;
        Database.UpsertResult sv;
        
        /* Custom Classes */
        SystemLog sysLog = new SystemLog(false, false, false, false);
        Set<String> setAccRef = new Set<String> ();
        try
        {                
            res.statusCode = Constants.HTTP_STATUS_CODE_NO_CONTENT;
            
            String json = req.requestBody.toString();
            system.debug(LoggingLevel.Error,'json:'+json);
            List<EL1Account> reqData = (List<EL1Account>)System.JSON.deserialize(json , List<EL1Account>.class);
            /* Delete this once it will go to the Production*/
            objectType = Account_Reference__c.sObjectType.getDescribe().getName();
            for( EL1Account el1:reqData )
            {
                mapAccEl1.Put(el1.External_Person_Key,el1); 
                setAccRef.Add( el1.Account_Reference );
                mapAccReference.Put(
                    getMapTypeId( objectType+'_ExtId', el1.External_Person_Key, el1.Account_Reference, el1.ReferenceType),
                    el1);    
                checkIncomingData( objectType , el1, mapRequest); 
            } 
            
            accData =  getAccountData( mapAccEl1,compareAcc, mapRequest ); /* Get Existing Account and Create new if needed */

            Account accNotSave;
            /* Upsert Account */
            if( accData  != null && accData.size() >0 )
            {
                upr = Database.upsert(accData.values() ,Account.Fields.C_External_Person_Key__c ,false);                   
                checkUpsertResult(Account.sObjectType.getDescribe().getName() , upr , accData.values() , mapRequest,mapAccEl1, sysLog );
                                 
            }  // END if( accData  != null && accData.size() >0 )

            /* Build list of all account involved in synchronization */
            for( Account acc: accData.values() )
            {
                compareAcc.Put(acc.C_External_Person_Key__c,acc);                     
            }
          
            accReference = getAccountReference( setAccRef, mapAccReference, compareAcc, mapRequest );
            
            if( accReference != null && accReference.size() >0 )
            {
                upr = Database.upsert(accReference ,Account_Reference__c.Fields.C_ExternalId__c ,false);    
                checkUpsertResult( Account_Reference__c.sObjectType.getDescribe().getName() , upr , accReference , mapRequest,mapAccEl1, sysLog );
                                     
            }  // END  if( accReference != null && accReference.size() >0 )

            sysLog.checkInsertLog();  /* Check if there is any error */   
            
             if( res != null && mapRequest.size() > 0  ) 
                res.statusCode = Constants.HTTP_STATUS_CODE_OK;
            system.debug(LoggingLevel.Error,'mapRequest:'+mapRequest);
            return mapRequest.values();
        }catch(Exception E)
        {
            res.StatusCode = Constants.HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR ;
            sysLog.addLogNoThrow( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'doPost', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                       
            sysLog.addLogNoThrow( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'doPost', String.valueOf(req.requestBody), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                                   
            return getResponseError( Constants.HTTP_FUNCTION_ERROR, Constants.EL1_INTERNAL_SERVER_ERROR);
             
        }
    }
    
    
    /*
        function checkUpsertResult is responsible for checking if there was any error during save records
        @objectType: Object Type(Account, Account Reference)
        @upr: Upsert result
        @lsData: Collection of data which wehere updated 
        @mapRequest: Map Collection of data retrieved from webservice and they are holding the error
        @mapAccEl1: Map Collection of data retrieved from webservice 
        @sysLog: System log class
        
    */
    public static void checkUpsertResult( String objectType, Database.UpsertResult [] upr, List<sObject> lsData, 
        Map<String,EL1_AccountRequest> mapRequest,Map<String,EL1Account> mapAccEl1, SystemLog sysLog 
    )
    {
        Database.UpsertResult sv;
        Account accNotSave;
        Account_Reference__c accRefNotSave;
        if( upr != null && sysLog != null && lsData != null)
        {
            for(Integer i=0;i<upr.size();i++){
               if (!upr.get(i).isSuccess() || Test.isRunningTest() ){
                    // DML operation failed
                    sv = upr.get(i);
                    if( objectType == Account.sObjectType.getDescribe().getName())
                    {
                        accNotSave = (Account)lsData.get(i);//failed record from the list
                        checkSavedData( accNotSave , sv, mapRequest,mapAccEl1,sysLog);
                    } else if( objectType == Account_Reference__c.sObjectType.getDescribe().getName() )
                    {
                        accRefNotSave = ( Account_Reference__c)lsData.get(i);//failed record from the list
                        checkSavedData( accRefNotSave , sv, mapRequest,mapAccEl1,sysLog);   
                    }
               }  // END if (!upr.get(i).isSuccess())
            
            } // END for( Database.UpsertResult sv: upr )    
        }   
    }
    
    
    /*
        function checkSavedData responsible for checking if Accounts were saved correctly
        @ acc: Account which was processed
        @ sv: Object which store result from saving 
        @ mapRequest: Collection of data with missing mandatory fields or not saved
        @ mapAccEl1: Collection of data comming from EL1
        @ sysLog: System log object      
    */
    public static void checkSavedData( Account acc, Database.UpsertResult sv, 
        Map<String,EL1_AccountRequest> mapRequest,Map<String,EL1Account> mapAccEl1,SystemLog sysLog)
    {
        Boolean Result = true;
        String resMessage = '';
        String el1_Key;     
        EL1Account el1;
        EL1Account el1Origin;
        EL1_AccountRequest el1_Request;
        ResponseError errMessage ;
        if( mapRequest == null ) mapRequest = new Map<String,EL1_AccountRequest>();
        if(mapAccEl1 == null ) mapAccEl1 = new Map<String,EL1Account> ();
        
        if( acc != null && sv != null ) 
        {   
            el1_Key = acc.C_External_Person_Key__c;
            
            
            el1_Request = new EL1_AccountRequest(); 
            errMessage = new ResponseError();
            el1Origin = mapAccEl1.get(acc.C_External_Person_Key__c);        
            if ( el1Origin == null ) el1Origin = new EL1Account();
            el1 = new EL1Account();
            el1.Account_Reference  = '';
            el1.External_Person_Key  = acc.C_External_Person_Key__c;
            el1.External_Family_Key  = acc.C_External_Family_Key__c;
            el1.Language  = acc.C_Language__c;
            el1.Salutation  = acc.Salutation;
            el1.FirstName  = acc.FirstName;
            el1.LastName  = acc.LastName;
            el1.ReferenceType = el1Origin.ReferenceType;
            el1.Email  = acc.PersonEmail;
        
            errMessage.Message = resMessage + ' '+ Constants.EL1_SAVING_ERROR;
            errMessage.Code = Constants.EL1_DML_ERROR;
            el1_Request.request = el1;
            el1_Request.error = errMessage;
            mapRequest.put(el1_Key,el1_Request);
            sysLog.addLog( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'checkSavedData', 
                           SystemLog.getLogMessageFromSaveError(sv)+',Data:['+String.valueOf(el1)+']', String.valueOf(sv.getId()),'?',214,ApexPages.severity.ERROR ) , null );          
        }
        
    }
    
    /*
        function checkSavedData responsible for checking if Account References were saved correctly
        @ acc: Account which was processed
        @ sv: Object which store result from saving 
        @ mapRequest: Collection of data with missing mandatory fields or not saved
        @ mapAccEl1: Collection of data comming from EL1
        @ sysLog: System log object      
    */    
    public static void checkSavedData( Account_Reference__c acRef, Database.UpsertResult sv, 
        Map<String,EL1_AccountRequest> mapRequest,Map<String,EL1Account> mapAccEl1,SystemLog sysLog)
    {
        String el1_Key;
        String objectType = Account_Reference__c.sObjectType.getDescribe().getName();
        Boolean Result = true;
        EL1Account el1;
        EL1Account el1Origin;
        EL1_AccountRequest el1_Request;
        ResponseError errMessage ;
        String resMessage = '';
        if( mapRequest == null ) mapRequest = new Map<String,EL1_AccountRequest>();
        if(mapAccEl1 == null ) mapAccEl1 = new Map<String,EL1Account> ();
        
        if( acRef != null && sv != null )   
        {
        
            el1_Key = getMapTypeId( objectType, '', acRef.Name, acRef.C_Reference_Type__c);
            
            el1_Request = new EL1_AccountRequest(); 
            errMessage = new ResponseError();
            el1Origin = mapAccEl1.get(acRef.C_External_Person_Key__c); 
            if( el1Origin == null ) el1Origin =  new EL1Account();
            el1 = new EL1Account();
            el1.Account_Reference  = acRef.Name;
            el1.External_Person_Key  = acRef.C_External_Person_Key__c;
            el1.External_Family_Key  = el1Origin.External_Family_Key;
            el1.Language  = el1Origin.Language;
            el1.Salutation  = el1Origin.Salutation;
            el1.FirstName  = el1Origin.FirstName;
            el1.LastName  = el1Origin.LastName;
            el1.ReferenceType = acRef.C_Reference_Type__c;
            el1.Email  = el1Origin.Email;
            
            
            errMessage.Message = resMessage + ' '+ Constants.EL1_SAVING_ERROR;
            errMessage.Code = Constants.EL1_DML_ERROR;
            el1_Request.request = el1;
            el1_Request.error = errMessage;
            mapRequest.put(el1_Key,el1_Request);
            sysLog.addLog( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'checkSavedData', 
                           SystemLog.getLogMessageFromSaveError(sv)+',Data:['+String.valueOf(el1)+']', String.valueOf(sv.getId()),'?',270,ApexPages.severity.ERROR ) , null ); 
            
            
        }
        
    }
    
    /*
        function getMapTypeId responsible for generatinf External ID by Object Type
        @ objectType: Object tyep Account,Account Reference,..
        @ key1: First Key 
        @ key2: Second Key 
        @ key3: Third Key  
    */ 
    public static String getMapTypeId( String objectType, String key1, String key2,String key3)
    {
        String Result = '';
        if( key1 == null ) key1 = '';
        if( key2 == null ) key2 = '';
        if( key3 == null ) key3 = '';
        Result = key1;
        if( objectType == Account_Reference__c.sObjectType.getDescribe().getName()){ Result = key1+'/'+key2+'/'+key3;}
        else  if( objectType == Account_Reference__c.sObjectType.getDescribe().getName()+'_ExtId'){ Result = key2+'/'+key3;}
        return Result;
    }
    
    /*
        function checkIncomingData responsible for checking Mandatory Fields for data comming from EL1
        @ objectType: Object tyep Account,Account Reference,..
        @ accEl1: Data Comming from EL1
        @ mapRequest: Collection of data comming from EL1 with response 
    */ 
    public static boolean checkIncomingData(String objectType, EL1Account accEl1, Map<String,EL1_AccountRequest> mapRequest)
    {
        String el1_Key;
        String el1_PrimaryKey;
        Boolean Result = true;
        EL1_AccountRequest el1_Request;
        ResponseError errMessage ;
        String resMessage = '';
        if( mapRequest == null ) mapRequest = new Map<String,EL1_AccountRequest>();
        if( accEL1 != null )    
        { 
            el1_Key = getMapTypeId( objectType, accEL1.External_Person_Key, accEL1.Account_Reference, accEL1.ReferenceType);
            el1_Request = new EL1_AccountRequest(); 
            errMessage = new ResponseError();
            if( String.isEmpty(accEL1.LastName) )
            {
                resMessage = 'LastName';
                Result = false;
            }
            else if( String.isEmpty(accEL1.Account_Reference) ){                
                resMessage = 'Account_Reference';
                Result = false;
                
            } if( String.isEmpty(accEL1.External_Person_Key)){              
                Result = false;
                resMessage = 'External_Person_Key';
                
            } else if( String.isEmpty(accEL1.ReferenceType) ){
            
                Result = false; 
                resMessage = 'ReferenceType';
            }
           
            if( Result == false )
            {
                errMessage.Message = resMessage + ' '+Constants.EL1_FIELD_NOT_SPECIFIED ;
                errMessage.Code = Constants.EL1_MISSING_ARGUMENT;
                el1_Request.request = accEl1;
                el1_Request.error = errMessage;
                mapRequest.put(el1_Key,el1_Request);
            }
        }
        return Result;
    }
 
    /*
        function getAccountData responsible for creating list of Account 
        @ mapAccEl1: Collection of Account received via REST API call
        @ compareAcc: Collections of Account with key value of External_Person_Key__c
        @ mapRequest: Class which store message for HTTP Response
    */
    private static Map<String,Account> getAccountData(Map<String,EL1Account> mapAccEl1, Map<String,Account> compareAcc,
        Map<String,EL1_AccountRequest> mapRequest)
    { 
        String SOQL;
        String sfdc_Language;
        String sfdc_Email ;
        String sfdc_Saluation;
        Account acc_SFDC; 
        Id devRecordTypeId;
        List<Account> lsData ;
        Set< String > accExtIds = new Set<String>();
        Map<String,Account> Result = new Map<String,Account>();
        if ( compareAcc == null )  compareAcc = new  Map<String,Account>(); // This Map Collection need to be create outside of this function !!! 
        SystemLog sysLog = new SystemLog(false, false, false, false);
        
        SOQL = ' Select Id, PersonEmail, LastName, FirstName, C_External_Person_Key__c,';
        SOQL += ' C_External_Family_Key__c, C_Language__c,  Salutation From ';
        SOQL += Account.sObjectType.getDescribe().getName()+' Where C_External_Person_Key__c IN :accExtIds ';
        try
        {
            devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            if( mapAccEl1 != null && mapAccEl1.size() > 0)
            {
                accExtIds.addAll(mapAccEl1.keySet());
                system.debug(LoggingLevel.Error,'SOQL:'+SOQL);
                system.debug(LoggingLevel.Error,'accExtIds:'+accExtIds);
                lsData = Database.query( SOQL );
                
                for( Account acc: lsData)
                {
                    compareAcc.put(acc.C_External_Person_Key__c,acc);
                }

                for( EL1Account el1: mapAccEl1.values())
                {
                    acc_SFDC = null; sfdc_Language ='';
                    sfdc_Saluation = ''; sfdc_Email = '' ;
                    acc_SFDC = compareAcc.get( el1.External_Person_Key );
                    
                    if( acc_SFDC != null ) 
                    {
                        sfdc_Language = acc_SFDC.C_Language__c;
                        sfdc_Saluation = acc_SFDC.Salutation;
                        if( !String.isEmpty(acc_SFDC.PersonEmail)) sfdc_Email = acc_SFDC.PersonEmail;
                    }
                    
                    /* Update Account only if there is Change because LastModified date*/
                    if( (acc_SFDC == null || el1.Language !=  sfdc_Language || sfdc_Saluation != acc_SFDC.Salutation ||                        
                         el1.External_Family_Key != acc_SFDC.C_External_Family_Key__c || el1.LastName != acc_SFDC.LastName ||
                         el1.FirstName != acc_SFDC.FirstName ||  el1.Email != sfdc_Email 
                        )
                         && !String.isEmpty(el1.LastName))                     
                    {
                        if( acc_SFDC == null ) acc_SFDC = new Account( RecordTypeId = devRecordTypeId);
                        acc_SFDC.C_Language__c = el1.Language;
                        acc_SFDC.Salutation = el1.Salutation;
                        acc_SFDC.C_External_Family_Key__c = el1.External_Family_Key;
                        acc_SFDC.LastName = el1.LastName;
                        acc_SFDC.FirstName = el1.FirstName;
                        if( !String.isEmpty( el1.Email)) acc_SFDC.PersonEmail = el1.Email;
                        acc_SFDC.C_External_Person_Key__c = el1.External_Person_Key;
                        Result.put(acc_SFDC.C_External_Person_Key__c,acc_SFDC);                      
                       
                    }  // END if( (acc_SFDC == null || el1.Language !=  sfdc_Language ||
                }  // END for( EL1Account el1: mapAccEl1.values())                
            }
            return Result;
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'getAccountData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );                          
            return new Map<String,Account>();
        }
    }
    
    /*
        function getAccountReference responsible for creating list of Account Reference
        @ mapAccReference: Collection of Account Reference received via REST API call
        @ mapAccount: Collections of Account from SFDC database
        @ mapRequest: Class which store message for HTTP Response
    */
    private static List< Account_Reference__c> getAccountReference(Set<String> setAccRef,Map<String,EL1Account> mapAccReference, Map<String,Account> mapAccount,
        Map<String,EL1_AccountRequest> mapRequest )
    {
        List< Account_Reference__c> Result ;
        String SOQL;
        String refType = ''; 
        Account acc;
        Account_Reference__c accRefClone;
        Account_Reference__c accRef; 
        Set< String > accRefIds = new Set<String>();
        Map<String,Account_Reference__c> mapResult = new Map<String, Account_Reference__c>();
        Map<String,Map<String, Account_Reference__c>> hrAccRef = new  Map<String,Map<String, Account_Reference__c>>();
        Map<String, Account_Reference__c> compareAccRef = new Map<String, Account_Reference__c>();
        String objectType =  Account_Reference__c.sObjectType.getDescribe().getName();
        
        if( mapAccount == null) mapAccount = new Map<String,Account>();
        if( setAccRef == null ) setAccRef = new Set<String>();
        SystemLog sysLog = new SystemLog(false, false, false, false);
        
        SOQL = getSOQForAccountReverence();
        try
        {
            if( mapAccReference != null && mapAccReference .size() > 0)
            {
                accRefIds.addAll(setAccRef/*mapAccReference.keySet()*/);
                system.debug(LoggingLevel.Error,'SOQL:'+SOQL);
                system.debug(LoggingLevel.Error,'accRefIds:'+accRefIds);
                Result = Database.query( SOQL );
                for(  Account_Reference__c accountRef: Result)
                {  
                    compareAccRef = hrAccRef.get(accountRef.Name);
                    if( compareAccRef == null) compareAccRef  = new Map<String, Account_Reference__c> ();
                    compareAccRef.put(accountRef.C_Reference_Type__c ,accountRef);
                    hrAccRef.put(accountRef.Name,compareAccRef);
                }
                
                Result.Clear();
                
                for( EL1Account el1: mapAccReference.values())
                {
                    accRef = null; accRefClone = null; refType = ''; compareAccRef  = null;
                    
                    compareAccRef = hrAccRef.get(el1.Account_Reference);
                    if( compareAccRef != null ) accRef = compareAccRef.get( el1.ReferenceType );
                    acc = mapAccount.get( el1.External_Person_Key); 
                   
                    if( accRef != null)
                    {
                        refType = accRef.C_Reference_Type__c;
                    }
                    
                    if( ( acc != null ) && 
                        ( !String.isEmpty(el1.Account_Reference))
                      )
                    {
                      
                        if(  accRef != null  || compareAccRef != null) 
                        {
                            for( Account_Reference__c oldAccRef : compareAccRef.values())
                            {
                                /* Change Account for Account Reference if there is need*/
                                if( oldAccRef.C_External_Person_Key__c != el1.External_Person_Key && 
                                    !String.isEmpty(el1.ReferenceType) && !String.isEmpty(el1.Account_Reference) )
                                {
                                    accRefClone = oldAccRef.clone(true, true, false, false);   
                                    accRefClone.C_External_Person_Key__c = el1.External_Person_Key;
                                    accRefClone.C_Account_Name__c = acc.Id;
                                    mapResult.put(accRefClone.C_ExternalId__c, accRefClone );
                                }
                               
                            }  //  END for( LMP_Account_Reference__c oldAccRef : compareAccRef.values())
                        }  // END if(  accRef != null  || compareAccRef != null) 
                        
                        /* Create new Account Reference*/
                        if( accRef == null && !String.isEmpty(el1.ReferenceType) && !String.isEmpty(el1.Account_Reference) ) 
                        {
                            accRef = new Account_Reference__c( );
                            accRef.Name = el1.Account_Reference;
                            accRef.C_Account_Name__c = acc.Id;
                            accRef.C_Reference_Type__c = el1.ReferenceType ;
                            accRef.C_ExternalId__c = getMapTypeId( objectType+'_ExtId', el1.External_Person_Key, el1.Account_Reference, el1.ReferenceType);
                            accRef.C_External_Person_Key__c = el1.External_Person_Key;
                            mapResult.put(accRef.C_ExternalId__c, accRef);
                        }  // END if( accRef == null ) 
                    }  // END if( ( acc != null ) && 
                }  // END for( EL1Account el1: mapAccReference.values())               
            }  // END if( mapAccReference != null && mapAccReference .size() > 0)
            
            Result.AddAll(mapResult.values());
            return Result;
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( EL1_AccountRestResource.ClassName,'getAccountReference', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );                                     
            return new List<Account_Reference__c>();
        }
    }
     
     
    
    /*SOQL*/
    public static String getSOQForAccountReverence()
    {
        String Result = ' Select Id, Name , C_Account_Name__r.Name, C_Account_Name__r.C_External_Person_Key__c, ';
        Result += ' C_Account_Name__r.C_External_Family_Key__c, C_Account_Name__r.C_Language__c, C_Account_Name__r.Salutation,';
        Result += ' C_Account_Name__r.FirstName, C_Account_Name__r.LastName, C_Account_Name__r.PersonEmail, ';
        Result += ' C_Account_Name__c, C_External_Person_Key__c, C_Reference_Type__c, C_ExternalId__c ';
        Result += ' From '+Account_Reference__c.sObjectType.getDescribe().getName() +' where Name IN :accRefIds ';
        return Result;
    }
    
    /* Wrapper classes */ 
    public class ResponseError {
        public String Message { get;set;}
        public String Code {get;set;}
    }
    
    public static List<EL1_AccountRequest> getResponseError( String message, String code) {
        
        List<EL1_AccountRequest> Result = new List<EL1_AccountRequest>();
        EL1_AccountRequest el1 = new EL1_AccountRequest();
        ResponseError err = new ResponseError(); 
        el1.request = new EL1Account ();
        err.Message = message;
        err.Code = code;
        el1.error = err;
        Result.Add(el1);
        return Result;
    }
    
 
    global class EL1_AccountRequest{
        public EL1Account request{get;set;}
        public ResponseError error{get;set;}
    }
    
    global class EL1Account{
        public String Account_Reference;
        public String External_Person_Key;
        public String External_Family_Key;
        public String Language;
        public String Salutation;
        public String FirstName;
        public String LastName;
        public String ReferenceType;
        public String Email;
        // ...
    }
}