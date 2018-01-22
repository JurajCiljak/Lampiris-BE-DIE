/*
    @Author: Juraj Ciljak
    @CreateDate: 30.10.2017
    @LastModify: 
    @Description: Unit Test class for CustomSettings 
    @Version: 1.0.1
*/
@isTest
private class CustomSettingsTest {

	@isTest(SeeAllData=true)
	static void myCustomSettings() {   
		Test.startTest();
		Integration_Credential__c iCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
		system.assertNotEquals(null, iCred);
		
		Map<String,CRM2_Concern_Id__c> mapCRM2_concern = CustomSettings.getCRM2_ConcernId();
		system.assertNotEquals(0, mapCRM2_concern.size()); 
		
		CustomSettings.getCRM2_ConcernKey('','','');
		
		iPortal_MimeType__c ip_MT = CustomSettings.get_iPortal_MimeType('jpg');
		system.assertNotEquals(null, ip_MT);
	
		Test.stopTest();
	}
}