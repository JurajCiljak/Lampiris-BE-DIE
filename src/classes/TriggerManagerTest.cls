/*
	@Author: Juraj Ciljak
	@CreateDate: 24.07.2017
	@LastModify: 
	@Description: This code resides from Developers' generic Toolbox and has been developped outside scope of a specific project.
	@Version: 1.0.1
*/

/*
	@Author: Juraj Ciljak
	@CreateDate: 24.07.2017
	@LastModify: 
	@Description: Test class for TriggerManage
	@Version: 1.0.1 
*/
@isTest  
private with sharing class TriggerManagerTest  extends TriggerManager.TriggerHandler{
    
    public TriggerManagerTest() {
         super('TriggerManagerTest', Account.sObjectType);
    }
    
    static testMethod void TriggerManagerTest() {
    	Test.startTest();
    	TriggerHandler trg_HNDL = new TriggerHandler( 'TriggerManagerTest', Account.sObjectType );
    	trg_HNDL.bulkBefore( new List<sObject>(), new Map<Id, sObject>(), new Map<Id, sObject> ());
    	trg_HNDL.bulkAfter( new List<sObject>(), new Map<Id, sObject>(), new Map<Id, sObject> ());
    	Account acc = new Account();     
        trg_HNDL.beforeInsert(acc);
        
        trg_HNDL.beforeUpdate(acc,acc);
        trg_HNDL.beforeDelete(acc);
        trg_HNDL.afterInsert(acc);
        trg_HNDL.afterUpdate(acc,acc);
        trg_HNDL.afterDelete(acc);
        trg_HNDL.afterUndelete(acc);
        trg_HNDL.andFinally();
    	Test.stopTest();	
    
    }
}