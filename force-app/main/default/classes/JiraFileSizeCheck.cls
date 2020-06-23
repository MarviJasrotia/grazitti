public class JiraFileSizeCheck {
    public static JiraSalesforceDetail__c SizeCheck(){
        JiraSalesforceDetail__c settings=new JiraSalesforceDetail__c();
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            settings = JiraSalesforceDetail__c.getInstance('File_Size');
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req= CreateJIRAWrapper.CreateRequest('/rest/api/2/attachment/meta', 'GET' ,'application/json');
        HttpResponse res = new HttpResponse();
        try{
            res=http.send(req);
            if(res.getstatuscode()==200){
                String ResponseBody=res.getbody();
                map<string,object> deserialize=(map<string,object>)JSON.deserializeUntyped(ResponseBody);
                Object obj1=deserialize.get('uploadLimit');
                String body=JSON.serialize(obj1);
                Long bodyy;
                if(body!=NULL && body!='')
                    bodyy=long.valueOf( body);
                
                String JiraStorageCapacity=FileSize(bodyy);
                if(schema.sObjectType.JiraSalesforceDetail__c.fields.value__c.isUpdateable()){
                    settings.value__c=JiraStorageCapacity;
                }
                return settings;
            }else{
                GenerateJiraLogs.CreateLogRealTime('JiraFileSizeCheck',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'SizeCheck', res.getBody());   
                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraFileSizeCheck',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'SizeCheck', Error);   
            
        }
        return null;
    }
    public Static String FileSize(Long Value){
        /* string representation of a file's size in KB and MB */
        
        if (Value <= (1024*512)){
            //KB
            Decimal kb = Decimal.valueOf(Value);
            kb = kb.divide(1024,2);
            return string.valueOf(kb) + ' KB';
        }
        else{
            //MB
            Decimal mb = Decimal.valueOf(Value);
            mb = mb.divide((1024*1024),2);
            return string.valueOf(mb) + ' MB';
        }
    }
}