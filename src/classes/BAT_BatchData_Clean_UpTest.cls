/*
    @Author: Juraj Ciljak
    @CreateDate: 25.10.2017
    @LastModify: 
    @Description: Tes class for dule Batch for BAT_BatchData_Clean_Up
                  Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-60
    @Version: 1.0.1
*/
@isTest
private class BAT_BatchData_Clean_UpTest {
	
	public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;}
	
    @testSetup 
    static void setup() {
        UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
        UnitTest.AccountReferenceInit();
		UnitTest.CaseInit();
		UnitTest.EmailMessageInit(); 
		UnitTest.testBatchData = [ Select Id, Name, T_CaseId__c,T_ExecutingTime__c From BatchData__c 
			Where Object_Id__c =:UnitTest.TestEmailMessage.Id LIMIT 1 ];
		system.assertNotEquals(null,UnitTest.testBatchData.Id);	
		UnitTest.testBatchData.T_ExecutingTime__c = system.now().addMonths( ( -2  ) ); 
		update UnitTest.testBatchData;
    }

    static testmethod void BAT_BatchData_Clean_UpTest() {        
        Test.startTest();
        BAT_BatchData_Clean_Up uca = new BAT_BatchData_Clean_Up();
        Id batchId = Database.executeBatch(uca);
        system.assertEquals(BAT_BatchData_Clean_Up.ClassName,BAT_BatchData_Clean_Up.class.getName());
        Test.stopTest();

        // after the testing stops, assert records were updated properly
      //  System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
    
}