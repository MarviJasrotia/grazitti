({
	doInit : function(component, event, helper) {
        var language = $A.get("$Locale.language");
       
        component.set('v.lang',language);
        helper.getDoItData(component,event);
        component.set('v.refreshjiralist',false);
        var vfOrigin = "https://connectorjira-dev-ed.lightning.force.com/";
        window.addEventListener("message", $A.getCallback(function(event) {
            if(event.data=='Linkedsuccess'||event.data.includes('grz-sf')){
                helper.getDoItData(component,event);
            }
            console.log(event.data);
        }), false);
	},
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log(action.name,row.Id);
        switch (action.name) {
            case 'Show_details':
                helper.ViewJiraIssue(component, row);
                break;
            case 'Unlink_Jira':
                helper.removeJira(component, row);
                break;
        }
    }
})