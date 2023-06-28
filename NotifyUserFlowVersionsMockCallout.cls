@isTest
global class NotifyUserFlowVersionsMockCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        List<FlowDefinitionView> flows = [SELECT Id, Label FROM FlowDefinitionView];
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"records":[{"CreatedById":"0055i000003BnpmAAC","MasterLabel":"'+flows[0].Label+'"},{"CreatedById":"0055i000003BnpmAAD","MasterLabel":"'+flows[1].Label+'"},{"CreatedById":"0055i000003BnpmAAE","MasterLabel":"'+flows[2].Label+'"}]}');
        response.setStatusCode(200);
        return response; 
    }
}