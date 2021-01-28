public with sharing class OrderActivatedHelper {
    
    public static void setItemStatusToActivated(List<String> idOrders){
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId IN: idOrders];
        for(OrderItem orderItem: orderItems){
            orderItem.Status__c = 'Activated';
        }
        update orderItems;
    }
}
