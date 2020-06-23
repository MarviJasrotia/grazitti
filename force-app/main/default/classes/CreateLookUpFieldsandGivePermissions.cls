global with Sharing class CreateLookUpFieldsandGivePermissions implements Database.Batchable<sObject>,  Database.AllowsCallouts,Database.Stateful{
    public set<string> sfObjects = new set<string>();
    public string sessionId;
    String query='';
    String nameSpace ='';
    public list<string> fieldList = new list<string>();
    
    public CreateLookUpFieldsandGivePermissions(set<String> sfObjects,string sessionId,list<string> fieldList){
        
        this.sfObjects = sfObjects;
        this.sessionId = sessionId;
        this.fieldList = fieldList;
        
        nameSpace = '';
        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
        
        if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){
            nameSpace = ThisOrg[0].NameSpacePrefix;
        }
        if(nameSpace==null||nameSpace==''){nameSpace='';}else{nameSpace=nameSpace+'__';}
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Name From Jira_Project__c';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();

        /* to create lookup of selected object on jirarelation object */
        for(string selectedObject : sfobjects){
            
            String updSelectedObj = selectedObject;
            
            
            if(!fieldList.isEmpty() && selectedObject!=NULL){
                if(!fieldList.contains(selectedObject+'Relation__c')){
                    
                    if (selectedObject.contains(nameSpace.toLowerCase())&& nameSpace!='') {
                        selectedObject =  selectedObject.remove(nameSpace.toLowerCase());
                    } 
                    
                    if (selectedObject.contains('Grz_Sf__')) {
                        selectedObject = selectedObject.remove('Grz_Sf__');
                    } 
                    
                    if (selectedObject.containsIgnoreCase('__c')){
                        updSelectedObj = selectedObject.remove('__c');
                    }
                    
                    if(updSelectedObj.contains('__')){
                        updSelectedObj=updSelectedObj.substring(updSelectedObj.indexof('__')+2,updSelectedObj.length() );
                        
                    }
                    //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                    String objectapiname = 'JiraRelationship__c';
                    String fieldlabel = updSelectedObj;
                    String fieldapiname = updSelectedObj+'Relation';
                    
                    string type = 'Lookup';
                    integer precision;
                    string visibleLines ='';
                    HTTPResponse res ;
                    HttpRequest requestinside = new HttpRequest();
                    requestinside.setHeader('Authorization', 'Bearer ' + sessionId);
                    requestinside.setHeader('Content-Type', 'application/json');
                    requestinside.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/tooling/sobjects/CustomField/');
                    requestinside.setMethod('POST');
                    String fieldDef = '{"Metadata" : ';
                    String metadef = '"type" : "' + type + '", "inlineHelpText" : "","referenceTo" : "'+selectedObject+'","relationshipLabel" : "JiraRelationships","relationshipName" : "JiraRelationships","precision" : ' + precision + ',"label" : "'+fieldlabel+'","required" : false' + visibleLines;
                    fieldDef += '{'+metadef+'},';
                    
                    fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
                    
                    requestinside.setBody(fieldDef);
                    try{
                        requestinside.setCompressed(true);
                        http h = new http();
                        res = h.send(requestinside);
                      
                        
                    }catch(exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('CreateLookUpFieldsandGivePermissions',requestinside.getEndPoint(), requestinside.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'Execute Method', Error));   
                        
                    }    
                } 
            }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
        /***************************************************************/
    }
    global void finish(Database.BatchableContext BC){
        Set<FieldPermissions> FieldPermissionset = New Set<FieldPermissions>();
        Set<String> permissionIds = New Set<String>();
        for(permissionset ps : [SELECT Id,ProfileId FROM PermissionSet  where IsOwnedByProfile = true ]){
            permissionIds.add(ps.Id);
            
        }
        
        
        for(string selectedObject : sfobjects){
            if(!fieldList.contains(selectedObject+'Relation__c') && selectedObject!=NULL){
                string updSelectedObj= selectedObject;
                if (selectedObject.contains(nameSpace.toLowerCase())&& nameSpace!='') {
                    selectedObject =  selectedObject.remove(nameSpace.toLowerCase());
                } 
                
                if (selectedObject.contains('Grz_Sf__')) {
                    selectedObject = selectedObject.remove('Grz_Sf__');
                } 
                if (selectedObject.containsIgnoreCase('__c')){
                    updSelectedObj = selectedObject.remove('__c');
                }
                if(updSelectedObj.contains('__')){
                    updSelectedObj=updSelectedObj.substring(updSelectedObj.indexof('__')+2,updSelectedObj.length() );
                    
                }
                String fieldapiname = updSelectedObj+'Relation';
                
                For(String Id : permissionIds){
                    FieldPermissions FP = New FieldPermissions();
                    if(Schema.sObjectType.FieldPermissions.fields.Field.isCreateable()){ 
                        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                        FP.Field = 'JiraRelationship__c.'+NameSpace+fieldapiname+'__c';
                    }
                    if(Schema.sObjectType.FieldPermissions.fields.SObjectType.isCreateable()){
                        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                        FP.SObjectType = 'JiraRelationship__c';
                    }
                    if(Schema.sObjectType.FieldPermissions.fields.ParentId.isCreateable()){ 
                        FP.ParentId = Id;
                        
                        
                    }
                    if(Schema.sObjectType.FieldPermissions.fields.PermissionsRead.isCreateable()){ 
                        FP.PermissionsRead = true;
                    }
                    if(Schema.sObjectType.FieldPermissions.fields.PermissionsEdit.isCreateable()){ 
                        FP.PermissionsEdit = true;
                    }
                    FieldPermissionset.add(FP);
                  
                    
                }
            }
            
            
        }
        
        if(!FieldPermissionset.isEmpty()){
            Try{
                
                List<FieldPermissions> FieldPermissionsList = New List<FieldPermissions>();
                FieldPermissionsList.addAll(FieldPermissionset); 
             
                if(schema.sObjectType.FieldPermissions.iscreateable()){
                    Insert FieldPermissionsList;     
                }
            } 
            catch(exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
             //cannot insert because FieldPermissionsList is a set-up object 
                //   GenerateJiraLogs.CreateLogRealTime('CreateLookUpFieldsandGivePermissions',null, null, null,null,null, null , null, null, ' Insert FieldPermission', Error);
                
                String errorDetails = Json.Serialize(FieldPermissionset);
            }
        }
      
    }
    
}