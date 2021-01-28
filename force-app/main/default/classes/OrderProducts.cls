public with sharing class OrderProducts{

    @AuraEnabled(cacheable=true)
    public static Boolean isOrderActive(String idOrder){
        return [SELECT Id, Status FROM Order WHERE Id =: idOrder].Status == 'Activated';
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        return [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true];        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(String idOrder){
        Order order = [SELECT Id, Name, Pricebook2Id FROM Order WHERE Id =: idOrder];
        if(order.Pricebook2Id != null){
            return OrderProductsHelper.getOrderProducts(order);
        }        
        return new List<OrderItem>();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getAllOrderItems(String idOrder) {
        return [SELECT Id, UnitPrice, TotalPrice, Quantity, Product2.Name, 
            Product2Id FROM OrderItem WHERE OrderId =: idOrder];
    }

    @AuraEnabled
    public static void activateOrder(String idOrder){
        try{
            Order order = [SELECT Id, Account.Name, OrderNumber, Type, Status FROM Order WHERE Id =: idOrder];
            List<OrderItem> orderItems = [SELECT Id, Product2.Name, Product2.ProductCode, UnitPrice, Quantity 
                FROM OrderItem WHERE OrderId =: idOrder];
            OrderProductsHelper.sendRequestToActivateOrder(order, orderItems);
        }catch(Exception e){
			System.debug('Line number: ' + e.getLineNumber() +  ' - Cause: ' + e.getCause() + ' - Message: ' + e.getMessage());
			throw e;            
        }                
    }

    @AuraEnabled
    public static void insertOrUpdateNewProduct(String idProduct, String idOrder, String idOrderItem){
        try{
            if(!String.isEmpty(idOrderItem)){
                OrderProductsHelper.updateOrderItemQty(idOrderItem);                
            }else{
                OrderProductsHelper.createOrderItem(idOrder, idProduct);                                
            }
        }catch (Exception e){
			System.debug('Line number: ' + e.getLineNumber() +  ' - Cause: ' + e.getCause() + ' - Message: ' + e.getMessage());
			throw e;  
        }
    }
}
