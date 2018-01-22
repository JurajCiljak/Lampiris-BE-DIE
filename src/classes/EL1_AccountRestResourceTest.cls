/*
    @Author: Juraj Ciljak
    @CreateDate: 19.10.2017
    @LastModify:  
    @Description: Unit test class EL1_AccountRestResourceTest for retrieving data from EL1
                  Task: SFDCFR-25 -> https: https://jira.lampiris.be/browse/SFDCBE-25
                  Task: SFBECASE-49 -> https://jira.lampiris.be/browse/SFBECASE-49
    @Version: 1.0.2
*/
@isTest
private class EL1_AccountRestResourceTest  {

    static testMethod void EL1_AccountRestResource_UT() {
        
        Set<String> accRefIds = new Set<String>();
        Database.UpsertResult [] upr;
        Database.UpsertResult sv;
        List<Account> lsAccount = new List<Account>();
        Map<String,EL1_AccountRestResource.EL1_AccountRequest> mapRequest = new Map<String,EL1_AccountRestResource.EL1_AccountRequest> ();
        Map<String,EL1_AccountRestResource.EL1Account> mapAccEl1 = new Map<String,EL1_AccountRestResource.EL1Account>();
        Test.startTest();
      //  Id recordId = createTestRecord();

        RestRequest request = new RestRequest();
        request.requestUri = 'https://' + URL.getSalesforceBaseUrl().getHost() + '/'+EL1_AccountRestResource.ClassName+'/doPost';

        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        List<EL1_AccountRestResource.EL1Account> lsRequestData = new List<EL1_AccountRestResource.EL1Account>();
     //    account_Reference, external_Person_Key,  external_Family_Key, language,String salutation,  firstName, lastName, referenceType, email
        EL1_AccountRestResource.EL1Account el1 = generateEL1_Request( 'E14836481','BI11XX22','ZI11XX22','EN','Mr.','Lampiris','BOT',Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ENERGY,'Lampiris.BOT@lampiris.be');
        lsRequestData.Add( el1 ); 
        accRefIds.Add( el1.Account_Reference);
        
        el1 = generateEL1_Request( 'E14836482','BI11XX22','ZI11XX22','EN','Mr.','Lampiris','BOT',Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ISOL,'Lampiris.BOT@lampiris.be');       
        accRefIds.Add( el1.Account_Reference);
        lsRequestData.Add( el1);
        
        el1 = generateEL1_Request( '','','','','','','',Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ISOL,'');
        lsRequestData.Add( el1);
        
        request.requestBody = Blob.valueOf( System.JSON.serialize(lsRequestData));
        RestContext.request = request;
        // Update status of existing record to Working
	
        List<EL1_AccountRestResource.EL1_AccountRequest> responseData = EL1_AccountRestResource.doPost(); 
        system.debug(LoggingLEvel.Error,'Responnce:'+responseData);
		system.assertNotEquals(responseData.size(),0); // IF there is no records in responnse it means no error        
       
        List<Account_Reference__c> lsAccRef = Database.query(EL1_AccountRestResource.getSOQForAccountReverence());
        system.assertEquals(lsAccRef.size(),2);
        Account_Reference__c accRef = lsAccRef.get(0);
        Account acc = accRef.C_Account_Name__r;
		upr = Database.upsert(lsAccRef ,Account_Reference__c.Fields.C_ExternalId__c ,false);    
       
	
		String resData = EL1_AccountRestResource.doGet(); 
		system.assertEquals(Constants.HTTP_EL1_METHOD_NOT_ALLOWED,resData);
		
		resData = EL1_AccountRestResource.doDelete(); 
		system.assertEquals(Constants.HTTP_EL1_METHOD_NOT_ALLOWED,resData);
		
		 
        SystemLog sysLog = new SystemLog(false, false, false, false);
		//Map<String,EL1_AccountRequest> mapRequest,Map<String,EL1Account> mapAccEl1
		
		EL1_AccountRestResource.checkUpsertResult( Account_Reference__c.sObjectType.getDescribe().getName(),  upr, lsAccRef, mapRequest,mapAccEl1,  sysLog );
     	
     	lsAccount.Add(acc);
     	upr = Database.upsert(lsAccount ,Account.Fields.C_External_Person_Key__c ,false);    
     	EL1_AccountRestResource.checkUpsertResult( Account.sObjectType.getDescribe().getName(),  upr, lsAccount, mapRequest,mapAccEl1,  sysLog );
     
     
     	/* Test Again for comparation  */
     	
        request.requestBody = Blob.valueOf( System.JSON.serialize(lsRequestData));
        RestContext.request = request;
     	responseData = EL1_AccountRestResource.doPost(); 
     
     	/* Move Account Reference */
     	lsRequestData.clear();
        el1 = generateEL1_Request( 'E14836482','BI11XX23','ZI11XX23','EN','Mr.','Lampiris','BOT',Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ENERGY,'Lampiris.BOT@lampiris.be');       
        accRefIds.Add( el1.Account_Reference);
        lsRequestData.Add( el1);
        
        request.requestBody = Blob.valueOf( System.JSON.serialize(lsRequestData));
        RestContext.request = request;
     	responseData = EL1_AccountRestResource.doPost(); 
     	
     	EL1_AccountRestResource.getResponseError( Constants.HTTP_FUNCTION_ERROR, Constants.EL1_INTERNAL_SERVER_ERROR);
        Test.stopTest();
        
    }
    
    public static EL1_AccountRestResource.EL1Account generateEL1_Request( String account_Reference, String external_Person_Key, String external_Family_Key,
    	String language,String salutation, String  firstName, String lastName, String referenceType, String email )
    {
    	EL1_AccountRestResource.EL1Account Result = new EL1_AccountRestResource.EL1Account();
    	Result.Account_Reference = account_Reference;
		Result.External_Person_Key = external_Person_Key;
		Result.External_Family_Key = external_Family_Key;
		Result.Language = language;
		Result.Salutation = salutation;
		Result.FirstName = firstName;
		Result.LastName = lastName;
		Result.FirstName = firstName;
		Result.ReferenceType = referenceType;
		Result.Email = email;
  
		return Result;
    }
}