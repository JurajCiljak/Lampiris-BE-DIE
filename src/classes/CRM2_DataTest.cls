/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Handler class for Email Message
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
@isTest
private class CRM2_DataTest { 

    @isTest(SeeAllData=true) // SeeAllData beacuse Custom Settings
    static void myCRM2_DataFunctionalTest() {
    	Test.startTest();
    	TST_UtilityClass.TestUtilityWrapperClass utilityTest = new TST_UtilityClass.TestUtilityWrapperClass();
        utilityTest.MainInit(true);
		utilityTest.AccountReferenceInit();
		utilityTest.CaseInit();
		utilityTest.BatchDataInit();
		utilityTest.EmailMessageInit();
		
		utilityTest.testCase = [ Select Id, Owner.Name, OwnerId, CaseNumber,Owner.FirstName, Owner.LastName,
			C_Service__c, C_Question__c, C_Concern__c
		   From Case where Id=:utilityTest.testCase.Id LIMIT 1 ];
		
		
		utilityTest.testBatchData = [ Select T_CaseId__c,T_DescriptionHistory__c,T_ExecutingTime__c,
			External_Id__c, Object_Id__c, ObjectName__c, Parent_Id__c,Process__c,ObjectStatus__c, T_CaseId__r.LastModifiedDate,
			T_CaseId__r.Status, T_CaseId__r.CaseNumber, T_CaseId__r.Subject, T_CaseId__r.Description, LastModifiedDate,
			T_CaseId__r.C_Account_Reference__r.Name, T_CaseId__r.C_Service__c, T_CaseId__r.C_Question__c, T_CaseId__r.C_Concern__c,
			T_CaseId__r.Owner.Name, T_CaseId__r.OwnerId, T_CaseId__r.AccountId, T_CaseId__r.Owner.Alias, T_CaseId__r.Owner.FirstName, 
			T_CaseId__r.Owner.LastName, T_CaseId__r.Account.FirstName, T_CaseId__r.Account.LastName From BatchData__c 
			Where Id=:utilityTest.testBatchData.Id LIMIT 1 ];
		   
		system.debug(LoggingLevel.Error,'utilityTest.testCase:'+utilityTest.testCase );
		String sValue = CRM2_Data.getUserCRM2_Name( utilityTest.testCase.OwnerId, utilityTest.testCase.Owner, '' );
    	
    	system.assertNotEquals(null,sValue);
    	system.assertNotEquals('',sValue);
    	
    	
    	CRM2_Data.CRM2_Email crm2_Email = CRM2_Data.convertSFDCToCRM2_Data( utilityTest.testCase,utilityTest.testBatchData, 
    		CustomSettings.getCRM2_ConcernId(), CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ) );
	 	
	 	/* Test EmailMessage */
    	utilityTest.testBatchData =  TST_UtilityClass.createTestBatchDataFromEmailMessage( utilityTest.testEmailMessage );
    	Database.upsert( utilityTest.testBatchData,BatchData__c.Fields.External_Id__c);
    	
    	utilityTest.testBatchData = [ Select T_CaseId__c,T_DescriptionHistory__c,T_ExecutingTime__c,LastModifiedDate,
			External_Id__c, Object_Id__c, ObjectName__c, Parent_Id__c,Process__c, ObjectStatus__c,T_CaseId__r.LastModifiedDate,
			T_CaseId__r.Status, T_CaseId__r.CaseNumber, T_CaseId__r.Subject, T_CaseId__r.Description,
			T_CaseId__r.C_Account_Reference__r.Name, T_CaseId__r.C_Service__c, T_CaseId__r.C_Question__c, T_CaseId__r.C_Concern__c,
			T_CaseId__r.Owner.Name, T_CaseId__r.OwnerId, T_CaseId__r.AccountId, T_CaseId__r.Owner.Alias, T_CaseId__r.Owner.FirstName, 
			T_CaseId__r.Owner.LastName, T_CaseId__r.Account.FirstName, T_CaseId__r.Account.LastName From BatchData__c 
			Where Id=:utilityTest.testBatchData.Id LIMIT 1 ];
    	
    	crm2_Email = CRM2_Data.convertSFDCToCRM2_Data( utilityTest.testEmailMessage,utilityTest.testBatchData, 
    		CustomSettings.getCRM2_ConcernId(), CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ) );
	 	 
	 	/* Testing Attachement */
	 	utilityTest.AttachmentInit();
    	
    	utilityTest.testBatchData =  TST_UtilityClass.createTestBatchDataFromAttachment( utilityTest.testAttachment,
    		utilityTest.testEmailMessage 
		);
    	Database.upsert( utilityTest.testBatchData,BatchData__c.Fields.External_Id__c);
    	
    	utilityTest.testBatchData = [ Select T_CaseId__c,T_DescriptionHistory__c,T_ExecutingTime__c,
			External_Id__c, Object_Id__c, ObjectName__c, Parent_Id__c,Process__c, ObjectStatus__c, T_CaseId__r.LastModifiedDate,
			T_CaseId__r.Status, T_CaseId__r.CaseNumber, T_CaseId__r.Subject, T_CaseId__r.Description,LastModifiedDate,
			T_CaseId__r.C_Account_Reference__r.Name, T_CaseId__r.C_Service__c, T_CaseId__r.C_Question__c, T_CaseId__r.C_Concern__c,
			T_CaseId__r.Owner.Name, T_CaseId__r.OwnerId, T_CaseId__r.AccountId, T_CaseId__r.Owner.Alias, T_CaseId__r.Owner.FirstName, 
			T_CaseId__r.Owner.LastName, T_CaseId__r.Account.FirstName, T_CaseId__r.Account.LastName From BatchData__c 
			Where Id=:utilityTest.testBatchData.Id LIMIT 1 ];
    	
    	crm2_Email = CRM2_Data.convertSFDCToCRM2_Data( utilityTest.testAttachment,utilityTest.testBatchData, 
    		CustomSettings.getCRM2_ConcernId(), CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ) );
    	
    	
    	CRM2_Data.CRM2_Response resp = new CRM2_Data.CRM2_Response();
    	resp.code = ' some code ';
		resp.message = ' some message';
	  	resp.extraInfo = new List<CRM2_Data.CRM2_Response_ExtraInfo>();
		CRM2_Data.CRM2_Response_ExtraInfo extraInfo = new CRM2_Data.CRM2_Response_ExtraInfo();
		extraInfo.Id = utilityTest.testAttachment.Id;
		resp.extraInfo.Add( extraInfo );
	
    	SystemLog sysLog = new SystemLog(false, false, false, false);
    	String jsonData = JSON.serialize( resp );
    	CRM2_Data.CRM2_Response crm2_Responce = CRM2_Data.deserializeJSON_To_CRM2_Response( jsonData, sysLog);
    	
    	Test.stopTest();
        
    }
}