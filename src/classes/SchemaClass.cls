/**
    * @Author: Juraj Ciljak
    * @Created: 13.10.2017
    * @Description: Class for getting API name of the object
    * @LastModify: 
    * --------------------------------------------------
*/ 
public without sharing class SchemaClass {
 
    
    
    public static String getFields(String ObjectName,Boolean standardFields)
    {
        String Result = '';
        String stdFields = ' | OwnerId | IsDeleted | CurrencyIsoCode | CreatedDate | CreatedById | ';
        stdFields += 'LastModifiedDate | LastModifiedById | SystemModstamp | LastViewedDate | LastActivityDate |';
        stdFields +=' LastReferencedDate |';
        String fieldName = '';
        try{
            if( !String.isEmpty(ObjectName))
            {
                Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                Schema.SObjectType sobjType = gd.get(ObjectName); 
                Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
                Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
                Schema.SObjectField field;
                for(String   key: fieldsMap.keySet())
                {
                    field = fieldsMap.get(key);
                    fieldName = String.valueOf(field); 
                    if( !standardFields  && stdFields.containsIgnoreCase('| '+fieldName+' |') ){}
                    else
                    	Result +=  fieldName+ ' , ';
                }
                Result = Result.removeEnd(', ');
                
            }
            return Result;
        }catch(Exception E)
        {
            //TODO some Error handling
            return '';
        }
    }
    
    public static String getObjectTypeFromId( Id oId )
    {
    	String Result = '';
    	if( !String.isEmpty( oId)) Result = oId.getSObjectType().getDescribe().getName();
    	return Result;	
    }
    
    public static String getObjectName( Schema.SObjectType sObjType )
    {
    	String Result;
    	Result = sObjType.getDescribe().getName();
    	return Result;
    }
}