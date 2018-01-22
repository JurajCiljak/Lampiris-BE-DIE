/*
    @Author: Juraj Ciljak
    @CreateDate: 30.10.2017
    @LastModify: 
    @Description: Unit Test class for AuthCallout 
                      Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
    @Version: 1.0.1
*/
@isTest
private class AuthCalloutTest {

    @isTest(SeeAllData=true) // SeeAllData beacuse Custom Settings
    static void myAuthCallou_CRM2() {


   		String jsonData = getHTTP_POST_CRM2_Data('123456789');
   		Integration_Credential__c IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION ); 
   		Map<String, String> responseHeaders = new Map<String, String>();
    	
    	List<String> lsJSON_Resp = new List<String>();
    	SystemLog sysLog  = new SystemLog(false, false, false, false);
    	
    	responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
    	responseHeaders.put('Method','POST');
    	 
    	Test.startTest(); 
    	RequestMockTest fakeResponse ;
		responseHeaders.put('Endpoint',IntegrationCred.EndPoint__c);
		fakeResponse = new RequestMockTest(Constants.HTTP_STATUS_CODE_NO_CONTENT,'No Content', '', responseHeaders);
				
		Test.setMock(HttpCalloutMock.class, fakeResponse); 
		
		AuthCallout authCall = new AuthCallout();
		
		Integer iValue = authCall.basicAuthCalloutWithJSON( IntegrationCred.EndPoint__c, IntegrationCred.UserName__c, 
    			IntegrationCred.Password__c, 'POST', jsonData,lsJSON_Resp,sysLog);
		
		System.assertEquals(0,sysLog.Logs.size());	  // NO ERROR
		
		fakeResponse = new RequestMockTest(Constants.HTTP_STATUS_CODE_OK,'Content', getHTTP_POST_CRM2_Data_Response('123456789'), responseHeaders);
		Test.setMock(HttpCalloutMock.class, fakeResponse); 
		
		iValue = authCall.basicAuthCalloutWithJSON( IntegrationCred.EndPoint__c, IntegrationCred.UserName__c, 
    			IntegrationCred.Password__c, 'POST', jsonData,lsJSON_Resp,sysLog);
    			
		system.assertEquals(AuthCallout.ClassName, AuthCallout.class.getName());
		system.assertNOTEquals(0,sysLog.Logs.size());	  // SOME ERROR
		system.assertNOTEquals(0,lsJSON_Resp.size());	  // RESPONSE ERROR IF status code NOT 204	
		
    	Test.stopTest(); 
        
    }
    
    public static String getHTTP_POST_CRM2_Data( String recId )
    {
    	String Result;
    	List<CRM2_Data.CRM2_Email> lsCRM2_Data = new List<CRM2_Data.CRM2_Email>();
    	CRM2_Data.CRM2_Email cmr2_EmailData = new CRM2_Data.CRM2_Email(); 
    	cmr2_EmailData.id = recId;
		cmr2_EmailData.reference = 'EL1'+recId;
		cmr2_EmailData.application = '';
		cmr2_EmailData.user = '';
		cmr2_EmailData.ticketType = '';
		cmr2_EmailData.concern = '';
		cmr2_EmailData.description = '';
		cmr2_EmailData.documents = new List<CRM2_Data.CRM2_Document> ();
    	
    	lsCRM2_Data.Add(cmr2_EmailData);
    	Result = JSON.serialize(  lsCRM2_Data ); 
    	return Result;
    }
    
    public static String getHTTP_POST_CRM2_Data_Response( String errId)
    {
    	String Result;
    	List<CRM2_Data.CRM2_Response> crm2_Res = new List<CRM2_Data.CRM2_Response>();
    	CRM2_Data.CRM2_Response crm2 = new CRM2_Data.CRM2_Response();
    	crm2.code = ' TO DO Code';
		crm2.message = ' TO DO message';
	  	crm2.extraInfo = new List<CRM2_Data.CRM2_Response_ExtraInfo>();
	  	CRM2_Data.CRM2_Response_ExtraInfo exInf = new CRM2_Data.CRM2_Response_ExtraInfo();
	  	exInf.id = errId;
	  	crm2.extraInfo.Add( exInf );
	  	crm2_Res.Add(crm2);
    	Result = JSON.serialize(  crm2_Res ); 
    	return Result;
    }
}