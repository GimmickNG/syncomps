package syncomps.interfaces 
{
	import flash.text.TextField;
	
	/**
	 * Used to denote classes which make use of text, editable or otherwise, intended for use in accessibility property implementation.
	 * Closure is not guaranteed when modifying contents of the textField via the internal textField property, i.e. the component may not work exactly as expected.
	 * For this reason, it is best suited for only modifying the following properties:
	 * * tabIndex
	 * * caretIndex (via setSelection)
	 * * accessibilityProperties
	 * * accessibilityImplementation
	 * @author Gimmick
	 */
	public interface ILabel 
	{
		function get textField():TextField
	}
	
}