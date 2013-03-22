
/* Compile with
 *   valac --pkg libsoup-2.4 --thread *.vala config/config.vala -o magento.a
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

		//api.catalog_product_info("151-837-015/B", "", null, "sku");

		//filter: http://www.magentocommerce.com/wiki/1_-_installation_and_configuration/using_collections_in_magento
		HashTable<string,Value?> filter = Soup.value_hash_new();
		// HashTable<string,Value?> eq = Soup.value_hash_new();
		// eq.insert("eq","151-837-015/B");
		// filter.insert("sku", eq);
		// api.catalog_product_list(filter, "shop_de");

		HashTable<string,Value?> equals_any_of = Soup.value_hash_new();
		equals_any_of.insert("like","151-837%"); // % = wildcard: http://www.w3schools.com/sql/sql_like.asp	
		filter.insert("sku", equals_any_of);
		api.catalog_product_list(filter, "shop_de");

		return 0;
	}
}