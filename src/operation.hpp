#define SASS_OPERATION

#include "ast_fwd_decl.hpp"

namespace Sass {

	template<typename T>
	class Operation {
	public:
		virtual T operator()(AST_Node*);
		virtual ~Operation() = 0;
		// statements
		virtual T operator()(Block*) = 0;
		virtual T operator()(Ruleset*) = 0;
		virtual T operator()(Propset*) = 0;
		virtual T operator()(Media_Query*) = 0;
		virtual T operator()(At_Rule*) = 0;
		virtual T operator()(Declaration*) = 0;
		virtual T operator()(Assignment*) = 0;
		virtual T operator()(Import<Function_Call*>*) = 0;
		virtual T operator()(Import<String*>*) = 0;
		virtual T operator()(Warning*) = 0;
		virtual T operator()(Comment*) = 0;
		virtual T operator()(If*) = 0;
		virtual T operator()(For*) = 0;
		virtual T operator()(Each*) = 0;
		virtual T operator()(While*) = 0;
		virtual T operator()(Extend*) = 0;
		virtual T operator()(Definition<MIXIN>*) = 0;
		virtual T operator()(Definition<FUNCTION>*) = 0;
		virtual T operator()(Mixin_Call*) = 0;
		// expressions
		virtual T operator()(List*) = 0;
		virtual T operator()(Binary_Expression<AND>*) = 0;
		virtual T operator()(Binary_Expression<OR>*) = 0;
		virtual T operator()(Binary_Expression<EQ>*) = 0;
		virtual T operator()(Binary_Expression<NEQ>*) = 0;
		virtual T operator()(Binary_Expression<GT>*) = 0;
		virtual T operator()(Binary_Expression<GTE>*) = 0;
		virtual T operator()(Binary_Expression<LT>*) = 0;
		virtual T operator()(Binary_Expression<LTE>*) = 0;
		virtual T operator()(Binary_Expression<ADD>*) = 0;
		virtual T operator()(Binary_Expression<SUB>*) = 0;
		virtual T operator()(Binary_Expression<MUL>*) = 0;
		virtual T operator()(Binary_Expression<DIV>*) = 0;
		virtual T operator()(Negation*) = 0;
		virtual T operator()(Function_Call*) = 0;
		virtual T operator()(Variable*) = 0;
		virtual T operator()(Textual<NUMBER>*) = 0;
		virtual T operator()(Textual<PERCENTAGE>*) = 0;
		virtual T operator()(Textual<DIMENSION>*) = 0;
		virtual T operator()(Textual<HEX>*) = 0;
		virtual T operator()(Number*) = 0;
		virtual T operator()(Percentage*) = 0;
		virtual T operator()(Dimension*) = 0;
		virtual T operator()(Color*) = 0;
		virtual T operator()(Boolean*) = 0;
		virtual T operator()(Interpolation*) = 0;
		virtual T operator()(Flat_String*) = 0;
		virtual T operator()(Media_Expression*) = 0;
		// parameters and arguments
		virtual T operator()(Parameter*) = 0;
		virtual T operator()(Parameters*) = 0;
		virtual T operator()(Argument*) = 0;
		virtual T operator()(Arguments*) = 0;
		// selectors
		virtual T operator()(Interpolated_Selector*) = 0;
		virtual T operator()(Simple_Selector*) = 0;
		virtual T operator()(Reference_Selector*) = 0;
		virtual T operator()(Placeholder_Selector*) = 0;
		virtual T operator()(Pseudo_Selector*) = 0;
		virtual T operator()(Negated_Selector*) = 0;
		virtual T operator()(Selector_Sequence*) = 0;
		virtual T operator()(Selector_Combination*) = 0;
		virtual T operator()(Selector_Group*) = 0;
	};
	template<typename T>
	inline Operation<T>::~Operation() { }

}