/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Test class for HNDL_Case
                  Task: SFBECASE-113 - https://jira.lampiris.be/browse/SFBECASE-113  
    @Version: 1.0.1
*/
@isTest
private class HLPR_CaseServiceTest {

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

    @isTest
    static  void testRemoveAccountLinkToCase() {
        Test.startTest();
        UnitTest.CPAS_EmailAddressInit();
        List<Case> lsCase = new List<Case>();
        Case cs;
        cs = TST_UtilityClass.createTestCase( UnitTest.TestAccountReference,UnitTest.testUser );
        cs.SuppliedEmail='tst@tst.com';
        cs.C_Account_Reference__c = null;

        system.assert(cs.AccountId!=null);
        lsCase.Add(cs);
        insert lsCase;
        HNDL_Case.setFirstRun(true);
        Set<Id> caseIds=new Set<Id>();
        for (Case aCase : lsCase) {
            caseIds.add(cs.Id);
        }
        System.debug('Linked account is:'+cs.AccountId);
        List<Case> caseResultList= [ SELECT Id, AccountId FROM Case WHERE Id in :caseIds];

        for (Case caseResult : caseResultList) {
            System.debug('Case '+ caseResult.Id +' inserted linked to account :'+caseResult.AccountId);
            system.assert(caseResult.Id!=null);
            system.assertEquals(null,caseResult.AccountId);
        }

        Test.stopTest();

    }

    @isTest
    static  void testLinkAccountToCase() {
        Test.startTest();
        List<Case> lsCase = new List<Case>();
        Case cs;
        cs = TST_UtilityClass.createTestCase( UnitTest.TestAccountReference,UnitTest.testUser );
        cs.C_Account_Reference__c = null;

        system.assert(cs.AccountId!=null);
        lsCase.Add(cs);
        insert lsCase;
        HNDL_Case.setFirstRun(true);
        Set<Id> caseIds=new Set<Id>();
        for (Case aCase : lsCase) {
            caseIds.add(cs.Id);
        }
        System.debug('The Account Linked is:'+cs.AccountId);
        List<Case> caseResultList= [ SELECT Id, AccountId FROM Case WHERE Id in :caseIds];

        for (Case caseResult : caseResultList) {
            System.debug('Case '+ caseResult.Id +' inserted linked to account :'+caseResult.AccountId);
            system.assert(caseResult.Id!=null);
            system.assertEquals(cs.AccountId,caseResult.AccountId);
        }

        Test.stopTest();

    }

    static testMethod void HLPR_CaseServiceTest() {
        
        Test.startTest();
        BatchData__c bd2;
        List<Case> lsCase = new List<Case>();
        List<Case> lsUpdateCase = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        Case cs;
        cs = TST_UtilityClass.createTestCase( UnitTest.TestAccountReference,UnitTest.testUser );
        cs.C_Account_Reference__c = null;
    	lsCase.Add(cs);
        
        
        insert lsCase;
        HNDL_Case.setFirstRun(true);
        for( Case csUp: lsCase)
        {
        	csUp.Status = Constants.CASE_STATUS_RE_OPENED;
        	setCaseId.Add(csUp.Id);
        	lsUpdateCase.Add(csUp); 
        }
        
        update lsUpdateCase;
        
        List<BatchData__c > updateBatch = new List<BatchData__c >();
        List<BatchData__c > lsBatch = [Select Id,T_ExecutingTime__c From BatchData__c Where Object_Id__c IN:setCaseId ];
        
        
        system.assertEquals(lsBatch.Size(),lsUpdateCase.size());
        
        for( BatchData__c bd : lsBatch)
        {
        	bd.T_ExecutingTime__c = system.now() - 10000; 
        	updateBatch.Add( bd );
        	//system.assertNotEquals( bd2.T_ExecutingTime__c, bd.T_ExecutingTime__c);
        }
        
        update updateBatch;
        
        lsBatch = [Select Id,T_ExecutingTime__c From BatchData__c Where Object_Id__c IN:setCaseId ];
        system.debug(LoggingLevel.Error,'lsBatch:'+lsBatch);
        cs.C_Account_Reference__c = UnitTest.TestAccountReference.Id;
        
		update cs;
		
	    /* Testing if T_ExecutingTime__c field was changed */
	    Map<Id,BatchData__c > MapBatch = new Map<Id,BatchData__c >([Select Id,T_ExecutingTime__c 
	    	From BatchData__c Where Object_Id__c IN:setCaseId ]);
	    system.debug(LoggingLevel.Error,'MapBatch:'+MapBatch);	
        for( BatchData__c bd : lsBatch)
        {
        	bd2 = MapBatch.get( bd.Id );
        	system.assertNotEquals( bd2.T_ExecutingTime__c, bd.T_ExecutingTime__c);
        }
        
        system.assertEquals(HLPR_CaseService.ClassName,HLPR_CaseService.class.getName());
        
        Test.stopTest();
        
    }
    
   
}