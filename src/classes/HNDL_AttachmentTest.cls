/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Test class for HNDL_Case
                  Task:  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
@isTest
private class HNDL_AttachmentTest {

    public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;} 
	
	@testSetup 
    static void setup() {
	
    }
    
	static {
	    UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
		UnitTest.AccountReferenceInit();
		UnitTest.CaseInit();
		
		UnitTest.TestCase.Status = Constants.CASE_STATUS_RE_OPENED;
		update UnitTest.TestCase;
		UnitTest.EmailMessageInit(); 
		UnitTest.AttachmentInit();
		UnitTest.testBatchData = [ Select Id, Name, T_CaseId__c,T_ExecutingTime__c From BatchData__c 
			Where Object_Id__c =:UnitTest.testAttachment.Id LIMIT 1 ];
		system.assertNotEquals(null,UnitTest.testAttachment);
		
	}

    static testMethod void HNDL_AttachmentTest() {
        Test.startTest();
        List<Attachment> lsAtt = new List<Attachment>();
        List<Attachment> lsUpdateAtt = new List<Attachment>();
        Set<Id> setAttId = new Set<Id>();
        Attachment att;
        for( integer i = 1 ;i < 20; i++ )
        {
        	att = TST_UtilityClass.createTestAttachemnt( UnitTest.testEmailMessage.Id );
        	lsAtt.Add(att);
        }
        
        insert lsAtt;
        
        for( Attachment attUp: lsAtt)
        {
        	//attUp.Status = Constants.CASE_STATUS_RE_OPENED;
        	setAttId.Add(attUp.Id);
        	lsUpdateAtt.Add(attUp); 
        }
        
        update lsUpdateAtt;
        
        List<BatchData__c > lsBatch = [Select Id From BatchData__c Where Object_Id__c IN:setAttId ];
        system.assertEquals(lsBatch.Size(),lsUpdateAtt.size());
        
        delete lsUpdateAtt;
        undelete lsUpdateAtt;
        
        HNDL_Attachment.setFirstRun( true );
		HNDL_Attachment.isFirstRun();  
		HNDL_Attachment.setFirstRunFalse();     
        Test.stopTest();
        
    }
}