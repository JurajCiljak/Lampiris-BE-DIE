/*
    @Author: Juraj Ciljak
    @CreateDate: 25.10.2017
    @LastModify: 
    @Description: Schedule Batch for CRM2 and SFDC integeration
                  Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-60
    @Version: 1.0.1
*/ 
global class SCH_BatchData_Clean_Up implements Schedulable    {
    
	public static final String CRON_EXP = '0 0 23 1 * ?';
  	public static final String SCH_JOB_NAME = 'Scheduled Clean Up Batch Data';
  	public static final String SCH_JOB_NAME_TEST = 'Scheduled Clean Up Batch Data Test';
  	
   	
  	public static void start(){
	    
	    SCH_BatchData_Clean_Up wr = new SCH_BatchData_Clean_Up(); 
	    
	    String crn_JobName = SCH_BatchData_Clean_Up.SCH_JOB_NAME ;   
	    String sch = SCH_BatchData_Clean_Up.CRON_EXP;
	    String jobID = '';
	    
	    if (Test.IsRunningTest() ) crn_JobName  = SCH_BatchData_Clean_Up.SCH_JOB_NAME_TEST;     // running test                
	    jobID = system.schedule( crn_JobName , sch, wr); 
	      
	   
    }
   
   	global void execute(SchedulableContext sc) {
       
        Integer defaulSize = 1000;
        Integer defaulnumberOfMinutes = null;
        BatchExecute__c bat = BatchExecute.getBatchSettings(BAT_BatchData_Clean_Up.ClassName);       
        if( bat != null && bat.BatchSize__c != null)
        {
        	defaulSize = Integer.ValueOf(bat.BatchSize__c);
    		defaulnumberOfMinutes = Integer.ValueOf(bat.TimeFrame__c);
        }
        Id batchId = database.executeBatch(new BAT_BatchData_Clean_Up(),defaulSize);
        
       
   	}    
   	
   	
  
  
   
}