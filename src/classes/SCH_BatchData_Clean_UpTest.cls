/*
    @Author: Juraj Ciljak
    @CreateDate: 30.10.2017
    @LastModify: 
    @Description: Unit Test class for SCH_CRM2_Integeration
                      Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-601
    @Version: 1.0.1
*/
@isTest
private class SCH_BatchData_Clean_UpTest {


    @testSetup 
    static void setup() {
		BatchExecute__c bat = new BatchExecute__c(
			Name = BAT_BatchData_Clean_Up.ClassName,
			BatchSize__c = 1000
		);
		insert bat;
    }
	
	static testMethod void SCH_BatchData_Clean_UpTest() {
		Test.startTest();
		SCH_BatchData_Clean_Up.start();
		Test.stopTest();
		String crn_JobName  = SCH_BatchData_Clean_Up.SCH_JOB_NAME_TEST ;  
		 
		 /* Check in which time frame is the job running */
        List<CronTrigger> lsCron = [SELECT StartTime, PreviousFireTime,NextFireTime,EndTime,CronJobDetailId FROM CronTrigger 
                WHERE CronJobDetailId IN( Select Id From CronJobDetail Where Name =:crn_JobName ) Limit 1 ];
        system.assertNotEquals(0,lsCron.size());
		
	}   
}