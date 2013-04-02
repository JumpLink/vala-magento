using Soup;

namespace Magento {

	public class XMLRPC : Object {

		Soup.Session session;
		string session_id;
		string uri;
		Config config;

		public XMLRPC (Magento.Config config) {
			this.config = config;
		    session = new Soup.SessionSync();
		    uri = "http://"+config.host+config.path;
		}

		public void login () {
			var message = Soup.XMLRPC.request_new(this.uri,"login", typeof(string),config.user, typeof(string),config.key, GLib.Type.INVALID);
			
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

			var message = Soup.XMLRPC.request_new(this.uri,"endSession", typeof(string),session_id, GLib.Type.INVALID);

			session.send_message(message);

			string data = (string) message.response_body.flatten().data;

			Value v = Value(typeof(string));
			try {
				Soup.XMLRPC.parse_method_response(data, data.length, out v);
			}
			catch(Error e) {
				error("While processing the response: "+e.message);
			}
			if (v.get_boolean()) {
				print("Disconnected successfully\n");
				debug(v.get_boolean().to_string()+"\n"+data);
			} else {
				error("During Disconnection: "+v.get_boolean().to_string()+"\n"+data);
			}			
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
				case "gboolean":
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
				case "gboolean":
					print_tabs(depth);
					print(v.get_boolean().to_string());
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

		public Value parse_method_response(string data) {
			string _data = data.replace("<nil/>", ""); // WORKADOUND nil is not supportet?
			Value result = Value(typeof(HashTable));
			try {
				if(Soup.XMLRPC.parse_method_response (_data, -1, out result)) {
					debug("parsed");
					//print_value_types(v);
					//print_value(v);
					return result;
				}
				else {
					return "Error while processing the response!";
				}
			}
			catch(Soup.XMLRPC.Fault e) {
				return "Error while processing the response: "+e.message;
			}
		}

		public Value call (string api, ValueArray? apiargs) {
			//client.methodCall('call', [ client.sessionId, api, args ], cb)

			var message = Soup.XMLRPC.request_new(this.uri,"call", typeof(string),session_id, typeof(string),api, typeof(ValueArray),apiargs, GLib.Type.INVALID);
						
			debug(message.method);
			debug(message.reason_phrase);
			debug(message.uri.to_string(false));
			debug((string)message.request_body.flatten().data);
			
			session.send_message(message);

			string data = (string) message.response_body.flatten().data;

			return parse_method_response(data);
		}
	}	
}