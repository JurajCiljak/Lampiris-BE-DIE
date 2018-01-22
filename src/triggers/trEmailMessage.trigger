/*
    @Author: Juraj Ciljak
    @CreateDate: 20.10.2017
    @LastModify: 
    @Description: Trigger EmailMessage 
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-115
    @Version: 1.0.1
*/
trigger trEmailMessage on EmailMessage (before insert,after insert, after undelete, after update) {
    TriggerManager.createHandler(HNDL_EmailMessage.class);     
}