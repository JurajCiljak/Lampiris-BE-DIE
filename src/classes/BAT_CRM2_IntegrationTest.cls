/*
    @Author: Juraj Ciljak
    @CreateDate: 30.10.2017
    @LastModify: 
    @Description: Unit Test class for BAT_CRM2_Integration and BAT_HNDL_CRM2_Integration
                      Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
    @Version: 1.0.1
*/
@isTest
private class BAT_CRM2_IntegrationTest {
	
	public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;} 
	
	@testSetup 
    static void setup() {
	
    }
    
	static {
	    UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
		UnitTest.AccountReferenceInit();
		UnitTest.CaseInit();
		UnitTest.EmailMessageInit(); 
		UnitTest.testBatchData = [ Select Id, Name, T_CaseId__c,T_ExecutingTime__c From BatchData__c 
			Where Object_Id__c =:UnitTest.TestEmailMessage.Id LIMIT 1 ];
		UnitTest.CRM2_IntegrationCredInit(); 
	}

	
	//@isTest(SeeAllData=true) // SeeAllData beacuse Custom Settings
    static testMethod void myBAT_CRM2_IntegrationTest_STATUS_CODE_NO_CONTENT() {
        
        Integration_Credential__c IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ); 
   		Map<String, String> responseHeaders = new Map<String, String>();
    	
    	List<String> lsJSON_Resp = new List<String>();
    	SystemLog sysLog  = new SystemLog(false, false, false, false);
    	
    	responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
    	responseHeaders.put('Method','POST');
    	 
    	Test.startTest(); 
    	RequestMockTest fakeResponse ;
		responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
		
		/* Response should be Empty */
		fakeResponse = new RequestMockTest(Constants.HTTP_STATUS_CODE_NO_CONTENT,'No Content', 
			'', responseHeaders); 
				
		Test.setMock(HttpCalloutMock.class, fakeResponse); 
		
		BAT_CRM2_Integration bat = new BAT_CRM2_Integration(null,system.now().addMinutes(10),30,SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN);
        Id batchId = Database.executeBatch(bat);
		
		
		Test.stopTest();
		system.assertEquals(0,bat.NextExecution.size()); // NO ERROR LOG
		system.assertEquals(0,bat.sysLog.Logs.size()); // NO ERROR LOG
        
    }
    
    static testMethod void myBAT_CRM2_IntegrationTest_STATUS_CODE_OK() {
        
        Integration_Credential__c IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ); 
   		Map<String, String> responseHeaders = new Map<String, String>();
    	
    	List<String> lsJSON_Resp = new List<String>();
    	SystemLog sysLog  = new SystemLog(false, false, false, false);
    	
    	responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
    	responseHeaders.put('Method','POST');
    	 
    	Test.startTest(); 
    	RequestMockTest fakeResponse ;
		responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
		
		
		/* Response should be Empty */
		fakeResponse = new RequestMockTest(Constants.HTTP_STATUS_CODE_OK,'No Content', 
			getHTTP_POST_CRM2_Data_Response( String.valueOf(UnitTest.TestEmailMessage.Id) ), responseHeaders); 
				
		Test.setMock(HttpCalloutMock.class, fakeResponse); 
		
		BAT_CRM2_Integration bat = new BAT_CRM2_Integration(null,system.now().addMinutes(10),30,SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN);
        bat.sysLog = sysLog;
        Id batchId = Database.executeBatch(bat);
		String sValue = BAT_CRM2_Integration.ClassName;
		Test.stopTest();
		//system.assertNOTEquals(0,bat.NextExecution.size()); // NO ERROR LOG
		//	system.assertNOTEquals(0,bat.sysLog.Logs.size()); // NO ERROR LOG
		//system.debug(LoggingLevel.Error,'sysLog-Y:'+bat.sysLog);
		//system.debug(LoggingLevel.Error,'NextExecution:'+bat.NextExecution); // NO ERROR LOG
		
         
    }
    
    
    static testMethod void myBAT_CRM2_IntegrationTest_STATUS_CODE_INTERNAL_SERVER_ERROR() {
        
        Integration_Credential__c IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ); 
   		Map<String, String> responseHeaders = new Map<String, String>();
    	
    	List<String> lsJSON_Resp = new List<String>();
    	SystemLog sysLog  = new SystemLog(false, false, false, false);
    	
    	responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
    	responseHeaders.put('Method','POST');
    	 
    	Test.startTest(); 
    	RequestMockTest fakeResponse ;
		responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
		
		system.debug(LoggingLevel.Error,'UnitTest:'+UnitTest);
		
		/* Response should be Empty */
		fakeResponse = new RequestMockTest(Constants.HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR,'No Content', 
			getHTTP_POST_CRM2_Data_Response( String.valueOf(UnitTest.TestEmailMessage.Id) ), responseHeaders); 
				
		Test.setMock(HttpCalloutMock.class, fakeResponse); 
		
		BAT_CRM2_Integration bat = new BAT_CRM2_Integration(null,system.now().addMinutes(10),30,SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN);
        bat.sysLog = sysLog;
        Id batchId = Database.executeBatch(bat);
		String sValue = BAT_CRM2_Integration.ClassName;
		Test.stopTest();
		//system.assertNOTEquals(0,bat.NextExecution.size()); // NO ERROR LOG
		//	system.assertNOTEquals(0,bat.sysLog.Logs.size()); // NO ERROR LOG
		//system.debug(LoggingLevel.Error,'sysLog-Y:'+bat.sysLog);
		//system.debug(LoggingLevel.Error,'NextExecution:'+bat.NextExecution); // NO ERROR LOG
		
        
    }
    
    
    public static String getHTTP_POST_CRM2_Data_Response( String errId )
    {
    	String Result;
    	CRM2_Data.CRM2_Response crm2 = new CRM2_Data.CRM2_Response();
    	crm2.code = ' TO DO Code';
		crm2.message = ' TO DO message';
	  	crm2.extraInfo = new List<CRM2_Data.CRM2_Response_ExtraInfo>();
	  	CRM2_Data.CRM2_Response_ExtraInfo exInf = new CRM2_Data.CRM2_Response_ExtraInfo();
	  	exInf.id = errId;
	  	crm2.extraInfo.Add( exInf );
	  	Result = JSON.serialize(  crm2 ); 
    	return Result;
    }
}