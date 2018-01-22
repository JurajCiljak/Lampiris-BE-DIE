/*
    @Author: Juraj Ciljak
    @CreateDate: 22.10.2017
    @LastModify: 
    @Description: Trigger Case 
                  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/

trigger trAttachment on Attachment (after insert, after update) {
    TriggerManager.createHandler(HNDL_Attachment.class);        
}