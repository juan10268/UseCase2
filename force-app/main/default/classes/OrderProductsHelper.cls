public with sharing class OrderProductsHelper {

    public static List<OrderItem> getOrderProducts(Order order){
        List<String> idPricebookEntries = OrderProductsHelper.getPricebookEntries(order.Pricebook2Id);
        if(!idPricebookEntries.isEmpty()){
            List<OrderItem> orderItems = [SELECT Id, Product2.Name, Product2Id, Quantity,
                PricebookEntry.Id, ListPrice FROM OrderItem WHERE PricebookEntry.IsActive = true 
                AND PricebookEntry.Id IN: idPricebookEntries AND OrderId =: order.Id];
            return OrderProductsHelper.getOrderItemsWithQuantities(orderItems);
        }
        return new List<OrderItem>();
    }

    public static void sendRequestToActivateOrder(Order order, List<OrderItem> orderItems){
        String JSONBody = OrderProductsHelper.buildOrderBody(order);
        JSONBody = (!orderItems.isEmpty())? JSONBody + OrderProductsHelper.buildJSONOrderItemBody(orderItems): JSONBody + '}';        
        HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setHeader('Content-Type','Application/JSON');
		req.setEndpoint('https://cognizantusecase2.requestcatcher.com/test');
		req.setMethod('POST');
        req.setTimeout(60000);
		req.setBody(JSONBody);
		res = http.send(req);
		if(res.getStatusCode() == 200){
            OrderProductsHelper.updateOrderStatus(order);
		}else{
			throw new CalloutException('Error during HTTP Callout');
		}       
    }

    public static void updateOrderItemQty(String idOrderItem){
        OrderItem orderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id =: idOrderItem];
        orderItem.Quantity++;
        update orderItem;
    }

    public static void createOrderItem(String idOrder, String idProduct){
        Order order = [SELECT Id, Pricebook2Id, EndDate, EffectiveDate FROM Order WHERE Id =: idOrder];
        Product2 product = [SELECT Id, ProductCode, Name FROM Product2 WHERE Id =: idProduct];
        PricebookEntry pricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: order.Pricebook2Id
            AND Product2Id =: idProduct];        
        OrderProductsHelper.buildOrderItem(order, product, pricebookEntry);
    }

    private static void buildOrderItem(Order order, Product2 product, PricebookEntry pricebookEntry){
        OrderItem orderItem = new OrderItem(
            EndDate = order.EndDate,
            Description = 'Product ' + product.Name + ' added.',
            OrderId = order.Id,
            Product2Id = product.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            ServiceDate = order.EffectiveDate,
            Status__c = 'Draft',
            UnitPrice = pricebookEntry.UnitPrice
        );
        insert orderItem;
    }

    private static List<OrderItem> getOrderItemsWithQuantities(List<OrderItem> orderItems){
        Map<String, OrderItem> mapOrderItems = new Map<String, OrderItem>();
        for(OrderItem orderItem: orderItems){
            if(mapOrderItems.containsKey(orderItem.Product2Id)){
                mapOrderItems.get(orderItem.Product2Id).Quantity += orderItem.Quantity;
                mapOrderItems.put(orderItem.Product2Id, mapOrderItems.get(orderItem.Product2Id));
            }else{
                mapOrderItems.put(orderItem.Product2Id, orderItem);
            }
        }
        return mapOrderItems.values();
    }

    private static void updateOrderStatus(Order order){
        order.Status = 'Activated';
        update order;
    }

    private static String buildOrderBody(Order order){
        return '{' +
            '"accountNumber": "' + order.Account.Name + '",' +
            '"orderNumber": "' + order.OrderNumber + '",' +
            '"type": "' + order.Type + '",' +
            '"status": "' + order.Status + '"';            
    }

    private static String buildJSONOrderItemBody(List<OrderItem> orderItems){
        String JSONBody = '';
        for(OrderItem orderItem: orderItems){
            if(JSONBody.isWhitespace()){
                JSONBody = ', "orderProducts": [' + OrderProductsHelper.buildJSONOrderItem(orderItem);
            }else{
                JSONBody = JSONBody + '},' + OrderProductsHelper.buildJSONOrderItem(orderItem);
            }
        }
        return JSONBody + '}]}';
    }

    private static String buildJSONOrderItem(OrderItem orderItem){
        return '{' +
            '"name": "' + orderItem.Product2.Name + '",' +
            '"code": "' + orderItem.Product2.ProductCode + '",' +
            '"unitPrice": ' + orderItem.UnitPrice + ',' +
            '"quantity": ' + orderItem.Quantity;      
    }
            
    private static List<String> getPricebookEntries(String idPricebook){
        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: idPricebook];
        if(!pricebookEntries.isEmpty()){
            List<String> idPricebookEntries = new List<String>();
            for(PricebookEntry pricebookEntry: pricebookEntries){
                idPricebookEntries.add(pricebookEntry.Id);
            }
            return idPricebookEntries;
        }
        return new List<String>();    
    }
}
