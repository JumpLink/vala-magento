using Magento;

namespace Magento {

	public class Wrapper : GLib.Object {
		Magento.API magento_api;

		public Wrapper() {

			// Magento with config
			Magento.Config magento_config = Magento.Config();
			GLib.Settings settings = new GLib.Settings ("org.jumplink.magento");
			magento_config.host = settings.get_string("host");
			magento_config.port = settings.get_int("port");
			magento_config.path = settings.get_string("path");
			magento_config.user = settings.get_string("user");
			magento_config.key = settings.get_string("key");

			magento_api = new Magento.API(magento_config);

		}

		~Wrapper() {

		}

		/**
		 * Allows you to retrieve the list of products.
		 * @param filter Table of filters by attributes (optional) 
		 * @param storeView Store view ID or code (optional)
		 * @return A new GLib.ValueArray with a GLib.HashTable for each product.
		 * @see {@link [http://www.magentocommerce.com/wiki/doc/webservices-api/api/catalog_product#catalog_product.list]}.
		 * @see {@link [http://www.magentocommerce.com/api/soap/catalog/catalogProduct/catalog_product.list.html]}.
		 */
		public string catalog_product_list_from_sku (string sku, string storeView) {

			print ("vala: "+sku+" "+storeView);

			HashTable<string,Value?> filter = Soup.value_hash_new ();
			HashTable<string,Value?> equals_any_of = Soup.value_hash_new ();
			equals_any_of.insert("like",sku+"%");
			filter.insert("sku", equals_any_of);


			GLib.ValueArray values = magento_api.catalog_product_list (filter, storeView);
			string json_result = catalog_product_list_result_to_json (values);
			return json_result;

		}

		private string catalog_product_list_result_to_json (GLib.ValueArray values) {
			string json_array = "[";
			foreach (GLib.Value val in values) {
				if (val.type_name () == "GHashTable") {
					string json = "{";
					GLib.HashTable<string,Value?> vhash = (GLib.HashTable<string,GLib.Value?>)val;
					vhash.for_each ((key, product) => {
						if(product.type_name () == "gchararray" || product.type_name () == "GValueArray") {
							switch (key) {
								case "product_id":
								case "sku":
								case "set":
								case "name":
								case "type":
									json += @"\"$(key)\": \"$(product.get_string ())\"";
									json += ",";
									// print (product.get_string ());
									break;
								case "category_ids":
									// list_store.set (iter, 3, product.get_string ()); // TOTO is an array of gchararray
									break;
								default:
									printerr ("unknown attribute: "+key);
									break;
							}
						} else {
							printerr ("wrong type: "+product.type_name ()+" "+key);
						}
					});
					json = json.substring (0, json.length-1); // remove Komma
					json += "},";
					json_array += json;
				} else {
					printerr ("Wrong data structure: "+val.type_name ());
				}
			}
			json_array = json_array.substring (0, json_array.length-1); // remove Komma
			return json_array+="]";
		}

	}
}