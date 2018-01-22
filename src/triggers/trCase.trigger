/*
	@Author: Juraj Ciljak
	@CreateDate: 21.10.2017
	@LastModify: 
	@Description: Trigger Case 
				  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
	@Version: 1.0.1
*/
trigger trCase on Case (after insert, after undelete, after update, before insert, before update) {
	TriggerManager.createHandler(HNDL_Case.class);  
}