global with Sharing class SendJiraErrorLogsToGrazitti  implements Schedulable {
    global void execute(SchedulableContext SC) {
        Boolean HasError = false;
        Date LastDay=Date.today().adddays(-1);
        String Message='<table style="border:1px solid black;border-collapse: collapse;"><tr><th colspan="12" style="padding: 0 10px;border:1px solid black;">JIRA ERROR LOGS</th></tr><tr><th style="padding: 0 10px;border:1px solid black;">ID</th><th style="padding: 0 10px;border:1px solid black;">Apex Class</th><th style="border:1px solid black;">RecordID</th><th style="padding: 0 10px;border:1px solid black;">EndPoint</th><th style="padding: 0 10px;border:1px solid black;">Method</th> <th style="padding: 0 10px;border:1px solid black;"> From</th><th style="padding: 0 10px;border:1px solid black;" >Requested Body</th><th style="padding: 0 10px;border:1px solid black;">Response Body</th><th style="padding: 0 10px;border:1px solid black;">Response Status</th><th style="padding: 0 10px;border:1px solid black;">Response Status Code</th><th style="padding: 0 10px;border:1px solid black;">Other Details </th><th style="padding: 0 10px;border:1px solid black;">CreatedDate</th></tr>';
        
        for(JiraErrorLogs__c JiraError:[SELECT Id, Apex_Class__c, Other_Details__c, RecordId__c, Request_Details__c, Request_End_Point__c, Request_From__c, Request_Method__c, Response_Details__c, Response_Status_Code__c, Response_Status__c,CreatedDate FROM JiraErrorLogs__c where CreatedDate >=:LastDay]){
            Message+='<tr>'+
                '<td style="border:1px solid black;" >' +JiraError.id+'</td>'+
                '<td style="border:1px solid black;" >' +JiraError.Apex_Class__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.RecordId__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Request_End_Point__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Request_Method__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Request_From__c+'</td>'+
                '<td style="border:1px solid black;'+ ((JiraError.Request_Details__c!=''&& JiraError.Request_Details__c!=null)?'min-width:800px;">':'">') +JiraError.Request_Details__c+'</td>'+
                '<td style="border:1px solid black;'+ ((JiraError.Response_Details__c!=''&& JiraError.Response_Details__c!=null)?'min-width:800px;">':'">') +JiraError.Response_Details__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Response_Status__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Response_Status_Code__c+'</td>'+
                '<td style="border:1px solid black;">' +JiraError.Other_Details__c+'</td>'+
                '<td style="border:1px solid black;">' + JiraError.CreatedDate+'</td>'+
                '</tr>';
            HasError=true;
        } 
        Message+='</table>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        list<String> address= new list<String>();
        address.add('jirasfdc@grazitti.com');
        mail.setToAddresses(address);
        mail.setSubject('Jira Salesforce Connector '+System.UserInfo.getOrganizationName() +' with Org Id: '+ System.UserInfo.getOrganizationId());
        mail.setHtmlBody(Message);
        if(HasError){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}