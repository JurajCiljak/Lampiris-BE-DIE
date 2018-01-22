/*
	@Author: Juraj Ciljak
	@CreateDate: 24.07.2017
	@LastModify: 
	@Description: This code resides from Developers' generic Toolbox and has been developped outside scope of a specific project.
	@Version: 1.0.1
*/

global class TriggerManager {
    private static System.LoggingLevel logLevel = LoggingLevel.INFO;
    public enum triggerEventType { AfterDelete, AfterInsert, AfterUndelete, AfterUpdate, BeforeDelete, BeforeInsert, BeforeUpdate }

    private static TriggerManager.ITriggerHandler getHandler(Type t) {
        if (t == null) return null;
 
        // Instantiate the type
        Object o = t.newInstance();

        // if its not an instance of ITrigger return null
        if (!(o instanceOf TriggerManager.ITriggerHandler)) return null;

        return (TriggerManager.ITriggerHandler)o;
    }

    // Public static method to create and execute a trigger handler
    public static void createHandler(Type handlerType) {
        TriggerManager.ITriggerHandler handler = getHandler(handlerType);
        if (handler == null) throw new TriggerException('Not a valid Trigger Handler: ' + handlerType);
        execute(handler);
    }

    // controls the execution of the handler. Arguments: ITriggerHandler handler (Trigger Handler to execute)
    private static void execute(TriggerManager.ITriggerHandler handler) {
        if (Trigger.isBefore) {
            if (Trigger.isDelete)
                handler.bulkBefore(Trigger.Old, Trigger.oldMap, Trigger.newMap); // gather data required into sets/maps, prior execution of the BEFORE trigger
            else
                handler.bulkBefore(Trigger.New, Trigger.oldMap, Trigger.newMap);
        } else {
            if (Trigger.isDelete)
                handler.bulkAfter(Trigger.Old, Trigger.oldMap, Trigger.newMap); // gather data required into sets/maps, prior execution of the AFTER trigger
            else
                handler.bulkAfter(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
        
        handler.andFinally(); // Perform any post processing. Eg. DML operations on other objects.
        logFinally(); // Alway show this logmessage after processing trigger.
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

    // Virtual class ITriggerHandler, 'TriggerHandler' implements this interface, all sObject handlers extend the TriggerHandler class
    public interface ITriggerHandler {
        void bulkBefore(List<sObject> lst, Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void bulkAfter(List<sObject> lst, Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void beforeInsert(SObject so);
        void beforeUpdate(SObject oldSo, SObject so);
        void beforeDelete(SObject so);
        void afterInsert(SObject so);
        void afterUpdate(SObject oldSo, SObject so);
        void afterDelete(SObject so);
        void afterUndelete(SObject so);
        void andFinally();
    }

    public virtual class TriggerHandler implements ITriggerHandler {

        public String instanceName;
        public triggerEventType hndlEvent;
        public Schema.sObjectType recType;

        public TriggerHandler(String instance_Name, Schema.sObjectType soType) {
            this.instanceName = instance_Name;
            this.recType = soType;
            initLogs();
        }

        private void initLogs() {
            if (Trigger.isExecuting) {
                integer triggersize = trigger.new != null ? trigger.new.size() : trigger.old.size();
                if      (Trigger.isInsert && Trigger.isBefore)  hndlEvent = triggerEventType.BeforeInsert;
                else if (Trigger.isInsert && Trigger.isAfter)   hndlEvent = triggerEventType.AfterInsert;
                else if (Trigger.isUpdate && Trigger.isBefore)  hndlEvent = triggerEventType.BeforeUpdate;
                else if (Trigger.isUpdate && Trigger.isAfter)   hndlEvent = triggerEventType.AfterUpdate;
                else if (Trigger.isDelete && Trigger.isBefore)  hndlEvent = triggerEventType.BeforeDelete;
                else if (Trigger.isDelete && Trigger.isAfter)   hndlEvent = triggerEventType.AfterDelete;
                else if (Trigger.isundelete)                    hndlEvent = triggerEventType.AfterUndelete;

                system.debug(LoggingLevel.Info,' Trigger event: ' + hndlEvent.Name() + ' / No. records: ' + triggersize );
               // if (TriggerManagerConfig.showTriggerDataInDebug)
                {
                	system.debug(LoggingLevel.Info,'Trigger.new:' + Trigger.new );
                	system.debug(LoggingLevel.Info,'Trigger.newMap ' + Trigger.newMap );
                	system.debug(LoggingLevel.Info,'Trigger.old: ' + Trigger.old );
                	system.debug(LoggingLevel.Info,'Trigger.oldMap ' + Trigger.oldMap );
                }
            } else {
                // used for testing purposes
                hndlEvent = triggerEventType.BeforeInsert;
            }
        }

        // virtual method templates
        public virtual void bulkBefore(List<sObject> lst, Map<Id, sObject> oldMap, Map<Id, sObject> newMap)   {
            system.debug(LoggingLevel.Info,'Entered bulkBefore');
        }
        
        public virtual void bulkAfter(List<sObject> lst, Map<Id, sObject> oldMap, Map<Id, sObject> newMap)    {
            system.debug(LoggingLevel.Info,'Entered bulkAfter');
        }
               
        public virtual void beforeInsert(SObject so){}	// TO DO
                
        public virtual void beforeUpdate(SObject oldSo, SObject so){} // TO DO
        
        public virtual void beforeDelete(SObject so){}	// TO DO
        
        public virtual void afterInsert(SObject so){}	// TO DO
        
        public virtual void afterUpdate(SObject oldSo, SObject so){}	// TO DO
        
        public virtual void afterDelete(SObject so){}	// TO DO
        
        public virtual void afterUndelete(SObject so){}	// TO DO
        
        public virtual void andFinally() {}
    }

    public class TriggerException extends Exception {}
}