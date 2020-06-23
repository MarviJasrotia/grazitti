global with Sharing class UpdateReporintgFields implements Database.Batchable<sObject>,  Database.AllowsCallouts,Database.Stateful{ 
    set<id> fieldIds = New Set<id>();
    string sessionId;
    String query='';
    String nameSpace ='';
    Set<String> objectFields = New Set<String>();
    Set<String> objectFieldsForPermission = New Set<String>();
    public List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
    Set<String> JiraIssueFields=new Set<String>();
    public UpdateReporintgFields(set<id> fieldIds,string sessionId){
        JiraIssueFields.add('status');
        JiraIssueFields.add('reporter');
        JiraIssueFields.add('summary');
        JiraIssueFields.add('description');
        JiraIssueFields.add('priority');
        JiraIssueFields.add('labels');
        JiraIssueFields.add('assignee');
        this.fieldIds = fieldIds;
        List<Jira_ProjectFieldsMapping__c> a=[select id, ProjectissueTypeData__c,JIRA_Field_Api_Name__c, Jira_Field_Name__c, DataType__c,isArray__c from Jira_ProjectFieldsMapping__c Field where id in :fieldIds];
        this.sessionId = sessionId;
        nameSpace = '';
        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
        
        if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null)
            NameSpace = ThisOrg[0].NameSpacePrefix;
    }  
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'select id, ProjectissueTypeData__c,JIRA_Field_Api_Name__c, Jira_Field_Name__c, DataType__c,isArray__c from Jira_ProjectFieldsMapping__c Field where id in :fieldIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Map<String,Schema.SObjectType> gd=Schema.getGlobalDescribe(); 
        //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
        if(gd.ContainsKey('JiraIssue__c')){
            //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
            Map<String,Schema.SObjectField> SchemaField=gd.get('JiraIssue__c').getDescribe().Fields.getMap(); 
            For(String fieldApiVal : SchemaField.keySet()){
                fieldApiVal = fieldApiVal.toLowerCase();
                
                if (fieldApiVal.contains(nameSpace.toLowerCase()+'__')) {
                    if(nameSpace!='' && nameSpace!=null){
                        fieldApiVal =  fieldApiVal.remove(nameSpace.toLowerCase()+'__');
                    }
                } else if (fieldApiVal.contains('Grz_Sf__')) {
                    fieldApiVal = fieldApiVal.remove('Grz_Sf__');
                }
                
                objectFields.add(fieldApiVal);
            }
        }
        for(sObject JPM : Scope){
            
            
            Jira_ProjectFieldsMapping__c Field = (Jira_ProjectFieldsMapping__c)JPM;
            
            if(JiraIssueFields.contains(Field.JIRA_Field_Api_Name__c)){
                continue;
            }
            String fieldapiname = String.valueOf(field.JIRA_Field_Api_Name__c);
            if(!objectFields.contains(fieldapiname.toLowerCase()+'__c') && !fieldapiname.toLowerCase().contains('issuelinks')) {
                //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
                String objectapiname = 'JiraIssue__c';
                String fieldlabel = field.Jira_Field_Name__c;
                HttpRequest requestinside = new HttpRequest();
                HTTPResponse res = new HTTPResponse();
                requestinside.setHeader('Authorization', 'Bearer ' + sessionId);
                requestinside.setHeader('Content-Type', 'application/json');
                requestinside.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/tooling/sobjects/CustomField/');
                requestinside.setMethod('POST');
                String fieldDef = '{"Metadata" : ';
                string type = 'Text';
                integer precision;
                string length = '255';
                String value = '';
                String valueSet1 = '';
                string visibleLines ='';
                if(Field.DataType__c.toLowerCase() == 'textarea' ){
                    type = 'LongTextArea';
                    length = '32768';
                    visibleLines = ',\"visibleLines\":3';
                }
                else if(Field.DataType__c.toLowerCase() == 'float'){
                    type = 'Number';
                    precision = 18;
                    length = 'null,"scale":"2"';
                }else if(Field.DataType__c.toLowerCase() == 'datetime'){
                    type = 'DateTime';
                }else if(Field.DataType__c.toLowerCase() == 'datepicker'){
                    type = 'Date';
                }
                else{
                    type = 'Text';
                }
                String metadef;
                if(type=='DateTime'||type=='Date'){
                    metadef = '"type" : "' + type + '", "inlineHelpText" : "","precision" : ' + precision + ',"label" : "'+fieldlabel+'","required" : false';
                    
                }else{
                    metadef = '"type" : "' + type + '", "inlineHelpText" : "","precision" : ' + precision + ',"label" : "'+fieldlabel+'","length":' + length +',"required" : false' + visibleLines;
                    
                }       
                fieldDef += '{'+metadef+'},';
                fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
                
                requestinside.setBody(fieldDef);
                try{
                    requestinside.setCompressed(true);
                    
                    http h = new http();
                    res = h.send(requestinside);
                    if(res.getStatusCode() == 201 || res.getStatusCode() == 204){
                        objectFields.add(fieldapiname.toLowerCase() + '__c');
                        objectFieldsForPermission.add(fieldapiname.toLowerCase() + '__c');
                        
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('UpdateReporintgFields',requestinside.getEndpoint(), requestinside.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, null, null, 'Execute Method', res.getbody()));
                    }
                }catch(exception e){
                    String Error=e.getMessage();
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('UpdateReporintgFields',requestinside.getEndpoint(), requestinside.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Execute Method', Error));
                    
                }
            }
        }       
    }
    
    global void finish(Database.BatchableContext BC){
        Set<FieldPermissions> FieldPermissionset = New Set<FieldPermissions>();
        String ProfileIds = '';
        Set<String> permissionIds = New Set<String>();
        For(Reporting_Permissions__c cs : [Select Profile_Id__c FROM Reporting_Permissions__c LIMIT 500]){
            if(ProfileIds == ''){
                ProfileIds = cs.Profile_Id__c;
            }
            else{
                if(!ProfileIds.contains(cs.Profile_Id__c))
                    ProfileIds = ProfileIds + ',' + cs.Profile_Id__c;
            }    
        }
        if(profileIds!=''){
            List<String> st = ProfileIds.split(',');
            for(permissionset ps : [SELECT Id FROM PermissionSet WHERE ProfileId IN :st]){
                permissionIds.add(ps.Id);
            }
        }
        /*for(Jira_ProjectFieldsMapping__c Field: [select id,JIRA_Field_Api_Name__c, Jira_Field_Name__c from Jira_ProjectFieldsMapping__c Field where id in :fieldIds]){}*/
        for(String Field: objectFieldsForPermission){
            //Jira_ProjectFieldsMapping__c Field = (Jira_ProjectFieldsMapping__c)JPM;
            //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
            String objectapiname = 'JiraIssue__c';
            For(String Id : permissionIds){
                FieldPermissions FP = New FieldPermissions();
                if(Schema.sObjectType.FieldPermissions.fields.Field.isCreateable()){ 
                    //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
                    FP.Field = 'JiraIssue__c.'+  (nameSpace !=''?nameSpace+'__':'')+  Field;
                }
                if(Schema.sObjectType.FieldPermissions.fields.SObjectType.isCreateable()){ 
                    //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
                    FP.SObjectType = 'JiraIssue__c';
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
        if(!FieldPermissionset.isEmpty()){
            Try{
                
                List<FieldPermissions> FieldPermissionsList = New List<FieldPermissions>();
                FieldPermissionsList.addAll(FieldPermissionset);
                //database.insert(FieldPermissionsList,false);
                if(schema.sObjectType.FieldPermissions.iscreateable()){
                    Insert FieldPermissionsList;	
                }
            }
            catch(exception e){
                String errorDetails = Json.Serialize(FieldPermissionset);
                GenerateJiraLogs.CreateLogRealTime('UpdateReporintgFields','', 'Finish Method', null, null,null,null,errorDetails, '', 'Enable Reporting', e.getmessage());
            }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}