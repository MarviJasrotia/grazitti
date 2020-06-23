/**
* @author: Grazitti
* This class helps to link with Jira platform 
* to construct JSON request structure required to create JIRA from Case
*/
global with sharing class CreateJIRAWrapper {  
    
    /**
* creates the bridge between salesforce and jira platform.
* @param Endpoint url to hitfor creating request.
* @param PostMethord specify the type of request - post/put/get.
* @param ContentType specify the structure of body in request- multipart/form-data ,application/json.
* @return req.
* @returntype HttpRequest. 
*/
    
    global static HttpRequest CreateRequest(string Endpoint, String PostMethod, string ContentType){
        
        if(!Jira_login__c.sObjectType.getDescribe().isAccessible()){
            return null;
        }
        Jira_login__c jiralogin=Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA'):new Jira_login__c();
        
        HttpRequest req = new HttpRequest();    
        
        if(jiralogin.Basic_Authentication__c==true){
            
            Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
            Blob data = EncodingUtil.base64Decode(Jira_login__c.getValues('JIRA').password__c);
            
            Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data);
            
            String password = decryptedBlobData.toString();
            
            Blob headerValue = Blob.valueOf(Jira_login__c.getValues('JIRA').Username__c+':'+password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type',ContentType);
            req.setMethod(PostMethod);
            req.setTimeout(120000);
            req.setEndpoint(Jira_login__c.getValues('JIRA').end_point__c + Endpoint);
            
        }else if(jiralogin.Token_Authentication__c==true){
            
            String nonce    = String.valueOf(Crypto.getRandomLong());
            String timestamp= String.valueOf(DateTime.now().getTime() / 1000);
            String accesstoken='';
            string consumerkey='';
            accesstoken=jiralogin.Access_Token__c;
            
            consumerkey=jiralogin.Consumer_Key__c;
            
            String consumersecret='';
            
            for(Integer i=1;i<=5;i++){
                
                if(jiralogin.get('Private_Key'+i+'__c')!=null){
                    consumersecret +=jiralogin.get('Private_Key'+i+'__c');
                } 
            }
          
            req.setMethod(PostMethod);
            req.setHeader('Content-Type',ContentType);
            req.setTimeout(120000);
            
            req.setEndpoint(Jira_login__c.getValues('JIRA').end_point__c + Endpoint);
            req = signRequest(req,consumerkey,consumersecret,accesstoken);
            
            
        }
        
        return req;
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
}