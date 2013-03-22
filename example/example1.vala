// Example from http://kushaldas.in/posts/how-to-do-xmlrpc-calls-in-vala-using-libsoup-tutorial.html
// Compile with  valac --pkg libsoup-2.4 --thread example1.vala
// run with G_MESSAGES_DEBUG=all ./example1 

using Soup;

public void main(string[] args) {
	var message = xmlrpc_request_new("http://kushaldas.wordpress.com/xmlrpc.php","demo.sayHello");
	var session = new SessionSync();
	session.send_message(message);

	string data = (string) message.response_body.flatten().data;
	//print(data);
	Value v = Value(typeof(string));
	try {
		Soup.XMLRPC.parse_method_response(data, -1, out v);
	}
	catch(Error e) {
		debug("Error while processing the response");
	}
	string msg = v.get_string();
	debug("Got: %s\n", msg);
	//print(msg);

}