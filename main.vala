
/* Compile with
 *   valac --pkg libsoup-2.4 --thread *.vala config/config.vala -o magento
 * run with
 *   ./main
 * to run with debug-information
 *   G_MESSAGES_DEBUG=all ./main
 */

namespace Magento {
	static int main (string[] args) {
		Magento.Config config = Magento.Config();
		config.host = HOST;
		config.port = PORT;
		config.path = PATH;
		config.user = USER;
		config.key= KEY;

		XMLRPC magento = new XMLRPC(config);
		magento.login();
		//magento.call("catalog_product.list"); {"021-198-009/B", "shop_de"}
		ValueArray params = new ValueArray(1);
		Value sku = Value(typeof(string));
		sku.set_string("021-198-009/B");
		params.append(sku);
		magento.call("catalog_product.info", params);
		magento.end();
		return 0;
	}
}