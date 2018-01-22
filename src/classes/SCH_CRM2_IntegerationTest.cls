/*
    @Author: Juraj Ciljak
    @CreateDate: 30.10.2017
    @LastModify: 
    @Description: Unit Test class for SCH_CRM2_Integeration
                      Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-601
    @Version: 1.0.1
*/
@isTest
private class SCH_CRM2_IntegerationTest {

    @testSetup 
    static void setup() {
		BatchExecute__c bat = new BatchExecute__c(
			Name = BAT_CRM2_Integration.ClassName,
			BatchSize__c = 1000
		);
		insert bat;
    }
	
	static testMethod void SCH_CRM2_IntegerationTest() {
		Test.startTest();
		SCH_CRM2_Integeration.start( SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN );
		Test.stopTest();
		String crn_JobName  = SCH_CRM2_Integeration.SCH_JOB_NAME_TEST + SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN ;  
		 
		 /* Check in which time frame is the job running */
        List<CronTrigger> lsCron = [SELECT StartTime, PreviousFireTime,NextFireTime,EndTime,CronJobDetailId FROM CronTrigger 
                WHERE CronJobDetailId IN( Select Id From CronJobDetail Where Name =:crn_JobName ) Limit 1 ];
        system.debug(LoggingLevel.Error,'lsCron:'+lsCron);    
        system.assertNotEquals(0,lsCron.size());
		
	}   
}