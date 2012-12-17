/* Compile with
 *   valac --pkg libsoup-2.4 --thread Magento.vala config/config.vala
 * run with
 *   ./Magento
 * to run with debug-information
 *   G_MESSAGES_DEBUG=all ./Magento
 */
using Soup;

public class Magento : Object {

    Soup.Session session;
    string session_id;

    public Magento () {
        session = new SessionSync();
    }

    public void login () {
		var message = Soup.XMLRPC.request_new("http://"+host+path,"login", typeof(string),apiUser, typeof(string),apiKey, GLib.Type.INVALID);
		
		session.send_message(message);

		string data = (string) message.response_body.flatten().data;

		Value v = Value(typeof(string));
		try {
			Soup.XMLRPC.parse_method_response(data, data.length, out v);
		}
		catch(Error e) {
			debug("Error while processing the response");
		}
		session_id = v.get_string();
		debug("Session ID: %s\n", session_id);
    }

    public void end () {
    	//client.methodCall('endSession', [ client.sessionId ], cb);
    }

    private void print_tabs(int tabs) {
    	for (int i = 0;i<tabs;i++) {
    		print("\t");
    	}
    }

	private void print_value_types(Value v, int depth = 0) {
		print_tabs(depth);
		print(v.type_name());
		print("\n");
		switch (v.type_name()) {
			case "gchararray":
			break;
			case "GValueArray":
				unowned ValueArray valuearray = (ValueArray) v;
				foreach (Value value in valuearray.values) {
					print_value_types(value, depth+1);
				}
			break;
			case "GHashTable":
				HashTable<string,Value?> vhash = (HashTable<string,Value?>)v;
				vhash.for_each ((key, value) => {
					print_value_types(value, depth+1);
				});
			break;
		}
	}

	private void print_value(Value v, int depth = 0) {
		switch (v.type_name()) {
			case "gchararray":
				print_tabs(depth);
				print(v.get_string());
				print("\n");
			break;
			case "GValueArray":
				unowned ValueArray valuearray = (ValueArray) v;
				foreach (Value value in valuearray.values) {
					print_value(value, depth+1);
				}
			break;
			case "GHashTable":
				HashTable<string,Value?> vhash = (HashTable<string,Value?>)v;
				vhash.for_each ((key, value) => {
					print_tabs(depth);
					print(key);
					print("\n");
					print_value(value, depth+1);
				});
			break;
		}
		
	}

    public void parse_method_response(string data) {
    	string _data = data.replace("<nil/>", ""); // WORKADOUND nil is not supportet?
    	HashTable<string,Value?> vhash = null;
		Value v = Value(typeof(HashTable<string,Value?>));
		try {
			if(Soup.XMLRPC.parse_method_response (_data, -1, out v)) {
				//vhash =  (HashTable<string,Value?>)v;
				//debug(v.type_name());
				debug("parsed");
				print_value_types(v);
				print_value(v);
			}
		}
		catch(Soup.XMLRPC.Fault e) {
			debug("Error while processing the response: %s",e.message);
		}
		
    }

    public void call (string api, ValueArray? apiargs) {
    	//client.methodCall('call', [ client.sessionId, api, args ], function(err,res) {

    	var message = Soup.XMLRPC.request_new("http://"+host+path,"call", typeof(string),session_id, typeof(string),api, typeof(ValueArray),apiargs, GLib.Type.INVALID);

		session.send_message(message);

		string data = (string) message.response_body.flatten().data;

		parse_method_response(data);
		
		//debug(data);

		//debug();

		//debug(v.type_name());


		//HashTable<string,Value?> vhash = (HashTable<string,Value?>)v;
		//debug(vhash.size().to_string());
		//string msg = v.get_string();
		//("Session ID: %s\n", msg);
    }

    static int main (string[] args) {
    	Magento magento = new Magento();
    	magento.login();
    	//magento.call("catalog_product.list"); {"021-198-009/B", "shop_de"}
    	ValueArray params = new ValueArray(1);
    	Value sku = Value(typeof(string));
    	sku.set_string("021-198-009/B");
    	params.append(sku);
    	magento.call("catalog_product.info", params);
        return 0;
    }
}