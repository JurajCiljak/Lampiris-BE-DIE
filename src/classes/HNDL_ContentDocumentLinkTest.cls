/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Handler class for Case
                  Task:  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
@isTest
private class HNDL_ContentDocumentLinkTest {

    static testMethod void HNDL_ContentDocumentLinkTest() {
        Test.startTest();
        TST_UtilityClass.TestUtilityWrapperClass UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
		UnitTest.AccountReferenceInit();
		UnitTest.CRM2_IntegrationCredInit(); 
		UnitTest.CaseInit();
		UnitTest.EmailMessageInit(); 
		UnitTest.ContentDocumentInit();
		
		UnitTest.testBatchData = [ Select Id, Name, T_CaseId__c,T_ExecutingTime__c From BatchData__c 
			Where Object_Id__c =:UnitTest.testContentVersion.Id LIMIT 1 ];
		
		system.assertNotEquals(null,UnitTest.testBatchData.Id); 
		HNDL_ContentDocumentLink.setFirstRun(true);
		HNDL_ContentDocumentLink.isFirstRun();
		HNDL_ContentDocumentLink.setFirstRunFalse();
		
        Test.stopTest();
        
    }
}