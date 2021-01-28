trigger OrderActivated on Order(after update) {
    List<String> idOrders = new List<String>();
    for(Order order: Trigger.new){
        if(Trigger.oldMap.get(order.Id).Status != 'Activated' && order.Status == 'Activated'){
            idOrders.add(order.Id);
        }
    }
    if(!idOrders.isEmpty()){
        OrderActivatedHelper.setItemStatusToActivated(idOrders);
    }
}