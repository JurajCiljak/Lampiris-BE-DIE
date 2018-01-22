/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Test class for HNDL_Case
                  Task:  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
@isTest
private class HNDL_CaseTest {

	public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;} 
	
	public static final Integer NUMBER_OF_CASES = 15;
	
	@testSetup 
    static void setup() {
	
    }
    
	static {
	    UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
		UnitTest.AccountReferenceInit();
		UnitTest.CaseInit();
		
		UnitTest.TestCase.Status = Constants.CASE_STATUS_RE_OPENED;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
		UnitTest.EmailMessageInit(); 
		
		UnitTest.testBatchData = [ Select Id, Name, T_CaseId__c,T_ExecutingTime__c From BatchData__c 
			Where Object_Id__c =:UnitTest.TestCase.Id LIMIT 1 ];
		system.assertNotEquals(null,UnitTest.testBatchData);
		
	}

    static testMethod void HNDL_CaseTest() {
        
        Test.startTest();
        List<Case> lsCase = new List<Case>();
        List<Case> lsUpdateCase = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        Case cs;
        for( integer i = 1 ;i < NUMBER_OF_CASES; i++ ) 
        {
        	cs = TST_UtilityClass.createTestCase( UnitTest.TestAccountReference,UnitTest.testUser );
        	lsCase.Add(cs);
        }
        
        insert lsCase;
        HNDL_Case.setFirstRun(true);
        for( Case csUp: lsCase)
        {
        	csUp.Status = Constants.CASE_STATUS_RE_OPENED;
        	setCaseId.Add(csUp.Id);
        	lsUpdateCase.Add(csUp); 
        }
        
        update lsUpdateCase;
        /*
        List<BatchData__c > lsBatch = [Select Id From BatchData__c Where Object_Id__c IN:setCaseId ];
        system.assertEquals(lsBatch.Size(),lsUpdateCase.size());
        
        delete lsUpdateCase;
        undelete lsUpdateCase;
        
        UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_SUPPORT;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
		
	    UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_CUSTOMER;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
        
        HNDL_Case.setFirstRun( true );
		HNDL_Case.isFirstRun(); 
		HNDL_Case.setFirstRunFalse();     */
        Test.stopTest();
        
    }
    
    static testMethod void HNDL_CaseTestDelete() {
        
        Test.startTest();
        List<Case> lsCase = new List<Case>();
        List<Case> lsUpdateCase = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        Case cs;
        for( integer i = 1 ;i < NUMBER_OF_CASES; i++ ) 
        {
        	cs = TST_UtilityClass.createTestCase( UnitTest.TestAccountReference,UnitTest.testUser );
        	lsCase.Add(cs);
        }
        
        insert lsCase;
        
        
        List<BatchData__c > lsBatch = [Select Id From BatchData__c Where Object_Id__c IN:setCaseId ];
        system.assertEquals(lsBatch.Size(),lsUpdateCase.size());
        
        delete lsUpdateCase;
        undelete lsUpdateCase;
        /*
        UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_SUPPORT;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
		
	    UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_CUSTOMER;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
        
        HNDL_Case.setFirstRun( true );
		HNDL_Case.isFirstRun(); 
		HNDL_Case.setFirstRunFalse();     */
        Test.stopTest();
        
    }
    
     static testMethod void HNDL_CaseTestStatusChange() {
        
        Test.startTest();
        List<Case> lsCase = new List<Case>();
        List<Case> lsUpdateCase = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        Case cs;
       
        UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_SUPPORT;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
		
	    UnitTest.TestCase.Status = Constants.CASE_STATUS_ON_HOLD_CUSTOMER;
		HNDL_Case.setFirstRun(true);
		update UnitTest.TestCase;
        
        HNDL_Case.setFirstRun( true );
		HNDL_Case.isFirstRun(); 
		HNDL_Case.setFirstRunFalse();     
        Test.stopTest();
        
    }
}