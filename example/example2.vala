// Example from http://kushaldas.in/2010/03/22/how-to-do-xmlrpc-calls-in-vala-using-libsoup-tutorial/
// Compile with  valac --pkg libsoup-2.4 --thread example2.vala
// run with G_MESSAGES_DEBUG=all ./example2 

using Soup;

public void main(string[] args) {
	var message = Soup.XMLRPC.request_new("http://kushaldas.wordpress.com/xmlrpc.php","demo.addTwoNumbers",typeof(int),20,typeof(int),30);
	var session = new SessionSync();
	session.send_message(message);

	string data = (string) message.response_body.flatten().data;
	Value v = Value(typeof(int));
	try {
		Soup.XMLRPC.parse_method_response(data, -1, out v);
	}
	catch(Error e) {
		debug("Error while processing the response");
	}
	int msg = v.get_int();
	debug("Got: %d\n", msg);

}
