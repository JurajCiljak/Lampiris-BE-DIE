/*
        @Author: Juraj Ciljak
        @CreateDate: 10.10.2016
        @LastModify:
        @Description: Class designe for batch size for jobs
        @Version: 1.0.1
*/


global class BatchExecute {
   
    public static BatchExecute__c getBatchSettings(String batchName)
    {
    	BatchExecute__c Result = BatchExecute__c.getInstance(batchName);
		return Result;
    		
    }
    
    
}