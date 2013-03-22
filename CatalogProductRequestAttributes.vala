namespace Magento {
	//TODO all
	public class CatalogProductRequestAttributes : Object {
		/**
		 * Array of attributes
		 */
		private ValueArray attributes;
		/**
		 * Array of additional attributes
		 */
		private ValueArray additional_attributes;

		public CatalogProductRequestAttributes() {
			attributes = new ValueArray(0);
			additional_attributes = new ValueArray(0);
		}

		public void append_string(bool is_additional_attribute, string str) {
			Value _str = Value(typeof(string));
			_str.set_string(str);
			if(is_additional_attribute)
				additional_attributes.append(_str);
			else
				attributes.append(_str);
		}
	}
}