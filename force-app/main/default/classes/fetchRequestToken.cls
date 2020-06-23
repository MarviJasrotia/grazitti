public with Sharing Class fetchRequestToken{
        public String lang{get;set;}
    public List<JiraErrorLogs__c> JiraLogsToInsert;
    public String accesstoken='';
    public List<Jira_login__c> setting;
    public List<JiraSalesforceDetail__c> settingPublic;
    public String ConsumerSecret='';
    public String consumerkey='';
    String URLstatus='';
    public fetchRequestToken(){
        lang=userinfo.getLanguage();
        JiraLogsToInsert = new List<JiraErrorLogs__c>();
        settingPublic= new List<JiraSalesforceDetail__c>();
        setting =new List < Jira_login__c >();
        getrequest();
    }   
    
    public  void getrequest(){
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            setting = [select id,Access_Token__c,Private_Key1__c,Private_Key2__c,Private_Key3__c,Private_Key4__c,Private_Key5__c,Basic_Authentication__c,Token_Authentication__c,Consumer_Key__c ,End_Point__c,License_Key__c,Password__c from Jira_login__c where name = 'JIRA'];
        }
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){

            settingPublic.add(JiraSalesforceDetail__c.getvalues('Display_Name')!=null?JiraSalesforceDetail__c.getvalues('Display_Name'):new JiraSalesforceDetail__c(name='Display_Name'));
            
        }
        httprequest req = new httprequest();
        httpresponse resp;
        try{
            req.setMethod('POST');
            String oauthToken=ApexPages.CurrentPage().getparameters().get('oauth_token');
            String verifier=ApexPages.CurrentPage().getparameters().get('oauth_verifier');
            URLstatus=ApexPages.CurrentPage().getparameters().get('status');
            
            req.setEndpoint(setting[0].End_Point__c+'/plugins/servlet/oauth/access-token');
            consumerkey =setting[0].Consumer_Key__c ;
            
            consumersecret ='';
            
            for(integer i=1; i<=5;i++){
                if(setting[0].get('Private_Key'+i+'__c')!=null){
                    consumersecret +=setting[0].get('Private_Key'+i+'__c');
                } 
            }
            
            httprequest req1 = signRequest(req,consumerkey,consumersecret,oauthToken,verifier);
            
            http h = new http();
            
            
            resp = h.send(req);
            if(resp.getstatuscode()==200){
                String token=resp.getbody();
                
                If(token!=NULL && token!=''){
                    accesstoken=token.Substring(0,token.indexof('&'));
                    accesstoken=accesstoken.remove('oauth_token=');
                }
            }else{
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('fetchRequestToken',req.getEndPoint(), req.getMethod(), String.valueof(resp.getstatusCode()),resp.getbody(),resp.getstatus(), req.getbody(), null, null, 'getrequest', resp.getBody()));
                
            }
        }catch(Exception ex){
            String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('fetchRequestToken',req.getEndPoint(), req.getMethod(), String.valueof(resp.getstatusCode()),resp.getbody(),resp.getstatus(), req.getbody(), null, null, 'getrequest', Errormsg));
            
        }
    }
    
    public PageReference ClosePage(){
        
        Map<String,String> loginSuccessMap=new Map<String,String>();
        loginSuccessMap=checkconnectionstatus();
        if(loginSuccessMap.containsKey('true')){
            
            if(schema.sObjectType.Jira_login__c.fields.Access_Token__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.Access_Token__c.isUpdateable()){
                setting[0].Access_Token__c= accesstoken;
            }
            
            if(schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isUpdateable()){
                setting[0].LoginSuccess__c=true;
            }
            if(schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isCreateable() && schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isUpdateable()){
                settingPublic[0].value__c=loginSuccessMap.get('true');
            }
            if(schema.sObjectType.Jira_login__c.fields.Username__c.isCreateable() && schema.sObjectType.Jira_login__c.fields.Username__c.isUpdateable()){
                setting[0].Username__c=loginSuccessMap.get('true');
            }
            if(URLstatus!='' && URLstatus!=NULL && URLstatus.substring(0,15)==userinfo.getOrganizationId().substring(0,15)){
                try{
                    if(schema.sObjectType.Jira_login__c.isUpdateable()){
                        update setting;
                    }
                    if(schema.sObjectType.JiraSalesforceDetail__c.isUpdateable()){
                        update settingPublic;
                    }
                }catch(Exception ex){
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('fetchRequestToken',null, null, null,null,null, null , null, null, 'ClosePage', Error);
                }
            }
        }
        
        
        return new PageReference('javascript:opener.location.href =\'/apex/AdminSetting\';window.close();');
    }
    
    public static HttpRequest signRequest(HttpRequest req, String consumerKey, String consumerSecret,String token_oauth,String verifier) {
        
        String nonce     = String.valueOf(Crypto.getRandomLong());
        String timestamp = String.valueOf(DateTime.now().getTime() / 1000);
        Map<String,String> parameters = new Map<String,String>();
        
        String Callback='';
        
        Map<String,CallBack_URL__c> callbackUrl =CallBack_URL__c.getAll();
        if(callbackUrl.ContainsKey('Callback'))
            Callback=callbackUrl.get('Callback').URL__c; 
        
        parameters.put('oauth_signature_method','RSA-SHA1');
        parameters.put('oauth_consumer_key', consumerKey);
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_version', '1.0');
        parameters.put('oauth_callback',callback);
        parameters.put('oauth_token', token_oauth);
        parameters.put('oauth_verifier', verifier);
        
        
        String signature = TokenAuthenticationClass.generateSignature(req, consumerSecret, parameters);
        String header = TokenAuthenticationClass.generateHeader(signature, parameters);
        req.setHeader('Authorization', header);
        return req;
    }
    
    
    public  Map<String,String> checkconnectionstatus(){
        Map<String,String> userNameMap=new Map<String,String>();
        boolean IsSuccess= true;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        try{
            if(setting[0].Token_Authentication__c==true){
                req.setEndpoint( setting[0].End_Point__c + '/rest/auth/1/session' );
                req.setmethod('GET'); 
                
                String nonce    = String.valueOf(Crypto.getRandomLong());
                String timestamp= String.valueOf(DateTime.now().getTime() / 1000);
                
                req = signRequest(req,consumerkey,consumersecret,accesstoken);
                res = http.send(req);
                
                if(res.getstatuscode()== 401 && res.getstatus()=='Unauthorized'){
                    GenerateJiraLogs.CreateLogRealTime('fetchRequestToken',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'checkconnectionstatus', res.getBody());   
                    IsSuccess= false;
                }else if(res.getstatuscode()== 200){
                    Map<String,Object> getuserName=(Map<String,Object>)JSON.deserializeUntyped(res.getbody());
                    userNameMap.put('true',(String)getuserName.get('name'));
                }
                
            }
            return userNameMap;
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('fetchRequestToken',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'checkconnectionstatus', Error);   
            
        }
        return null;
    }
    
    public static HttpRequest signRequest(HttpRequest req, String consumerKey, String consumerSecret,String accesstoken) {
        
        String nonce     = String.valueOf(Crypto.getRandomLong());
        String timestamp = String.valueOf(DateTime.now().getTime() / 1000);
        
        Map<String,String> parameters = new Map<String,String>();
        
        parameters.put('oauth_signature_method','RSA-SHA1');
        parameters.put('oauth_consumer_key', consumerkey);
        parameters.put('oauth_token', accesstoken);
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_version', '1.0');
        
        String signature = TokenAuthenticationClass.generateSignature(req, consumerSecret, parameters);
        String header = TokenAuthenticationClass.generateHeader(signature, parameters);
        req.setHeader('Authorization', header);
        return req;
    }
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
}