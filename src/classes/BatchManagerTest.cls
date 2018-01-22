/*
    @ Author: Juraj Ciljak
    @ Description: Test class stored helper function for generate records in Unit Test
    @ CreatedDate: 24.07.2017
    @ LastModify:
    @ Notes:  
    @ Version: 1.0.1
*/
@isTest
public with sharing class BatchManagerTest extends BatchManager.BatchHandler{

	/* Constructor*/
 	public BatchManagerTest()
    {
        super( BatchManagerTest.class.getName(), BatchData__c.sObjectType);          
    } 
    
	@isTest(SeeAllData=true) // SeeAllData beacuse Custom Settings
    static void myBatchManagerTest() {
    	
    	Test.startTest();
    	SystemLog sysLog = new SystemLog(false, false, true, false);
        Map<String,List<sObject>> oDataContainer = new Map<String,List<sObject>>();
    	BatchManagerTest hndl_CRM2 = new BatchManagerTest(); 
    	
    	hndl_CRM2.setBasicAttributes( false,true,false, oDataContainer, sysLog); 
    	
    	/* Testing Execute */
    	BatchManager.createHandler(
            BatchManagerTest.class,hndl_CRM2);                               
        
        BatchManagerTest hndl_CRM2_test;
        
        /* Testing Null Handler  */
        BatchManager.createHandler(
            BatchManagerTest.class,hndl_CRM2_test);         
        system.assertEquals(null,hndl_CRM2_test);
        
        /* Testing Start */
        hndl_CRM2.setBasicAttributes( true, false ,false, oDataContainer, sysLog); 
        BatchManager.createHandler(
            BatchManagerTest.class,hndl_CRM2);  
        
        /* Testing Start */
        hndl_CRM2.setBasicAttributes( false, false ,true, oDataContainer, sysLog); 
        BatchManager.createHandler(
            BatchManagerTest.class,hndl_CRM2);  
        
        system.assertEquals(0,sysLog.Logs.size());            
    	Test.stopTest();
    	
    	
    }    
}