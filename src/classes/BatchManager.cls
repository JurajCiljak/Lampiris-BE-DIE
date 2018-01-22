/*
	@Author: Juraj Ciljak
	@CreateDate: 24.07.2017
	@LastModify: 
	@Description: This code resides from Developers' generic Toolbox and has been developped outside scope of a specific project.
	@Version: 1.0.1
*/


global class BatchManager {
    private static System.LoggingLevel logLevel = LoggingLevel.INFO;
    public enum BatchEventType { Start, Execute, Finish }

    private static BatchManager.BatchHandler getHandler(Type t) {
        if (t == null) return null;
 
        // Instantiate the type
        Object o = t.newInstance();

        // if its not an instance of IBatch return null
        if (!(o instanceOf BatchManager.IBatchHandler)) return null;

        return (BatchManager.BatchHandler)o;
    }

    // Public static method to create and execute a Batch handler
    public static void createHandler(Type handlerType, BatchManager.BatchHandler handler ) {
        if (handler == null) handler = getHandler(handlerType);
        if (handler == null) throw new BatchException('Not a valid Batch Handler: ' + handlerType);

   //     system.debug(LoggingLEvel.Error,'batch:'+batch);
        execute(handler);
    }

    // controls the execution of the handler. Arguments: IBatchHandler handler (Batch Handler to execute)
    private static void execute(BatchManager.BatchHandler handler) {
        if( handler != null )
        {
	        if (handler.isStart) {
	            handler.start(handler.oData); // gather data required into sets/maps, prior execution of the BEFORE Batch
	        }
	        else if (handler.isExecute) {
	            handler.execute();
	
	        }else if (handler.isFinish) {
	            handler.finish(handler.oData);
	
	        }
        }   
        handler.andFinally(); // Perform any post processing. Eg. DML operations on other objects.
        logFinally(); // Alway show this logmessage after processing Batch.
    }
    
    public static void logFinally()
    {
    	
    	String s = '\n################################################################';
    	s += '\n## LIMITS';
    	s += '\n################################################################';
    	s += '\n## Total SOQL Queries used: '+Limits.getQueries().format()          +' of '+Limits.getLimitQueries().format()+' allowed. ';
    	s += '\n## Total CPU used: '+Limits.getCpuTime().format() + ' of ' + Limits.getLimitCpuTime().format() + ' allowed.'  ;
    	s += '\n################################################################';
    	system.debug(LoggingLevel.Info,s);
    }

    // Virtual class IBatchHandler, 'BatchHandler' implements this interface, all sObject handlers extend the BatchHandler class
    public interface IBatchHandler {
        
        void finish(List<sObject> oData);
        void execute( );
        void start(List<sObject> oData);
       
        void andFinally(); 
    }
	
	 
    public virtual class BatchHandler implements IBatchHandler {
		public Boolean isExecuting ;
		public Boolean IsFinish	{get;set;}
		public Boolean IsExecute{get;set;}
		public Boolean IsStart{get;set;}
		public List<sObject> oData{get;set;}
		public Map<String,List<sObject>> oDataContainer{get;set;}  
        public String instanceName;
        public BatchEventType hndlEvent;
        public Schema.sObjectType recType;
		public SystemLog SysLog {get;set;}
        public BatchHandler(String instance_Name, Schema.sObjectType soType) {
            this.instanceName = instance_Name;
            this.recType = soType;
    		this.isExecuting = false;
			this.isFinish = false;
			this.isExecute = false;
			this.isStart = true;
            this.initLogs();
        }
		
		public virtual void setBasicAttributes( Boolean isStart, Boolean isExecute, Boolean isFinish, Map<String,List<sObject>> odataContainer,
			SystemLog sysLog )
		{
			this.IsFinish = isFinish;
			this.IsExecute = isExecute;
			this.IsStart = isStart;	
			this.SysLog = sysLog;
			this.oDataContainer = odataContainer;
		}
		
        private void initLogs() {
      		if (this.isFinish)  hndlEvent = BatchEventType.Finish;
            else if (this.isExecute)   hndlEvent = BatchEventType.Execute;
            else if (this.isStart)  hndlEvent = BatchEventType.Start;
           
          
        }

        // virtual method templates
        public virtual void finish(List<sObject> oData)   {           
        }
        
        public virtual void execute()    {
             
        }
        
        public virtual void start(List<sObject> oData){
        	// TO DO
        }
        
     
        
        public virtual void andFinally() {}
    }

    public class BatchException extends Exception {}
}