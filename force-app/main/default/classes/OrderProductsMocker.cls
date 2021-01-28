global class OrderProductsMocker implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		if(req.getEndpoint().contains('https://cognizantusecase2.requestcatcher.com/test')){
			res.setBody('request caught');
		}
		return res;
	}
}
