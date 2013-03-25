namespace Magento {

	public class API : Object {
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
		 */
		public GLib.Value catalog_product_info (string productId, string storeView, ValueArray? attributes, string productIdentifierType) {

			GLib.ValueArray params = new GLib.ValueArray(4);

			params.append(productId);

			params.append(storeView);

			params.append(""); // TODO params.append(attributes);

			params.append(productIdentifierType);

			return connection.call("catalog_product.info", params);
		}

		/**
		 * Allows you to retrieve the list of products.
		 * @param filters Array of filters by attributes (optional)
		 * @param storeView Store view ID or code (optional)
		 */
		public GLib.ValueArray catalog_product_list (GLib.HashTable<string,Value?> filter, string storeView) {

			GLib.ValueArray params = new ValueArray(2);

			params.append(filter);
			params.append("shop_de");

			GLib.Value result_as_gvalue = connection.call("catalog_product.list", params);
			if (result_as_gvalue.type_name() == "GValueArray") {
				return  ((GLib.ValueArray)result_as_gvalue).copy(); // TODO do this witout a copy?
			} else {
				error("Wrong type of return value");
			}
		}
	}
}