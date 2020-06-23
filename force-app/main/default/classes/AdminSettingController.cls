/** 
* @Author Grazitti
* Controller for AdminSetting.vfp
* responsible for establish connection between jra and salesforce and get all related info from jira like 
* users,projects,field.
*/ 
public with sharing class AdminSettingController {
    public String lang{get;set;}
    public Boolean isAccessable{get;set;}
    public Boolean showvalidationdata {get;set;}    
    public Jira_login__c adminSetting {get;set;}
    public Map<String, JiraSalesforceDetail__c> adminSettingPublic {get;set;}
    public Boolean loginSuccess{get;set;}
    public list<SelectOption> relation{get;set;}
    public String PrivateKey{get;set;}
    public Boolean Fieldsuccess{get;set;}
    public Boolean projectSuccess{get;set;}
    public String token{get;set;}
    public boolean showmodal {get;set;}
    public Boolean ObjectLimitExceed{get;set;}
    public Boolean ObjectLimit;
    public Integer delObjCount{get;set;}
    public list<SelectOption> Languages {get;set;}
    public List<Sinergify_Trigger__c> SinergifyTriggers;
    public AdminSettingController() {
        lang=userinfo.getLanguage();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        showvalidationdata =false;
        isAccessable=true;
        set<String> objectname = new set<String>();
        //Namespace removed Grz_Sf
        objectname.add('Rule_Set__c');
        objectname.add('jira_Project__c');
        objectname.add('jira_ProjectFieldsMapping__c');
        objectname.remove(null);
        ObjectLimitExceed = false;
        ObjectLimit=false;
        PrivateKey='';
        ValidateObjectAccess.PermissionWrapper PerWrap= ValidateObjectAccess.Accessable(objectname);
        if(!(PerWrap.objectUpdatable.containsAll(objectname) && PerWrap.objectAccessible.containsAll(objectname) &&
             PerWrap.objectDeletable.containsAll(objectname) && PerWrap.objectCreateable.containsAll(objectname) 
            )){
                isAccessable=false;      
                ErrorMessage(System.label.ErrorMsg1_Label);
                return;
            }else {
                relation=new list<SelectOption>();
                relation.add(new SelectOption('OCOJ',System.label.AdminSettingController_Label2));
                relation.add(new SelectOption('OCMJ',System.label.AdminSettingController_Label3));
                Languages = JiraService.LanguageOptions();
                showmodal = false;
                Fieldsuccess=false;
                loginSuccess=false;
                projectSuccess=false;
                token='';
                adminsetting = new Jira_login__c();
                adminSettingPublic = new Map<String, JiraSalesforceDetail__c>();
                SinergifyTriggers = new List<Sinergify_Trigger__c>();
                Set<String> SettingstoCall= new Set<String>();
                
                
                
                SettingstoCall.add('Edit_Jira_In_SF');
                SettingstoCall.add('Auto_SF_Comment_Sync_Type');
                SettingstoCall.add('Sync_SF_Comments');
                SettingstoCall.add('Sync_SF_Attachment');
                SettingstoCall.add('Store_Jira_Comment_in_Case');
                SettingstoCall.add('Relationship_Type');
                SettingstoCall.add('Jira_Type_Server');
                SettingstoCall.add('Jira_Comment_As_Private');
                SettingstoCall.add('JiraCommentsSyncToJiraIssue');
                SettingstoCall.add('Display_Name');
                SettingstoCall.add('File_Size');
                if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
                    for(JiraSalesforceDetail__c JiraSFDetails:[SELECT Id, Name, Value__c, Description__c FROM JiraSalesforceDetail__c where name in :SettingstoCall LIMIT 100]){
                        adminSettingPublic.put(JiraSFDetails.Name,JiraSFDetails);
                    }
                    
                }
                
                
                if (!adminSettingPublic.containsKey('Auto_SF_Comment_Sync_Type')){
                    adminSettingPublic.put('Auto_SF_Comment_Sync_Type',new JiraSalesforceDetail__c(name='Auto_SF_Comment_Sync_Type',value__c='no'));
                }
                
                if (!adminSettingPublic.containsKey('Store_Jira_Comment_in_Case')){
                    adminSettingPublic.put('Store_Jira_Comment_in_Case',new JiraSalesforceDetail__c(name='Store_Jira_Comment_in_Case',value__c='no'));
                }
                
                if (!adminSettingPublic.containsKey('Edit_Jira_In_SF')){
                    adminSettingPublic.put('Edit_Jira_In_SF',new JiraSalesforceDetail__c(name='Edit_Jira_In_SF',value__c='no'));
                }
                
                if (!adminSettingPublic.containsKey('Jira_Comment_As_Private')){
                    adminSettingPublic.put('Jira_Comment_As_Private',new JiraSalesforceDetail__c(name='Jira_Comment_As_Private',value__c='no'));
                }
                
                if (!adminSettingPublic.containsKey('JiraCommentsSyncToJiraIssue')){
                    adminSettingPublic.put('JiraCommentsSyncToJiraIssue',new JiraSalesforceDetail__c(name='JiraCommentsSyncToJiraIssue',value__c='no'));
                } 
                if (!adminSettingPublic.containsKey('Relationship_Type')){
                    adminSettingPublic.put('Relationship_Type',new JiraSalesforceDetail__c(name='Relationship_Type',value__c='OCMJ'));
                }
                if (!adminSettingPublic.containsKey('Sync_SF_Attachment')){
                    adminSettingPublic.put('Sync_SF_Attachment',new JiraSalesforceDetail__c(name='Sync_SF_Attachment',value__c='no'));
                }
                if (!adminSettingPublic.containsKey('Sync_SF_Comments')){
                    adminSettingPublic.put('Sync_SF_Comments',new JiraSalesforceDetail__c(name='Sync_SF_Comments',value__c='no'));
                }
                if (!adminSettingPublic.containsKey('Jira_Type_Server')){
                    adminSettingPublic.put('Jira_Type_Server',new JiraSalesforceDetail__c(name='Jira_Type_Server',value__c='no'));
                }
                
                if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
                    adminSetting= Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c(Name = 'JIRA');
                }
                
                for(integer i=1; i<=5;i++){
                    if(adminsetting.get('Private_Key'+i+'__c')!=null && adminsetting.get('Private_Key'+i+'__c')!=''){
                        PrivateKey+=adminsetting.get('Private_Key'+i+'__c');
                    } 
                }
                
                List<Sinergify_Trigger__c> ExisitngSinergifyTriggers = new List<Sinergify_Trigger__c>();
                ExisitngSinergifyTriggers=[Select id from Sinergify_Trigger__c limit 1];
                if(ExisitngSinergifyTriggers.isEmpty()){
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='UpdateFieldWithData',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='JiraRelationshipTrigger',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='JiraIssueTrigger',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='JiraAutoFileAttach',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='JiraAutoComment',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='JiraAutoAttachment',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='FeedItemTrigger',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='AddJiraCommentsfromIdea',isActive__c=true));
                    SinergifyTriggers.add(new Sinergify_Trigger__c(name='AddJiraComments',isActive__c=true));
                    
                }
                
                if (adminSetting != null && adminSetting.End_Point__c != null) {
                    LoginSuccessClass Log = checkconnectionstatus();
                    if(Log.isSuccess){
                        ProjectSettingController pro=new ProjectSettingController();
                        loginSuccess=true;
                        
                        if (!adminSettingPublic.containsKey('Display_Name')){
                            adminSettingPublic.put('Display_Name',new JiraSalesforceDetail__c(name='Display_Name',value__c=Log.DisplayName));
                        }else{
                            adminSettingPublic.get('Display_Name').value__c=Log.DisplayName;
                        }
                        if (!adminSettingPublic.containsKey('File_Size')){
                            adminSettingPublic.put('File_Size',new JiraSalesforceDetail__c(name='File_Size',value__c=Log.DisplayName));
                        }else{
                            adminSettingPublic.get('File_Size').value__c=SizeCheck();
                        }
                        
                    }else{
                        if(Log.Body==null){
                            Log.Body='Unauthorized';
                        }
                        ErrorMessage(System.label.AdminSettingController_Label4 +': '+Log.Body);
                    }
                }
                
                if(adminsetting.LoginSuccess__c){
                    loginSuccess=true;
                    projectSuccess=true;
                    if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
                        Fieldsuccess= [select id from Jira_Project__c LIMIT 1] != null? true:false;
                    }
                }
                
            }
        
        
        
    }
    Public PageReference LangaugeReset(){
        return new pageReference('/apex/AdminSetting?lg='+lang);
    }
    public PageReference RefreshRequestToken(){
        
        
        try{
            if(privatekey!='' && privatekey!=NULL){
                String private_key=privatekey;
                Integer privateKeylength=privatekey.Length();
                Integer keysize=privateKeylength/255+(math.mod(privateKeylength,255)>0?1:0);
                
                String temp='';
                for(Integer i=1; i<=keysize;i++){
                    
                    if(private_key!=''){
                        
                        if(private_key.length()>255){
                            temp= private_key.substring(0,255);
                        }else{
                            temp= private_key;
                        }
                        
                        
                        adminSetting.put('Private_Key'+i+'__c',temp);
                        private_key=private_key.remove(temp);
                        
                        
                    }
                }
                if(Schema.sObjectType.Jira_login__c.fields.End_Point__c.isAccessible() && Schema.sObjectType.Jira_login__c.fields.Consumer_Key__c.isAccessible()){
                    token=TokenAuthenticationClass.getRequestToken(adminsetting.End_Point__c,PrivateKey ,adminSetting.Consumer_Key__c);
                }
                if(schema.sObjectType.Jira_login__c.isUpdateable()){
                    update adminSetting;
                }
            }
        }catch(exception e){
            String Error=System.label.cause_Label +e.getCause()+'\n'+ System.label.LineNumber_Label +e.getLineNumber()+'\n'+ System.label.Message_Label +e.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null, null, null, 'RequestToken', Error);  
            
            if(adminSetting.id!=NULL){
                if(schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isUpdateable()){
                    adminSetting.LoginSuccess__c=false;
                }
                if(schema.sObjectType.Jira_login__c.fields.Access_Token__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.Access_Token__c.isUpdateable()){
                    adminSetting.Access_Token__c='';
                }
                try{
                    if(schema.sObjectType.Jira_login__c.isUpdateable()){
                        update adminSetting;
                    }
                }catch(Exception ex){
                    String Errormessage=System.label.cause_Label +e.getCause()+'\n'+ System.label.LineNumber_Label +e.getLineNumber()+'\n'+ System.label.Message_Label +e.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null, null, null, 'RequestToken', Errormessage);  
                    
                }
            }
        }
        
        return null;
    }
    
    @future(callout=true) 
    public static void checkloginsuccess(){
        try{
            if(Schema.sObjectType.Jira_login__c.isAccessible() && 
               (Schema.sObjectType.Jira_login__c.isUpdateable() ||
                Schema.sObjectType.Jira_login__c.isCreateable())){
                    Jira_login__c jiralogin=Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c();
                    Map<String, JiraSalesforceDetail__c> jiraloginPublic = JiraSalesforceDetail__c.getAll();
                    
                    list<JiraSalesforceDetail__c> jiraloginPublicList = new list<JiraSalesforceDetail__c>();
                    Map<String,String> loginSuccessMap;
                    if(jiralogin.id!=null){ 
                        loginSuccessMap=new Map<String,String>();
                        loginSuccessMap=JiraService.checkconnectionstatus();
                        
                        if(loginSuccessMap.containsKey('true') ){
                            if(schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isUpdateable()){
                                jiralogin.LoginSuccess__c=true;
                            }
                            if(Schema.sObjectType.JiraSalesforceDetail__c.isAccessible() && 
                               (Schema.sObjectType.JiraSalesforceDetail__c.isUpdateable() ||
                                Schema.sObjectType.JiraSalesforceDetail__c.isCreateable())){
                                    JiraSalesforceDetail__c jiraloginDisplayName=jiraloginPublic.containsKey('Display_Name')? jiraloginPublic.get('Display_Name'):new JiraSalesforceDetail__c(name='Display_Name');
                                    JiraSalesforceDetail__c jiraloginFileSize=jiraloginPublic.containsKey('File_Size')? jiraloginPublic.get('File_Size'):new JiraSalesforceDetail__c(name='File_Size');
                                    if(schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isCreateable() && schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isUpdateable()){
                                        jiraloginDisplayName.value__c=loginSuccessMap.get('true');
                                        jiraloginFileSize.value__c =SizeCheck();
                                        jiraloginPublicList.add(jiraloginFileSize);
                                        jiraloginPublicList.add(jiraloginDisplayName);
                                    }
                                }
                        }else{
                            if(schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isUpdateable()){
                                jiralogin.LoginSuccess__c=false;
                            }
                        }
                        
                    }
                    
                    if(schema.sObjectType.Jira_login__c.isCreateable() && schema.sObjectType.Jira_login__c.isUpdateable()){
                        
                        upsert jiralogin;
                    }
                    if(schema.sObjectType.JiraSalesforceDetail__c.isCreateable() && schema.sObjectType.JiraSalesforceDetail__c.isUpdateable()){
                        
                        upsert jiraloginPublicList;
                    }
                }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null, null, null, 'checkloginsuccess', Error);  
        }
    }
    
    public static String SizeCheck(){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req=CreateJIRAWrapper.CreateRequest('/rest/api/2/attachment/meta', 'GET', 'application/json');
        try{
            res=http.send(req);
            if(res.getstatuscode()==200){
                String ResponseBody=res.getbody();
                map<string,object> deserialize=(map<string,object>)JSON.deserializeUntyped(ResponseBody);
                Object obj1=deserialize.get('uploadLimit');
                String body=JSON.serialize(obj1);
                Long bodyy=long.valueOf( body);
                String JiraStorageCapacity=JiraFileSizeCheck.FileSize(bodyy);
                return JiraStorageCapacity;
            }else{
                GenerateJiraLogs.CreateLogRealTime('AdminSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Attachment', res.getBody());  
                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Attachment', Error);  
        }
        return null;
    }
    
    
    
    /**
* insert/update the license in org.
* update the jira log in details if the endpoint is same.
* inserts the jira log in settings if no other jira log in is there
*/
    public pageReference checkUrlChange() {
        try {          
            List < Jira_login__c > setting = new List < Jira_login__c > ();
            if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
                setting = [select id,Private_Key1__c,Private_Key2__c,Private_Key3__c,Private_Key4__c,Private_Key5__c,Basic_Authentication__c,Token_Authentication__c,Consumer_Key__c ,End_Point__c, License_Key__c,Password__c from Jira_login__c where name = 'JIRA'];
            }
            
            if (setting.Size() > 0) {
                if (setting[0].End_Point__c != Null && setting[0].End_Point__c != adminsetting.End_Point__c) {
                    loginSuccess=false;
                    projectSuccess=false;
                    Fieldsuccess=false;
                    showmodal = true;
                }else{
                    showmodal = false;
                    if (!(Jira_login__c.sObjectType.getDescribe().isAccessible() && Jira_login__c.sObjectType.getDescribe().isUpdateable() && Jira_login__c.sObjectType.getDescribe().isCreateable())) {
                        
                    }else{
                        
                        if(adminSetting.Basic_Authentication__c==true && adminSetting.Token_Authentication__c==false){
                            //Check if the pasword is changes by user
                            if(adminSetting.Password__c != setting[0].Password__c){
                                // Encode the password before saving it.
                                Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                Blob clearData=Blob.valueOf(adminSetting.Password__c );
                                if(Schema.sObjectType.Jira_login__c.fields.Password__c.isCreateable() && Schema.sObjectType.Jira_login__c.fields.Password__c.isUpdateable()){
                                    adminSetting.Password__c=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
                                }
                                
                            }
                            if(Schema.sObjectType.Jira_login__c.fields.Token_Authentication__c.isCreateable() && Schema.sObjectType.Jira_login__c.fields.Token_Authentication__c.isUpdateable()){
                                adminSetting.Token_Authentication__c=false;
                            }
                            
                        }
                        
                        if(adminSetting.Token_Authentication__c==true && adminSetting.Basic_Authentication__c==false){
                            String consumersecret='';
                            for(integer i=1; i<=5;i++){
                                if(setting[0].get('Private_Key'+i+'__c')!=null){
                                    consumersecret +=setting[0].get('Private_Key'+i+'__c');
                                } 
                            }
                            
                            if( (PrivateKey!='' && PrivateKey!=NULL && PrivateKey!=consumersecret) || (adminSetting.Consumer_Key__c!=Setting[0].Consumer_Key__c) ){
                                String private_key=PrivateKey;
                                Integer privateKeylength=PrivateKey.Length();
                                Integer keysize=privateKeylength/255+(math.mod(privateKeylength,255)>0?1:0);
                                
                                String temp='';
                                for(Integer i=1; i<=keysize;i++){
                                    if(private_key!=''){
                                        if(private_key.length()>255){
                                            temp= private_key.substring(0,255);
                                        }else{
                                            temp= private_key;
                                        }
                                        
                                        adminSetting.put('Private_Key'+i+'__c',temp);
                                        private_key=private_key.remove(temp);
                                        
                                    }
                                }
                                if(Schema.sObjectType.Jira_login__c.fields.Basic_Authentication__c.isCreateable() && Schema.sObjectType.Jira_login__c.fields.Basic_Authentication__c.isUpdateable()){
                                    adminSetting.Basic_Authentication__c=false;
                                }
                                
                                token=TokenAuthenticationClass.getRequestToken(adminsetting.End_Point__c,privatekey, adminSetting.Consumer_Key__c);
                                
                            }     
                        }
                        
                        if(Jira_login__c.sObjectType.getDescribe().isCreateable() && Jira_login__c.sObjectType.getDescribe().isUpdateable()){
                            upsert adminSetting;
                        }
                        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isCreateable() && JiraSalesforceDetail__c.sObjectType.getDescribe().isUpdateable()){
                            
                            if(adminSettingPublic.get('Sync_SF_Comments').value__c=='no'){
                                adminSettingPublic.get('Auto_SF_Comment_Sync_Type').value__c ='';
                            } 
                            if(adminSettingPublic.get('JiraCommentsSyncToJiraIssue').value__c=='no'){
                                adminSettingPublic.get('Store_Jira_Comment_in_Case').value__c ='';
                                adminSettingPublic.get('Jira_Comment_As_Private').value__c ='';
                            } 
                            if (!adminSettingPublic.values().isEmpty()){
                                upsert adminSettingPublic.values();
                            }
                        }
                        if(Sinergify_Trigger__c.sObjectType.getDescribe().isCreateable() && Sinergify_Trigger__c.sObjectType.getDescribe().isUpdateable()){
                            if(!SinergifyTriggers.isEmpty()){
                                insert SinergifyTriggers;
                            }
                        }
                        if(adminSetting.Basic_Authentication__c==true && adminSetting.Token_Authentication__c==false){
                            checkloginsuccess();
                            pageReference pref = page.adminsetting;
                            pref.setRedirect(true);
                            return pref;
                        }
                        return null;
                    }
                }
            } else {
                if(schema.sObjectType.Jira_login__c.fields.Name.isCreateable()){
                    adminsetting.Name = 'JIRA';
                }
                
                if(adminSetting.Password__c!=NULL && adminSetting.Password__c!=''){
                    Blob clearData=Blob.valueOf(adminSetting.Password__c);
                    Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                    if(schema.sObjectType.Jira_login__c.fields.Password__c.isCreateable()){
                        adminSetting.Password__c= EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
                    }
                }
                if(PrivateKey!='' && PrivateKey!=NULL){
                    String private_key=PrivateKey;
                    Integer privateKeylength=PrivateKey.Length();
                    Integer keysize=privateKeylength/255+(math.mod(privateKeylength,255)>0?1:0);
                    
                    String temp='';
                    for(Integer i=1; i<=keysize;i++){
                        if(private_key!=''){
                            if(private_key.length()>255){
                                temp= private_key.substring(0,255);
                            }else{
                                temp= private_key;
                            }
                            adminSetting.put('Private_Key'+i+'__c',temp);
                            private_key=private_key.remove(temp);
                        }
                    }
                } 
                
                if(adminSetting.Basic_Authentication__c!=NULL && adminSetting.Basic_Authentication__c==true){ 
                    checkloginsuccess();
                    pageReference pref = page.adminsetting;
                    pref.setRedirect(true);
                    if(Jira_login__c.sObjectType.getDescribe().isCreateable()){
                        insert adminsetting;
                    }
                    if(adminSettingPublic.get('Sync_SF_Comments').value__c=='no'){
                        adminSettingPublic.get('Auto_SF_Comment_Sync_Type').value__c ='';
                    } 
                    if(adminSettingPublic.get('JiraCommentsSyncToJiraIssue').value__c=='no'){
                        adminSettingPublic.get('Store_Jira_Comment_in_Case').value__c ='';
                        adminSettingPublic.get('Jira_Comment_As_Private').value__c ='';
                    } 
                    if (!adminSettingPublic.values().isEmpty()){
                        upsert adminSettingPublic.values();
                    }
                    if(Sinergify_Trigger__c.sObjectType.getDescribe().isCreateable() && Sinergify_Trigger__c.sObjectType.getDescribe().isUpdateable()){
                        if(!SinergifyTriggers.isEmpty()){
                            try{
                                insert SinergifyTriggers;
                            }catch(Exception Ex){
                                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                                GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'URLchange', Error);
                                
                            }
                        }
                    }
                    
                    return pref;
                }else if(adminSetting.Token_Authentication__c!=NULL && adminSetting.Token_Authentication__c==true){
                    if(Schema.sObjectType.Jira_login__c.fields.End_Point__c.isAccessible() && Schema.sObjectType.Jira_login__c.fields.Consumer_Key__c.isAccessible()){
                        token=TokenAuthenticationClass.getRequestToken(adminsetting.End_Point__c,privatekey, adminSetting.Consumer_Key__c);
                    }
                    if(Jira_login__c.sObjectType.getDescribe().isCreateable()){
                        insert adminsetting;
                    }
                    if(JiraSalesforceDetail__c.sObjectType.getDescribe().isCreateable() && JiraSalesforceDetail__c.sObjectType.getDescribe().isUpdateable()){
                        list<JiraSalesforceDetail__c> jsdToUpsert = new list<JiraSalesforceDetail__c>();
                        for (string jsd:adminSettingPublic.keyset()){
                            jsdToUpsert.add(adminSettingPublic.get(jsd));
                        }
                        if (!jsdToUpsert.isEmpty()){
                            upsert jsdToUpsert;
                        }
                    }
                    
                    if(Sinergify_Trigger__c.sObjectType.getDescribe().isCreateable() && Sinergify_Trigger__c.sObjectType.getDescribe().isUpdateable()){
                        if(!SinergifyTriggers.isEmpty()){
                            try{
                                insert SinergifyTriggers;
                            }catch(Exception Ex){
                                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                                GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'URLchange', Error);
                                
                            }
                        }
                    }
                    return null;
                }
                
                
            }
            
        } catch (Exception ex) { 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'URLchange', Error);
            
            ErrorMessage(System.label.AdminSettingController_Label5);
        }
        
        pageReference pref = page.adminsetting;
        pref.setRedirect(true);
        return null;
    }
    /*  
public static  map<String,String> fetchJiraUserList(String  Username){
Map<String, String> usersMap = new Map<String, String>();
HttpRequest req = new HttpRequest();
if(Username!=null && Username!=''){

req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/search?username='+Username, 'GET', 'application/json');
}
Http http = new Http();
HTTPResponse res;
try {

String jsonInput;
res = http.send(req);
jsonInput = res.getBody();
if(Test.isRunningTest() || res.getStatusCode()==200){
List<Object> userList =new List<Object>();
userList = (List<Object>)JSON.deserializeUntyped(jsonInput);


for(Object user : userList){
Map<String, Object> userDataMap = (Map<String, Object>)user;
usersMap.put((String)userDataMap.get('emailAddress'), (String)userDataMap.get('displayName'));
usersMap.put((String)userDataMap.get('key'), (String)userDataMap.get('displayName'));
}

return usersMap;
}else{
GenerateJiraLogs.CreateLogRealTime('AdminSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Fetch Jira User List', res.getBody());

}
}catch(Exception ex){
String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
GenerateJiraLogs.CreateLogRealTime('AdminSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Fetch Jira User List', Error);
return null;
}
return null;
}
*/
    /**
* Reloads the page,making unsaved changes revert. 
*/
    public pageReference cancelSettings() {
        pageReference pref = page.adminsetting;
        pref.setRedirect(true);
        return pref;
    }
    /**
*  Used when jira log in settings are changed with different end point.
*  Update the setting. 
*/
    public pageReference checkUrlChange_OnOK() {
        if (!Jira_login__c.sObjectType.getDescribe().isAccessible() && !Jira_login__c.sObjectType.getDescribe().isUpdateable() && !Jira_login__c.sObjectType.getDescribe().isCreateable() && Schema.sObjectType.Jira_login__c.fields.End_Point__c.isAccessible() && Schema.sObjectType.Jira_login__c.fields.End_Point__c.isCreateable() && Schema.sObjectType.Jira_login__c.fields.End_Point__c.isUpdateable()) return null;
        else {
            Jira_login__c setting = [select id,Private_Key1__c,Private_Key2__c,Private_Key3__c,Private_Key4__c,Private_Key5__c,Basic_Authentication__c,Token_Authentication__c,Consumer_Key__c ,Name,Password__c,License_Key__c, End_Point__c from Jira_login__c where name = 'JIRA'
                                     Limit 1
                                    ];
            
            
            
            if (setting != null && setting.End_Point__c != adminsetting.End_Point__c) {
                
                showmodal = false;
                if(Schema.sObjectType.Jira_login__c.isAccessible() && (Schema.sObjectType.Jira_login__c.isUpdateable() ||Schema.sObjectType.Jira_login__c.isCreateable())){
                    if(Schema.sObjectType.Jira_login__c.fields.id.isAccessible() && Schema.sObjectType.Jira_login__c.fields.id.isCreateable() && Schema.sObjectType.Jira_login__c.fields.id.isUpdateable())  {
                        adminsetting.id = setting.id;
                    }
                    if(adminsetting.Basic_Authentication__c==true && adminsetting.Token_Authentication__c==false){
                        if(adminSetting.Password__c != setting.Password__c && schema.sObjectType.Jira_login__c.fields.id.isUpdateable()){
                            Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                            Blob clearData=Blob.valueOf(adminSetting.Password__c );
                            if(Schema.sObjectType.Jira_login__c.fields.Password__c.isAccessible() && Schema.sObjectType.Jira_login__c.fields.Password__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.Password__c.isUpdateable())  {
                                adminSetting.Password__c=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
                            }
                        }
                        
                    }else if(adminsetting.Basic_Authentication__c==false  && adminsetting.Token_Authentication__c==true){
                        String consumersecret='';
                        
                        for(integer i=1; i<=5;i++){
                            if(setting.get('Private_Key'+i+'__c')!=null){
                                consumersecret +=setting.get('Private_Key'+i+'__c');
                            } 
                        }
                        if( (privatekey!='' && privatekey!=NULL && privatekey!=consumersecret) || (adminSetting.Consumer_Key__c!=Setting.Consumer_Key__c) ){
                            String private_key=privatekey;
                            Integer privateKeylength=privatekey.Length();
                            Integer keysize=privateKeylength/255+(math.mod(privateKeylength,255)>0?1:0);
                            
                            String temp='';
                            for(Integer i=1; i<=keysize;i++){
                                
                                if(private_key!=''){
                                    
                                    if(private_key.length()>255){
                                        temp= private_key.substring(0,255);
                                    }else{
                                        temp= private_key;
                                    }
                                    
                                    adminSetting.put('Private_Key'+i+'__c',temp);
                                    private_key=private_key.remove(temp);
                                    
                                }
                            }
                        }
                        if(Schema.sObjectType.Jira_login__c.fields.End_Point__c.isAccessible() && Schema.sObjectType.Jira_login__c.fields.Consumer_Key__c.isAccessible()){
                            token=TokenAuthenticationClass.getRequestToken(adminsetting.End_Point__c,privatekey, adminSetting.Consumer_Key__c);
                        }
                        try{
                            if(Jira_login__c.sObjectType.getDescribe().isCreateable()){
                                insert adminsetting;
                            }
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'Insert Adminsetting', Error);
                            
                        }
                        return null;
                    }
                    
                    
                }
                
                if(Schema.sObjectType.Jira_login__c.isAccessible() &&
                   (Schema.sObjectType.Jira_login__c.isUpdateable() ||
                    Schema.sObjectType.Jira_login__c.isCreateable())){
                        try{
                            if(Jira_login__c.sObjectType.getDescribe().isCreateable() &&  Jira_login__c.sObjectType.getDescribe().isUpdateable() ){
                                upsert adminsetting;
                            }
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'Upsert Adminsetting', Error);
                            
                        }
                        pageReference pref = page.adminsetting;
                        pref.setRedirect(true);
                        return pref;
                    }
                
            } 
        }
        return null;
    }
    /**
* delete fieldmapping,projectmapping,ruleset when the jira endpoint is changed .
* call checkUrlChange_OnOK.
*/
    public PageReference save() {
        try{
            if ((Jira_Project__c.sObjectType.getDescribe().isDeletable())) {
                List<String> ContentTitle= new List<String>();
                List < Jira_Project__c > projects=new List < Jira_Project__c > ();
                if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
                    projects = [select id ,Projectkey__c from Jira_Project__c limit 1000];
                }
                if (projects != null && !projects.isEmpty()) {
                    list<ContentDocument> CdList = new list<ContentDocument>();
                    
                    for(Jira_Project__c JP:projects){
                        String Title=JP.Projectkey__c+'_Json.txt';
                        String Title1=JP.Projectkey__c+'_NotAllowedJson.txt';
                        ContentTitle.add(Title);
                        ContentTitle.add(Title1);
                    }
                    
                    CdList = [select id from ContentDocument where Title in :ContentTitle];
                    if(!CdList.isEmpty()){
                        
                        if(Schema.sObjectType.ContentDocument.isDeletable()){
                            delete CdList;
                        }
                        
                    } 
                    delete projects;
                    
                    projectSuccess=false;
                }
            }
            if (Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() && Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isDeletable()) {
                List < Jira_ProjectFieldsMapping__c > fields = [select id from Jira_ProjectFieldsMapping__c limit 1000];
                if (fields != null && !fields.isEmpty()) {
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.isDeletable()){
                        delete fields;
                    }
                }
                Fieldsuccess=false;
            }
            if (!(Rule_Set__c.sObjectType.getDescribe().isAccessible() && Rule_Set__c.sObjectType.getDescribe().isUpdateable() && Rule_Set__c.sObjectType.getDescribe().isDeletable())) {
                return null;
            } else {
                List < Rule_Set__c > ruleSetList = new List < Rule_Set__c > ();
                ruleSetList = [select id from Rule_Set__c LIMIT 1000];
                if (ruleSetList.size() > 0) {
                    if(Schema.sObjectType.Rule_Set__c.isDeletable()){
                        delete ruleSetList;
                    }
                }
            }
            
            
            loginSuccess=false;
            List<Jira_login__c> setting=new List<Jira_login__c> ();
            if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
                setting=[select id,Basic_Authentication__c,Token_Authentication__c,LoginSuccess__c from Jira_login__c where name = 'JIRA' Limit 1 ];
            }
            if(Schema.sObjectType.Jira_login__c.isDeletable()){
                Delete setting;
            }
            Jira_login__c jiralogin=new Jira_login__c(Name='JIRA',End_Point__c=adminSetting.End_Point__c);
            if(Schema.sObjectType.Jira_login__c.isCreateable()){
                insert jiralogin;
            }
            return null;
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('AdminSettingController',null, null, null,null,null, null , null, null, 'Save', Error);
            
        }
        return null;
    }
    public PageReference cancel() {
        return null;
    }
    /**
*  Displays the error message if any 
*  @param Error  (String) holds the message to be displayed during an exception 
*/ 
    public static void ErrorMessage(String Error){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Error );
        ApexPages.addMessage(msg); 
    }
    
    /**
* calles the class LicenseKey responsible to check sync limit with jira.
*/
    
    
    
    
    
    public pagereference ValidationCompRecall(){
        //dummy rerender 
        showvalidationdata =true;
        return null;
    }
    
    
    public static LoginSuccessClass checkconnectionstatus(){
        LoginSuccessClass Log = new LoginSuccessClass();
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res=new HTTPResponse();
        try{
            req = CreateJIRAWrapper.CreateRequest('/rest/auth/1/session' ,'GET' ,'application/json');
            if(req!=NULL && req.getEndpoint()!=NULL && req.getEndpoint()!=''){
                res = http.send(req);
            }
            if(res.getstatuscode()== 401 && res.getstatus()=='Unauthorized'){
                Log.IsSuccess=false;
                Log.Body='Status:'+ res.getstatus()+' Status Code:'+res.getstatuscode();
                
            }else if(res.getstatuscode()== 200){
                Log.IsSuccess=true;
                Map<String,Object> getuserName=(Map<String,Object>)JSON.deserializeUntyped(res.getbody());
                Log.DisplayName=(String)getuserName.get('name');
            }
        } catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            
            if(Error!=null && Error.contains('Remote site settings')){
                Error=Error.substringBefore('Remote site settings')+' '+System.label.AdminSettingController_Label6;
            }
            Log.IsSuccess=False;
            Log.Body=Error;
        }
        return Log;
    }
    
    public class LoginSuccessClass{
        public Boolean IsSuccess;
        Public String Body;
        Public String DisplayName;
        public LoginSuccessClass(){
            IsSuccess=false;
        }
    }
    
    
}