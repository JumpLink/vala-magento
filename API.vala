using Gee;

namespace Magento {

	public class API : GLib.Object {
		XMLRPC connection; // TODO interface bauen damit Verbindungsart z.B. mit SOAP ausgetauscht werden kann

		public API(Magento.Config config) {
			connection = new Magento.XMLRPC(config);
			connection.login();
		}

		~API() {
			connection.end();
		}

		/**
		 * Allows you to retrieve information about the required product.
		 * @param productId Product ID or SKU
		 * @param storeView Store view ID or code (optional)
		 * @param attributes Array of catalogProductRequestAttributes (optional)
		 * @param productIdentifierType Defines whether the product ID or SKU value is passed in the "product" parameter.
		 * @return a new GLib.HashTable<string,Value?> with each attribute as the key.
		 */
		public GLib.HashTable<string,Value?> catalog_product_info (string productId, string storeView, GLib.ValueArray? attributes, string productIdentifierType) {

			GLib.ValueArray params = new GLib.ValueArray(4);

			params.append(productId);
			params.append(storeView);
			params.append(attributes); // TODO params.append(attributes);

			params.append(productIdentifierType);

			GLib.Value result_as_gvalue = connection.call("catalog_product.info", params);
			
			if (result_as_gvalue.type_name() == "GHashTable") {
				return (GLib.HashTable<string,Value?>) result_as_gvalue;
			} else if (result_as_gvalue.type_name() == "gchararray") {
				GLib.HashTable<string,Value?> error = Soup.value_hash_new ();
				error.insert("error", result_as_gvalue);
				error.insert("sku", productId);
				GLib.warning(((string)result_as_gvalue)+" productId: "+productId);
				return error;
			} else {
				string error_string = "Wrong type of return value: "+result_as_gvalue.type_name();
				GLib.HashTable<string,Value?> error = Soup.value_hash_new ();
				error.insert("error", result_as_gvalue);
				GLib.warning(error_string);
				return error;
			}
		}

		/**
		 * Allows you to retrieve the list of products.
		 * @param filter Table of filters by attributes (optional) 
		 * @param storeView Store view ID or code (optional)
		 * @return A new GLib.ValueArray with a GLib.HashTable for each product.
		 * @see {@link [http://www.magentocommerce.com/wiki/doc/webservices-api/api/catalog_product#catalog_product.list]}.
		 * @see {@link [http://www.magentocommerce.com/api/soap/catalog/catalogProduct/catalog_product.list.html]}.
		 */
		public GLib.ValueArray catalog_product_list (GLib.HashTable<string,Value?>? filter, string storeView) {

			GLib.ValueArray params = new ValueArray(2);

			if(filter != null)
				params.append(filter);
			else
				params.append(Soup.value_hash_new ());

			params.append(storeView);

			GLib.Value result_as_gvalue = connection.call("catalog_product.list", params);
			if (result_as_gvalue.type_name() == "GValueArray") {
				return  ((GLib.ValueArray)result_as_gvalue).copy(); // TODO do this witout a copy?
			} else {
				string error_string = "Wrong type of return value: "+result_as_gvalue.type_name();
				GLib.HashTable<string,Value?> error = Soup.value_hash_new ();
				error.insert("error", result_as_gvalue);
				GLib.ValueArray error_result = new ValueArray(1);
				error_result.append(error);
				GLib.warning(error_string);
				return error_result;
			}
		}


		/**
		 * Just return all available sku's
		 */
		public Gee.HashSet<string> catalog_product_list_all_skus () {
			Gee.HashSet<string> result = new Gee.HashSet<string> ();
			GLib.ValueArray products = this.catalog_product_list (null, "");
			foreach (GLib.Value product in products) {
				if (product.type_name () == "GHashTable") {
					GLib.HashTable<string,Value?> vhash = (GLib.HashTable<string,GLib.Value?>)product;
					vhash.for_each ((attribute__key, attribute_value) => {
						if(attribute_value.type_name() == "gchararray" || attribute_value.type_name () == "GValueArray") {
							switch (attribute__key) {
								case "product_id":
									break;
								case "sku":
									result.add ( attribute_value.get_string () );
									break;
								case "category_ids":
									break;
								case "set":
									break;
								case "name":
									break;
								case "type":
									break;
								default:
									warning ("unknown attribute: "+attribute__key);
									break;
							}
						} else {
							warning ("wrong type: "+attribute_value.type_name ()+" "+attribute__key);
						}
					});
				} else {
					warning ("Wrong data structure: "+product.type_name ());
				}
			}
			return result;
		}

		/**
		 * Update product.
		 * Allows you to update the required product. Note that you should specify only those parameters which you want to be updated.
		 * @param productId product ID or Sku.
		 * @param productData Array of catalogProductCreateEntity.
		 * @param storeView Store view ID or code (optional).
		 * @param identifierType Defines whether the product ID or SKU is passed in the 'product' parameter.
		 * @return True if the product is updated.
		 * @see {@link [http://www.magentocommerce.com/wiki/doc/webservices-api/api/catalog_product#catalog_product.update]}.
		 * @see {@link [http://www.magentocommerce.com/api/soap/catalog/catalogProduct/catalog_product.update.html]}.
		 */
		public bool catalog_product_update (string productId, GLib.HashTable<string,Value?> productData, string storeView = "", string identifierType = "sku") {

			GLib.ValueArray params = new ValueArray(4);

			params.append(productId);
			params.append(productData);
			params.append(storeView);
			params.append(identifierType);

			GLib.Value result_as_gvalue = connection.call("catalog_product.update", params);
			if (result_as_gvalue.type_name() == "gboolean") {
				return  (bool)result_as_gvalue; // TODO do this witout a copy?
			} else if (result_as_gvalue.type_name() == "gchararray") {
				GLib.warning ("Return value is gchararray: "+result_as_gvalue.get_string ());
				return false;
			} else {
				GLib.warning ("Wrong type of return value: "+result_as_gvalue.type_name ());
				return false;
			}
		}
	}
}