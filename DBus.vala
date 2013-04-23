namespace Magento {
	[DBus (name = "org.jumplink.magento")]
	interface ProductStock : Object {
		public abstract string get (string sku) throws IOError;
		//public abstract int create (string msg) throws IOError;
		public abstract void update (string sku, string stock_strichweg_qty, string stock_vwheritage_qty, string total_qty, string heritage_dueweeks, string heritage_availabilitymessagecode) throws IOError;
	}
}