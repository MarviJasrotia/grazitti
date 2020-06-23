public class JiraIssueGateway {
    
    @future(callout=true)
    public Static Void updateObjectURLOnjira(String MapofData ){ 
        Map<String,Object> FinalMapForJiraAndBody = new Map<String,Object>();
        String Error='';
        FinalMapForJiraAndBody =(Map<String,Object>) JSON.deserializeUntyped(MapofData);
        for(String newjira: FinalMapForJiraAndBody.KeySet()){
            String Body=String.valueOf(FinalMapForJiraAndBody.get(newjira));
            Body='{"fields":{'+Body +'}}';
            
            try{
                HttpRequest req = new HttpRequest();
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+newjira, 'PUT' ,'application/json');
                req.setBody(Body);
                Http gethttp = new Http();
                HTTPResponse res;
                
                res = gethttp.send(req);
            }catch(Exception ex){
                Error+='------\n'+ex.getCause()+'\n'+ex.getLineNumber()+'\n'+ex.getMessage()+'\n';
            }
        }
        
        if(Error!=''){
            GenerateJiraLogs.CreateLogRealTime('JiraIssueGateway',null, null, null,null,null, null , null, null, 'JiraIssueGateway', Error);
            
        }
    }
}