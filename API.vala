namespace Magento {

	public class API : Object {
		XMLRPC connection; // TODO interface bauen damit Verbindungsart z.B. mit SOAP ausgetauscht werden kann

		public API(Magento.Config config) {
			connection = new XMLRPC(config);
			connection.login();
		}

		/**
		 * Allows you to retrieve information about the required product.
		 * @param productId Product ID or SKU
		 * @param storeView Store view ID or code (optional)
		 * @param attributes Array of catalogProductRequestAttributes (optional)
		 * @param productIdentifierType Defines whether the product ID or SKU value is passed in the "product" parameter.
		 */
		public void catalog_product_info (string productId, string storeView, CatalogProductRequestAttributes? attributes, string productIdentifierType) {

			ValueArray params = new ValueArray(4);

			params.append(productId);

			params.append(storeView);

			params.append(""); // TODO params.append(attributes);

			params.append(productIdentifierType);

			connection.call("catalog_product.info", params);
			connection.end();
		}

		/**
		 * Allows you to retrieve the list of products.
		 * @param filters Array of filters by attributes (optional)
		 * @param storeView Store view ID or code (optional)
		 */
		public void catalog_product_list (HashTable<string,Value?> filter, string storeView) {

			ValueArray params = new ValueArray(2);

			params.append(filter);
			params.append("shop_de");

			connection.call("catalog_product.list", params);
			connection.end();
		}
	}
}