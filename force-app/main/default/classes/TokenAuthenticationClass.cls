public class TokenAuthenticationClass {
    
    public static String getRequestToken(String Endpoint ,String private_key,String consumer_key){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();

        Jira_login__c jiralogin=Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c();
        
        httprequest req = new httprequest();
        httpresponse resp;
        try{
            req.setMethod('POST');
            req.setEndpoint(Endpoint +'/plugins/servlet/oauth/request-token');
            String consumerKey=consumer_key;
            String consumersecret=private_key;
            httprequest req1 = signRequest(req,consumerkey,consumersecret);
            http h = new http();
            resp = h.send(req1);
            if(resp.getstatuscode()==200){
                String token=resp.getbody();
                return token;
            }else{
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('TokenAuthenticationClass',req.getEndpoint(), req.getMethod(), String.valueof(resp.getstatusCode()),resp.getbody(),resp.getstatus(), req.getbody() , null, null , 'Request Token', resp.getbody()));
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('TokenAuthenticationClass',req.getEndpoint(), req.getMethod(), String.valueof(resp.getstatusCode()),resp.getbody(),resp.getstatus(), req.getbody() , null, null , 'Request Token', Error));
        }
        if(!JiraLogsToInsert.isEmpty()){
            insert JiraLogsToInsert;
        }
        return null;
    }
    
    public static HttpRequest signRequest(HttpRequest req, String consumerKey, String consumerSecret) {
        
        String nonce     = String.valueOf(Crypto.getRandomLong());
        String timestamp = String.valueOf(DateTime.now().getTime() / 1000);
        
        String Callback='';
        Map<String,CallBack_URL__c> callbackUrl =CallBack_URL__c.getAll(); 
        if(callbackUrl.ContainsKey('Callback'))
            Callback=callbackUrl.get('Callback').URL__c; 
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_signature_method','RSA-SHA1');
        parameters.put('oauth_consumer_key', consumerKey);
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_version', '1.0');
        parameters.put('oauth_callback',callback );
        
        String signature = generateSignature(req, consumerSecret, parameters);
        
        String header = generateHeader(signature, parameters);
        req.setHeader('Authorization', header);
        
        return req;
    }
    
    public static String generateSignature(HttpRequest req, String consumerSecret, Map<String,String> parameters) {
        String s = createBaseString(req, parameters);
        s=s.replaceAll('%7E', '~');
        Blob sig = Crypto.sign('RSA', Blob.valueOf(s), EncodingUtil.base64Decode(consumerSecret + 'Jg=='));
        
        return EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
    }
    
    public static String generateHeader(String signature, Map<String,String> parameters) {
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header + key + '="'+parameters.get(key)+'", ';
        }
        return header + 'oauth_signature="' + signature + '"';
    }
    
    private static String createBaseString(HttpRequest req, Map<String,String> parameters) {
        Map<String,String> p = parameters.clone();
        if(req.getMethod().equalsIgnoreCase('post') && req.getBody()!=null &&
           req.getHeader('Content-Type')=='application/x-www-form-urlencoded') {
               p.putAll(getUrlParams(req.getBody()));
               
           }
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        } 
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
        
        // According to OAuth spec, host string should be lowercased, but Google and LinkedIn
        // both expect that case is preserved.
        return req.getMethod().toUpperCase()+ '&' +
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
    
    private static Map<String,String> getUrlParams(String value) {
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                res.put(kv[0],kv[1]);
            }
        }
        
        return res;
    }
}