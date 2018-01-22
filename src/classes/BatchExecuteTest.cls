/*
    @ Author: 		Juraj Ciljak
    @ Description:	Test Class for BatchExecuteTest
    @ CreatedDate:	10.10.2016
    @ LastModify:	Juraj :  
    @ Notes:  		
*/
@isTest
public with sharing class BatchExecuteTest {
    
    @testSetup 
    static void setup() {
		BatchExecute__c bat = new BatchExecute__c(
			Name = 'BAT_CRM2_Integration',
			BatchSize__c = 20
		);
		insert bat;
    }
    
    static testMethod void BatchExecuteTest()
	{
	 	Integer defaulSize = null;
	 	BatchExecute__c bat = BatchExecute.getBatchSettings('BAT_CRM2_Integration');       
        if( bat != null && bat.BatchSize__c != null) defaulSize = Integer.ValueOf(bat.BatchSize__c);        
        system.assertNotEquals(defaulSize,null);
        
        
        defaulSize = null;
	 	bat = BatchExecute.getBatchSettings('BAT_CRM2_Integration');       
        if( bat != null && bat.BatchSize__c != null) defaulSize = Integer.ValueOf(bat.BatchSize__c);
        system.assertNotEquals(defaulSize,null);
	
	}
    
    
}