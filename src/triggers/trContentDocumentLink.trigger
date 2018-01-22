trigger trContentDocumentLink on ContentDocumentLink (after insert) {
	TriggerManager.createHandler(HNDL_ContentDocumentLink.class);     
}