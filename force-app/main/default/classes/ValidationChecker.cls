global class ValidationChecker {
    
    Webservice static String checker(ID objectId){
        
        try{
            Schema.SobjectType ConvertType;
            String genericObjectName;
            String objectName='';
            //FIND OUT THE OBJECT NAME
            genericObjectName=objectId.getSObjectType().getDescribe().getName();
            objectName=objectId.getSObjectType().getDescribe().getlabel();
            //CONVERT THE GENERIC OBJECT NAME TO ITS INSTANCE
            ConvertType=Schema.getGlobalDescribe().get(genericObjectName);
            
            list<validation__c> validation;
            String unFilledFields='';
            map<String,String> fieldmap;
            fieldmap=new map<String,String>();
            if(!validation__c.sObjectType.getDescribe().isAccessible()){
                return null;
            }
                validation = new  list<validation__c>([SELECT Id,FieldNames__c,Field_Label__c, Name FROM Validation__c WHERE object__C=:objectName ]);
            
            if(!validation.isEmpty()){
                String validquery='';
                for(validation__c valid:validation){
                    if(Schema.sObjectType.Validation__c.fields.Field_Label__c.isAccessible() && Schema.sObjectType.Validation__c.fields.FieldNames__c.isAccessible()){
                    fieldmap.put(valid.FieldNames__c,valid.Field_Label__c);
                    validquery+=valid.FieldNames__c+',';
                    }
                }
                
                String query='select id, '+validquery.removeEnd(',')+' from ' + genericObjectName + ' where id=\''+ string.escapeSingleQuotes(objectId) +'\' limit 1';
                for(Sobject cs:Database.query(query)){
                    for(validation__c valid:validation){
                        if(cs.get(valid.FieldNames__c)==null ||cs.get(valid.FieldNames__c)==''){
                            unFilledFields+='Please fill the following fields before creating the issue : \n';
                            unFilledFields+='\u2022 '+fieldmap.get(valid.FieldNames__c)+ '\n';
                        }
                    }
                }
            }
            return unFilledFields;
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ValidationChecker','', '', null,null,null, null, null, '', 'ValidationChecker', Error);
            return System.label.Message_Label +ex.getMessage();  
        }
        return null;
    }
    
    
}