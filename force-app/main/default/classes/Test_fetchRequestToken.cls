@isTest
public class Test_fetchRequestToken {
    
    @isTest 
    public Static void  requestToken(){
        
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        jira.Token_Authentication__c=true;
        insert jira;
        JiraSalesforceDetail__c jsDetail = new JiraSalesforceDetail__c();
        jsDetail.Name = 'Display_Name';
        jsDetail.Value__c='true';
        insert jsDetail;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        fetchRequestToken fc=new fetchRequestToken();
        fc.ClosePage();
        string consumerkey = 'JiraDemoRubrik';
        string consumersecret = 'MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALRiMLAh9iimur8VA7qVvdqxevEuUkW4K+2KdMXmnQbG9Aa7k7eBjK1S+0LYmVjPKlJGNXHDGuy5Fw/d7rjVJ0BLB+ubPK8iA/Tw3hLQgXMRRGRXXCn8ikfuQfjUS1uZSatdLB81mydBETlJhI6GH4twrbDJCR2Bwy/XWXgqgGRzAgMBAAECgYBYWVtleUzavkbrPjy0T5FMou8HX9u2AC2ry8vD/l7cqedtwMPp9k7TubgNFo+NGvKsl2ynyprOZR1xjQ7WgrgVB+mmuScOM/5HVceFuGRDhYTCObE+y1kxRloNYXnx3ei1zbeYLPCHdhxRYW7T0qcynNmwrn05/KO2RLjgQNalsQJBANeA3Q4Nugqy4QBUCEC09SqylT2K9FrrItqL2QKc9v0ZzO2uwllCbg0dwpVuYPYXYvikNHHg+aCWF+VXsb9rpPsCQQDWR9TT4ORdzoj+NccnqkMsDmzt0EfNaAOwHOmVJ2RVBspPcxt5iN4HI7HNeG6U5YsFBb+/GZbgfBT3kpNGWPTpAkBI+gFhjfJvRw38n3g/+UeAkwMI2TJQS4n8+hid0uus3/zOjDySH3XHCUnocn1xOJAyZODBo47E+67R4jV1/gzbAkEAklJaspRPXP877NssM5nAZMU0/O/NGCZ+3jPgDUno6WbJn5cqm8MqWhW1xGkImgRk+fkDBquiq4gPiT898jusgQJAd5Zrr6Q8AO/0isr/3aa6O6NLQxISLKcPDk2NOccAfS/xOtfOz4sJYM3+Bs4Io9+dZGSDCA54Lw03eHTNQghS0A==';   
        //  TokenAuthenticationClass.getRequestToken('www.test.com',consumersecret,consumerkey);
        Test.stopTest();
        Jira_login__c Jset= [Select id,LoginSuccess__c from Jira_login__c limit 1];
        System.assertEquals( Jset.LoginSuccess__c,true);
        
    }
}