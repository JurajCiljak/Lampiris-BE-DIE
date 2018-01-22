/*
    @Author: Juraj Ciljak
    @CreateDate: 31.10.2017
    @LastModify: 
    @Description: Test Class for Email Message
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
@isTest
private class HNDL_EmailMessageTest {
	

	static testMethod void myCRM2_DataFunctionalTest() {
    	
    	Test.startTest();
    	TST_UtilityClass.TestUtilityWrapperClass utilityTest = new TST_UtilityClass.TestUtilityWrapperClass();
        utilityTest.MainInit(true);
		utilityTest.AccountReferenceInit();
		utilityTest.CaseInit();
	//	utilityTest.BatchDataInit();
		utilityTest.EmailMessageInit(); 
		HNDL_EmailMessage.setFirstRunFalse(); 
		HNDL_EmailMessage.setFirstRun( true );
		HNDL_EmailMessage.isFirstRun();
		/* Test mass insert*/
		List<EmailMessage> lsEml = new List<EmailMessage>();
		List<EmailMessage> lsUpdateEml = new List<EmailMessage>();
		EmailMessage eml;
		
		for(integer i = 1; i < 5; i++) 
		{
			eml = TST_UtilityClass.testEmailMessage( utilityTest.testCase,'Test '+String.valueOf(i));	
			lsEml.Add( eml );
		}
		insert lsEml;
		
		/* Check if BatchData is insert */
		BatchData__c bd = [ Select Id From BatchData__c Where Object_Id__c =:eml.Id LIMIT 1];
		System.assertNotEquals(null,bd);
		
		for(EmailMessage eml1 : lsEml)
		{
			eml1.Subject = eml.Subject + ':)';
			lsUpdateEml.Add( eml1 );
		}
		update lsUpdateEml;
		
		/* Check if all EmailMessage were inserted to the BatchData object */
		Map<Id,EmailMessage> mapEmlCheck = new Map<Id,EmailMessage>();
		mapEmlCheck.putAll(lsUpdateEml);
		List<BatchData__c> lsBD = [ Select Id From BatchData__c Where Object_Id__c =:mapEmlCheck.keySet()];
		system.assertEquals(lsBD.size(),lsUpdateEml.size());
		Test.stopTest();  
	}
}