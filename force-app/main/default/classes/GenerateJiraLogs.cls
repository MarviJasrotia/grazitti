public with Sharing class GenerateJiraLogs {
    @future(callout=true)
    public static void CreateLog(String ClassName,String EndPoint,String Method,String ResStatusCode, String ResBody,String ResStatus, String ReqBody ,String Body,String ReferenceId,String ReqFrom,String OtherDetails){
        JiraErrorLogs__c Error = new JiraErrorLogs__c();
        if(schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isUpdateable()){
            Error.Apex_Class__c=ClassName;
        }
        
        if(ResStatusCode!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isCreateable()
          && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isUpdateable()){  
            Error.Response_Status_Code__c=ResStatusCode;
        }
        if(ResBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable()
          && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c=ResBody;
        }
        if(ResStatus!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isCreateable() 
          && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isUpdateable()){
            Error.Response_Status__c=ResStatus;
        }
        if(ReqBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isUpdateable()){
            Error.Request_Details__c=ReqBody;
        }
        if(Body!=null && ResBody==null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c= Body;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isUpdateable()){
            Error.Request_End_Point__c=EndPoint;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isUpdateable()){
            Error.Request_Method__c=Method;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Name.isCreateable() && 
           schema.sObjectType.JiraErrorLogs__c.fields.Name.isUpdateable()){
               
               Error.Name='Jira';
           }
        if(schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isUpdateable()){
            Error.RecordId__c=ReferenceId;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isUpdateable()){
            Error.Request_From__c=ReqFrom;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isCreateable() &&
           schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isUpdateable()){
               Error.Other_Details__c=OtherDetails;
           }
        if(schema.sObjectType.JiraErrorLogs__c.isCreateable() &&
           schema.sObjectType.JiraErrorLogs__c.isUpdateable()){
            
            Insert Error;
        }
    }
    
    public static void CreateLogRealTime(String ClassName,String EndPoint,String Method,String ResStatusCode, String ResBody,String ResStatus, String ReqBody ,String Body,String ReferenceId,String ReqFrom,String OtherDetails){
        JiraErrorLogs__c Error = new JiraErrorLogs__c();
        if(schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isUpdateable()){
            Error.Apex_Class__c=ClassName;
        }
        
        
        if(ResStatusCode!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isUpdateable()){
            Error.Response_Status_Code__c=ResStatusCode;
        }
        if(ResBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c=ResBody;
        }
        if(ResStatus!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isUpdateable()){
            Error.Response_Status__c=ResStatus;
        }
        if(ReqBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isUpdateable()){
            Error.Request_Details__c=ReqBody;
        }
        if(Body!=null && ResBody==null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable()&&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c= Body;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isUpdateable()){
            Error.Request_End_Point__c=EndPoint;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isCreateable()&&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isUpdateable()){
            Error.Request_Method__c=Method;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Name.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Name.isUpdateable()){
            
            Error.Name='Jira';
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isCreateable()&&
          schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isUpdateable()){
            Error.RecordId__c=ReferenceId;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isCreateable()&&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isUpdateable()){
            Error.Request_From__c=ReqFrom;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isCreateable()&&
          schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isUpdateable()){
            Error.Other_Details__c=OtherDetails;
        }
        if(schema.sObjectType.JiraErrorLogs__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.isUpdateable()){
            
            Insert Error; 
        }
    }
    public static JiraErrorLogs__c CreateJiraLog(String ClassName,String EndPoint,String Method,String ResStatusCode, String ResBody,String ResStatus, String ReqBody ,String Body,String ReferenceId,String ReqFrom,String OtherDetails){
        JiraErrorLogs__c Error = new JiraErrorLogs__c();
        if(schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isUpdateable()){
            Error.Apex_Class__c=ClassName;
        }
        if(ResStatusCode!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isCreateable()  &&
          schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isUpdateable()){
            Error.Response_Status_Code__c=ResStatusCode;
        }
        if(ResBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c=ResBody;
        }
        if(ResStatus!=null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isUpdateable()){
            Error.Response_Status__c=ResStatus;
        }
        if(ReqBody!=null && schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isUpdateable()){
            Error.Request_Details__c=ReqBody;
        }
        if(Body!=null && ResBody==null && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isUpdateable()){
            Error.Response_Details__c= Body;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isUpdateable() ){
            if(EndPoint==null || EndPoint==''){
                Error.Request_End_Point__c=EndPoint;
            }else{
                Error.Request_End_Point__c=EndPoint.length()>255?EndPoint.substring(0,255):Endpoint;
                
            }
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isUpdateable()){
            Error.Request_Method__c=Method;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Name.isCreateable() &&
           schema.sObjectType.JiraErrorLogs__c.fields.Name.isUpdateable() ){
            
            Error.Name='Jira';
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isUpdateable()){
            Error.RecordId__c=ReferenceId;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isCreateable() &&
          schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isUpdateable()){
            Error.Request_From__c=ReqFrom;
        }
        if(schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isUpdateable() && 
           schema.sObjectType.JiraErrorLogs__c.fields.Other_Details__c.isCreateable()){
            Error.Other_Details__c=OtherDetails;
        } 
        
        return Error; 
    }
}