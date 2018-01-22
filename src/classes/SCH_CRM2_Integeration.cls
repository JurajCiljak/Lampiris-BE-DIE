/*
    @Author: Juraj Ciljak
    @CreateDate: 22.10.2017
    @LastModify: 
    @Description: Schedule Batch for CRM2 and SFDC integeration
                  Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-60
    @Version: 1.0.1
*/
global class SCH_CRM2_Integeration implements Schedulable    {
    
    /* Constants */
	public static final String CRON_EXP_FIRST = '0 0 * * * ?';
	public static final String CRON_EXP_SECOND = '0 20 * * * ?';
	public static final String CRON_EXP_THIRD = '0 40 * * * ?';
  	public static final String SCH_JOB_NAME = 'Scheduled CRM2 and Email-To-Case Integeration ';
  	public static final String SCH_JOB_NAME_TEST = 'Scheduled CRM2 and Email-To-Case Integeration Test ';
  	 
 	/**/
 	public static String CRON_SCH_CRM2_INTEGRATION_FIRST_RUN = 'First 20 min.';
 	public static String CRON_SCH_CRM2_INTEGRATION_SECOND_RUN = 'Second 20 min.';
 	public static String CRON_SCH_CRM2_INTEGRATION_THIRD_RUN = 'Third 20 min.';  	
  	
  	global String RunningVersion{get;set;}
  	
  	public static void start( String runVersion ){ 
	    String jobID = '';
	    SCH_CRM2_Integeration wr = new SCH_CRM2_Integeration(); 
	    
	    // This section of code will schedule the execution
	    wr.RunningVersion = runVersion;   
	    String crn_JobName = SCH_CRM2_Integeration.SCH_JOB_NAME + wr.RunningVersion ;   
	    String sch = SCH_CRM2_Integeration.CRON_EXP_FIRST;
	    
	    if( runVersion == CRON_SCH_CRM2_INTEGRATION_SECOND_RUN )
	    	sch = SCH_CRM2_Integeration.CRON_EXP_SECOND;
	    else if( runVersion == CRON_SCH_CRM2_INTEGRATION_THIRD_RUN)
	    	sch = SCH_CRM2_Integeration.CRON_EXP_THIRD;
	   
	    if ( !Test.IsRunningTest() ) crn_JobName = SCH_CRM2_Integeration.SCH_JOB_NAME + wr.RunningVersion ; 
	    else  crn_JobName  = SCH_CRM2_Integeration.SCH_JOB_NAME_TEST + wr.RunningVersion ;     // running test                
	    
	    jobID = system.schedule( crn_JobName , sch, wr); 
	   
    }  
    
   	global void execute(SchedulableContext sc) {
       
        Integer defaulSize = 1000;
        Integer defaulnumberOfMinutes = 20;
        BatchExecute__c bat = BatchExecute.getBatchSettings(BAT_CRM2_Integration.ClassName);       
        if( bat != null && bat.BatchSize__c != null) 
        {
        	defaulSize = Integer.ValueOf(bat.BatchSize__c);
    		defaulnumberOfMinutes = Integer.ValueOf(bat.TimeFrame__c);
        } 
        Id batchId = database.executeBatch(new BAT_CRM2_Integration(system.now(),null,defaulnumberOfMinutes,RunningVersion),defaulSize);
        
   	}    
   
}