/* Compile with
 *   valac --pkg libsoup-2.4 --thread *.vala config/config.vala example/example3 -o sample3.a
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

		//filter: http://www.magentocommerce.com/wiki/1_-_installation_and_configuration/using_collections_in_magento
		HashTable<string,Value?> filter = Soup.value_hash_new();
		HashTable<string,Value?> equals = Soup.value_hash_new();
		equals.insert("eq","151-837-015/B");
		filter.insert("sku", equals);
		api.catalog_product_list(filter, "shop_de");

		return 0;
	}
}