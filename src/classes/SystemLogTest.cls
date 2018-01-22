/*
    @ Author: Juraj Ciljak
    @ Description: Class for display message on the page and log to the Custom Object
    @ CreatedDate: 27.07.2017
    @ LastModify:  
    @ Notes:  
    @ Version: 1.0.1 
*/
@isTest
private class SystemLogTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        SystemLog sysLog = new SystemLog(false, false, true, false);
        sysLog.addLog( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
								String.valueOf(''),'?',0,ApexPages.severity.ERROR ) , null);	
								
		sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
			String.valueOf(''),'?',0,ApexPages.severity.INFO ) , null, true );	
			
		sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
			String.valueOf(''),'?',0,ApexPages.severity.CONFIRM ) , null, true );		
		
		sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
			String.valueOf(''),'?',0,ApexPages.severity.WARNING ) , null, true );		
				
		sysLog.checkInsertLog();
		
		sysLog = new SystemLog(false, true, true, false);
		sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
			String.valueOf(''),'?',0,ApexPages.severity.WARNING ) , null, true );		
			
			
		sysLog = new SystemLog(false, false, true, false);
		sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
			String.valueOf(''),'?',0,ApexPages.severity.WARNING ) , null, true );		
				
			
		try{
			sysLog = new SystemLog(false, false, true, true);
       	 	sysLog.addLog( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
									String.valueOf(''),'?',0,ApexPages.severity.ERROR ) , null );	
		}catch(Exception E)
		{
			sysLog.addLogNoThrow( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf(E),  
				'','?',0,ApexPages.severity.FATAL ) , null, true )	;
		}
		
		String sValue = SystemLog.ClassName;
		sysLog.checkInsertLog();
		
		
		SystemLog.SystemLogMessage( SystemLog.getSystemLog( 'SystemLogTest','myUnitTest', String.valueOf('Hello mister'),  
									String.valueOf(''),'?',0,ApexPages.severity.ERROR ) ,null, false, false, true, false );
		
		Lead ld = new Lead();
		List<Lead> lsLead = new List<Lead>();
		lsLead.Add(ld);
		Database.SaveResult [] sr = Database.insert(lsLead,false);
		String err = '';
		for( Database.SaveResult sv: sr )
		{
			err = SystemLog.getLogMessageFromSaveError( sv );
		}
		system.assertNotEquals(null,err);
		system.assertNotEquals('',err);
		
		Database.UpsertResult [] svu;

        Test.stopTest();
    }
    
    static testMethod void myCheckSaveLog() {
        // TO DO: implement unit test
        Test.startTest();
        SystemLog sysLog = new SystemLog(false, false, false, false);
        TST_UtilityClass.TestUtilityWrapperClass utilityTest = new TST_UtilityClass.TestUtilityWrapperClass();
        utilityTest.MainInit(true);
		utilityTest.AccountReferenceInit();
		
		List<Account> lsAccount = new List<Account>();
		Account acc = new Account();//TST_UtilityClass.TST_UtilityClass.createTestAccount('Account X','0474123496',null); 
		lsAccount.Add(acc);
		Database.UpsertResult [] sr = Database.upsert(lsAccount,false); // There will be error in the result for testing function below
		String sValue = '';
		for( Database.UpsertResult sv: sr )
		{
			sValue = SystemLog.getLogMessageFromSaveError( sv );
		}
		
		Boolean bValue = sValue.contains('STATUS');
		system.assertEquals(bValue, true);
		
		
		SystemLog.checkUpsertResult( String.ValueOf( Account.SObjectType) , sr, lsAccount, sysLog );
		
		List<Account_Reference__c> lsAccountRef = new List<Account_Reference__c>();
		Account_Reference__c accRef = new Account_Reference__c();
		lsAccountRef.Add(accRef);
		sr = Database.upsert(lsAccountRef,false); // There will be error in the result for testing function below
		
		
		SystemLog.checkUpsertResult( String.ValueOf( Account_Reference__c.SObjectType) , sr, lsAccountRef, sysLog );
		
        Test.stopTest();
    }
    
}