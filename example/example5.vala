
/* Compile with
 *   valac --pkg libsoup-2.4 --thread *.vala config/config.vala example/example5 -o sample5.a
 * run with
 *   ./main
 * to run with debug-information
 *   G_MESSAGES_DEBUG=all ./main
 */

using Soup;

namespace Magento {
	static int main (string[] args) {
		Magento.Config config = Magento.Config();
		config.host = HOST;
		config.port = PORT;
		config.path = PATH;
		config.user = USER;
		config.key= KEY;
		Magento.API api = new Magento.API(config);

		api.catalog_product_info("151-837-015/B", "", null, "sku");

		return 0;
	}
}